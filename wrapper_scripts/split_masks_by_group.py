import os, sys
import tifffile as tf
import numpy as np
from glob import glob

mask_path = sys.argv[1]
id_pos = int(sys.argv[2]) - 1

mask_dir = os.path.dirname(mask_path)
mask = tf.imread(mask_path)
samplename = os.path.basename(mask_path).split('_')[id_pos]
cellgroup_file = glob(os.path.join(mask_dir, '*' + samplename + '_cp_cellgroup.txt'))[0]

with open(cellgroup_file, 'r') as f:
    cellgroup_lines = f.readlines()
clock_cell_labels = []
for l in cellgroup_lines:
    if '=' in l:
        cellgroup = l.split(' = ')[0]
        labels = np.asarray(l.split(' = ')[1].strip('\n').strip('[]').split(','))
        if labels[0] != '':
            out_dir = os.path.join(mask_dir, cellgroup)
            os.makedirs(out_dir, exist_ok = True)
            
            labels = labels.astype('int')
            cmask = np.zeros(mask.shape, dtype = np.int8)
            for i in range(len(labels)):
                cmask[mask == labels[i]] = 1
                clock_cell_labels.append(labels[i])
            tf.imwrite(os.path.join(out_dir,os.path.basename(mask_path).replace('.tif','_%s.tif'%cellgroup)), data = cmask)
    
    out_dir = os.path.join(mask_dir, 'clock_cells')
    os.makedirs(out_dir, exist_ok = True)
    cmask = np.zeros(mask.shape, dtype = np.int8)
    for label in clock_cell_labels:
        cmask[mask == label] = 1
    tf.imwrite(os.path.join(out_dir,os.path.basename(mask_path).replace('.tif','_clock_cells.tif')), data = cmask)