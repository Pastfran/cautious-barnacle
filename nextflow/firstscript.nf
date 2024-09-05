nextflow.enable.dsl=2

process downloadFile{
	publishDir "/home/past/cautious-barnacle/nextflow", mode: 'copy', overwrite: true 
	
	output: 
		path "batch1.fasta"
	
	"""
	wget https://tinyurl.com/cqbatch1 -O batch1.fasta
	"""
}

process countSequences {
	publishDir "/home/past/cautious-barnacle/nextflow", mode: 'copy', overwrite: true
	output: path "numseqs.txt"	
	"""
	grep "^>" batch1.fasta | wc -l > numseqs.txt
	"""
}

workflow {
	downloadFile()
	countSequences()
}