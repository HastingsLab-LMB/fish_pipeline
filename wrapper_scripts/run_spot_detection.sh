#!/bin/bash

img_dir=$1
out_dir=$2
spots_channel_file=$3
spots_parameter_file_dir=$4
tmp_dir=$5
script_dir=$6


### extract fish channels
tmp_img_dir=$tmp_dir/fish_dir
if [ ! -d $tmp_img_dir ]; then mkdir -p $tmp_img_dir; fi
tmp_out_dir=$tmp_img_dir/extracted
if [ ! -d $tmp_out_dir ]; then mkdir -p $tmp_out_dir; fi
tmp_img_dir=$tmp_img_dir/imgs
if [ ! -d $tmp_img_dir ]; then mkdir -p $tmp_img_dir; fi

cp $spots_channel_file $tmp_img_dir
cp -u $img_dir/*.tif $tmp_img_dir
ls $tmp_img_dir/*.tif > $tmp_img_dir/to_quantify.txt
awk -F',' '{print $1}' $spots_channel_file > $tmp_out_dir/channel_list.txt

n=$(wc -l < $tmp_img_dir/to_quantify.txt)

sbatch -J extract --array=1-$n --wait $script_dir/sbatch_extract_channel.sh "$tmp_img_dir" "$tmp_out_dir" "$script_dir"
wait

cp -r $tmp_out_dir/* $img_dir &

### run radial symmetry
tmp_RS_dir=$tmp_dir/fish_dir/radial_symmetry
if [ ! -d $tmp_RS_dir ]; then mkdir -p $tmp_RS_dir; fi

for g in `cat $tmp_out_dir/channel_list.txt`; do
    cat $spots_parameter_file_dir/${g}_spots_params.txt $script_dir/RS_macro.ijm > $tmp_out_dir/$g/RS_macro.ijm;
    sed -i "1s@^@out_dir=\"$tmp_RS_dir/$g\"\;\n@" $tmp_out_dir/$g/RS_macro.ijm
    sed -i "1s@^@dir=\"$tmp_out_dir/$g\"\;\n@" $tmp_out_dir/$g/RS_macro.ijm
done

ls $tmp_out_dir/*/RS_macro.ijm > $tmp_out_dir/RS_list.txt

n=$(wc -l < $tmp_out_dir/RS_list.txt)

sbatch -J rs --array=1-$n --wait $script_dir/sbatch_RS_wrapper.sh "$tmp_out_dir"
wait

cp -r $tmp_RS_dir $out_dir
cp $tmp_out_dir/channel_list.txt $out_dir/radial_symmetry

rm -rf $tmp_dir/fish_dir