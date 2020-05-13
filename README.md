# Welcome

This project presents you, running macOS, with a single-source-and-run script to:

1. download, build, and locally install all build tools required to build Tesseract OCR
2. download Tesseract OCR, target iOS, and build libraries that you can add to your XCode projects without the need for a dependency/package manager

*Locally install* means that all build artifacts (binaries, libs, etc...) are installed under a single directory, Root.  **su** privileges and mucking with your system are avoided.

## Pre-requisites

Achieving the single-source-and-run goal does require some pre-requisite work on your part.  You must have Xcode 11 and the command-line tools already installed.

### Existing tooling, brew

This project does not attempt to be compatible with any existing tooling you may have installed.  I do not know if brew precludes any of the directions/build-steps, or vice-versa; we do not use brew.

## Kicking it off (Installing)

1. `cd` into the directory that will host the project
2. Clone this repo
       git clone <https://github.com/zacharysyoung/tesseract-build.git> .
3. `cd tesseract-build && Scripts/build.sh`
