#!/usr/bin/env bash

set -euo pipefail

# instalación temporal solo para descargar el dataset
python3 -m pip install --quiet gdown

gdown 'https://drive.google.com/uc?id=1Aa_hBeNA1-BtJhumzjbgvQRHpAvjk5Dh' -O dataset_ripeness.zip

unzip dataset_ripeness.zip -d data/

python3 -m pip uninstall -y gdown