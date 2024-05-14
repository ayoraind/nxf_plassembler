## Workflow to Utilize Plassembler for Plasmid assembly.
### Usage

```

===============================================
 TAPIR Plassembler Pipeline version 1.0dev
===============================================

 Usage:
        The typical command for running the pipeline is as follows:
        nextflow run main.nf --input "PathTosamplesheet" --outdir "PathToOutputDir" -profile conda

        Mandatory arguments:
         --input                        Sample sheet containing 'sample', 'R1', 'R2', and 'LongFastQ' columns
         --outdir                       Output directory (e.g., "/MIGE/01_DATA/plassembler_out")


        Helpful arguments:
         --help                         This usage statement.
         --version                      Version statement


```


## Introduction
This pipeline uses Plassembler for automated plasmid assembly.
 

## Word of Note
This is an ongoing project at the Microbial Genome Analysis Group, Institute for Infection Prevention and Hospital Epidemiology, Üniversitätsklinikum, Freiburg. The project is funded by BMBF, Germany, and is led by [Dr. Sandra Reuter](https://www.uniklinik-freiburg.de/institute-for-infection-prevention-and-control/microbial-genome-analysis.html).


## Authors and acknowledgment
The TAPIR (Track Acquisition of Pathogens In Real-time) team.

