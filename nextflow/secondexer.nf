nextflow.enable.dsl=2

params.out = "$launchDir/output2"

process downloadFile {
	publishDir params.out, mode: 'copy', overwrite: true
	output: 
		path "second.fasta"
	"""
	wget https://tinyurl.com/cqbatch1 -O second.fasta
	"""
}
process sequenceSplit {
	publishDir params.out, mode: 'copy', overwrite: true
	input:
		path infile
	output: 
		path "sequence*"
	"""
	split -l 2 -d --additional-suffix .fasta $infile sequence
	"""
}
workflow {
downloadFile | sequenceSplit
}