#!/bin/bash

function todec()
{
if read -t 0; then
        echo "ibase=16; $(cat)" | bc
else
        echo "ibase=16; $*" | bc
fi
}

