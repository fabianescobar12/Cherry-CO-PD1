#!/usr/bin/env bash
#SBATCH --job-name=cherry-yolo
#SBATCH --cpus-per-task=4
#SBATCH --mem=30G
#SBATCH --gres=gpu:1
#SBATCH --error=logs/train_%j.err
#SBATCH --output=logs/train_%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=nombre.apellido@dominio.uoh.cl
#SBATCH --partition=gpu            # Ejemplo, ajusta a tu clúster

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTAINER="$ROOT_DIR/singularity/yolov11_container.sif"

module load singularity/3.11.4      # si el clúster lo requiere

singularity exec --nv \
    --bind "$ROOT_DIR":"$ROOT_DIR" \
    "$CONTAINER" \
    python3 "$ROOT_DIR/src/train_sequential.py"
