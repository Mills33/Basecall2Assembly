#!/bin/bash

source package e801ab1f-03a5-44b2-9fcd-0d574b671120 # pod5 0.3.6


ont=${snakemake_input[0]}
prefix=${snakemake_params[0]}


mkdir  POD5

if [ $(ls $ont/*pod5 | head -n 1) ]; then
	ln -s $ont/*pod5 POD5/
	touch POD5/POD5.complete
elif [ $(ls $ont/*fast5 | head -n 1) ]; then
	mkdir ${ont}/POD5
	pod5 convert fast5 ${ont}/*.fast5 --threads 16 --output ${ont}/POD5/${prefix}_converted.pod5 && touch POD5/POD5.complete 
	ln -s ${ont}/POD5/${prefix}_converted.pod5 POD5/
else
	echo "Input is incorrect format must be fast5 or pod5" > FAILED_conversion
fi
	
