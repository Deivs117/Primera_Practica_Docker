#!/usr/bin/env bash
# scripts/ssh_server.sh
# Abre SSH en servidorUbuntu.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

vagrant ssh servidorUbuntu
