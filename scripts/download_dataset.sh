#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="$ROOT_DIR/data"
mkdir -p "$DATA_DIR"

echo "📥 Descargando dataset..."
python3 -m pip install --quiet gdown

gdown 'https://drive.google.com/uc?id=1Aa_hBeNA1-BtJhumzjbgvQRHpAvjk5Dh' \
      -O "$DATA_DIR/dataset_ripeness.zip"

unzip -q "$DATA_DIR/dataset_ripeness.zip" -d "$DATA_DIR"
rm "$DATA_DIR/dataset_ripeness.zip"

python3 -m pip uninstall -y gdown
echo "✅  Dataset disponible en $DATA_DIR"