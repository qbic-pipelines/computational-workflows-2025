#!/bin/bash -ue
zip compressed.zip uppercase.txt
gzip -c uppercase.txt > compressed.gz
bzip2 -c uppercase.txt > compressed.bz2
