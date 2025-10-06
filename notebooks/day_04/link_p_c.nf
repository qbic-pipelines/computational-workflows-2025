#!/usr/bin/env nextflow

process SPLITLETTERS {
    publishDir 'results', mode: 'copy'
    
    input:
    tuple val(meta), val(input_str), val(out_name)
    
    output:
    path "chunk_*.txt"
    
    script:
    def block_size = meta.block_size
    """
    #!/usr/bin/env python3
    
    input_str = "${input_str}"
    block_size = ${block_size}
    out_name = "${out_name}"
    
    # Split string into chunks
    chunks = [input_str[i:i+block_size] for i in range(0, len(input_str), block_size)]
    
    # Write each chunk to a separate file
    for i, chunk in enumerate(chunks):
        with open(f"chunk_{out_name}_{i+1}.txt", "w") as f:
            f.write(chunk)
    """
} 

process CONVERTTOUPPER {
    publishDir 'results', mode: 'copy'
    
    input:
    path chunk_file
    
    output:
    path "upper_*.txt"
    
    script:
    """
    cat ${chunk_file} | tr '[:lower:]' '[:upper:]' > upper_${chunk_file}
    """
} 

workflow { 
    // 1. Read in the samplesheet (samplesheet_2.csv)  into a channel. The block_size will be the meta-map
    // 2. Create a process that splits the "in_str" into sizes with size block_size. The output will be a file for each block, named with the prefix as seen in the samplesheet_2
    // 4. Feed these files into a process that converts the strings to uppercase. The resulting strings should be written to stdout

    // read in samplesheet
    samplesheet_ch = Channel.fromPath('samplesheet_2.csv')
        | splitCsv(header: true)
        | map { row ->
            def meta = [block_size: row.block_size as Integer]
            return [meta, row.input_str, row.out_name]
        }

    // split the input string into chunks
    chunk_files_ch = SPLITLETTERS(samplesheet_ch)

    // lets remove the metamap to make it easier for us, as we won't need it anymore
    chunk_files_ch
        | flatten
        | CONVERTTOUPPER

    // convert the chunks to uppercase and save the files to the results directory
}