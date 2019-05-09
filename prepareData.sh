DNAME="download" 
DN='ITKTubeTK - Bullitt - Healthy MR Database' 
DD="${DN}/Designed Database of MR Brain Images of Healthy Volunteers"
LBL_SUBDIR="AuxillaryData/VascularNetwork.tre"

OUT_DIR="orig_data"
OUT_LBLDIR="$OUT_DIR"/lbl
OUT_IMGDIR="$OUT_DIR"/img

if [ ! -d "$OUT_DIR" ]; then
  NEW_DOWNLOAD=true
  if [ ! -d "$DN" ]; then
    if [ ! -d "$DNAME" ]; then
      echo "downloading and unpacking the dataset into folder $DNAME"
      wget https://data.kitware.com/api/v1/collection/591086ee8d777f16d01e0724/download
    else
      echo "found an existing \"$DNAME\" directory, I will not download the data again"
    fi
    echo "unpacking the dataset into folder $DN"
    unzip "$DNAME"
    echo "removing $DNAME"
    rm "$DNAME"
  else
    echo "found an existing \"$DN\" directory, I shall not download and unpack the data again"
  fi
    
  mkdir $OUT_DIR
  mkdir $OUT_LBLDIR
  mkdir $OUT_IMGDIR
  
  echo "copying the annotated images into folder $OUT_IMGDIR and the ground truths into $OUT_LBLDIR"
  for D in "$DD"/Normal*
  do
    ID=`echo $D | sed -e "s/.*\/Normal-\(\d\)*/\1/"`
    #echo ${ID}
    if [ -e "$D/$LBL_SUBDIR" ]; then
      cp "$D/MRA/Normal$ID-MRA.mha" "$OUT_IMGDIR/$ID.mha"
      cp "$D/$LBL_SUBDIR" "$OUT_LBLDIR/$ID.tre"
    fi
  done
  echo "removing $DD and $DN"
  rm -rf "$DD"
  rm -rf "$DN"
else
  echo "found an existing \"$OUT_DIR\" directory, I shall not acquire the dataset again"
fi
  
if [ ! -d img ] || [ "$NEW_DOWNLOAD" = true ]; then
  echo "generating the inputs into folder img"
  python convertMha2Py.py "$OUT_IMGDIR" img
else
  echo "found an existing \"img\" directory, not re-generating the inputs"
fi
  
if [ ! -d lbl ] || [ "$NEW_DOWNLOAD" = true ]; then
  echo "rendering the ground truths into folder lbl"
  mkdir lbl
  for TRE in "$OUT_LBLDIR"/*.tre; do
    OUTNAME=`basename "$TRE" | sed -e 's/\.tre//'`
    python renderGroundTruth.py  "$TRE" lbl/"$OUTNAME.npy" --volume_size 128 448 448 --dimension_permutation 2 1 0 
  done
else
  echo "I found an existing \"lbl\" dir, I will not re-render the ground truths"
fi

echo "cropping the volumes to remove empty margins; folder img_cropped"
mkdir img_cropped
for IMG in img/*.npy; do
  OUTNAME=` basename "$IMG" `
  python crop.py "$IMG" img_cropped/"$OUTNAME" --crop_dims 0 128 16 432  64 392
done

echo "cropping the labels to remove empty margins; folder lbl_cropped"
mkdir lbl_cropped
for LBL in lbl/*.npy; do
  OUTNAME=` basename "$LBL" `
  python crop.py "$LBL" lbl_cropped/"$OUTNAME" --crop_dims 0 128 16 432  64 392
done

echo "cutting the volumes; results in folder img_cropped"
mkdir img_cut
for IMG in img_cropped/*.npy; do
  OUTNAME=` basename "$IMG" `
  python cut.py "$IMG" img_cut/"$OUTNAME" --nb_pieces 1 2 2
done

echo "cutting the labels; results in folder lbl_cut"
mkdir lbl_cut
for LBL in lbl_cropped/*.npy; do
  OUTNAME=` basename "$LBL" `
  python cut.py "$LBL" lbl_cut/"$OUTNAME" --nb_pieces 1 2 2
done

echo "generating projection labels in lbl_projections"
mkdir lbl_projections
for LBL in lbl_cut/*.npy; do
  OUTNAME=`basename "$LBL"`
  python project.py "$LBL" lbl_projections/"$OUTNAME"
done
  
./split_data.sh img_cut lbl_cut lbl_projections img
