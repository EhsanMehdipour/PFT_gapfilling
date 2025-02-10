# PFT_gapfilling
This repository is providing the neccasary codes for running and analysis the two well-established satellite gap-filling methods ,DINEOF and DINCAE, for gap-filling of total chlorophyl-a (TChla) and chlorophyll-a of phytoplankton functional type dataset provided by Copernicus Marine Service.

# Installation
```
conda create --name PFT_gapfilling -c conda-forge --file requirements.txt
```
or
```
mamba create --name PFT_gapfilling -c conda-forge --file requirements.txt
```
## Interactive Environment
You can connect the environment to JupyterLab using:
```
python -m ipykernel install --user --name=PFT_gapfilling --display-name "PFT_gapfilling"
```
For type II regression in matchup analysis use the following package. The installation is explained in the package.

https://github.com/OceanOptics/pylr2
```
pip install git+https://github.com/OceanOptics/pylr2.git
```
