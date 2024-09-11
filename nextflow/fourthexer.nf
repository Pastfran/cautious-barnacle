nextflow.enable.dsl=2

params.out = "$launchDir/output3"
params.url = "https://gitlab.com/dabrowskiw/cq-examples/-/raw/master/data/sequences.sam"
params.temps = "$launchDir/store"

process downloadFile {
    storeDir params.temps
	input 
		val inurl 
    output:
        path "samfile.sam"
        
    """
    wget ${inurl} -O samfile.sam
    """
}

process splitFile {
	publishDir params.out, mode: "copy", overwrite: true 
	
	input: 
		path infile 
		
	output: 
		path "seq_*.fasta"
		
	// greife alle Zeile die, kein @ enthalten | 
		//schneide für alle übrige Zeilen Felder 1 und 10 aus der Datei(tabgetrennt) |
			// suche nach s und ersetze den zeilenanfang mit > 
				// tr übersetzt oder ersetzt zeichen: suche nach tab zeichen und ersetze mit zeilenumbruch (tab nach sequenz! erste zeile >sequnce, zweite Zeile die Basenabfolgen )
					// teile die Zeil in mehrere Datein auf, nummerische suffixe, zeilen pro Datei, dateiennamen beginnen mit seq_ und enden mit .fasta 
		"""
		grep -v "@" $infile | cut -f 1,10 |sed "s/^/>" | tr '\t' '\n' | split -d -l - seq_ --additional-suffix=.fasta 
		"""
}

process countStart {
	publishDir params.out, mode: "copy", overwrite: true 
	
	input	
		path infile 
		
	output	
		path "${infile.getSimpleName()}_counts_start.txt"
	 // greife alle matching parts zu ATG und schreib sie untereinander|
		// zähle zeilen mit ATG (aus vorherigem schritt)
			// speichere Ergebenis der wc -l Zahl in infile.getSimpleName()
		"""
		grep -o "ATG" $infile | wc -l > ${infile.getSimpleName()}_counts_start.txt
		"""
}

process summary {
	publishDir params.out, mode: "copy", overwrite: true 
	input: 
		path infile 
	output: 
		path "summary.txt"
		
	// zeigen den inhalt von allen dateien an 
		//suche nach dateien mit .fasta, ersetze sie durch nichts (aka gelöscht), und das global (also überall und nicht nur beim ersten mal)
		
		"""
		cat * | sed 's/\\.fasta//g' >> summary.txt
		"""
}
workflow {
    downloadFile | splitFile 
}
