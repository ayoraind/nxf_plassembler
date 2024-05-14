process PLASSEMBLER_RUN {
    tag "$meta.id"
    label 'process_high'

    conda "${projectDir}/conda_environments/plassembler.yml"
    
    input:
    tuple val(meta), path(forwardread), path(reverseread), path(longread), path(database)
     

    output:
    tuple val(meta), path("*_plasmids.fasta")       , emit: plasmid_fasta
    tuple val(meta), path("chromosome.fasta")       , emit: chromosome_fasta
    tuple val(meta), path("*_plasmids.gfa")         , emit: plasmid_gfa
    path("*_summary.tsv")                           , emit: summary_tsv
    tuple val(meta), path("*.log")                  , emit: log
    tuple val(meta), path("logs")                   , emit: logs
    tuple val(meta), path("flye_output")            , emit: flye_out
    tuple val(meta), path("unicycler_output")       , emit: unicycler_out
    tuple val(meta), path("plasmid_fastqs")         , emit: plasmid_fastqs
    path "versions.yml"                             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    plassembler run \\
        $args \\
	-d $database \\
	-l $longread \\
        -1 $forwardread \\
	-2 $reverseread \\
	-m 1  \\
	-p $prefix  \\
        -o $prefix \\
	--keep_fastqs \\
	--keep_chromosome  \\
        -r
    

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        plassembler: \$( plassembler --version 2>&1 | cut -d',' -f2 | sed 's/version //g' )
    END_VERSIONS
    """
    
}

process COMBINE_PLASSEMBLER_RUN {
    tag "combine plassembler summaries"


    input:
    path(plassembler_tsvs)
    


    output:
    path("combined_plassembler_out.tsv"), emit: plassembler


    script:
    """
    PLASSEMBLER_FILES=(${plassembler_tsvs})

    for index in \${!PLASSEMBLER_FILES[@]}; do
    PLASSEMBLER_FILE=\${PLASSEMBLER_FILES[\$index]}
    
    # add header line if first file
    if [[ \$index -eq 0 ]]; then
      echo "sample\t\$(head -1 \${PLASSEMBLER_FILE})" >> combined_plassembler_out.tsv
    fi
    awk -v OFS='\\t' 'FNR>=2 { print FILENAME, \$0 }' \${PLASSEMBLER_FILE} |  sed 's/\\.tsv//g' >> combined_plassembler_out.tsv
    done

    """
}


process CUSTOM_DUMPSOFTWAREVERSIONS {

    publishDir "${params.outdir}", mode:'copy'

    input:
    path versions

    output:
    path "software_versions.yml"    , emit: yml_ch
    path "software_versions_mqc.yml", emit: mqc_yml_ch
    path "versions.yml"             , emit: versions_ch

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    template 'dumpsoftwareversions.py'
}
