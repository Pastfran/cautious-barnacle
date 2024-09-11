nextflow.enable.dsl = 2 

params.storeDir = "${launchDir}/store"
params.accession = "SRR16641606"
params.out = "$launchDir/output4"

process downloadSRA {
	storeDir params.storeDir
	container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3"
	input: 
		val accession 
	
	output:
		path "${accession}"
	
	script:
	"""
	prefetch $accession
	"""
}

process convertFastq {
	publishDir params.out, mode: "copy", overwrite: true 
	storeDir params.storeDir
	container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3"
	input:
		path sra_file
		
	output:
		path "${sra_file}.fastq"
	
	script: 
	"""
	fasterq-dump --split-spot $sra_file
	"""
}

process basicStats {
	publishDir params.out, mode: "copy", overwrite: true
	container "https://depot.galaxyproject.org/singularity/ngsutils%3A0.5.9--py27heb79e2c_4"
	input: 
		path infile 
		
	output: 
		path "stats.txt"
		
	script: 
	"""
	fastqutils stats $infile > "stats.txt"
	"""
}

workflow {
	a = downloadSRA(Channel.from(params.accession)) | convertFastq | basicStats
}



