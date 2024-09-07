#! /usr/bin/env nextflow

nextflow.enable.dsl=2

params.sample = ""
params.outputDir = ""
params.sampleID = ""


process getCsvFromVep {

	stageInMode 'copy'
	publishDir "${params.outputLocation}/CSV_File", mode: 'copy'

	input:
	val sampleName
	path vcffile

	output:
	path "*.csv"

	script:

	ext = vcffile.getExtension()
	base = vcffile.getBaseName()

	if (ext == "gz")
		"""
		gzip -d $vcffile
		python3 $projectDir/bin/vepToCsv.py $base "${sampleName}.csv"

		"""
	else

		"""
		python3 $projectDir/bin/vepToCsv.py $vcffile "${sampleName}.vep_ann.csv"

		"""
}
