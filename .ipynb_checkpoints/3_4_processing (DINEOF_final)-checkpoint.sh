#!/bin/bash

## Parallelization of the runs on multiple CPUs
## Choose the array as the number of the regions 
## The hyperparameters are chosen randomly from an specified range

#SBATCH --account=oze.oze
#SBATCH --job-name=DINEOF
#SBATCH --output=./log/random_final_%a.log
#SBATCH --error=./log/random_final_%a.log
#SBATCH --ntasks-per-node=1
#SBATCH --nodes=1
#SBATCH --partition=mpp
#SBATCH --time=48:00:00
#SBATCH --qos=48h
#SBATCH --array=1-10
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

region=${SLURM_ARRAY_TASK_ID}
experiment='final'

## generating the init file
srun python random_DINEOF_final.py --experiment $experiment --region $region

input_file="random/${region}_${experiment}.init"

## Parallel reconstruction
srun $dineof_exec $input_file