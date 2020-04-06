#!/bin/bash
inotifywait -m /home/mcs/snapServer/runtime/"Mineland v1"/stats -e create -e moved_to |
    while read dir action file; do
        echo "The file '$file' appeared in directory '$dir' via '$action'"
        # do something with the file
    done
