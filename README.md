# Efficient CGM Data Compression and Reconstruction

MATLAB® implementation of encoding, compression, and reconstruction methods for **Continuous Glucose Monitoring (CGM)** profiles.  
This repository accompanies the study:  

> *"Peak-Nadir Encoding for Efficient CGM Data Compression and High-Fidelity Reconstruction"*  

[![DOI](https://zenodo.org/badge/849228670.svg)](https://doi.org/)

---

## 📖 Citation
If you use this code in your research, please cite:  

```
No citable content, yet
```

Paper link: https://  

## 🚀 Getting Started

### Prerequisites
- MATLAB® R2020a or later  
- Input CGM dataset in CSV format (288 samples per row, 24 h @ 5 min resolution)  

### Installation
1. Download the latest release from GitHub → [releases](https://github.com/simcich/QoCGM/releases)  
2. Download the required support code (QoCGM) → [support release](https://github.com/simcich/QoCGM/releases)  
3. Unzip the archives and move the folders to your preferred location.  
4. Open MATLAB® and add the source folder (including subfolders) to your MATLAB® path:  
   ```matlab
   addpath(genpath('~/MATLAB/code/src'))



## 🧑‍💻 Usage
To reproduce the experiments, run the main script:

```
RunMain.m
```

This script:

- Loads CGM profiles
- Applies compression methods:
  PN: Peaks & Nadirs
  PN+: Peaks, Nadirs & Support points
  Uniform Downsampling
- Reconstructs the signals
- Calculate CGM-derived metrics
- Evaluates performance (R², MAE, compression ratio, and CGM-derived metrics)
- Optionally plots results (landmark selection and reconstruction)
