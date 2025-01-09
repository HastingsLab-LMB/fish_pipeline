#!/bin/bash

img_dir=$1
out_dir=$2
segmentation_parameter_file=$3
tmp_dir=$4
script_dir=$5

source $segmentation_parameter_file

### preprocess and extract segmentation channels
tmp_img_dir=$tmp_dir/segment_dir
if [ ! -d $tmp_img_dir ]; then mkdir -p $tmp_img_dir; fi
tmp_out_dir=$tmp_img_dir/prepped
if [ ! -d $tmp_out_dir ]; then mkdir -p $tmp_out_dir; fi
tmp_img_dir=$tmp_img_dir/imgs
if [ ! -d $tmp_img_dir ]; then mkdir -p $tmp_img_dir; fi

cp $segmentation_parameter_file $tmp_img_dir
cp $img_dir/*.tif $tmp_img_dir
ls $tmp_img_dir/*.tif > $tmp_img_dir/to_quantify.txt

n=$(wc -l < $tmp_img_dir/to_quantify.txt)

sbatch -J segment_prep --array=1-$n --wait $script_dir/sbatch_segmentation_prep.sh "$tmp_img_dir" "$tmp_out_dir" "$script_dir"
wait

cp -r $tmp_out_dir $img_dir &


### run cellpose
tmp_img_dir=$tmp_out_dir
ls $tmp_img_dir/*.tif > $tmp_img_dir/to_quantify.txt
cp $segmentation_parameter_file $tmp_img_dir
tmp_out_dir=$tmp_dir/segment_dir/cellpose
if [ ! -d $tmp_out_dir ]; then mkdir -p $tmp_out_dir; fi

n=$(wc -l < $tmp_img_dir/to_quantify.txt)

if test "$use_gpu" = "True";
then
    sbatch -J cellpose --partition=gpu --gres=gpu:1 --array=1-$n --wait $script_dir/sbatch_cellpose_3D.sh "$tmp_img_dir" "$script_dir"
else
    sbatch -J cellpose --array=1-$n --wait $script_dir/sbatch_cellpose_3D.sh "$tmp_img_dir" "$script_dir"
fi
wait

cp -r $tmp_out_dir $out_dir

rm -rf $tmp_dir/segment_dir