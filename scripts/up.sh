#!/usr/bin/env bash
# scripts/up.sh
# Levanta ambas VMs con aprovisionamiento.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

echo "==> Levantando VMs con aprovisionamiento..."
vagrant up --provision
