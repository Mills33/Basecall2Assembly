#!/bin/bash

model=${snakemake_input[1]}
prefix=${snakemake_params[0]}
pod5=${snakemake_params[1]}/POD5
out=Basecalled/Basecalled.fastq

source package b1490e9c-4180-47c9-85c0-bb300845b7be # dorado 0.7.2

dorado basecaller  --emit-fastq $model -r $pod5 > ${out}


