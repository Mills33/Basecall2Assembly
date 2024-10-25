#!/bin/bash


ref=${snakemake_input[0]}
datatype=${snakemake_params[0]}
bam=Results/${datatype}_mappings_sorted.bam
wd=${snakemake_params[1]}
out=Results/${datatype}

singularity instance start --overlay ${wd}/dependencies/python3_pysam.img /software/1413a4f0-44e3-4b9d-b6c6-0f5c0048df88/1413a4f0-44e3-4b9d-b6c6-0f5c0048df88.img $datatype

singularity exec --overlay ${wd}/dependencies/python3_pysam.img /software/1413a4f0-44e3-4b9d-b6c6-0f5c0048df88/1413a4f0-44e3-4b9d-b6c6-0f5c0048df88.img python3 scripts/bamConcordance.py $ref ${bam} ${out}.csv

singularity instance stop $datatype
