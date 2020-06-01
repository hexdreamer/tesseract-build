#! /bin/zsh -f

cp -v \
  ~/dev/tesseract-build/Root/lib/*.a \
  ~/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/dependencies/lib

xcodebuild test \
  -project /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract.xcodeproj \
  -scheme SwiftyTesseract \
  -destination 'platform=iOS Simulator,name=iPhone SE (2nd generation),OS=13.5'