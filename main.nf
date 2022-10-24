/// tsv config file from input argument
tsvPath = params.input

inputChan = Channel.empty()
tsvFile = file(tsvPath)
inputChan = extractFastq(tsvFile)

process GERMLINE{

	publishDir "${launchDir}/results/${idPatient}", mode: 'copy'
	
	memory 128.GB
		
	input:
	tuple val(idPatient), val(gender), val(status), val(idSample), val(idRun), val(file1), val(file2) 

	output:
	path "*"

	script:
	ref = params.ref
	knownsite = params.knownsites

	"""
	pbrun germline \
		--ref ${ref} \
		--in-fq ${file1} ${file2} \
		--knownSites ${knownsite} \
		--out-bam ${idPatient}.bam \
		--out-variants ${idPatient}.vcf \
		--out-recal-file ${idPatient}_recal.txt
	"""

}

workflow {

GERMLINE(inputChan)

}


/// Define input file in format: "subject gender status sample lane fastq1 fastq2"
def returnStatus(it) {
    if (!(it in [0, 1])) exit 1, "Status is not recognized in TSV file: ${it}, see --help for more information"
    return it
}

def returnFile(it) {
    if (!file(it).exists()) exit 1, "Missing file in TSV file: ${it}, see --help for more information"
    return file(it)
}

def hasExtension(it, extension) {
    it.toString().toLowerCase().endsWith(extension.toLowerCase())
}

def checkNumberOfItem(row, number) {
    if (row.size() != number) exit 1, "Malformed row in TSV file: ${row}, see --help for more information"
    return true
}

def extractFastq(tsvFile) {
    Channel.from(tsvFile)
        .splitCsv(sep: '\t')
        .map { row ->
            def idPatient  = row[0]
            def gender     = row[1]
            def status     = returnStatus(row[2].toInteger())
            def idSample   = row[3]
            def idRun      = row[4]
            def file1      = returnFile(row[5])
            def file2      = "null"
            if (hasExtension(file1, "fastq.gz") || hasExtension(file1, "fq.gz") || hasExtension(file1, "fastq") || hasExtension(file1, "fq")) {
                checkNumberOfItem(row, 7)
                file2 = returnFile(row[6])
                if (!hasExtension(file2, "fastq.gz") && !hasExtension(file2, "fq.gz")  && !hasExtension(file2, "fastq") && !hasExtension(file2, "fq")) exit 1, "File: ${file2} has the wrong extension. See --help for more information"
                if (hasExtension(file1, "fastq") || hasExtension(file1, "fq") || hasExtension(file2, "fastq") || hasExtension(file2, "fq")) {
                    exit 1, "We do recommend to use gziped fastq file to help you reduce your data footprint."
                }
            }
            else if (hasExtension(file1, "bam")) checkNumberOfItem(row, 6)
            else "No recognisable extention for input file: ${file1}"

            [idPatient, gender, status, idSample, idRun, file1, file2]
        }
}
