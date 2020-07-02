#!/bin/zsh -f

scriptpath=$0:A
parentdir=${scriptpath%/*}
scriptname=${scriptpath##*/}
builddir=$parentdir/build

if ! source $builddir/project_environment.sh; then
  echo "test_tesseract.sh: error sourcing $builddir/project_environment.sh"
  exit 1
fi

strip_whitespace() {
  local filename=$1

  cat $filename | tr -d '\n' | tr -d '\f' | tr -d ' '
}

langfiles=(
  'chi_tra.traineddata'
  'chi_tra_vert.traineddata'
  'eng.traineddata'
  'jpn.traineddata'
  'jpn_vert.traineddata'
)

# Download jpn and jpn_vert files
for langfile in $langfiles; do
  if [ -f $ROOT/share/tessdata/$langfile ]; then
    echo Found $langfile
    continue
  fi

  print -n "Downloading $langfile... "
  curl -L -f -s \
    https://github.com/tesseract-ocr/tessdata_best/raw/master/$langfile \
    --output $ROOT/share/tessdata/$langfile
  print 'done.'
done

# Run tesseract command-line program on a number of sample/test images;
#
#   tesseract CL program should be in Root/bin, and Root/bin is 
#   added to $PATH in project_environment.sh

cd $PROJECTDIR/iOCR/iOCR/Assets.xcassets

rm -f out.txt
tesseract hello_japanese_horizontal.imageset/test_hello_hori.png out -l jpn 2>/dev/null

got=$(strip_whitespace out.txt)
want='Hello,世界'

print -n 'test horizontal: '
if [ $got = $want ]; then
  print 'passed'
else
  print "failed; got '$got', want '$want'"
fi

rm -f out.txt
tesseract hello_japanese_vertical.imageset/test_hello_vert.png out -l jpn_vert 2>/dev/null

got=$(strip_whitespace out.txt)
want='Hello,世界'

print -n 'test vertical: '
if [ $got = $want ]; then
  print 'passed'
else
  print "failed; got '$got', want '$want'"
fi

rm -f out.txt