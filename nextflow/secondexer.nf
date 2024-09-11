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

process countRepeats {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "${infile.getSimpleName()}.repeatcount"
  """
  echo -n "${infile.getSimpleName()}" | cut -z -d "_" -f 2 > ${infile.getSimpleName()}.repeatcount
  echo -n ", " >> ${infile.getSimpleName()}.repeatcount
  grep -o "GCCGCG" $infile | wc -l >> ${infile.getSimpleName()}.repeatcount
  """
}

process makeReport {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "finalcount.csv"
  """
  cat * > count.csv
  echo "# Sequence number, repeats" > finalcount.csv
  cat count.csv >> finalcount.csv
  """
}



workflow {
downloadFile | sequenceSplit | flatten | countRepeats | collect | makeReport
}