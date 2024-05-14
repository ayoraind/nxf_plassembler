def help_message() {
  log.info """
        Usage:
        The typical command for running the pipeline is as follows:
        nextflow run main.nf --input "PathTosamplesheet" --outdir "PathToOutputDir" --database "PathToPLSDB" -profile conda 

        Mandatory arguments:
         --input	                Sample sheet containing 'sample', 'R1', 'R2', and 'LongFastQ' column
	 --database	                File Path to the plasmid database
         --outdir                       Output directory (e.g., "/MIGE/01_DATA/plassembler_run")
	
        Helpful arguments:
         --help                         This usage statement.
         --version                      Version statement
        """
}


def version_message(String version) {
      println(
            """
            ================================================
             TAPIR Plassembler Pipeline version ${version}
            ================================================
            """.stripIndent()
        )

}


def pipeline_start_message(String version, Map params){
    log.info "======================================================================"
    log.info "              TAPIR Plassembler Pipeline version ${version}"
    log.info "======================================================================"
    log.info "Running version   : ${version}"
    log.info "Sample sheet      : ${params.input}"
    log.info ""
    log.info "-------------------------- Other parameters --------------------------"
    params.sort{ it.key }.each{ k, v ->
        if (v){
            log.info "${k}: ${v}"
        }
    }
    log.info "======================================================================"
    log.info "Outputs written to path '${params.outdir}'"
    log.info "======================================================================"
    
    log.info ""
}


def complete_message(Map params, nextflow.script.WorkflowMetadata workflow, String version){
    // Display complete message
    log.info ""
    log.info "Ran the workflow: ${workflow.scriptName} ${version}"
    log.info "Command line    : ${workflow.commandLine}"
    log.info "Completed at    : ${workflow.complete}"
    log.info "Duration        : ${workflow.duration}"
    log.info "Success         : ${workflow.success}"
    log.info "Work directory  : ${workflow.workDir}"
    log.info "Exit status     : ${workflow.exitStatus}"
    log.info ""
}

def error_message(nextflow.script.WorkflowMetadata workflow){
    // Display error message
    log.info ""
    log.info "Workflow execution stopped with the following message:"
    log.info "  " + workflow.errorMessage
}
