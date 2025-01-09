import os, re, sys
from pathlib import Path
import pandas as pd
import tifffile as tf

img_path = sys.argv[1]
out_path = sys.argv[2]
img_dir = os.path.dirname(img_path)

spots_channel=pd.read_csv(os.path.join(img_dir, 'spots_channel.csv'), header = None, names = ['gene','channel'])
img = tf.imread(img_path)

for c in range(len(spots_channel)):
    ex = img[:, spots_channel.channel[c]-1]
    out_dir = Path(os.path.join(out_path, spots_channel.gene[c]))
    out_dir.mkdir(parents=True, exist_ok=True)
    tf.imwrite(os.path.join(out_dir, re.sub('.tif','_%s.tif' % (spots_channel.gene[c]), os.path.basename(img_path))), data = ex)