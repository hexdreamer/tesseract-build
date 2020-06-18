#!/bin/zsh -f

scriptpath=$0:A
parentdir=${scriptpath%/*}
scriptname=${scriptpath##*/}
builddir=$parentdir/build

if ! source $builddir/project_environment.sh; then
  echo "build_autoconf.sh: error sourcing $builddir/project_environment.sh"
  exit 1
fi

# Download jpn and jpn_vert files
for langfile in jpn.traineddata jpn_vert.traineddata; do
  if [ -f $ROOT/macos_x86_64/share/tessdata/$langfile ]; then
    continue
  fi

  curl -L -f \
    https://github.com/tesseract-ocr/tessdata_best/raw/master/$langfile \
    --output $ROOT/macos_x86_64/share/tessdata/$langfile
done

export PATH=$ROOT/macos_x86_64/bin:$PATH

# Run tesseract command-line program on a number of sample/test images;

rm out.txt
tesseract $PROJECTDIR/Notes/static/test_5012GI_hori.png out -l jpn 2>/dev/null

got=$(cat out.txt | tr -d '\n' | tr -d '\f' | tr -d ' ')
want='...是有5012GI的話、...'

echo '* tesseract $PROJECTDIR/Notes/static/test_5012GI_hori.png out -l jpn'
if [ $got != $want ]; then
  echo "  Got:  $got"
  echo "  Want: $want"
else
  echo '  passed'
fi

rm out.txt
tesseract $PROJECTDIR/Notes/static/test_hello_hori.png out -l jpn

got=$(cat out.txt | tr -d '\n' | tr -d '\f' | tr -d ' ')
want='Hello,世界'

echo '* tesseract $PROJECTDIR/Notes/static/test_hello_hori.png out -l jpn'
if [ $got != $want ]; then
  echo "  Got:  $got"
  echo "  Want: $want"
else
  echo '  passed'
fi

rm out.txt
tesseract $PROJECTDIR/Notes/static/test_5012GI_vert.png out -l jpn_vert

got=$(cat out.txt | tr -d '\n' | tr -d '\f' | tr -d ' ')
want='...是有5012GI的話、...'

echo '* tesseract $PROJECTDIR/Notes/static/test_5012GI_vert.png out -l jpn_vert'
if [ $got != $want ]; then
  echo "  Got:  $got"
  echo "  Want: $want"
else
  echo '  passed'
fi

rm out.txt
tesseract $PROJECTDIR/Notes/static/test_hello_vert_1.png out -l jpn_vert

got=$(cat out.txt | tr -d '\n' | tr -d '\f' | tr -d ' ')
want='Hello,世界'

echo '* tesseract $PROJECTDIR/Notes/static/test_hello_vert_1.png out -l jpn_vert'
if [ $got != $want ]; then
  echo "  Got:  $got"
  echo "  Want: $want"
else
  echo '  passed'
fi

rm out.txt
tesseract $PROJECTDIR/Notes/static/test_hello_vert_2.png out -l jpn_vert

got=$(cat out.txt | tr -d '\n' | tr -d '\f' | tr -d ' ')
want='Hello,世界'

echo '* tesseract $PROJECTDIR/Notes/static/test_hello_vert_2.png out -l jpn_vert'
if [ $got != $want ]; then
  echo "  Got:  $got"
  echo "  Want: $want"
else
  echo '  passed'
fi