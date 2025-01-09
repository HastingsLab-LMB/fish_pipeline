#!/bin/bash
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=40
#SBATCH --mem=420G
#SBATCH -e slurm/RS_%A_%a.e
#SBATCH -o slurm/RS_%A_%a.out
if [ ! -d slurm ]; then mkdir -p slurm; fi

image_dir=$1
RS_list=$image_dir/RS_list.txt
RS_script=$(cat $RS_list | head -n $SLURM_ARRAY_TASK_ID | tail -n 1)

/path/to/ImageJ-linux64 --headless --run $RS_script &> `dirname $RS_script`/RS.log