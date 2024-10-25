

sconfigfile: 'config.yaml'
localrules: Basecall2Assembly

rule Basecall2Assembly:
    input:
        assembly = "Verkko/assembly.fasta",
        pod5 = "POD5/POD5.complete",
        QC = "Results/HerroVsOG.png"
    output:
        finish = "Basecall2Assembly.complete"
    shell:
        "touch Basecall2Assembly.complete"

rule convert_fast5_pod5:
    input:
        signal = config['Raw_ONT'],
    params:
        pr = config['Name']
    output:
        "POD5/POD5.complete"
    script:
        "scripts/convert_to_pod5.sh"

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

rule filtering:
    input:
        fastq = "Basecalled/Basecalled.fastq"
    output:
        fastq_filtered = "Filtered/filtered.fastq"
    script:
        "scripts/filter_fastq.sh"

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
