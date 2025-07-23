#!/bin/bash
#SBATCH --job-name=test
#SBATCH --cpus-per-task=1
#SBATCH --mem=30G
#SBATCH --error=error_train.err
#SBATCH --output=output_train.out
#SBATCH --nodelist=v100
#SBATCH --gres=gpu:3
#SBATCH --mail-type=ALL
#SBATCH --mail-user=nombre.apellido@dominio.uoh.cl

set -euo pipefail

cd "$SLURM_SUBMIT_DIR"

ROOT_DIR="$SLURM_SUBMIT_DIR"
CONTAINER="$ROOT_DIR/singularity/yolov11_container.sif"


if [[ ! -f "$CONTAINER" ]]; then
    echo "❌ No se encontró la imagen Singularity en: $CONTAINER" >&2
    exit 1
fi




singularity exec --nv \
    --bind "$ROOT_DIR":"$ROOT_DIR" \
    "$CONTAINER" \
    python3 "$ROOT_DIR/scripts/train_paralelizado.py"