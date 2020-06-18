# Vertical Scripts, Tesseract

This CL program has a number of options that can significantly impact how well text is recognized in the image.

There's a lot of technical consideration that goes into the rendering of CJK fonts/scripts vertically:

- <https://www.w3.org/TR/jlreq/>
- <https://www.w3.org/International/tests/repo/results/writing-mode-vertical>
- <https://www.w3.org/International/articles/vertical-text/>

And for background on East Asian scripts:

- <https://en.wikipedia.org/wiki/CJK_Unified_Ideographs>
- <https://en.wikipedia.org/wiki/Horizontal_and_vertical_writing_in_East_Asian_scripts>

## Manga and OCR

Someone created a Japanese vertical traineddata file expressly for Manga, <https://github.com/zodiac3539/jpn_vert?files=1>.
