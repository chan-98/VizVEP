#! /usr/bin/env nextflow

nextflow.enable.dsl=2

params.sampleDir = ""
params.outputDir = ""

process bcftoolsIntersect {

	label 'bcftools'

	input:
	val sampleName
	path(vcffiles)
	path(vcfIdx)

	output:
	tuple val(sampleName), path("output_files/*.vcf")

	script:

	"""
	mkdir -p output_files

	bcftools isec $vcffiles -p output_files

	"""
}


process bcftoolsSort {

	label 'bcftools'
	
	input:
	tuple val(sampleName), path(vcffiles)

	output:
	tuple val(sampleName), path("*.vcf.gz")

	shell:
	
	'''
	for i in `ls *.vcf | sed 's/.vcf//g'`; do bcftools sort $i.vcf -Oz -o $i.vcf.gz; done;

	'''
}


process bcftoolsIndex {

	label 'bcftools'

	input:
	val sampleName
	path vcffiles

	output:
	path("*.vcf.gz.tbi")

	shell:

	'''
	for i in `ls *.vcf.gz | sed 's/.vcf.gz//g'`; do echo Indexing $i; bcftools index -t $i.vcf.gz; done;
	'''
}


process bcftoolsMerge {

	label 'bcftools'
	publishDir "${params.outputLocation}/Merged", mode: 'copy'

	input:
	tuple val(sampleName), path(vcffiles)
	path(vcfIdx)

	output:
	tuple val(sampleName), path("*.merged.vcf")

	script:

	"""
	bcftools merge $vcffiles --force-samples -o "${sampleName}.merged.vcf"

	"""
}
