import numpy as np
import math
import sys
import argparse
import re

if __name__ == '__main__' :

    parser = argparse.ArgumentParser(description='cut a numpy array stored as an .npy file')
    parser.add_argument('input_file', metavar='input_file', 
                        help='the .tre file to be processed') 
    parser.add_argument('output_file', metavar='output_file', 
                        help='the name of the output file to be created') 
    parser.add_argument('--nb_pieces', metavar='s', type=int, nargs='*',
                        help='number of equal pieces to cut into along each dimensions') 
    args=parser.parse_args()

    i=np.load(args.input_file)

    to_cut=[i]
    for k in range(len(args.nb_pieces)):
        result=[]
        for ii in to_cut:
            result+=np.array_split(ii,args.nb_pieces[k],axis=k)
        to_cut=result
    
    out_file=re.sub('\.npy$','',args.output_file)
    for k in range(len(result)):
        np.save(out_file+'_'+str(k)+'.npy',result[k])
                
