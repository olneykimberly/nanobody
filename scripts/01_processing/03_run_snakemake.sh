#!/bin/bash
#SBATCH --job-name=nanobody                                                              
#SBATCH --time=36:00:00                               
#SBATCH --mem=1G
#SBATCH -n 1 # threaded 
#SBATCH --cpus-per-task=1
#SBATCH -o slurm.nanobody.job.%j.out
#SBATCH -e slurm.nanobody.job.%j.err

# activate conda environment
source $HOME/.bash_profile
module load python3
conda activate nanobody

# change directory to where Snakefile is located
CWD="/tgen_labs/jfryer/kolney/nanobody/scripts/01_processing"
cd $CWD
snakemake --nolock -s Snakefile --jobs 9 --executor slurm --profile slurm_profile --rerun-incomplete --default-resources mem_mb=64000 ntasks=1 threads=1 runtime=1500 cpus_per_task=8
