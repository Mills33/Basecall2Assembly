The following snakefile controls a pipeline designed to take raw ONT data (fast5 or pod5), basecall, error correct and assemble.
It requires the path to the direcotry containing the raw ONT signals, reads, a sample name, paths to herro model and basecalling model you want to use and a path to a reference genome of ideally teh same species or as close as possible to be used during error correction QC.
Parameters are entered into a config file called config.yaml.

In the working directory there should be the following, note it is only the config file that needs to be edited everything else can be left as it is.:

-dependencies directory

-sm_profile directory

-scripts directory

-snakemake file

-config file* needs to be edited

-basecall2assembly.sh


The pipeline is run by :

0. Unzipping pysam.img.zip in the dependancies directory

1. Entering information into the config file:

WD: #Path to working directory
Model_basecall: #Path to basecalling model you want to use
Model_herro: #Path to herro model
Name: #Whatever you want to call your experiment - this will be used as a prefix for output
Raw_ONT: #Path to directory containing raw ONT (either fast5 or Pod5)
Ref: #Path to reference that will be used to assess efficacy of Herro error correction

2. sbatch qc_pipeline.sh


SNAKEFILE

A copy of the snakefile has been commented to better understand what is happening.

configfile: 'config.yaml'
localrules: Basecall2Assembly ## These are the rules which do not need to run on the cluster so do not have a profile for the cluster.


##Overall rule to run pipeline and ensure all the required outputs are generated.

rule Basecall2Assembly:
    input:
        assembly = "Verkko/assembly.fasta",
        pod5 = "POD5/POD5.complete",
        QC = "Results/HerroVsOG.png"
    output:
        finish = "Basecall2Assembly.complete"
    shell:
        "touch Basecall2Assembly.complete"

##Currently Dorado only runs on pod5 this assesses whether your data is pod5 and if it is fast5 it converts it

rule convert_fast5_pod5:
    input:
        signal = config['Raw_ONT'],
    params:
        pr = config['Name']
    output:
        "POD5/POD5.complete"
    script:
        "scripts/convert_to_pod5.sh"

##Basecalls raw ont using a user define model

rule basecall:
    input:
        pod5 = "POD5/POD5.complete", ## For some reason couldnt get it to take just  directory
        model = config['Model_basecall']
    params:
        pr = config['Name'],
        wd = config['WD']
    resources:
        gpu = 1
    output:
        fastq = "Basecalled/Basecalled.fastq"
    script:
        "scripts/basecall.sh"

##Filters fastq produced from basecalling in line with recommendations from Herro paper >10k length >10Q

rule filtering:
    input:
        fastq = "Basecalled/Basecalled.fastq"
    output:
        fastq_filtered = "Filtered/filtered.fastq"
    script:
        "scripts/filter_fastq.sh"


##Takes filtered fastq and uses Herro to error correct

rule error_correction:
    input:
        fastq_filtered = "Filtered/filtered.fastq",
        model = config['Model_herro']
    params:
        pr = config['Name']
    output:
        herro_fasta = "Herro/Error_corrrected.fasta"
    script:
        "scripts/herro.sh"

## First step in QC of error correction maps filtered (but not error corrected) reads to the user specified reference

rule map_OG_fastq_reference:
    input:
        fastq = "Filtered/filtered.fastq",
        ref = config['Ref'],
        wd = config['WD']
    params:
        datatype = "OG_filtered"
    output:
        "Results/OG_filtered_mappings.complete"
    script:
        "scripts/map_to_reference.sh"

## First step in QC of error correction maps error corrected reads to the user specified reference

rule map_Herro_corrected_reference:
    input:
        fasta = "Herro/Error_corrrected.fasta",
        ref = config['Ref'],
        wd = config['WD']
    params:
        datatype = "Herro_corrected"
    output:
        "Results/Herro_corrected_mappings.complete"
    script:
        "scripts/map_to_reference.sh"

##Runs bamconcordance.py to generate QV values for bam from error corrected reads

rule bam_concordance_herro:
    input:
        ref = config['Ref'],
        bam = "Results/Herro_corrected_mappings.complete"
    params:
        datatype = "Herro_corrected",
        wd = config['WD']
    output:
        "Results/Herro_corrected.csv"
    script:
        "scripts/run_bam_concordance.sh"

##Runs bamconcordance.py to generate QV values for bam from filtered but not corrected reads

rule bam_concordance_OG:
    input:
        ref = config['Ref'],
        bam = "Results/OG_filtered_mappings.complete"
    params:
        datatype = "OG_filtered",
        wd = config['WD']
    output:
        "Results/OG_filtered.csv"
    script:
        "scripts/run_bam_concordance.sh"

##Kicks off an R script that generates statistics and a violin plot to compare QV values before and after error correction and see if it was statistically significant.

rule plot_results_error_correction:
    input:
        "Results/Herro_corrected.csv",
        "Results/OG_filtered.csv"
    params:
        pr = config['Name']
    output:
        "Results/HerroVsOG.png",
        "Results/Error_correction_summary.csv"
    script:
        "scripts/compare_error_correction.sh"

##Runs verrko assembler using both error corrected reads and non error corrected reads

rule verkko_assembly:
    input:
        ont = "Filtered/filtered.fastq",
        herro = "Herro/Error_corrrected.fasta"
    params:
        wd = config['WD']
    output:
        "Verkko/assembly.fasta"
    script:
        "scripts/verkko.sh"
