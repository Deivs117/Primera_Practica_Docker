#!/usr/bin/env bash
# exercises/04_ml_jupyter_python3/clone_and_patch.sh
# Clona el repo asashiho/ml-jupyter-python3 y aplica los parches necesarios.
set -euo pipefail

REPO_URL="https://github.com/asashiho/ml-jupyter-python3.git"
TARGET_DIR="$(dirname "${BASH_SOURCE[0]}")/ml-jupyter-python3"

# 1) Clonar si no existe
if [ -d "$TARGET_DIR/.git" ]; then
  echo "==> Repositorio ya clonado en: $TARGET_DIR"
else
  echo "==> Clonando $REPO_URL ..."
  git clone "$REPO_URL" "$TARGET_DIR"
fi

DOCKERFILE="$TARGET_DIR/Dockerfile"

if [ ! -f "$DOCKERFILE" ]; then
  echo "ERROR: No se encontró Dockerfile en $TARGET_DIR" >&2
  exit 1
fi

echo "==> Aplicando parches al Dockerfile..."

# 2) Comentar libav-tools si existe (paquete descontinuado)
if grep -q "libav-tools" "$DOCKERFILE"; then
  sed -i 's/^\(.*libav-tools.*\)$/# \1  # patched: libav-tools no disponible en Ubuntu 22.04/' "$DOCKERFILE"
  echo "    Patch aplicado: comentada la línea de libav-tools."
else
  echo "    libav-tools no encontrado, omitiendo patch."
fi

# 3) Reemplazar Sklearn por scikit-learn
if grep -qi "Sklearn" "$DOCKERFILE"; then
  sed -i 's/Sklearn/scikit-learn/gi' "$DOCKERFILE"
  echo "    Patch aplicado: reemplazado Sklearn -> scikit-learn."
else
  echo "    Sklearn no encontrado, omitiendo patch."
fi

echo ""
echo "==> Parches aplicados. Ahora puedes hacer:"
echo "    cd $TARGET_DIR"
echo "    sudo docker build -t ml-jupyter:local ."
echo "    sudo docker run --name ml -it -p 8890:8888 ml-jupyter:local"
