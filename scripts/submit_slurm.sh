#!/bin/bash
#SBATCH --job-name=test
#SBATCH --cpus-per-task=1
#SBATCH --mem=30G
#SBATCH --error=error_train.err
#SBATCH --output=output_train.out
#SBATCH --nodelist=tokikura
#SBATCH --gres=gpu:1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=nombre.apellido@dominio.uoh.cl


CONTAINER = singularity/yolov11_container.sif

singularity exec --nv \
    $CONTAINER \
    python3 train_secuencial.py



