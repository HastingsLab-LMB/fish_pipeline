#!/bin/bash
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1
#SBATCH --mem=40G
#SBATCH -e slurm/RS_filter_%A_%a.e
#SBATCH -o slurm/RS_filter_%A_%a.out
if [ ! -d slurm ]; then mkdir -p slurm; fi

filter_list=$1
arg=$(cat $filter_list | head -n $SLURM_ARRAY_TASK_ID | tail -n 1)

/path/to/ImageJ-linux64 --headless -macro /path/to/fish_pipeline/filter_spots.ijm $arg