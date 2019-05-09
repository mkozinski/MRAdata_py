import numpy as np
import math
import re
import sys
import argparse

def drawLine(lbl,begPoint,endPoint):
    # endPoint and begPoint should be np.arrays
    # lbl is an np.array to which the line is rendered
    d=endPoint-begPoint
    mi=np.argmax(np.fabs(d))
    if d[mi]==0: # beginning and end points the same
        lbl[tuple(begPoint.astype(np.int))]=1
    else:
        coef=d/d[mi] # a vector that points from the current to the next pixel
        sz=np.array(lbl.shape) # an array holding a shape not an array of shape
        numsteps=int(abs(d[mi]))+1
        step=int(d[mi]/abs(d[mi])) # +-1
        for t in range(0,numsteps):
            pos=begPoint+coef*t*step
            if np.all(pos<sz) and np.all(pos>=0):
                lbl[tuple(pos.astype(np.int))]=1
            else:
                print("warning: reqested point",pos,"but the volume size is",sz)
    return lbl

def volInds(coords,scale,volDims,offset,downsampling):
    # volume index from coordinates from a trace file
    x=int((coords[volDims[0]]*scale[0]+offset[0])*downsampling[0])
    y=int((coords[volDims[1]]*scale[1]+offset[1])*downsampling[1])
    z=int((coords[volDims[2]]*scale[2]+offset[2])*downsampling[2])
    return x,y,z

def renderTRE2volume(fname, volumeDims, vol, scale, offset, downsampling):
    '''
      swcfname      name of the trace (.tre) file
      volumeDims    one-dimensional array;
                    volumeDims[1] is index of vol dimension corresponding to X
                    volumeDims[2] is index of vol dimension corresp to Y
                    volumeDims[3] is index of vol dimension corresp to Z
                    X,Y,Z are as interpreted in the tre format
      vol           np array into which we will render the ground truth lines
      scale         one-d array, with 3 elements
      offset        one-d array, with 3 elements
      downsampling  one-d array, with 3 elements
                    for point coordinates 'coord' from the trace file,
                    the first coordinate (x) of the volume is determined as:
                    (coord[volumeDims[0]]*scale[0]+offset[0])*downsampling[0]
                    and similarly for y and z
    '''

    # read the ground truth chains from the file
    chains=[]
    chain=[]
    start_new_chain=True # a two-state automaton 
                         # for identifying the first node of a chain
    for txtline in open(fname):
        if (re.match('\s*\#',txtline)!=None):
            # the line is a comment
            continue
        if (re.match('\s*[a-zA-Z]',txtline)!=None):
            # the line contains text
            start_new_chain=True
            continue
        if start_new_chain :
            chain=[]
            chains.append(chain) # append an empty chain, we will fill it later
            start_new_chain=False
        txtfields=txtline.split()
        floatfields=list(map(lambda x: float(x), txtfields))
        chain.append(np.array(floatfields)[0:4])
    
    # paint them to the ground truth volume
    for chain in chains:
        prev_coords=None
        for node in chain:
            cur_coords=volInds(node,scale,volumeDims,offset,downsampling)
            if prev_coords!=None:
                drawLine(vol,np.array(prev_coords),np.array(cur_coords))
            prev_coords=cur_coords


if __name__ == '__main__' :
    parser = argparse.ArgumentParser(description='render a ground truth in a form of a .tre file to a volume')
    parser.add_argument('input_file', metavar='input_file', 
                        help='the .tre file to be processed') 
    parser.add_argument('output_file', metavar='output_file', 
                        help='the name of the output file to be created') 
    parser.add_argument('--volume_size', metavar='s', type=int, nargs='*',
                        help='the dimension of the target volume') 
    parser.add_argument('--dimension_permutation', metavar='d', type=int, nargs='*',
                        help='the mapping from the volume dimensions to the order in the file') 
    args=parser.parse_args()
    lbl=np.zeros(tuple(args.volume_size),dtype=np.uint8)
    dims=np.array(args.dimension_permutation,dtype=np.uint8)
    renderTRE2volume(args.input_file, dims, lbl, np.array([1,1,1]), np.array([0,0,0]), np.array([1,1,1]))
    np.save(args.output_file,lbl)
