$HOSTNAME = ""
params.outdir = 'results'  


if (!params.input){params.input = ""} 

g_6_0_g_5 = file(params.input, type: 'any')


process Xenium_Download_Dataset {

input:
 path zipfile

output:
 path "output"  ,emit:g_5_outputDir00_g_0 


container "quay.io/viascientific/initialrun-docker:3.2"

script:

"""
#!/usr/bin/env bash

mkdir output 

unzip ${zipfile} -d output/

tar xzvf output/cell_feature_matrix.tar.gz
mv cell_feature_matrix output/

if [ -f "output/aux_outputs.tar.gz" ]; then
	tar xzvf output/aux_outputs.tar.gz
	mv aux_outputs output/
fi
"""
}


process Xenium_Data_Analysis {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /Output.rds$/) "Analysis_Results_RDS/$filename"}
publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /Analysis_Report.html$/) "HTML_Report/$filename"}
input:
 path Xenium_input

output:
 path "Output.rds"  ,emit:g_0_rdsFile00 
 path "Analysis_Report.html"  ,emit:g_0_outputHTML11 

container "quay.io/viascientific/scrna-seurat-v5:1.0"


script:

lower_threshold = params.Xenium_Data_Analysis.lower_threshold
higher_threshold = params.Xenium_Data_Analysis.higher_threshold


"""
ls ${Xenium_input}

ls ${Xenium_input}/*

path=\$(which Final_Report.Rmd) && cp \$path .

Rscript -e 'rmarkdown::render("Final_Report.Rmd","html_document", output_file = "Analysis_Report.html",params = list(Xenium_output="${Xenium_input}",
  lower_threshold=${lower_threshold},
  higher_threshold=${higher_threshold}
))'
"""

}


workflow {


Xenium_Download_Dataset(g_6_0_g_5)
g_5_outputDir00_g_0 = Xenium_Download_Dataset.out.g_5_outputDir00_g_0


Xenium_Data_Analysis(g_5_outputDir00_g_0)
g_0_rdsFile00 = Xenium_Data_Analysis.out.g_0_rdsFile00
g_0_outputHTML11 = Xenium_Data_Analysis.out.g_0_outputHTML11


}

workflow.onComplete {
println "##Pipeline execution summary##"
println "---------------------------"
println "##Completed at: $workflow.complete"
println "##Duration: ${workflow.duration}"
println "##Success: ${workflow.success ? 'OK' : 'failed' }"
println "##Exit status: ${workflow.exitStatus}"
}
