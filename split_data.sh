function getSplit {
  local IMGDIR=$1
  local LBLDIR=$2
  local LBLPROJDIR=$3
  local DATADIR=$4
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
  echo -e "trainFiles=[" >> $trainFile
  echo -e "testFiles=[" >> $testFile
  for A in $DATADIR/*
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
    for piece in 0 1 2 3; do # every file is cut into 4 pieces
      echo -en "[\"$IMGDIR/${R}_$piece.npy\", " >> $outfile
      echo -en  "\"$LBLDIR/${R}_$piece.npy\", " >> $outfile
      echo -en "[" >> $outfile
      for proj in 0 1 2; do # every piece has 3 projections
        echo -en "\"$LBLPROJDIR/${R}_${piece}_$proj.npy\", " >> $outfile
      done
      echo -e "]], " >> $outfile
    done
  done
  echo -e "]" >> $trainFile
  echo -e "]" >> $testFile
}

#DATADIR=img_cropped
#IMGDIR=img_cut
#LBLDIR=lbl_cut
#LBLPROJDIR=lbl_projections
#getSplit "$IMGDIR"  "$LBLDIR"  "$LBLPROJDIR" "$DATADIR"

echo "generating the split files"
getSplit "$1" "$2" "$3" "$4"
