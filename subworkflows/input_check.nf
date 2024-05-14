//
// Check input samplesheet and get read channels
//

params.options = [:]

include { SAMPLESHEET_CHECK } from '../modules/local/samplesheet_check.nf' addParams( options: params.options )

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    SAMPLESHEET_CHECK ( samplesheet )

    SAMPLESHEET_CHECK
        .out
        .splitCsv ( header:true, sep:',' )
        .map { create_fastq_channels(it) }
        .set { sample_info }

    emit:
    sample_info // channel: [ val(meta), [ R1, R2, LongFastQ ] ]
}

// Function to get list of [ meta, [ R1, R2, LongFastQ ] ]
def create_fastq_channels(LinkedHashMap row) {
    def meta = [:]
    meta.id         = row.sample
  //  meta.single_end = row.single_end.toBoolean()

    def array = []
    if (!file(row.LongFastQ).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> Fasta file does not exist!\n${row.LongFastQ}"
    } 
    if (!file(row.R1).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> Read 1 FastQ file does not exist!\n${row.R1}"
    }
    if (!file(row.R2).exists()) {
            exit 1, "ERROR: Please check input samplesheet -> Read 2 FastQ file does not exist!\n${row.R2}"
        }
    
    array = [ meta, [ file(row.R1), file(row.R2), file(row.LongFastQ) ] ]
	
    return array
}
