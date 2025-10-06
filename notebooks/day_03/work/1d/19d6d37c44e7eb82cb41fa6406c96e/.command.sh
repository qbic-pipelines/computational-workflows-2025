#!/bin/bash -euo pipefail
exploratory_plots.R \
    --sample_metadata "samplesheet.sample_metadata.tsv" \
    --feature_metadata "matrix_as_anno.feature_metadata.tsv" \
    --assay_files "salmon.merged.gene_counts.assay.tsv,all.normalised_counts.tsv,all.vst.tsv" \
    --contrast_variable "Condition" \
    --outdir "Condition" \
    --sample_id_col "sample" --feature_id_col "gene_id" --assay_names "raw,normalised,variance_stabilised" --final_assay "variance_stabilised" --outlier_mad_threshold -5 --palette_name "Set1" --log2_assays "raw,normalised"

cat <<-END_VERSIONS > versions.yml
"NFCORE_DIFFERENTIALABUNDANCE:DIFFERENTIALABUNDANCE:PLOT_EXPLORATORY":
    r-shinyngs: $(Rscript -e "library(shinyngs); cat(as.character(packageVersion('shinyngs')))")
END_VERSIONS
