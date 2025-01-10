# fish_pipeline
## Prerequisites
- Create a conda environment named fish_pipeline with the necessary packages (listed in fish_pipeline.yml).
- Download the directory `Fiji.app`, or install ImageJ locally from scratch, followed by installing the Radial Symmetry plugin.
- Have the slurm workload manager set up.
- The `wrapper_scripts` directory contains the wrapper scripts for running the pipeline:
   * `sbatch_RS_filter_spots.sh` (line 12): specify path pointing to ImageJ and the fish_pipeline folder containing wrapper scripts
   *  `sbatch_RS_wrapper.sh` (line 13): specify path pointing to ImageJ
- The `cellpose_model`directory contains the trained model for segmenting cells enriched for clock gene expression.  

## Running pipeline on test dataset
1. Obtain test dataset from this [figshare](https://figshare.com)
2. Specify the appropriate variables/parameters within the following files (can be found within the test dataset folder):
  -	`spots_channel.csv`
    * 1st column: channel name
    * 2nd column: channel number (1-based indexing)
  - `segmentation_params.txt`
    * segmentation_channels: main channel numbers and nuclear channel number, separated by commas. If multiple FISH channels that carry information on clock gene enrichment are to be used, separate their channel numbers by ‘+’ (e.g. `[1+3,4]`)
    * max_filter_size: radius of maximum filter (in pixels) to be applied to individual FISH channels carrying information on clock gene enrichment, separated by commas (e.g. `[4,5,6]`) 
    * gauss_filter_size: sigma of gaussian filter (in pixels) to be applied to average of maximum filtered FISH channels
    * model_path: full path to cellpose model
    * flow_threshold, cellprob_threshold, stitch_threshold, min_size and use_gpu are cellpose-specific parameters
  -	`*_spots_params.txt`
    * parameter specification for radial symmetry
3. `segment_and_spot_detect.sh` submit spot detection and segmentation slurm jobs in parallel:
  - change path variables as necessary
  - run it by e.g. `bash segment_and_spot_detect.sh`
  - two directories will be created within `out_dir`:
    * `detected_spots/radial_symmetry`, in which the .csv file containing the list of detected spots is saved
    * `masks/cellpose`, in which the .tif file of the segmented cells is saved
4. Correct masks and annotate them as necessary (done for this example dataset, cf. the files in `masks/corrected`)
5. `filter_spots.sh` submit the list of detected spots to be filtered by the masks of the cell groups they belong to
  - change path variables as necessary

