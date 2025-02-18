#!/bin/bash

## Parallelization of the runs on multiple CPUs
## Choose the array for the number of random reconstruction
## The hyperparameters are chosen randomly from an specified range

#SBATCH --account=oze.oze
#SBATCH --job-name=DINEOF
#SBATCH --output=./log/random_%a.log
#SBATCH --error=./log/random_%a.log
#SBATCH --ntasks-per-node=1
#SBATCH --nodes=1
#SBATCH --partition=mpp
#SBATCH --time=48:00:00
#SBATCH --qos=48h
#SBATCH --array=22-41%5
#SBATCH --mail-user=ehsan.mehdipour@awi.de
#SBATCH --mail-type=FAIL

# source activate dineof
## Importing modules
export OMP_NUM_THREADS=1
module load netlib-lapack
module load nvhpc
# module load intel-oneapi-compilers
# module load intel-oneapi-mkl
module load netcdf-fortran
# module load openmpi

## Path to the DINEOF execution file
dineof_exec="~/DINEOF/dineof"

## Choose the region for random reconstruction
region=9

## generating the init file
srun python random_DINEOF.py --experiment $SLURM_ARRAY_TASK_ID --region $region

input_file="random/${region}_${SLURM_ARRAY_TASK_ID}.init"

## Parallel initialization of random reconstruction
srun $dineof_exec $input_file

