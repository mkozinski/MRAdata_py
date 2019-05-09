import numpy as np
import math
import sys
import argparse
import re

if __name__ == '__main__' :

    parser = argparse.ArgumentParser(description='create a Maximum Intensity Projection of a numpy array stored as an .npy file')
    parser.add_argument('input_file', metavar='input_file', 
                        help='the .tre file to be processed') 
    parser.add_argument('output_file', metavar='output_file', 
                        help='the name of the output file to be created') 
    args=parser.parse_args()

    i=np.load(args.input_file)

    out_file=re.sub('\.npy$','',args.output_file)
    for k in range(i.ndim):
        i_max=np.max(i,axis=k)
        np.save(out_file+'_'+str(k)+'.npy',i_max)
                
