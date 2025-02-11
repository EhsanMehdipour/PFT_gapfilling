# Gapfilling of phytoplankton functional types (PFT)
**Objective:** This repository provides the necessary scripts for conducting and analysing two well-established satellite gap-filling methods, DINEOF and DINCAE, for gap-filling of total chlorophyll-a (TChla) and chlorophyll-a concentrations of five major PFT datasets provided by Copernicus Marine Service.

**Project:** Assessment of gap-filling techniques applied to satellite phytoplankton composition products for the Atlantic Ocean

## Requirements:
### Models:
[**DINEOF**](https://github.com/aida-alvera/DINEOF)

[**DINCAE**](https://github.com/gher-uliege/DINCAE.jl)
### Datasets:
[**PFT**](https://doi.org/10.48670/moi-00280) Dataset ID: cmems_obs-oc_glo_bgc-plankton_my_l3-multi-4km_P1D

[**SST**](https://doi.org/10.48670/moi-00165) Dataset ID: METOFFICE-GLO-SST-L4-NRT-OBS-SST-V2

### Installation:
Use Mamba or Conda for installation of necessary packages
```
mamba create --name PFT_gapfilling -c conda-forge --file requirements.txt
```
or
```
conda create --name PFT_gapfilling -c conda-forge --file requirements.txt
```
**Type II regression:** For type II regression in matchup analysis use [pylr2](https://github.com/OceanOptics/pylr2). The installation is explained in the package or directly use pip and git:
```
pip install git+https://github.com/OceanOptics/pylr2.git
```
### Interactive Environment
You can connect the environment to JupyterLab using:
```
python -m ipykernel install --user --name=PFT_gapfilling --display-name "PFT_gapfilling"
```

