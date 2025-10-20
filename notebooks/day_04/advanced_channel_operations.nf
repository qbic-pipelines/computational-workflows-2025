params.step = 0


workflow{

    // Task 1 - Read in the samplesheet.

    if (params.step == 1) {
        channel.fromPath('samplesheet.csv')
            .splitCsv(header:true)
            .map { row -> row.collect{ it.value } }
            .set { in_ch }  
    }

    // Task 2 - Read in the samplesheet and create a meta-map with all metadata and another list with the filenames ([[metadata_1 : metadata_1, ...], [fastq_1, fastq_2]]).
    //          Set the output to a new channel "in_ch" and view the channel. YOU WILL NEED TO COPY AND PASTE THIS CODE INTO SOME OF THE FOLLOWING TASKS (sorry for that).

    if (params.step == 2) {
        channel.fromPath('samplesheet.csv')
            .splitCsv(header:true)
            .map { row -> [ row.collect{ it.value }, [ row.sample_id, row.fastq_1, row.fastq_2 ] ] }
            .set { in_ch }  
        in_ch.view()            
    }

    // Task 3 - Now we assume that we want to handle different "strandedness" values differently. 
    //          Split the channel into the right amount of channels and write them all to stdout so that we can understand which is which.

    if (params.step == 3) {
        def in_samplesheet = Channel
            .fromPath('samplesheet.csv')
            .splitCsv(header: true)
            .map { row ->
                def meta = row.collectEntries { [it.key, it.value] }
                def files = [row.sample_id, row.fastq_1, row.fastq_2]
                [meta, files]
            }

        def grouped_ch = in_samplesheet.groupTuple()

        grouped_ch.map { metas, filesList ->
            println "Metadaten:"
            metas.each { println "\t$it" }

            println "File-Listen:"
            filesList.each { println "\t$it" }
        }.collect()         
    }

    // Task 4 - Group together all files with the same sample-id and strandedness value.

    if (params.step == 4) {
        def in_samplesheet = Channel
            .fromPath('samplesheet.csv')
            .splitCsv(header: true)
            .map { row ->
                def meta = row.collectEntries { [it.key, it.value] }
                def files = [row.sample_id, row.fastq_1, row.fastq_2]
                [meta, files]
            }

        def grouped_ch = in_samplesheet.groupTuple()

        grouped_ch.map { metas, filesList ->
            println "Metadaten:"
            metas.each { println "\t$it" }

            println "File-Listen:"
            filesList.each { println "\t$it" }
        }.collect()         
        
    }



}