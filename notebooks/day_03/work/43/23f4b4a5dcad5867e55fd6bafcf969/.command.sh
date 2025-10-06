#!/bin/bash -euo pipefail
differential_plots.R \
    --differential_file "condition_control_treated.deseq2.results.tsv" \
    --feature_metadata "matrix_as_anno.feature_metadata.tsv" \
    --outdir "condition_control_treated" \
    --feature_id_col "gene_id" --reference_level "SNI_Sal" --treatment_level "SNI_oxy" --fold_change_col "log2FoldChange" --p_value_column "padj" --diff_feature_id_col "gene_id" --fold_change_threshold "2.0" --p_value_threshold "0.05" --unlog_foldchanges "true" --palette_name "Set1"

cat <<-END_VERSIONS > versions.yml
"NFCORE_DIFFERENTIALABUNDANCE:DIFFERENTIALABUNDANCE:PLOT_DIFFERENTIAL":
    r-base: $(echo $(R --version 2>&1) | sed 's/^.*R version //; s/ .*$//')
    r-shinyngs: $(Rscript -e "library(shinyngs); cat(as.character(packageVersion('shinyngs')))")
END_VERSIONS
