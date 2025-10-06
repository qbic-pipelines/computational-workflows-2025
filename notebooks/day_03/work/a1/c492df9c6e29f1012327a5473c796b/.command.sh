#!/usr/bin/env python

from math import log2
from os import path
import pandas as pd
import platform
from sys import exit

# 1. Check that the current logFC/padj is not NA
# 2. Check that the current logFC is >= threshold (abs does not work, so use a workaround)
# 3. Check that the current padj is <= threshold
# If this is true, the row is written to the new file, otherwise not
if not any("condition_control_treated_test.deseq2.results.tsv".endswith(ext) for ext in [".csv", ".tsv", ".txt"]):
    exit("Please provide a .csv, .tsv or .txt file!")

table = pd.read_csv("condition_control_treated_test.deseq2.results.tsv", sep=("," if "condition_control_treated_test.deseq2.results.tsv".endswith(".csv") else "	"), header=0)
logFC_threshold = log2(float("2.0"))
table = table[~table["log2FoldChange"].isna() &
            ~table["padj"].isna() &
            (pd.to_numeric(table["log2FoldChange"], errors='coerce').abs() >= float(logFC_threshold)) &
            (pd.to_numeric(table["padj"], errors='coerce') <= float("0.05"))]

table.to_csv(path.splitext(path.basename("condition_control_treated_test.deseq2.results.tsv"))[0]+"_filtered.tsv", sep="	", index=False)

with open('versions.yml', 'a') as version_file:
    version_file.write('"NFCORE_DIFFERENTIALABUNDANCE:DIFFERENTIALABUNDANCE:FILTER_DIFFTABLE":' + "\n")
    version_file.write("    pandas: " + str(pd.__version__) + "\n")
