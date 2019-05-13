import torch
import numpy as np
import math
import sys
import argparse


if __name__ == '__main__' :

    parser = argparse.ArgumentParser(description='add margin to labels stored in .np files')
    parser.add_argument('input_file', metavar='input_file', 
                        help='the input .np file to be processed') 
    parser.add_argument('output_file', metavar='output_file', 
                        help='the name of the output file to be created') 
    args=parser.parse_args()

    l=np.load(args.input_file)

    margin=torch.nn.functional.max_pool3d(
        torch.from_numpy(l[np.newaxis,np.newaxis,...].astype(np.float)),kernel_size=5,padding=2,stride=1)
    l_with_margin=np.ones_like(l)-margin.squeeze().numpy().astype(np.byte)+2*l
    
    np.save(args.output_file,l_with_margin)
