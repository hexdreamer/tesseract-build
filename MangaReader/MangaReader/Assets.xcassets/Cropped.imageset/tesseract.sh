#! /bin/zsh -f

tesseract cropped2.jpg stdout -l jpn_vert --dpi 72 \
    -c tessedit_display_outwords=1 \
    -c tessedit_dump_pageseg_images=1 \
    -c tessedit_write_images=1 \
    -c textord_debug_tabfind=1 \
    -c textord_show_final_blobs=1 \
    -c textord_show_initial_words=1 \
    -c textord_show_new_words=1 \
    -c textord_tabfind_show_images=1 \
    -c textord_tabfind_show_partitions=1 \
    -c textord_tablefind_show_mark=1 \
    -c textord_tablefind_show_stats=1 \
    -c wordrec_display_segmentations=1 \
    -c wordrec_display_splits=1 \