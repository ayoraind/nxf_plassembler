include { check_mandatory_parameter; check_parameter_value } from './params_utilities.nf'

def default_params(){
    /***************** Setup inputs and channels ************************/
    def params = [:] as nextflow.script.ScriptBinding$ParamsMap
    // Defaults for configurable variables
    params.help = false
    params.version = false
    params.input = false
    params.outdir = false
    params.database = false
    return params
}

def check_params(Map params) { 
    final_params = params
    
    // set up reads files
    final_params.input = check_mandatory_parameter(params, 'input')
     
    // set up reads files
    final_params.database = check_mandatory_parameter(params, 'database')
    
    // set up output directory
    final_params.outdir = check_mandatory_parameter(params, 'outdir') - ~/\/$/
         
    return final_params
}

