#!/bin/bash -euo pipefail
# Dump .params.yml heredoc (section will be empty if parametrization is disabled)
cat <<"END_PARAMS_SECTION" > ./.params.yml
cpus: 2
artifact_dir: artifacts
input_dir: ./
meta:
  id: study
study_name: study
study_type: rnaseq
study_abundance_type: counts
report_file: !!org.codehaus.groovy.runtime.GStringImpl {}
report_title: null
report_author: null
report_contributors: null
report_description: null
report_scree: true
report_round_digits: 4
observations_type: sample
observations_id_col: sample
observations_name_col: null
features: matrix_as_anno.feature_metadata.tsv
features_type: gene
features_id_col: gene_id
features_name_col: gene_name
features_metadata_cols: gene_id,gene_name,gene_biotype
features_gtf_feature_type: transcript
features_gtf_table_first_field: gene_id
filtering_min_samples: 1.0
filtering_min_abundance: 1.0
filtering_min_proportion: null
filtering_grouping_var: null
filtering_min_proportion_not_na: 0.5
filtering_min_samples_not_na: null
exploratory_main_variable: auto_pca
exploratory_clustering_method: ward.D2
exploratory_cor_method: spearman
exploratory_n_features: 500
exploratory_whisker_distance: 1.5
exploratory_mad_threshold: -5
exploratory_assay_names: raw,normalised,variance_stabilised
exploratory_final_assay: variance_stabilised
exploratory_log2_assays: raw,normalised
exploratory_palette_name: Set1
differential_file_suffix: null
differential_feature_id_column: gene_id
differential_feature_name_column: gene_name
differential_fc_column: log2FoldChange
differential_pval_column: pvalue
differential_qval_column: padj
differential_min_fold_change: 2.0
differential_max_pval: 1.0
differential_max_qval: 0.05
differential_foldchanges_logged: true
differential_palette_name: Set1
differential_subset_to_contrast_samples: false
deseq2_test: Wald
deseq2_fit_type: parametric
deseq2_sf_type: ratio
deseq2_min_replicates_for_replace: 7
deseq2_use_t: false
deseq2_lfc_threshold: 0
deseq2_alt_hypothesis: greaterAbs
deseq2_independent_filtering: true
deseq2_p_adjust_method: BH
deseq2_alpha: 0.1
deseq2_minmu: 0.5
deseq2_vs_method: vst
deseq2_shrink_lfc: true
deseq2_cores: 1
deseq2_vs_blind: true
deseq2_vst_nsub: 1000
gene_sets_files: null
observations: samplesheet.sample_metadata.tsv
raw_matrix: salmon.merged.gene_counts.assay.tsv
normalised_matrix: all.normalised_counts.tsv
variance_stabilised_matrix: all.vst.tsv
contrasts_file: contrasts.contrasts_file.tsv
versions_file: collated_versions.yml
logo: nf-core-differentialabundance_logo_light.png
css: nf-core_style.css
citations: CITATIONS.md
END_PARAMS_SECTION

# Create output directory
mkdir artifacts

# Set parallelism for BLAS/MKL etc. to avoid over-booking of resources
export MKL_NUM_THREADS="2"
export OPENBLAS_NUM_THREADS="2"
export OMP_NUM_THREADS="2"

# Work around  https://github.com/rstudio/rmarkdown/issues/1508
# If the symbolic link is not replaced by a physical file
# output- and temporary files will be written to the original directory.
mv "differentialabundance_report.Rmd" "differentialabundance_report.Rmd.orig"
cp -L "differentialabundance_report.Rmd.orig" "study.Rmd"

# Render notebook
Rscript - <<EOF
    params = yaml::read_yaml('.params.yml')

    # Instead of rendering with params, produce a version of the R
    # markdown with param definitions set, so the notebook itself can
    # be reused
    rmd_content <- readLines('study.Rmd')

    # Extract YAML content between the first two '---'
    start_idx <- which(rmd_content == "---")[1]
    end_idx <- which(rmd_content == "---")[2]
    rmd_yaml_content <- paste(rmd_content[(start_idx+1):(end_idx-1)], collapse = "\n")
    rmd_params <- yaml::yaml.load(rmd_yaml_content)

    # Override the params
    rmd_params[['params']] <- modifyList(rmd_params[['params']], params)

    # Recursive function to add 'value' to list elements, except for top-level
    add_value_recursively <- function(lst, is_top_level = FALSE) {
        if (!is.list(lst)) {
            return(lst)
        }

        lst <- lapply(lst, add_value_recursively)
        if (!is_top_level) {
            lst <- list(value = lst)
        }
        return(lst)
    }

    # Reformat nested lists under 'params' to have a 'value' key recursively
    rmd_params[['params']] <- add_value_recursively(rmd_params[['params']], is_top_level = TRUE)

    # Convert back to YAML string
    updated_yaml_content <- as.character(yaml::as.yaml(rmd_params))

    # Remove the old YAML content
    rmd_content <- rmd_content[-((start_idx+1):(end_idx-1))]

    # Insert the updated YAML content at the right position
    rmd_content <- append(rmd_content, values = unlist(strsplit(updated_yaml_content, split = "\n")), after = start_idx)

    writeLines(rmd_content, 'study.parameterised.Rmd')

    # Render based on the updated file
    rmarkdown::render('study.parameterised.Rmd', output_file='study.html', envir = new.env())
    writeLines(capture.output(sessionInfo()), "session_info.log")
EOF

cat <<-END_VERSIONS > versions.yml
"NFCORE_DIFFERENTIALABUNDANCE:DIFFERENTIALABUNDANCE:RMARKDOWNNOTEBOOK":
    rmarkdown: $(Rscript -e "cat(paste(packageVersion('rmarkdown'), collapse='.'))")
END_VERSIONS
