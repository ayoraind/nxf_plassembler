#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// include non-process modules
include { help_message; version_message; complete_message; error_message; pipeline_start_message } from './modules/local/messages.nf'
include { default_params; check_params } from './modules/local/params_parser.nf'
include { help_or_version } from './modules/local/params_utilities.nf'

version = '1.0dev'

// setup default params
default_params = default_params()
// merge defaults with user params
merged_params = default_params + params

// help and version messages
help_or_version(merged_params, version)
final_params = check_params(merged_params)
// starting pipeline
pipeline_start_message(version, final_params)


// include processes
include { PLASSEMBLER_RUN; COMBINE_PLASSEMBLER_RUN; CUSTOM_DUMPSOFTWAREVERSIONS  } from './modules/local/processes.nf' addParams(final_params)
include { INPUT_CHECK       } from './subworkflows/input_check.nf'       addParams( options: [:] )


workflow  {

          if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }
         
	  ch_database = Channel
	  		       .fromPath( params.database, checkIfExists: true )
	                       
	 		       
	  ch_software_versions = Channel.empty()

    	//
    	// SUBWORKFLOW: Read in samplesheet, validate and stage input files
    	//
    	INPUT_CHECK (
        	ch_input
    	)
    
      //  ch_database.view()
      // ch_combined = INPUT_CHECK.out.sample_info.combine(ch_database)
      
       //  ch_combined = INPUT_CHECK.out.sample_info.map { sample -> tuple(sample, params.database) }
       
        ch_combined = INPUT_CHECK.out.sample_info.map { tuple_data ->
						def meta = tuple_data[0]
						def fastq_files = tuple_data[1]
						def forwardread = fastq_files[0]
						def reverseread = fastq_files[1]
						def longread = fastq_files[2]
						
						tuple(meta, forwardread, reverseread, longread, params.database)
				}
	 
	// ch_combined.view()
       
	  PLASSEMBLER_RUN(ch_combined)
	  ch_software_versions = ch_software_versions.mix(PLASSEMBLER_RUN.out.versions)
	 
	// collected_plassembler_ch = PLASSEMBLER_RUN.out.summary_tsv.collect( sort: {a, b -> a[0].getBaseName() <=> b[0].getBaseName()} )
	 
	// COMBINE_PLASSEMBLER_RUN(collected_plassembler_ch)
	 
	 CUSTOM_DUMPSOFTWAREVERSIONS(
	 	ch_software_versions.unique().collectFile(name: 'collated_versions.yml')
	 )
					
         
}

workflow.onComplete {
    complete_message(final_params, workflow, version)
}

workflow.onError {
    error_message(workflow)
}
