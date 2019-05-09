import os
import numpy as np
import SimpleITK as sitk 
import sys

idir=sys.argv[1] 
odir=sys.argv[2]
if not os.path.exists(odir):
  os.makedirs(odir)

for fn in os.listdir(idir):
  # Reads the image using SimpleITK
  itkimage = sitk.ReadImage(os.path.join(idir,fn))
  # Convert the image to a  numpy array 
  ct_scan = sitk.GetArrayFromImage(itkimage)
  f=open(odir+"/"+fn[:-4]+".npy","wb")
  np.save(f,ct_scan)
  f.close()

