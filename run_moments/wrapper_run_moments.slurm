#!/bin/bash

#SBATCH --mem 9G
#SBATCH --time 5:00:00
#SBATCH --partition standard
#SBATCH --account berglandlab
#SBATCH -c 1
#SBATCH -e /scratch/djb3ve/connor/run_moments/slurm-%a.err
#SBATCH --output /scratch/djb3ve/connor/run_moments/slurm-%a.out

# This Slurm script runs an array job of moments runs with one job per line of instructions_run_moments.txt,
# which should contain one SFS projection size per line, e.g. 20 corresponds to 20x20 SFS projections in moments

# Options file should contain output of "ls [input SFS directory]"
options_file="/scratch/djb3ve/connor/run_moments/instructions_run_moments.txt"
script_file="/scratch/djb3ve/connor/run_moments/run_moments.py"

OPTS=$(sed -n "${SLURM_ARRAY_TASK_ID}"p ${options_file})
python $script_file $OPTS
