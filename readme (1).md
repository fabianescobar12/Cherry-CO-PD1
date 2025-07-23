# Cherry Ripeness YOLOv11 🥬

> Entrenamiento y evaluación de modelos **YOLOv11** para clasificar la madurez de cerezas.

## Tabla de contenidos

- [Requisitos](#requisitos)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Instalación](#instalación)
  - [1. Clonar el repositorio](#1-clonar-el-repositorio)
  - [2. Construir el contenedor Singularity](#2-construir-el-contenedor-singularity)
  - [3. Descargar el dataset](#3-descargar-el-dataset)
- [Ejecución](#ejecución)
  - [Entrenamiento local](#entrenamiento-local)
  - [Entrenamiento en clúster SLURM](#entrenamiento-en-clúster-slurm)
- [Outputs](#outputs)
- [Personalización](#personalización)
- [Notas adicionales](#notas-adicionales)
- [Licencia](#licencia)

---

## Requisitos

| Recurso                 | Versión mínima  | Notas                                                          |
| ----------------------- | --------------- | -------------------------------------------------------------- |
| Git                     | —               | Para clonar el repositorio                                     |
| Singularity / Apptainer | **1.3.6‑1.el9** | Verificado con `singularity --version` y `apptainer --version` |
| GPU NVIDIA              | —               | Soporte CUDA (probado con CUDA 12.6)                           |
| SLURM (opcional)        | —               | Solo si entrenará en un clúster                                |

```bash
# Comprobar versión
singularity --version    # o
apptainer --version
```

---

## Estructura del proyecto

```text
.
├── configs/
│   └── cherries_maturity.yaml      # Rutas del dataset y clases
├── scripts/
│   ├── download_dataset.sh         # Descarga y descompresión del dataset
│   ├── submit_slurm.sh             # Envío de job SLURM
│   └── train_secuencial.py         # Entrenamiento iterativo
├── singularity/
│   ├── build_container.sh          # Helper para construir el SIF
│   ├── yolov11_container_definition.def  # Definición del contenedor
│   └── yolov11_container.sif       # (Se genera) contenedor listo
└── data/                           # (Se genera) dataset descargado
```

---

## Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/<usuario>/<repo>.git
cd <repo>
```

### 2. Construir el contenedor Singularity

```bash
bash singularity/build_container.sh
```

> **Tip:** También puede ejecutar directamente:
>
> ```bash
> singularity build singularity/yolov11_container.sif \
>     singularity/yolov11_container_definition.def
> ```

### 3. Descargar el dataset

```bash
bash scripts/download_dataset.sh
```

Esto creará la carpeta `data/` con las subcarpetas `train/`, `val/` y `test/`.

---

## Ejecución

### Entrenamiento local

```bash
singularity exec --nv \
    singularity/yolov11_container.sif \
    python scripts/train_secuencial.py
```

El script entrenará las combinaciones de tamaños de imagen y batch indicadas en `train_secuencial.py`. Los modelos y métricas se guardarán en `configs/`.

### Entrenamiento en clúster SLURM

1. Ajuste el correo, partición y `nodelist` en `scripts/submit_slurm.sh` según su entorno.
2. Envíe el trabajo:

```bash
sbatch scripts/submit_slurm.sh
```

Los logs de SLURM se guardarán en `output_train.out` y `error_train.err`.

---

## Outputs

| Archivo / Carpeta                                  | Contenido                                  |
| -------------------------------------------------- | ------------------------------------------ |
| `configs/sz{img}_bs{batch}/model_{batch}_{img}.pt` | Pesos entrenados para cada combinación     |
| `configs/training_summary.csv`                     | Resumen global con métricas, VRAM y tiempo |
| `output_train.out`, `error_train.err`              | Logs generados por SLURM                   |

---

## Personalización

- **Dataset**: edite las rutas o nombres de clases en `configs/cherries_maturity.yaml`.
- **Combinaciones de batch / tamaño**: modifique `img_sizes` y `batch_map` en `scripts/train_secuencial.py`.
- **Checkpoint inicial**: cambie `MODEL_WEIGHTS` para partir desde otro modelo.

---

## Notas adicionales

- El contenedor crea un entorno virtual en `/opt/venv` con todas las dependencias de `requirements.txt`.
- Si prefiere entrenar fuera de Singularity, cree su propio *virtualenv* y ejecute `scripts/train_secuencial.py` directamente.
- El script libera memoria GPU entre experimentos con `torch.cuda.empty_cache()`.

---

## Licencia

Este proyecto se distribuye bajo la licencia MIT (o la que corresponda).

