#!/bin/bash

source activate verkko

ont=${snakemake_input[0]}
herro=${snakemake_input[1]}
directory=${snakemake_params[0]}/Verkko

verkko -d ${directory} --hifi ${herro} --nano ${ont} --local-memory 200 --local-cpus 8 --mbg-run 8 160 10

source deactivate



