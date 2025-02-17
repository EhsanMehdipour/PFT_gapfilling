#!/bin/bash

## Parallelization of the runs on multiple GPUs
## Choose the array as the number of the regions 
## The hyperparameters are chosen randomly from an specified range

#SBATCH --account=oze.oze
#SBATCH --job-name=DINCAE
#SBATCH --output=./log/random_final_%a.log
#SBATCH --error=./log/random_final_%a.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 32
#SBATCH --partition=gpu
#SBATCH --gpus=a100:1
#SBATCH --time=30:00:00
#SBATCH --qos=48h
#SBATCH --array=1-10
#SBATCH --mail-user=ehsan.mehdipour@awi.de
#SBATCH --mail-type=FAIL

## Choose the path to the julia installation
julia="~/DINCAE/julia-1.9.3/bin/julia"

region=$SLURM_ARRAY_TASK_ID

## Parallel reconstruction
srun $julia random_final.jl $region