#! /usr/bin/env nextflow

nextflow.enable.dsl=2

params.sample = ""
params.sampleDir = ""
params.sampleID = ""
params.outputDir = ""


include {bcftoolsIntersect; bcftoolsMerge; bcftoolsSort; bcftoolsIndex; bcftoolsIndex as bcftoolsIndexIsec} from './modules/bcftools'
include {getCsvFromVep} from './modules/utils'



workflow {

        if (params.sample) {
                ch_samples = Channel.fromPath(params.sample)
		getCsvFromVep(params.sampleID, ch_samples)

        } else if (params.sampleDir) {
                ch_samples = Channel.fromPath("${params.sampleDir}/**").collect()

		bcftoolsIndex(params.sampleID, ch_samples)
		bcftoolsIntersect(params.sampleID, ch_samples, bcftoolsIndex.out)
		bcftoolsSort(bcftoolsIntersect.out)
		bcftoolsIndexIsec(params.sampleID, bcftoolsSort.out.map{ it[1] })
		bcftoolsMerge(bcftoolsSort.out, bcftoolsIndexIsec.out)
		getCsvFromVep(params.sampleID, bcftoolsMerge.out.map{ it[1] })

        } else {
		error 'ERROR: NOT A VALID INPUT. Please provide --sample [VCF file] OR --sampleDir [VCF directory]'
        }

}
