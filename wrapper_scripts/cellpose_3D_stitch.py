import os, sys, re
from pathlib import Path
from glob import glob
import numpy as np
import tifffile as tf

from cellpose import models, core, io

img_path = sys.argv[1] #image list to quantify in txt file
model_path = sys.argv[2]
n_channels = sys.argv[3].count(',')#channel to use for segmenting, 1-based index
flow_threshold = float(sys.argv[4]) #0.1 - 1.1, default is 0.4
cellprob_threshold = float(sys.argv[5]) #-6 to 6, default is 0
stitch_threshold = float(sys.argv[6])
min_size = float(sys.argv[7])
use_gpu = sys.argv[8]
if use_gpu == 'True':
    use_gpu = True
else:
    use_gpu = False
    
if n_channels == 0:
    channel=[0]
else:
    channel=[1,2]

out_dir = os.path.dirname(img_path)
out_dir = Path(os.path.join(os.path.dirname(out_dir), 'cellpose'))
out_dir.mkdir(parents=True, exist_ok=True)

model = models.CellposeModel(gpu=use_gpu, pretrained_model=model_path)

img = tf.imread(img_path)

mask, flow, style = model.eval(img, cellprob_threshold=cellprob_threshold, flow_threshold=flow_threshold, channels=channel, do_3D = False, stitch_threshold=stitch_threshold, min_size = 30, augment = False, batch_size = 4)

tf.imwrite(os.path.join(out_dir, re.sub('.tif','_cp_mask.tif', os.path.basename(img_path))), data = mask)