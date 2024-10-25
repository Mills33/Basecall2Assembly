#!/bin/bash


source package b1490e9c-4180-47c9-85c0-bb300845b7be # dorado 0.7.2

reads=${snakemake_input[0]}
model=${snakemake_input[1]}
out=${snakemake_output[0]}
echo "Performing error correction with herro"


dorado correct -m $model $reads > ${out}
