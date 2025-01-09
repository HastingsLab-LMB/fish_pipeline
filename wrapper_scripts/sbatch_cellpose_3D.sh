#!/bin/bash
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=2
#SBATCH --mem=256G
#SBATCH -e slurm/cellpose3d_%A.e
#SBATCH -o slurm/cellpose3d_%A.out
if [ ! -d slurm ]; then mkdir -p slurm; fi

image_dir=$1
image_list=$image_dir/to_quantify.txt
img_path=$(cat $image_list | head -n $SLURM_ARRAY_TASK_ID | tail -n 1)
img_basename=$(basename $img_path .tif)
tmp_out_dir=`dirname $image_dir`/cellpose
script_dir=$2

source $image_dir/segmentation_params.txt

source ${HOME}/.bashrc
conda activate fish_pipeline

python3 $script_dir/cellpose_3D_stitch.py $img_path $model_path $segmentation_channels $flow_threshold $cellprob_threshold $stitch_threshold $min_size $use_gpu