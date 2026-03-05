#!/usr/bin/env bash
# scripts/ssh_client.sh
# Abre SSH en clienteUbuntu.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

vagrant ssh clienteUbuntu
