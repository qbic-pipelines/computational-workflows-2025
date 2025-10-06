params.step = 0


workflow{

    // Task 1 - Extract the first item from the channel

    if (params.step == 1) {
        in_ch = channel.of(1,2,3)
        out_ch = in_ch.first()
        out_ch.view()

    }

    // Task 2 - Extract the last item from the channel
    
    if (params.step == 2) {

        in_ch = channel.of(1,2,3)
        out_ch = in_ch.last()
        out_ch.view()

    }

    // Task 3 - Use an operator to extract the first two items from the channel

    if (params.step == 3) {

        in_ch = channel.of(1,2,3)

        out_ch = in_ch.take(2)
        out_ch.view()



    }

    // Task 4 - Return the squared values of the channel
    
    if (params.step == 4) {

        in_ch = channel.of(2,3,4)
        out_ch = in_ch.map{i -> i * i}
        out_ch.view()

    }

    // Task 5 - Remember the previous task where you squared the values of the channel. Now, extract the first two items from the squared channel

    if (params.step == 5) {

        in_ch = channel.of(2,3,4)
        out_ch = in_ch.map {i -> i *i}
        out_ch = out_ch.take(2)
        out_ch.view()
        
    }

    // Task 6 - Remember when you used bash to reverse the output? Try to use map and Groovy to reverse the output

    if (params.step == 6) {
        
        in_ch = channel.of('Taylor', 'Swift')
        out_ch = in_ch.map { it.reverse()}
        out_ch.view()
        
    }

    // Task 7 - Use fromPath to include all fastq files in the "files_dir" directory, then use map to return a pair containing the file name and the file path (Hint: include groovy code)

    if (params.step == 7) {

        in_ch = channel.fromPath('files_dir/*.fq')
        out_ch = in_ch.map { i -> [i.getName(), i]}
        out_ch.view()


        
    }

    // Task 8 - Combine the items from the two channels into a single channel

    if (params.step == 8) {

        ch_1 = channel.of(1,2,3)
        ch_2 = channel.of(4,5,6)
        out_ch = channel.of("a", "b", "c")
        ch_1and2 = ch_1.concat(ch_2)
        out_ch = out_ch.concat(ch_1and2)
        out_ch.view()

    }

    // Task 9 - Flatten the channel

    if (params.step == 9) {

        in_ch = channel.of([1,2,3], [4,5,6])
        out_ch = in_ch.flatten()
        out_ch.view()



    }

    // Task 10 - Collect the items of a channel into a list. What kind of channel is the output channel (value)?

    if (params.step == 10) {

        in_ch = channel.of(1,2,3)
        out_ch = in_ch.collect()
        out_ch.view()
        // The output channel is a list channel

    }
    


    // Task 11 -  From the input channel, create lists where each first item in the list of lists is the first item in the output channel, followed by a list of all the items its paired with
    // e.g. 
    // in: [[1, 'A'], [1, 'B'], [1, 'C'], [2, 'D'], [2, 'E'], [3, 'F']]
    // out: [[1, ['A', 'B', 'C']], [2, ['D', 'E']], [3, ['F']]]

    if (params.step == 11) {

        in_ch = channel.of([1, 'V'], [3, 'M'], [2, 'O'], [1, 'f'], [3, 'G'], [1, 'B'], [2, 'L'], [2, 'E'], [3, '33'])
        out_ch = in_ch.groupTuple()
        out_ch.view()

    }

    // Task 12 - Create a channel that joins the input to the output channel. What do you notice

    if (params.step == 12) {

        left_ch = channel.of([1, 'V'], [3, 'M'], [2, 'O'], [1, 'B'], [3, '33'])
        right_ch = channel.of([1, 'f'], [3, 'G'], [2, 'L'], [2, 'E'],)
        out_ch = left_ch.join(right_ch)
        out_ch.view()


    }

    // Task 13 - Split the input channel into two channels, one of all the even numbers and the other of all the odd numbers. Write the output of each channel to a list
    //           and write them to stdout including information which is which

    if (params.step == 13) {

        in_ch = channel.of(1,2,3,4,5,6,7,8,9,10)
        
        (even_ch, odd_ch) = in_ch.branch {
            even: it % 2 == 0
            odd: it % 2 == 1
        }
            
        even_ch.collect().view { "Even numbers: $it" }
        odd_ch.collect().view { "Odd numbers: $it" }

    }

    // Task 14 - Nextflow has the concept of maps. Write the names in the maps in this channel to a file called "names.txt". Each name should be on a new line. 
    //           Store the file in the "results" directory under the name "names.txt"

    if (params.step == 14) {

        in_ch = channel.of(
            ['name': 'Harry', 'title': 'student'],
            ['name': 'Ron', 'title': 'student'],
            ['name': 'Hermione', 'title': 'student'],
            ['name': 'Albus', 'title': 'headmaster'],
            ['name': 'Snape', 'title': 'teacher'],
            ['name': 'Hagrid', 'title': 'groundkeeper'],
            ['name': 'Dobby', 'title': 'hero'],
        )
        
        names_ch = in_ch.map { it.name }
        names_ch.collectFile(name: 'results/names.txt', newLine: true)
    
    }


}