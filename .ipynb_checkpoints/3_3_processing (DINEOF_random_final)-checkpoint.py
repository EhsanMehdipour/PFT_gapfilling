## Import modules

import os
import math
import random
import argparse
import json
from function import create_folder_if_not_exists
from params import params

## parse the configuration from them SLURM file
parser = argparse.ArgumentParser(description="get the experiment number")
parser.add_argument('--experiment', type=str, required=True, help='the experiment number from slurm array')
parser.add_argument('--region', type=int, required=True, help='the region number from slurm code')
args = parser.parse_args()
experiment = args.experiment
region = args.region

# # Random Creation
# sst = random.choice([True, False])
# numit = random.randrange(1, 20)
# alpha = round(0.5 * 10**(-2 * random.random()),3)

# rec = 1
# norm = 0
# nev = 200

# filter_extent = round(2 * math.pi * math.sqrt(float(alpha)*float(numit)),2)

# Open and read the JSON file
json_file_path = 'random/json/9_11.json'

with open(json_file_path, 'r') as file:
    json_dict = json.load(file)

# Access the parameters
sst = json_dict['sst']
numit = json_dict['numit']
alpha = json_dict['alpha']
filter_extent = json_dict['filter_extent']
rec = json_dict['rec']
norm = json_dict['norm']
nev = json_dict['nev']

with open(f'random/json/{region}_{experiment}.json', 'w') as file:
    json.dump(json_dict, file, indent=4)  # indent=4 for pretty-printing

## list of PFT parameters
PFT = params['PFT']

if sst:
    PFT = PFT + ['sst']

working_dir = os.path.join(params['output_dir'], region)

## Input
data_file = os.path.join(working_dir,'ds_pft_dev_filled.nc')
mask_file = os.path.join(working_dir,'ds_pft_dev_filled.nc')
cloud_index = os.path.join(working_dir,'cloud_index_train.nc')

## Output
reconstuct_dir = os.path.join(working_dir,'DINEOF',experiment)
create_folder_if_not_exists(reconstuct_dir)
output_file = os.path.join(working_dir,'ds_reconstructed')
EOF_dir = reconstuct_dir

## Creating the path to the output files
data = [f"'{data_file}#{pft}'" for pft in PFT]
data_str = ','.join(data)

mask = [f"'{mask_file}#mask'" for pft in PFT]
mask_str = ','.join(mask)

results = [f"'{output_file}_{pft}.nc#{pft}'" for pft in PFT]
results_str = ','.join(results)

EOF_U = [f"'{EOF_dir}/EOF_{pft}.nc#{pft}'" for pft in PFT]
EOF_U_str =  ','.join(EOF_U)

## Creating the init file for running DINEOF
with open(f"random/{region}_{experiment}.init", "w") as f:
    f.write(f"""
!
! INPUT File for dineof 2.0
!
! Lines starting with a ! or # are comments
!

! gappy data to fill by DINEOF. For several matrices, separate names with commas 
! Example:  
!          data = ['seacoos2005.avhrr','seacoos2005.chl']

data = [{data_str}]


!--------------MASK FILE----------------------------------------------
! Land-sea mask of the gappy data. 
! Several masks can be especified, separated by commas:
! Example : 
!           mask = ['seacoos2005.avhrr.mask','seacoos2005.chl.mask']
!
! When no mask is especified (comment out the maskfile line), 
!                      no land points are present in the initial file

mask = [{mask_str}]

!---------------------------------------------------------------------





time = '{data_file}#time'
alpha = {alpha}
numit = {numit}


!
! Sets the numerical variables for the computation of the required
! singular values and associated modes.
!
! Give 'nev' the maximum number of modes you want to compute 

nev = {nev}

! Give 'neini' the minimum  number of modes you want to compute 

neini = 1

! Give 'ncv' the maximal size for the Krylov subspace 
! (Do not change it as soon as ncv > nev+5) 
! ncv must also be smaller than the temporal size of your matrix

ncv = {nev+5}

! Give 'tol' the treshold for Lanczos convergence 
! By default 1.e-8 is quite reasonable 

tol = 1.0e-8

! Parameter 'nitemax' defining the maximum number of iteration allowed for the stabilisation of eofs obtained by the cycle ((eof decomposition <-> truncated reconstruction and replacement of missing data)). An automatic criteria is defined by the following parameter 'itstop' to go faster 

nitemax = 300

! Parameter 'toliter' is a precision criteria defining the threshold of automatic stopping of dineof iterations, once the ratio (rms of successive missing data reconstruction)/stdv(existing data) becomes lower than 'toliter'. 

toliter = 1.0e-3

! Parameter 'rec' for complete reconstruction of the matrix 
! rec=1 will reconstruct all points; rec=0 only missing points

rec = {rec}

! Parameter 'eof' for writing the left and right modes of the
!input matrix. Disabled by default. To activate, set to 1

eof = 1

! Parameter 'norm' to activate the normalisation of the input matrix
!for multivariate case. Disabled by default. To activate, set to 1

norm = {norm}

! Output folder. Left and Right EOFs will be written here     
!

!Output = './'
Output = '{reconstuct_dir}'

!
! user chosen cross-validation points,
! remove or comment-out the following entry if the cross-validation points are to be chosen
! internally
!

! clouds = 'crossvalidation.clouds'

!
! "results" contains the filenames of the filled data
!

!results = ['All_95_1of2.sst.filled']
!results = ['Output/F2Dbelcolour_region_period_datfilled.gher']

results = [{results_str}]


! seed to initialize the random number generator

seed = 243435

EOF.U = [{EOF_U_str}]
EOF.V = '{EOF_dir}/EOF_V.nc#V'
EOF.Sigma = '{EOF_dir}/EOF_Sigma.nc#Sigma'

!-------------------------!
! cross-validation points !
!-------------------------!

!number_cv_points = 7000

!cloud surface size in pixels 
!cloud_size = 500



clouds = '{cloud_index}#clouds_index'


!
! END OF PARAMETER FILE 
!



    """)