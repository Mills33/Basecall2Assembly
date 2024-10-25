#!/bin/bash

fastq=${snakemake_input[0]}
out=${snakemake_output[0]}

source package 46a62eca-4f8f-45aa-8cc2-d4efc99dd9c6 # seqkit 0.12.0


seqkit seq -m 10000 -Q 10 $fastq -o $out


