#!/bin/bash
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=2
#SBATCH --mem=64G
#SBATCH -e slurm/split_mask_%A.e
#SBATCH -o slurm/split_mask_%A.out
if [ ! -d slurm ]; then mkdir -p slurm; fi

mask_dir=$1
id_pos=$2
script_dir=$3
mask_list=$mask_dir/mask_list.txt
mask_path=$(cat $mask_list | head -n $SLURM_ARRAY_TASK_ID | tail -n 1)

source ${HOME}/.bashrc
conda activate fish_pipeline
python3 $script_dir/split_masks_by_group.py $mask_path $id_pos