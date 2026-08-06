#!/usr/bin/env bash
# Idempotent Cloud Agent install for nanobot-webui.
# Prepares the Python backend (uv venv + editable install) and the
# React/Vite frontend (bun deps + production build). Safe to re-run.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# --- Toolchains: uv (Python) and bun (frontend) -----------------------------
export PATH="$HOME/.local/bin:$HOME/.bun/bin:$PATH"

if ! command -v uv >/dev/null 2>&1; then
  echo "[install] Installing uv…"
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

if ! command -v bun >/dev/null 2>&1; then
  echo "[install] Installing bun…"
  curl -fsSL https://bun.sh/install | bash
fi

export PATH="$HOME/.local/bin:$HOME/.bun/bin:$PATH"

# --- Backend: virtualenv + editable install ---------------------------------
if [ ! -d .venv ]; then
  echo "[install] Creating Python 3.11 virtualenv…"
  uv venv --python 3.11
fi

echo "[install] Installing backend (editable, with dev extras)…"
uv pip install -e ".[dev]"

# --- Frontend: dependencies + production build ------------------------------
echo "[install] Installing frontend dependencies…"
(cd web && bun install --frozen-lockfile)

echo "[install] Building frontend and embedding into the package…"
(cd web && bun run build)
rm -rf webui/web/dist
mkdir -p webui/web
cp -r web/dist webui/web/dist

echo "[install] Done."
