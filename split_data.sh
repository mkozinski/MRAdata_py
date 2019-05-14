function getSplit {
  local IMGDIR=$1
  local LBLDIR=$2
  local IMGCUTDIR=$3
  local LBLCUTDIR=$4
  local LBLPROJDIR=$5
  local LBLMARGDIR=$6
  local trainFile=trainFiles.txt
  local testFile=testFiles.txt
  if [[ -e $trainFile ]] ; then
    echo "Error: $trainFile exists"
    exit 1
  fi
  if [[ -e $testFile ]] ; then
    echo "Error: $testFile exists"
    exit 2
  fi
  echo -e "# image, label, label_with_margins, projection_labels" >> $trainFile
  echo -e "trainFiles=[" >> $trainFile
  echo -e "# image, label, label_with_margins, projection_labels" >> $testFile
  echo -e "testFiles=[" >> $testFile
  echo -e "# image, label" >> ${trainFile}_uncut
  echo -e "trainFiles=[" >> ${trainFile}_uncut
  echo -e "# image, label" >> ${testFile}_uncut
  echo -e "testFiles=[" >> ${testFile}_uncut
  for A in $IMGDIR/*
  do
    echo $A
    randn=$(( $RANDOM % 4 ))
    if (( $randn < 3 )) ; then
      outfile=$trainFile
    else 
      outfile=$testFile
    fi
    I=`basename $A`
    R=${I%.*}
    echo -en "[\"$IMGDIR/${R}.npy\", " >> ${outfile}_uncut
    echo -e  "\"$LBLDIR/${R}.npy\",]," >> ${outfile}_uncut
    for piece in 0 1 2 3; do # every file is cut into 4 pieces
      echo -en "[\"$IMGCUTDIR/${R}_$piece.npy\", " >> $outfile
      echo -en  "\"$LBLCUTDIR/${R}_$piece.npy\", " >> $outfile
      echo -en  "\"$LBLMARGDIR/${R}_$piece.npy\", " >> $outfile
      echo -en "[" >> $outfile
      for proj in 0 1 2; do # every piece has 3 projections
        echo -en "\"$LBLPROJDIR/${R}_${piece}_$proj.npy\", " >> $outfile
      done
      echo -e "]], " >> $outfile
    done
  done
  echo -e "]" >> $trainFile
  echo -e "]" >> $testFile
  echo -e "]" >> ${trainFile}_uncut
  echo -e "]" >> ${testFile}_uncut
}

#DATADIR=img_cropped
#IMGDIR=img_cut
#LBLDIR=lbl_cut
#LBLPROJDIR=lbl_projections
#LBLMARGDIR=lbl_with_margins
#getSplit "$IMGDIR" "$LBLDIR" "$IMGCUTDIR" "$LBLCUTDIR" "$LBLPROJDIR" "$LBLMARGDIR"

echo "generating the split files"
getSplit "$1" "$2" "$3" "$4" "$5" "$6"
