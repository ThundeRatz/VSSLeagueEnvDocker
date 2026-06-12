#!/usr/bin/env bash

TAG="stable"
DOCKER_IMAGE="thunderatz/vss-league-env:$TAG"

DOCKER_ARGUMENTS=(
  -it
  --rm
  --name vsss-gui
  --ipc=host
)

# 1. Detectar placa de vídeo e configurar o ecossistema híbrido (Nvidia PRIME)
if command -v nvidia-smi &>/dev/null && docker info 2>&1 | grep -q "Runtimes:.* nvidia"; then
  echo "[GPU] Grafico nvidia dedicado e ativa no Docker!"
  DOCKER_ARGUMENTS+=(
    --gpus all
    -e NVIDIA_VISIBLE_DEVICES=all
    -e NVIDIA_DRIVER_CAPABILITIES=all,graphics,utility
    -e __NV_PRIME_RENDER_OFFLOAD=1
    -e __GLX_VENDOR_LIBRARY_NAME=nvidia
  )
else
  echo "[GPU] Usando gráficos integrados ou AMD Radeon (ou Nvidia não configurada no Docker)."
  if [ -d /dev/dri ]; then
    DOCKER_ARGUMENTS+=(--device /dev/dri:/dev/dri)
  fi
fi

# 2. Detectar WSL vs Linux Nativo
if grep -qi microsoft /proc/version; then
  echo "[OS] WSL2 detectado."
  DOCKER_ARGUMENTS+=(
    -v /mnt/wslg/.X11-unix:/tmp/.X11-unix:ro
    -v /mnt/wslg/runtime-dir/${WAYLAND_DISPLAY:-wayland-0}:/tmp/${WAYLAND_DISPLAY:-wayland-0}:ro
    -e DISPLAY=:0
    -e WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-0}
    -e XDG_RUNTIME_DIR=/tmp
  )

  if [ -c /dev/dxg ]; then
    DOCKER_ARGUMENTS+=(
      --device /dev/dxg
      -v /usr/lib/wsl:/usr/lib/wsl
      -e LD_LIBRARY_PATH=/usr/lib/wsl/drivers
    )
  fi
else
  echo "[OS] Linux Nativo detectado."

  # Foco total no XWayland estável para Webots/Qt5
  if [ -n "$DISPLAY" ]; then
    echo "[DISPLAY] Configurando display $DISPLAY via XWayland."

    DOCKER_ARGUMENTS+=(
      -e DISPLAY="$DISPLAY"
      -v /tmp/.X11-unix:/tmp/.X11-unix:ro
    )
  else
    echo "[ERRO] Nenhuma variável de display ($DISPLAY) encontrada. Você está em uma sessão gráfica?"
    exit 1
  fi
fi

echo "Iniciando container..."
docker run "${DOCKER_ARGUMENTS[@]}" $DOCKER_IMAGE
