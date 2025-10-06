params.step = 0
params.zip = 'zip'


process SAYHELLO {
    debug true

    script:
    """
    echo "Hello World!"
    """
}

process SAYHELLO_PYTHON {
    debug true
    
    script:
    """
    python3 -c "print('Hello World!')"
    """
}

process SAYHELLO_PARAM {
    debug true
    
    input:
    val greeting
    
    script:
    """
    echo "$greeting"
    """
}

process SAYHELLO_FILE {
    publishDir 'results', mode: 'copy'
    
    input:
    val greeting
    
    output:
    path "output.txt"
    
    script:
    """
    echo "$greeting" > output.txt
    """
}

process UPPERCASE {
    input:
    val text
    
    output:
    path "uppercase.txt"
    
    script:
    """
    echo "$text" | tr '[:lower:]' '[:upper:]' > uppercase.txt
    """
}

process PRINTUPPER {
    debug true
    
    input:
    path inputfile
    
    script:
    """
    cat $inputfile
    """
}

process COMPRESS {
    input:
    path inputfile
    val format
    
    output:
    path "compressed.*"
    
    script:
    if (format == "zip")
        """
        zip compressed.zip $inputfile
        """
    else if (format == "gzip")
        """
        gzip -c $inputfile > compressed.gz
        """
    else if (format == "bzip2")
        """
        bzip2 -c $inputfile > compressed.bz2
        """
}

process COMPRESS_ALL {
    input:
    path inputfile
    
    output:
    path "compressed.*"
    
    script:
    """
    zip compressed.zip $inputfile
    gzip -c $inputfile > compressed.gz
    bzip2 -c $inputfile > compressed.bz2
    """
}

process WRITETOFILE {
    publishDir 'results', mode: 'copy'
    
    input:
    val records
    
    output:
    path "names.tsv"
    
    script:
    def lines = records.collect { "${it.name}\t${it.title}" }.join('\n')
    """
    echo -e "name\\ttitle" > names.tsv
    echo -e "$lines" >> names.tsv
    """
}

workflow {

    // Task 1 - create a process that says Hello World! (add debug true to the process right after initializing to be sable to print the output to the console)
    if (params.step == 1) {
        SAYHELLO()
    }

    // Task 2 - create a process that says Hello World! using Python
    if (params.step == 2) {
        SAYHELLO_PYTHON()
    }

    // Task 3 - create a process that reads in the string "Hello world!" from a channel and write it to command line
    if (params.step == 3) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_PARAM(greeting_ch)
    }

    // Task 4 - create a process that reads in the string "Hello world!" from a channel and write it to a file. WHERE CAN YOU FIND THE FILE?
    if (params.step == 4) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_FILE(greeting_ch)
    }

    // Task 5 - create a process that reads in a string and converts it to uppercase and saves it to a file as output. View the path to the file in the console
    if (params.step == 5) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        out_ch.view()
    }

    // Task 6 - add another process that reads in the resulting file from UPPERCASE and print the content to the console (debug true). WHAT CHANGED IN THE OUTPUT?
    if (params.step == 6) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        PRINTUPPER(out_ch)
    }

    
    // Task 7 - based on the paramater "zip" (see at the head of the file), create a process that zips the file created in the UPPERCASE process either in "zip", "gzip" OR "bzip2" format.
    //          Print out the path to the zipped file in the console
    if (params.step == 7) {
        greeting_ch = Channel.of("Hello world!")
        uppercase_ch = UPPERCASE(greeting_ch)
        compressed_ch = COMPRESS(uppercase_ch, params.zip)
        compressed_ch.view()
    }

    // Task 8 - Create a process that zips the file created in the UPPERCASE process in "zip", "gzip" AND "bzip2" format. Print out the paths to the zipped files in the console

    if (params.step == 8) {
        greeting_ch = Channel.of("Hello world!")
        uppercase_ch = UPPERCASE(greeting_ch)
        compressed_ch = COMPRESS_ALL(uppercase_ch)
        compressed_ch.view()
    }

    // Task 9 - Create a process that reads in a list of names and titles from a channel and writes them to a file.
    //          Store the file in the "results" directory under the name "names.tsv"

    if (params.step == 9) {
        in_ch = Channel.of(
            ['name': 'Harry', 'title': 'student'],
            ['name': 'Ron', 'title': 'student'],
            ['name': 'Hermione', 'title': 'student'],
            ['name': 'Albus', 'title': 'headmaster'],
            ['name': 'Snape', 'title': 'teacher'],
            ['name': 'Hagrid', 'title': 'groundkeeper'],
            ['name': 'Dobby', 'title': 'hero'],
        )

        in_ch
            | collect
            | WRITETOFILE
    }

}