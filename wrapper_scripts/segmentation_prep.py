import os, sys, re, cv2
from pathlib import Path
from glob import glob
import numpy as np
import tifffile as tf

from scipy.ndimage import maximum_filter, gaussian_filter

def z_wise(stack, fun, **kwargs):
    res = []
    for z in range(stack.shape[0]):
        res.append(fun(stack[z], **kwargs))
    res = np.stack(res, axis = 0)
    return res
    

##### set-up #####
img_path = sys.argv[1] #image list to quantify in txt file
channels = np.asarray(sys.argv[2].replace('[','').replace(']','').split(',')) #channel to use for segmenting, 1-based index
max_filter_size = np.asarray(sys.argv[3].replace('[','').replace(']','').split(',')).astype('float')
gauss_filter_size = float(sys.argv[4])  

out_dir = Path(os.path.join(os.path.dirname(os.path.dirname(img_path)), 'prepped'))
out_dir.mkdir(parents=True, exist_ok=True)

##### max and save channel(s) to be scaled to a tmp_dir #####
img = tf.imread(img_path)
if '+' in channels[0]:
    chs_to_sum = np.asarray(channels[0].split('+')).astype('int')
    nz,_,ny,nx = img.shape
    ehn = np.zeros((nz,ny,nx)).astype('float32')
    for i,s in enumerate(max_filter_size):
        tmp = img[:,chs_to_sum[i]-1]
        ehn = ehn + z_wise(tmp, maximum_filter, size = s)
    ehn = ehn/len(chs_to_sum)
    ehn = ehn.astype('uint16')
else:
    ehn = img[:,channels[0].astype('int')-1]
    ehn = z_wise(ehn, maximum_filter, size = max_filter_size[0])
    
ehn = z_wise(ehn, gaussian_filter, sigma = gauss_filter_size)


##### append scaled channel with auxillary channel #####
res = np.stack([ehn, img[:,channels[1].astype('int')-1]], axis = 0)
res = np.swapaxes(res, 0, 1)

tf.imwrite(os.path.join(out_dir, os.path.basename(img_path)), data = res.astype('uint16'), imagej = True)