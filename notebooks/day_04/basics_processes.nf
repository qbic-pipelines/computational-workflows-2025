params.step = 0
params.zip = 'zip'

// Task 1 - create a process that says Hello World! (add debug true to the process right after initializing to be sable to print the output to the console)
process SAYHELLO {
    debug true
    script:
    """
    echo 'Hello world!'
    """
}

// Task 2 - create a process that says Hello World! using Python
process SAYHELLO_PYTHON {
    debug true
    script:
    """
    python3 -c "print('Hello world!')"
    """
}

// Task 3 - create a process that reads in the string "Hello world!" from a channel and write it to command line
process SAYHELLO_PARAM {
    debug true

    input:
    val greeting_ch
    
    script:
    """
    echo ${greeting_ch}
    """
}

// Task 4 - create a process that reads in the string "Hello world!" from a channel and write it to a file. 
// WHERE CAN YOU FIND THE FILE?
process SAYHELLO_FILE {
    debug true

    input:
    val greeting_ch
    
    output:
    path 'greeting.txt'

    script:
    """
    echo ${greeting_ch} > greeting.txt
    """
}

// Task 5 - create a process that reads in a string and converts it to uppercase and saves it to a file as output. 
// View the path to the file in the console
process UPPERCASE {
    debug true

    input:
    val greeting_ch
    
    output:
    path 'uppercase.txt'

    script:
    """
    echo ${greeting_ch} | tr '[:lower:]' '[:upper:]' > uppercase.txt
    """
}

// Task 6 - add another process that reads in the resulting file from UPPERCASE 
// and print the content to the console (debug true). WHAT CHANGED IN THE OUTPUT?
process PRINTUPPER {
    debug true

    input:
    path upperfile_ch
    
    script:
    """
    cat ${upperfile_ch}
    """
}

// Task 7 - based on the paramater "zip" (see at the head of the file), 
//          create a process that zips the file created in the UPPERCASE process either in "zip", "gzip" OR "bzip2" format.
//          Print out the path to the zipped file in the console
process ZIPFILE {
    debug true

    input:
    path upperfile_ch

    output:
    path 'uppercase.*'

    script:
    """
    if [ "${params.zip}" = "zip" ]; then
        zip -j uppercase.zip "${upperfile_ch}"
        echo "Created file: uppercase.zip"
    elif [ "${params.zip}" = "gzip" ]; then
        gzip -c "${upperfile_ch}" > uppercase.gz
        echo "Created file: uppercase.gz"
    elif [ "${params.zip}" = "bzip2" ]; then
        bzip2 -c "${upperfile_ch}" > uppercase.bz2
        echo "Created file: uppercase.bz2"
    else
        echo "Unknown compression format: ${params.zip}"
        exit 1
    fi
    """
}


// Task 8 - Create a process that zips the file created in the UPPERCASE process in 
// "zip", "gzip" AND "bzip2" format. Print out the paths to the zipped files in the console
process ZIP_VARIANTS {
    debug true

    input:
    path upperfile_ch

    output:
    path 'uppercase.*'

    script:
    """
    zip -j uppercase.zip "${upperfile_ch}"
    echo "Created file: uppercase.zip"

    gzip -c "${upperfile_ch}" > uppercase.gz
    echo "Created file: uppercase.gz"

    bzip2 -c "${upperfile_ch}" > uppercase.bz2
    echo "Created file: uppercase.bz2"
    """
}

// Task 9 - Create a process that reads in a list of names and titles from a channel and writes them to a file.
//          Store the file in the "results" directory under the name "names.tsv"
process WRITETOFILE {
    debug true

    input:
    val person_ch

    output:
    path 'results/names.tsv'

    script:
    """
    mkdir -p results
    echo -e "name\ttitle" > results/names.tsv
    echo -e "${person_ch.name}\t${person_ch.title}" >> results/names.tsv
    """
}



//publishDir "/delta/chunkc"
//still need output declaration
//only puts specified outputs to the publishDir





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
        file_ch = SAYHELLO_FILE(greeting_ch)
        out_ch = ZIPFILE(file_ch)
        out_ch.view()
    }

    // Task 8 - Create a process that zips the file created in the UPPERCASE process in "zip", "gzip" AND "bzip2" format. Print out the paths to the zipped files in the console

    if (params.step == 8) {
        greeting_ch = Channel.of("Hello world!")
        file_ch = SAYHELLO_FILE(greeting_ch)
        out_ch = ZIP_VARIANTS(file_ch)
        out_ch.view()
    }

    // Task 9 - Create a process that reads in a list of names and titles from a channel and writes them to a file.
    //          Store the file in the "results" directory under the name "names.tsv"

    if (params.step == 9) {
        in_ch = channel.of(
            ['name': 'Harry', 'title': 'student'],
            ['name': 'Ron', 'title': 'student'],
            ['name': 'Hermione', 'title': 'student'],
            ['name': 'Albus', 'title': 'headmaster'],
            ['name': 'Snape', 'title': 'teacher'],
            ['name': 'Hagrid', 'title': 'groundkeeper'],
            ['name': 'Dobby', 'title': 'hero'],
        )

        WRITETOFILE(in_ch)
    }

}