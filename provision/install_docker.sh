#!/usr/bin/env bash
# provision/install_docker.sh
# Instala Docker CE en Ubuntu 22.04 de forma idempotente.
set -euo pipefail

echo "==> [install_docker.sh] Iniciando instalación de Docker CE..."

# 1) Remover versiones antiguas (si existen)
echo "==> Removiendo paquetes conflictivos (si existen)..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
  if dpkg -l "$pkg" &>/dev/null 2>&1; then
    apt-get remove -y "$pkg" || true
  fi
done

# 2) Instalar prereqs
echo "==> Instalando prerequisitos..."
apt-get update -y
apt-get install -y ca-certificates curl

# 3) Crear /etc/apt/keyrings y agregar llave GPG de Docker
echo "==> Configurando llave GPG de Docker..."
install -m 0755 -d /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/docker.asc ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
else
  echo "    Llave GPG ya existe, omitiendo descarga."
fi

# 4) Agregar repositorio oficial de Docker para Ubuntu
echo "==> Configurando repositorio Docker..."
if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "${VERSION_CODENAME}") stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null
else
  echo "    Repositorio Docker ya configurado, omitiendo."
fi

# 5) Instalar Docker CE y plugins
echo "==> Instalando Docker CE..."
apt-get update -y
apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# 6) Habilitar Docker
echo "==> Habilitando servicio Docker..."
systemctl enable --now docker

# 7) Agregar usuario vagrant al grupo docker
echo "==> Agregando usuario 'vagrant' al grupo docker..."
usermod -aG docker vagrant

echo ""
echo "============================================================"
echo " Docker CE instalado correctamente."
echo " NOTA: Debes reingresar por SSH (vagrant ssh) para que"
echo "       el grupo docker tome efecto sin necesidad de sudo."
echo "============================================================"
