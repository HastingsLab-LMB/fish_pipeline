#!/bin/bash
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1
#SBATCH --mem=32G
#SBATCH -e slurm/fish_channel_extract_%A_%a.e
#SBATCH -o slurm/fish_channel_extract_%A_%a.out
if [ ! -d slurm ]; then mkdir -p slurm; fi

image_dir=$1
out_path=$2
script_dir=$3
image_list=$image_dir/to_quantify.txt
img_path=$(cat $image_list | head -n $SLURM_ARRAY_TASK_ID | tail -n 1)

source ${HOME}/.bashrc
conda activate fish_pipeline

python3 $script_dir/extract_channel_of_interest.py $img_path $out_path