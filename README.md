# MVG-SDI: No-Reference Spectral Distortion Index for Pansharpened Images

[![DOI](https://zenodo.org/badge/DOIEnter.svg)](https://doi.org/10.3390/s26031002)
[![Paper](https://img.shields.io/badge/Paper-Sensors_2026-blue)](paper/sensors-26.pdf)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![MATLAB](https://img.shields.io/badge/MATLAB-R2024a%2B-orange)](https://www.mathworks.com/products/matlab.html)

**Official MATLAB implementation** for *"A No-Reference Multivariate Gaussian-Based Spectral Distortion Index for Pansharpened Images"* (Sensors **2026**, **26**(3), 1002; https://doi.org/10.3390/s26031002).[file:31]

**Authors**: Bishr Omer Abdelrahman Adam¹*, Xu Li¹, Jingying Wu¹, Xiankun Hao¹  
¹School of Electronics and Information, Northwestern Polytechnical University, Xi'an 710129, China  
*Correspondence: bishromer@outlook.com[file:31]

## Abstract
Pansharpening inevitably introduces spectral distortions compromising downstream remote sensing tasks. **MVG-SDI** is a novel no-reference index using **hybrid 21D features** (9D First-Digit Distribution via Benford's Law in Hyperspherical Color Space + 12D Color Moments on RGB+NIR) fitted to **Multivariate Gaussian models**. Spectral distortion is quantified by the symmetric Mahalanobis distance between original MS and fused image statistics. **Outperforms QNR/FQNR/MQNR** against FR benchmarks (SAM/CC/SID) on NBU dataset (IKONOS, WV-2/3/4).[file:31]

## Key Features
- **Patch-based** (32×32 blocks) for localized spectral analysis.
- **HCS transform** isolates spectral angles for FDD (Eq. 2-3).[file:31]
- **Pooled covariance** for robust Mahalanobis distance (Eq. 8).[file:31]
- Fully self-contained—no external dependencies beyond MATLAB toolboxes.

## 🚀 Quick Start

```matlab
% Clone & navigate (or add to path)
addpath('matlab');

% Load MS reference & fused pansharpened image (HxWxB double)
MS = double(imread('ms_nbu.tif'));      % e.g., 256x256x4
Fused = double(imread('fused_gs.tif')); % Same size

% Compute MVG-SDI (lower = better spectral fidelity)
quality = MVG_Spectral(MS, Fused);
fprintf('MVG-SDI Spectral Distortion: %.4f\n', quality);
