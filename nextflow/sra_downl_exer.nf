nextflow.enable.dsl = 2 

params.storeDir = "${launchDir}/store"
params.accession = null // um eingabe mit dem nextflow befehl machen zu können 
params.out = "$launchDir/output4"

process downloadSRA {
// zwischenspeichern des Downloads -> deswegen unten ein Channel nötig!
	storeDir params.storeDir 
	//cotainer, der alle Werkzeuge für die Aktion in der Linuxzeile drin hat
	container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3"
	// input als value, kein Pfad
	input: 
		val accession 
	// output vom Linuxcommand wird quasi der name der accession nummer
	output:
		path "${accession}"
	//Linux command
	script:
	"""
	prefetch $accession
	"""
}
// sar file quasi "auspacken" mit diesem prozess
process convertFastq {
	// ort der Outputspeicherung 
	publishDir params.out, mode: "copy", overwrite: true 
	//zusätzich storage
	storeDir params.storeDir
	container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3"
	// input der output von vorher, variable sra_file nur für bezug innerhalb des prozess wichtig 
	input:
		path sra_file
	//output ist quasi name von ersten prozess, weil über variable mitgetragen, mit Endung .fastq	
	output:
		path "${sra_file}.fastq"
	// entpacken des files, wichtig hier richtigen namen verwenden!
	script: 
	"""
	fasterq-dump --split-spot $sra_file
	"""
}
// basic statistic mit neuem toolkit
process basicStats {
	publishDir params.out, mode: "copy", overwrite: true
	container "https://depot.galaxyproject.org/singularity/ngsutils%3A0.5.9--py27heb79e2c_4"
	input: 
		path infile 
		
	output: 
		path "${infile.getSimpleName()}_stats.txt"
	//fastqutils stats gibt output der statistik in der commandozeile aus, deswegen speichern in file aus dem output! 	
	script: 
	"""
	fastqutils stats $infile > ${infile.getSimpleName()}_stats.txt
	"""
}

workflow {
	if (!params.accession) {
    error "No accession number provided. Use --accession parameter to specify it."
    }
	//geht auch ohne a= ? JA!
	downloadSRA(Channel.from(params.accession)) | convertFastq | basicStats
}



