#!/usr/bin/env python
# -*- coding: utf-8 -*-

from pathlib import Path
import datetime, time, os

import torch
import pandas as pd
from ultralytics import YOLO

# --- Localización del proyecto ---
REPO_DIR = Path(__file__).resolve().parents[1]
CFG_FILE = REPO_DIR / "configs" / "cherries_maturity.yaml"
SUMMARY_FILE = REPO_DIR / "training_summary.csv"
MODEL_WEIGHTS = "yolov11s.pt"          # Peso público de Ultralytics

IMG_SIZES = [1024, 640]
BATCH_MAP = {
    1024: [102, 69, 33, 18, 9],
    640:  [102, 69, 33, 18, 9],
}

def train_loop():
    log = []

    for img_size in IMG_SIZES:
        for batch_size in BATCH_MAP[img_size]:
            run_name = f"sz{img_size}_bs{batch_size}"
            model_dir = REPO_DIR / "runs" / run_name
            model_dir.mkdir(parents=True, exist_ok=True)

            model = YOLO(MODEL_WEIGHTS)

            torch.cuda.empty_cache()
            torch.cuda.reset_peak_memory_stats()

            t0 = time.time()
            model.train(
                data=CFG_FILE,
                epochs=120,
                imgsz=img_size,
                batch=batch_size,
                fraction=1.0,
                project=str(model_dir.parent),
                name=run_name,
            )
            t_train = time.time() - t0

            val_res = model.val(data=CFG_FILE, imgsz=img_size, batch=batch_size)
            perf_map50 = float(getattr(val_res.box, "map50", None)
                               or val_res.results_dict.get("metrics/mAP50(B)"))

            vram_gb = round(torch.cuda.max_memory_allocated() / 1024**3, 2)
            model_file = model_dir / f"model.pt"
            model.save(model_file)

            log.append({
                "datetime"            : datetime.datetime.now().isoformat(sep=" ", timespec="seconds"),
                "batch"               : batch_size,
                "img_size"            : img_size,
                "vram_gb"             : vram_gb,
                "train_time_min"      : round(t_train/60, 1),
                "mAP50"               : round(perf_map50, 4) if perf_map50 else None,
            })

            print(f"✔️  [{run_name}] guardado en {model_file.relative_to(REPO_DIR)}")

    pd.DataFrame(log).to_csv(SUMMARY_FILE, index=False)
    print(f"\n📄 Resumen guardado en: {SUMMARY_FILE.relative_to(REPO_DIR)}")

if __name__ == "__main__":
    train_loop()
