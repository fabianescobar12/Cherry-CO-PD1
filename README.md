# Proyecto: Detección de Madurez de Cerezas con **YOLOv11**

Este repositorio **utiliza el conjunto de datos público Cherry CO Dataset** (Cossio‑Montefinale *et al.*, 2024) para entrenar y validar un detector de madurez de cerezas basado en **Ultralytics YOLOv11**. Incluye los scripts de descarga del dataset, la definición de contenedor Singularity/Apptainer y ejemplos de ejecución tanto local como en un clúster **SLURM**.

---

## Tabla de contenidos

1. [Estructura del repositorio](#estructura-del-repositorio)
2. [Requisitos](#requisitos)
3. [Instalación](#instalación)
4. [Requisitos para ejecutar scripts shell](#requisitos-para-ejecutar-scripts-shell)
5. [Descarga del dataset](#descarga-del-dataset)
6. [Construcción del contenedor](#construcción-del-contenedor)
7. [Entrenamiento](#entrenamiento)
   - [Entrenamiento secuencial](#entrenamiento-secuencial)
   - [Entrenamiento paralelo](#entrenamiento-paralelo)
8. [Ejecución en clúster SLURM](#ejecución-en-clúster-slurm)
9. [Salida de resultados](#salida-de-resultados)
10. [Personalización](#personalización)
11. [Créditos](#créditos)

---

## Estructura del repositorio

```
configs/
 └─ cherries_maturity.yaml       # Configuración del dataset
scripts/
 ├─ download_dataset.sh          # Descarga y descompresión del dataset
 ├─ submit_slurm.sh              # Ejemplo de envío de job a SLURM
 ├─ train_secuencial.py          # Entrenamiento en un solo GPU
 └─ train_paralelizado.py        # Entrenamiento distribuido (DataParallel)
singularity/
 ├─ build_container.sh           # Construye la imagen SIF
 ├─ yolov11_container_definition.def  # Receta del contenedor
 └─ yolov11_container.sif        # Imagen generada (no versionada)
```

---

## Requisitos

| Herramienta               | Versión mínima | Comentario                                     |
| ------------------------- | -------------- | ---------------------------------------------- |
| **Git**                   | 2.x            | Para clonar el repositorio                     |
| **GPU NVIDIA**            | CUDA 12.6+     | Probado con runtime 12.6.3                     |
| **Apptainer/Singularity** | `1.3.6`        | Verificado con `apptainer version 1.3.6-1.el9` |
| **SLURM**                 | (opcional)     | Para ejecución batch en cluster                |

> **Nota**: Todo el software de Python (Ultralytics, PyTorch, etc.) se instala automáticamente dentro del contenedor.

---

## Instalación

1. **Clonar el repositorio de Github**
   ```bash
   git clone https://github.com/fabianescobar12/Cherry-CO-PD1.git
   cd Cherry-CO-PD1
   ```

---

## Requisitos para ejecutar scripts shell

Antes de ejecutar los scripts, es necesario otorgar permisos de ejecución al archivo shell (.sh). Para ello, se debe ejecutar los siguientes comandos desde la raíz del repositorio:
   - ```chmod +x scripts/download_dataset.sh```
   - ```chmod +x scripts/submit_slurm.sh```
   - ```chmod +x singularity/build_container.sh```

## Descarga del dataset

Ejecute el script de descarga que utiliza `gdown` para obtener los datos desde Google Drive:

```bash
bash scripts/download_dataset.sh
```

Se generará la carpeta `data/` con las particiones `train/`, `val/` y `test/`.

---

### Referencia del Dataset

> L. Cossio‑Montefinale, J. Ruiz‑del‑Solar y R. Verschae, "Cherry CO Dataset: A Dataset for Cherry Detection, Segmentation and Maturity Recognition," *IEEE Robotics and Automation Letters*, vol. 9, n.º 6, pp. 5552‑5558, junio 2024. doi: 10.1109/LRA.2024.3393214

---

## Construcción del contenedor

Para garantizar la reproducibilidad, utilice **Apptainer/Singularity**:

```bash
bash singularity/build_container.sh
```

Esto creará la imagen `singularity/yolov11_container.sif` basada en `nvidia/cuda:12.6.3-runtime-ubuntu24.04` e instalará todas las dependencias listadas en `requirements.txt` dentro de un entorno virtual ubicado en `/opt/venv`.

> Si su sistema no soporta `singularity build`, puede compilar en otro host y transferir la imagen SIF resultante.

---

## Entrenamiento

Previo al entrenamiento modifique `configs/cherries_maturity.yaml`, en el apartado `path`, donde deberá ingresar la ruta correspondiente a la carpeta del dataset.

Las ejecuciones sin utilizar slurm para la solicitud de recursos deben ejecutarse dentro del contenedor y en un nodo con acceso a GPU (de lo contrario, si estamos en un nodo sin GPU podemos llamarlo mediante la ejecución con slurm, como se explica más adelante), como sigue:

### 1. Entrenamiento secuencial (sin slurm)

Utiliza un solo GPU y recorre distintas combinaciones de tamaño de imagen y batch.

```bash
singularity exec --nv singularity/yolov11_container.sif \
    python3 scripts/train_secuencial.py
```

### 2. Entrenamiento paralelo (sin slurm)

Aprovecha varios GPUs (DataParallel). Configure la variable `DEVICES` en `scripts/train_paralelizado.py` según los índices visibles.

```bash
CUDA_VISIBLE_DEVICES=0,1,2 \
  singularity exec --nv singularity/yolov11_container.sif \
  python3 scripts/train_paralelizado.py
```

---

## Ejecución en clúster con SLURM

1. **Ajuste** `scripts/submit_slurm.sh`:
   - `--nodelist`, `--cpus-per-task`, `--gres=gpu:X`, etc.
   - `--mail-user` y otros metadatos.
2. **Envío del trabajo**
   ```bash
   sbatch scripts/submit_slurm.sh
   ```

El script invoca al contenedor y ejecuta `train_secuencial.py` o `train_paralelizado.py` según tus necesidades, logrando una buena práctica utilizando slurm para solicitar recursos al clúster.

---

## Salida de resultados

- Modelos entrenados: carpeta `cherry_yolo11_model/<run_name>/model_<batch>_<img_size>.pt`.
- Métricas resumidas: `configs/training_summary.csv` con columnas `datetime`, `batch`, `img_size`, `memoria_gb_vram`, `tiempo_entrenamiento` y `mAP50`.

---

## Personalización
- **Hiperparámetros**: Edite `img_sizes`, `batch_map` y `epochs` en los scripts de entrenamiento.
- **SLURM**: Cambie los parámetros SBATCH según los recursos de su clúster.

---

## Créditos

Desarrollado por Fabián Escobar y Camilo Aliste. Basado en **Ultralytics YOLOv11**.



