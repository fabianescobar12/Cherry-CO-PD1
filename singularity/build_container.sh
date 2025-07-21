#!/usr/bin/env bash
set -e
DEF=singularity/yolov11_container_definition_file.def
SIF=singularity/yolov11_container.sif

echo "▶️ Construyendo $SIF …"
singularity build "$SIF" "$DEF"
echo "✅  Contenedor listo: $SIF"