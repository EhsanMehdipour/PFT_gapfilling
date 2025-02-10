# PFT_gapfilling
This repository provides the necessary scripts for conducting and analysing two well-established satellite gap-filling methods, DINEOF and DINCAE, for gap-filling of total chlorophyll-a (TChla) and chlorophyll-a concentrations of five major phytoplankton functional type (PFT) dataset provided by Copernicus Marine Service.

# Installation
Use Mamba or Conda for installation of necessary packages
```
mamba create --name PFT_gapfilling -c conda-forge --file requirements.txt
```
or
```
conda create --name PFT_gapfilling -c conda-forge --file requirements.txt
```
**Type II regression**: For type II regression in matchup analysis use [pylr2](https://github.com/OceanOptics/pylr2). The installation is explained in the package or directly use pip and git:
```
pip install git+https://github.com/OceanOptics/pylr2.git
```
## Interactive Environment
You can connect the environment to JupyterLab using:
```
python -m ipykernel install --user --name=PFT_gapfilling --display-name "PFT_gapfilling"
```

