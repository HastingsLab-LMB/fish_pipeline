#!/bin/bash
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=2
#SBATCH --mem=64G
#SBATCH -e slurm/segmentatio_prep_%A.e
#SBATCH -o slurm/segmentation_prep_%A.out
if [ ! -d slurm ]; then mkdir -p slurm; fi

image_dir=$1
image_list=$image_dir/to_quantify.txt
img_path=$(cat $image_list | head -n $SLURM_ARRAY_TASK_ID | tail -n 1)
out_dir=$2
script_dir=$3

source $image_dir/segmentation_params.txt

source $HOME/.bashrc
conda activate fish_pipeline

python3 $script_dir/segmentation_prep.py $img_path $segmentation_channels $max_filter_size $gauss_filter_size