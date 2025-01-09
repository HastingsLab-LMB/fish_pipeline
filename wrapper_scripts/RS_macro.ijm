// This macro script runs the RS (radial symmetry) FIJI plug-in on all the images in all the sub-directories of the defined dir
// After finding the best parameters using the RS plugin GUI interactive mode on one example image,
// You can run this macro script on the entire dataset.
// Just change the directory path, and the values of the parameters in the begining of the script

// You can run this script either in the ImageJ GUI or headless (also from cluster) using this command (linux):
// <FIJI/DIR/PATH>/ImageJ-linux64 --headless --run </PATH/TO/THIS/SCRIPT>/RS_macro.ijm &> </PATH/TO/WHERE/YOU/WANT/YOUR/LOGFILE>.log

// The detection result table will be saved to the same directory as each image it was calculated for.

if ((File.isDirectory(out_dir))){
	File.makeDirectory(out_dir);
}

// Location of file where all run times will be saved:
timeFile = out_dir + File.separator + "RS_exec_times.txt";
setBatchMode(true);
file_list = getFileList(dir);
filtered_list = newArray();
for (q = 0; q < file_list.length; q++) {
	if (endsWith(file_list[q], ".tif")){
		filtered_list = Array.concat(file_list[q],filtered_list);
	}
}
imMin = 1000;
imMax = 0;
for (i=0; i<filtered_list.length; i++) {
    open(dir + File.separator + filtered_list[i]);
    Stack.getStatistics(voxelCount, mean, min, max, stdDev);
    min = parseInt(min);
    max = parseInt(max);
    if ((min < imMin)){
    	imMin = min;
    }
    if ((max > imMax)){
    	imMax = max;
    }
    run("Close All");
}



///////////////////////////////////////////////////

ransac_sub = split(ransac, ' ');
ransac_sub = ransac_sub[0];

bsMethod_sub = split(bsMethod, ' ');
bsMethod_sub = bsMethod_sub[0];

setBatchMode(true);

///////////////////////////////////////////////////

walkFiles(dir);

// Find all files in subdirs:
function walkFiles(dir) {
	list = getFileList(dir);
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i], "/"))
		   walkFiles(""+dir+list[i], out_dir);

		// If image file
		else  if (endsWith(list[i], ".tif")) 
		   processImage(dir, list[i], out_dir);
	}
}

function processImage(dirPath, imName, out_dir) {
	
	open("" + dirPath + File.separator + imName);
    resultPath = out_dir;
    File.makeDirectory(resultPath);

	results_csv_path = "" + resultPath + File.separator + replace(imName,".tif","") + 
	".csv";


	RSparams =  "image=" + imName + 
	" mode=Advanced anisotropy=" + anisotropyCoefficient + " robust_fitting=[" + ransac + "] use_anisotropy spot_intensity=[Integrate spot intensities (on candidate pixels)]" + 
	" image_min=" + imMin + " image_max=" + imMax + " sigma=" + sigmaDoG + " threshold=" + thresholdDoG + 
	" support=" + supportRadius + " min_inlier_ratio=" + inlierRatio + " max_error=" + maxError + " spot_intensity_threshold=" + intensityThreshold + 
	" background=[" + bsMethod + "] background_subtraction_max_error=" + bsMaxError + " background_subtraction_min_inlier_ratio=" + bsInlierRatio + 
	" results_file=[" + results_csv_path + "]" + 
	" " + useMultithread + " num_threads=" + numThreads + " block_size_x=" + blockSizX + " block_size_y=" + blockSizY + " block_size_z=" + blockSizZ +
    " min_number_of_inliers=" + minNumInliers + " initial=" + nTimesStDev1 + " final=" + nTimesStDe;

	print(RSparams);

	startTime = getTime();
	run("RS-FISH", RSparams);
	exeTime = getTime() - startTime; //in miliseconds
	
	// Save exeTime to file:
	File.append(results_csv_path + "," + exeTime + "\n ", timeFile);

	// Close all windows:
	run("Close All");	
	while (nImages>0) { 
		selectImage(nImages); 
		close(); 
    } 
} 
