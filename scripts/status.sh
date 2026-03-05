#!/usr/bin/env bash
# scripts/status.sh
# Muestra el estado de ambas VMs.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

vagrant status
