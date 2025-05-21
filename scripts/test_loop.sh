#!/bin/bash

echo "List of files in the current directory:"

for item in *
do 
    if [ -f "$item" ]; then
        echo "File: $item"
    elif [ -d "$item" ]
        echo "Directory: $item"
    if
done

echo ""
echo "Numbers from 1 to 3"

for i in 1 2 3 
do
    echo "Number: $i"
done

echo ""
echo "Numbers from 5 to 7 (using seq expr):"
for i in {5..7} 
do
    echo "Number: $i"
done



