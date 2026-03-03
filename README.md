<div align="center">

# 🛰️ MVG-SDI
### No-Reference Multivariate Gaussian-Based Spectral Distortion Index for Pansharpened Images

[![Paper](https://img.shields.io/badge/Paper-Sensors_2026-2196F3?style=flat-square&logo=readthedocs&logoColor=white)](https://doi.org/10.3390/s26031002)
[![DOI](https://img.shields.io/badge/DOI-10.3390%2Fs26031002-blue?style=flat-square)](https://doi.org/10.3390/s26031002)
[![MATLAB](https://img.shields.io/badge/MATLAB-R2024a+-orange?style=flat-square&logo=mathworks&logoColor=white)](https://www.mathworks.com)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Dataset](https://img.shields.io/badge/Dataset-NBU_Pansharpening-purple?style=flat-square)](https://doi.org/10.1109/MGRS.2020.3008355)

<br/>

**Bishr Omer Abdelrahman Adam\* · Xu Li\* · Jingying Wu · Xiankun Hao**

*School of Electronics and Information, Northwestern Polytechnical University, Xi'an 710129, China*

✉ bishromer@mail.nwpu.edu.cn · lixu@nwpu.edu.cn

<br/>

> **TL;DR** — MVG-SDI is the first no-reference metric dedicated *exclusively* to spectral distortion in pansharpened images. It combines Benford's Law (First Digit Distribution in Hyperspherical Color Space) with Color Moments inside a Multivariate Gaussian model, and outperforms QNR/FQNR/MQNR against full-reference benchmarks (SAM, CC, SID) on the NBU dataset across four satellite sensors.

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Method](#-method)
- [Quick Start](#-quick-start)
- [Dataset](#-dataset)
- [Results](#-results)
- [Citation](#-citation)

---

## 🔭 Overview

Pansharpening fuses a high-resolution panchromatic (PAN) image with a low-resolution multispectral (MS) image to produce a high-resolution MS product. This process inevitably introduces **spectral distortions** — colour shifts, radiometric inconsistencies, and loss of spectral fidelity — that corrupt downstream tasks such as NDVI calculation, mineral mapping, and change detection.

Existing no-reference (NR) quality metrics (e.g. QNR and its variants) suffer from two key problems:

| Problem | Description |
|---|---|
| **Spectral–spatial coupling** | High distortion scores concentrate on spatial edges, not actual colour errors |
| **Premature saturation** | FQNRλ spikes to near-maximum at the slightest degradation, losing sensitivity |

**MVG-SDI** solves both by using patch-level multivariate statistics that are sensitive purely to radiometric/spectral changes and respond monotonically as distortion increases.

---

## 🔧 Method

### Pipeline

```
MS Image ──┐
           ├─► 32×32 Patches ──► HCS Transform ──► FDD (9D, Benford's Law)  ──┐
           │                                                                    ├─► 21D Feature ──► MVG Model
           └─► 32×32 Patches ──► RGB+NIR Channels ──► Color Moments (12D)   ──┘
                                                                                      │
Fused Image ───────────────────────────────── (same pipeline) ──► MVG Model ─────────┤
                                                                                      ▼
                                                             Mahalanobis Distance = MVG-SDI Score
```

### Feature Extraction

**Step 1 — Hyperspherical Color Space (HCS) Transform**

The N-band image is decomposed into one intensity component and N−1 angular components:

$$I = \sqrt{\hat{M}_1^2 + \cdots + \hat{M}_N^2}, \qquad \theta_k = \tan^{-1}\!\left(\frac{\sqrt{\hat{M}_{k+1}^2 + \cdots + \hat{M}_N^2}}{\hat{M}_k}\right)$$

Angular components are normalized to [0, 1]:  $\bar{\theta}_k = \frac{2}{\pi}\,\theta_k$

**Step 2 — First Digit Distribution (FDD) Features — 9D**

For each normalized angular component, the probability of each leading digit $a \in \{1,\dots,9\}$ is computed. Pristine MS images follow Benford's Law in this domain; pansharpening-induced colour errors break this pattern.

**Step 3 — Color Moment (CM) Features — 12D**

For each 32×32 patch, compute mean $\mu$, standard deviation $\sigma$, and skewness $\gamma$ for each of R, G, B, NIR:

$$\mathbf{x}_\text{CM} = [\mu_R,\,\sigma_R,\,\gamma_R,\;\mu_G,\,\sigma_G,\,\gamma_G,\;\mu_B,\,\sigma_B,\,\gamma_B,\;\mu_\text{NIR},\,\sigma_\text{NIR},\,\gamma_\text{NIR}]^\top$$

**Step 4 — Combined Feature Vector — 21D**

$$\mathbf{x} = [\mathbf{x}_\text{FDD},\; \mathbf{x}_\text{CM}] \in \mathbb{R}^{21}$$

### Score Computation

Separate MVG models are fitted to the MS reference ($\mu_\text{ref}, \Psi_\text{ref}$) and the fused image ($\mu_\text{test}, \Psi_\text{test}$). The spectral distortion score is the symmetric Mahalanobis distance:

$$\boxed{D = \sqrt{(\mu_\text{ref} - \mu_\text{test})^\top\,\Psi^{-1}\,(\mu_\text{ref} - \mu_\text{test})}, \qquad \Psi = \frac{\Psi_\text{ref} + \Psi_\text{test}}{2}}$$

> **Lower D = better spectral fidelity.**

### Implementation Parameters

| Parameter | Value | Description |
|---|---|---|
| Patch size | 32 × 32 | Non-overlapping blocks |
| HCS normalization | 2/π | Maps θₖ to [0, 1] |
| FDD bins | 9 | Leading digits {1, …, 9} |
| CM features | 12 | μ, σ, γ × 4 channels |
| FDD features | 9 | Benford digit probabilities |
| **Total dim** | **21** | Concatenated per-patch vector |

---

## 🚀 Quick Start

```matlab
% 1. Add to MATLAB path
addpath('matlab');

% 2. Load images (double, same spatial dimensions)
MS    = double(imread('ms_image.tif'));     % e.g. 256×256×4
Fused = double(imread('fused_image.tif')); % e.g. 256×256×4

% 3. Compute MVG-SDI  —  lower score = less spectral distortion
score = MVG_Spectral(MS, Fused);
fprintf('MVG-SDI: %.4f\n', score);
```

### Batch Evaluation

```matlab
sensors   = {'IK', 'WV2', 'WV3', 'WV4'};
methods   = {'BT-H', 'GS', 'MTF-GLP', 'PNN', 'A-PNN'};
results   = zeros(numel(sensors), numel(methods));

for s = 1:numel(sensors)
    for m = 1:numel(methods)
        MS    = load_ms(sensors{s});
        Fused = load_fused(sensors{s}, methods{m});
        results(s, m) = MVG_Spectral(MS, Fused);
    end
end
```

---

## 🗄️ Dataset

Experiments use the publicly available **[NBU Pansharpening Benchmark](https://doi.org/10.1109/MGRS.2020.3008355)** (Meng et al., IEEE GRSM 2021).

| Sensor | Image Pairs | PAN Size | MS Size | MS Bands |
|---|:---:|---|---|:---:|
| IKONOS (IK) | 200 | 1024 × 1024 | 256 × 256 | 4 |
| WorldView-2 (WV-2) | 500 | 1024 × 1024 | 256 × 256 | 8 |
| WorldView-3 (WV-3) | 160 | 1024 × 1024 | 256 × 256 | 8 |
| WorldView-4 (WV-4) | 500 | 1024 × 1024 | 256 × 256 | 4 |
| **Total** | **1 360** | | | |

Download the dataset from the [NBU official page](https://github.com/xingxingmeng/NBU-Dataset).

---

## 📊 Results

### Consistency with Full-Reference Metrics (SROCC / PLCC / RMSE)

Higher SROCC & PLCC and lower RMSE = better. **Bold** = best per row.

#### IK & WV-2 Datasets

| Dataset | FR Metric | Method | SROCC ↑ | PLCC ↑ | RMSE ↓ |
|---|---|---|:---:|:---:|:---:|
| IK | CC | **Ours** | **0.8089** | **0.9719** | **0.0032** |
| IK | CC | FQNRλ | 0.7308 | 0.8602 | 0.0113 |
| IK | CC | MQNRλ | 0.6070 | 0.5602 | 0.0113 |
| IK | SAM | **Ours** | **0.8903** | **0.8765** | **0.0752** |
| IK | SAM | FQNRλ | 0.8810 | 0.7720 | 0.0993 |
| IK | SAM | MQNRλ | 0.6000 | 0.7933 | 0.0951 |
| WV-2 | CC | **Ours** | **0.7000** | **0.9594** | **0.0036** |
| WV-2 | SAM | **Ours** | **0.8801** | **0.9510** | **0.0095** |

#### WV-3 & WV-4 Datasets

| Dataset | FR Metric | Method | SROCC ↑ | PLCC ↑ | RMSE ↓ |
|---|---|---|:---:|:---:|:---:|
| WV-3 | CC | **Ours** | **0.9000** | **0.9937** | **0.0005** |
| WV-3 | SAM | **Ours** | **0.9000** | **0.9839** | **0.1251** |
| WV-4 | CC | FQNRλ | **0.9747** | **0.9878** | **0.0004** |
| WV-4 | SAM | FQNRλ | **0.9747** | **0.9968** | **0.0066** |

> MVG-SDI leads on 3 out of 4 sensors for CC and SAM. FQNRλ leads on WV-4 but with inconsistent behaviour across other datasets.
---

## 🙏 Acknowledgements

This work is supported by the Practice and Innovation Funds for Graduate Students of Northwestern Polytechnical University and the Key R&D Program of Shaanxi Province (No. 2025CY-YBXM-079).

Fusion algorithm implementations sourced from the [PanCollection](https://github.com/liangjiandeng/PanCollection) MATLAB toolkits.

---

## 📎 Citation

If you find this work useful, please cite:

```bibtex
@article{adam2026mvgsdi,
  title   = {A No-Reference Multivariate Gaussian-Based Spectral Distortion
             Index for Pansharpened Images},
  author  = {Adam, Bishr Omer Abdelrahman and Li, Xu and
             Wu, Jingying and Hao, Xiankun},
  journal = {Sensors},
  volume  = {26},
  number  = {3},
  pages   = {1002},
  year    = {2026},
  doi     = {10.3390/s26031002}
}
```

---

<div align="center">
<sub>© 2026 Adam et al. · Published under CC BY 4.0 · MDPI Sensors · Northwestern Polytechnical University</sub>
</div>
