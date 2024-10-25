#!/bin/bash
#SBATCH -p ei-medium# partition (queue)
#SBATCH -c 1
#SBATCH --mem 2G # memory pool for all cores
#SBATCH -t 07-00:00 # time (D-HH:MM)
#SBATCH -o slurm.%N.%j.out # STDOUT
#SBATCH -e slurm.%N.%j.err # STDERR
#SBATCH --mail-type=END,FAIL # notifications for job done & fail
#SBATCH --mail-user=camilla.ryan@earlham.ac.uk # send-to add

source activate snakemake

snakemake --workflow-profile sm_profile --rerun-triggers=mtime  Basecall2Assembly.complete


source deactivate
