#!/bin/bash -euo pipefail
make_app_from_files.R \
    --sample_metadata samplesheet.sample_metadata.tsv \
    --feature_metadata matrix_as_anno.feature_metadata.tsv \
    --assay_files salmon.merged.gene_counts.assay.tsv,all.normalised_counts.tsv,all.vst.tsv \
    --contrast_file contrasts.csv \
    --contrast_stats_assay 3 \
    --differential_results condition_control_treated.deseq2.results.tsv,condition_control_treated_test.deseq2.results.tsv \
    --output_dir study \
    --assay_names "raw,normalised,variance_stabilised" --sample_id_col "sample" --feature_id_col "gene_id" --feature_name_col "gene_name" --diff_feature_id_col "gene_id" --fold_change_column "log2FoldChange" --pval_column "pvalue" --qval_column "padj" --unlog_foldchanges "true"    --guess_unlog_matrices \

cat <<-END_VERSIONS > versions.yml
"NFCORE_DIFFERENTIALABUNDANCE:DIFFERENTIALABUNDANCE:SHINYNGS_APP":
    r-shinyngs: $(Rscript -e "library(shinyngs); cat(as.character(packageVersion('shinyngs')))")
END_VERSIONS
