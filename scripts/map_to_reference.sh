#!/bin/bash

source package c92263ec-95e5-43eb-a527-8f1496d56f1a # samtools-1.18
source package minimap2-2.21

reads=${snakemake_input[0]}
ref=${snakemake_input[1]}
wd=${snakemake_input[2]}
datatype=${snakemake_params[0]}
out=Results/${datatype}

minimap2 -a -Q --eqx --secondary=no -I9G -K8G -t 32 $ref $reads | samtools view -Sb -@32 > ${out}_mappings.bam

samtools sort -@32 ${out}_mappings.bam -o ${out}_mappings_sorted.bam
samtools index -@32 ${out}_mappings_sorted.bam && touch ${out}_mappings.complete





