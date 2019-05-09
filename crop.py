import numpy as np
import math
import sys
import argparse


if __name__ == '__main__' :

    parser = argparse.ArgumentParser(description='crop a numpy array stored as an .npy file')
    parser.add_argument('input_file', metavar='input_file', 
                        help='the .tre file to be processed') 
    parser.add_argument('output_file', metavar='output_file', 
                        help='the name of the output file to be created') 
    parser.add_argument('--crop_dims', metavar='s', type=int, nargs='*',
                        help='crop dimensions in the format: dim1_low dim1_high dim2_low dim2_high etc.') 
    args=parser.parse_args()

    i=np.load(args.input_file)

    assert len(args.crop_dims)>0 and len(args.crop_dims)%2==0, \
           "--crop_dims requires an even number of arguments: pairs of low - high coordinates"
    index=tuple(slice(args.crop_dims[2*k],args.crop_dims[2*k+1]) for k in range(len(args.crop_dims)//2))
    i_cropped=np.copy(i[index])

    np.save(args.output_file,i_cropped)
