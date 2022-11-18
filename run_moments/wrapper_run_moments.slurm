#!/bin/bash

#SBATCH --mem 9G
#SBATCH --time 2:00:00
#SBATCH --partition standard
#SBATCH --account berglandlab
#SBATCH -c 1
#SBATCH -e /scratch/djb3ve/connor/errors_slurm/slurm-%a.err
#SBATCH --output /scratch/djb3ve/connor/output_slurm/slurm-%a.out

# Options file should contain output of "ls [input SFS directory]"
options_file="/scratch/djb3ve/connor/instructions_run_moments.txt"
script_file="/scratch/djb3ve/connor/run_moments.py"

OPTS=$(sed -n "${SLURM_ARRAY_TASK_ID}"p ${options_file})
python $script_file $OPTS
