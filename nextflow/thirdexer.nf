nextflow.enable.dsl=2

params.url = "https://tinyurl.com/cqbatch1"
params.out = "$launchDir/output"


process downloadUrl {
  publishDir params.out, mode: "copy", overwrite: true
  output:
    path "batch1.fasta"
  """
  wget ${params.url} -O batch1.fasta
  """
}

process splitSequences {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "seq_*.fasta"
  """
  split -d -l 2 --additional-suffix .fasta $infile seq_
  """
}
process Gcount {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "${infile.getSimpleName()}_Gcounts.txt"
  """
  grep -o "G" ${infile} | wc -l > ${infile.getSimpleName()}_Gcounts.txt
  """
}


workflow {downloadUrl | splitSequences | process Gcount}