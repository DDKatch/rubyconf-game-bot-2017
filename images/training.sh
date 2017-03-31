#!/bin/bash

tesseract ezz.font.exp0.png ezz.font.exp0 box.train

unicharset_extractor ezz.font.exp0.box

# font name <italic> <bold> <fixed> <serif> <fraktur>
echo "font 0 0 0 0 0" > font_properties

shapeclustering -F font_properties -U unicharset ezz.font.exp0.tr

mftraining -F font_properties -U unicharset -O ezz.unicharset ezz.font.exp0.tr

cntraining ezz.font.exp0.tr

# prefix "relevant" files with our lazzuage code
mv inttemp ezz.inttemp
mv normproto ezz.normproto
mv pffmtable ezz.pffmtable
mv shapetable ezz.shapetable
combine_tessdata ezz.

# copy the created ezz.traineddata to the tessdata folder
# so tesseract is able to find it
