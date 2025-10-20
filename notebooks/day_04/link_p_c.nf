#!/usr/bin/env nextflow

process SPLITLETTERS {
    // 2. Create a process that splits the "in_str" into sizes with size block_size. 
    // The output will be a file for each block, named with the prefix as seen in the samplesheet_2
    
    debug true
    
    input:
    tuple val(meta), val(in_str)
    
    output:
    path "chunk_*.txt"
    
    script:
    """
    echo "Processing: ${in_str} with block_size: ${meta.block_size}"
    echo "${in_str}" | fold -w ${meta.block_size} | split -l 1 - chunk_ --numeric-suffixes --suffix-length=3
    for file in chunk_*; do
        echo "Created file: \$file with content:"
        cat \$file | od -c  # Shows actual characters including nulls
        mv \$file \${file}.txt
    done
    """
}

process CONVERTTOUPPER {
    // 4. Feed these files into a process that converts the strings to uppercase. 
    // The resulting strings should be written to stdout
    debug true
    publishDir "results", mode: 'copy'
    
    input:
    path chunk_file
    
    output:
    path "upper_${chunk_file}"
    
    script:
    """
    tr '[:lower:]' '[:upper:]' < ${chunk_file} > upper_${chunk_file}
    cat upper_${chunk_file}
    """
} 


workflow { 
if (params.step == 1) {
   
    // 1. Read in the samplesheet (samplesheet_2.csv)  into a channel. The block_size will be the meta-map
    channel.fromPath('samplesheet_2.csv')
            .splitCsv(header: true, sep: ',')  
            .map { row -> 
                def meta = [block_size: row.block_size as Integer]
                return [meta, row.input_str]  // Use the actual column name
            }
            .set { input_ch }

        
    input_ch.view { "Input channel: $it" }  // Debug line
    
    

    // 2. Create a process that splits the "in_str" into sizes with size block_size. The output will be a file for each block,
    //    named with the prefix as seen in the samplesheet_2
    SPLITLETTERS(input_ch)


    // 4. Feed these files into a process that converts the strings to uppercase. 
    //    The resulting strings should be written to stdout

    // read in samplesheet


    // split the input string into chunks

    // lets remove the metamap to make it easier for us, as we won't need it anymore
    chunks_ch = SPLITLETTERS.out.flatten()
    // convert the chunks to uppercase and save the files to the results directory
    CONVERTTOUPPER(chunks_ch)

}

if (params.step == 2) {
        
    // 1. Samplesheet einlesen
    def in_samplesheet = Channel
        .fromPath('samplesheet.csv')
        .splitCsv(header: true)
        .map { row ->
            def meta = row.collectEntries { k,v ->
                // block_size optional auf 1000, wird aber jetzt ignoriert
                [k,v]
            }
            def files = [row.sample_id, row.fastq_1, row.fastq_2]
            [meta, files]
        }

    // 2. SPLITLETTERS Prozess – jetzt nur ein "Chunk" pro Datei
    def split_ch = SPLITLETTERS(in_samplesheet)

    // 3. CONVERTTOUPPER Prozess – nur eine Datei pro Sample
    CONVERTTOUPPER(split_ch)
}

}