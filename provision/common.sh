#!/usr/bin/env bash
# provision/common.sh
# Helpers y funciones compartidas para scripts de aprovisionamiento.
set -euo pipefail

# Imprime un encabezado de sección
section() {
  echo ""
  echo "============================================================"
  echo "  $*"
  echo "============================================================"
}

# Verifica si un paquete está instalado
pkg_installed() {
  dpkg -l "$1" &>/dev/null 2>&1
}

# Verifica si un comando existe
cmd_exists() {
  command -v "$1" &>/dev/null
}
