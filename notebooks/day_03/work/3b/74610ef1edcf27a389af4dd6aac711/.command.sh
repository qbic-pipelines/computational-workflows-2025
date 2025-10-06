#!/bin/bash -euo pipefail
validate_fom_components.R \
    --sample_metadata "salmon.merged.gene_counts.tsv" \
    --feature_metadata 'matrix_as_anno.csv' \
    --assay_files "samplesheet.csv" \
    --contrasts_file "contrasts.csv" \
    --output_directory "study" \
    --sample_id_col 'sample' --feature_id_col 'gene_id'

cat <<-END_VERSIONS > versions.yml
"NFCORE_DIFFERENTIALABUNDANCE:DIFFERENTIALABUNDANCE:VALIDATOR":
    r-base: $(echo $(R --version 2>&1) | sed 's/^.*R version //; s/ .*$//')
    r-shinyngs: $(Rscript -e "library(shinyngs); cat(as.character(packageVersion('shinyngs')))")
END_VERSIONS
