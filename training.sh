#!/bin/bash

tesseract engg.arial.exp0.png engg.arial.exp0 nobatch box.train

unicharset_extractor engg.arial.exp0.box

# font name <italic> <bold> <fixed> <serif> <fraktur>
echo "arial 0 0 0 0 0" > font_properties

shapeclustering -F font_properties -U unicharset engg.arial.exp0.tr

mftraining -F font_properties -U unicharset -O engg.unicharset 
    engg.arial.exp0.tr

    cntraining engg.arial.exp0.tr


    # prefix "relevant" files with our language code
    mv inttemp engg.inttemp
    mv normproto engg.normproto
    mv pffmtable engg.pffmtable
    mv shapetable engg.shapetable
    combine_tessdata engg.

    # copy the created engg.traineddata to the tessdata folder
    # so tesseract is able to find it
