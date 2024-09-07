# **VizVEP**
**Visualize Ensembl-VEP annotations with Excel**
*This Nextflow pipeline VEP annotated VCF file to EXCEL viewable CSV format files. If multiple types of VCF files are available of the same sample, it can also merge them and provide a single CSV output.*

## **REQUIREMENTS**
1. Nextflow (version 22 or above)
2. Docker / Singularity
3. Python (version 3.8 or above)

## **INSTRUCTIONS TO RUN THE WORKFLOW**

	### *To convert single VCF file to CSV*
	
`nextflow run main.nf -profile [docker | singularity] --sample ./data/NA12878.haplotypecaller.filtered_VEP.ann.vcf.gz --outDir ./results --sampleID NA12878`

	### *To merge 2 VCF files and convert to CSV*
	
`nextflow run main.nf -profile [docker | singularity] --sample ./data/merge_samples --outDir ./results --sampleID HCC1395T_vs_HCC1395N`
