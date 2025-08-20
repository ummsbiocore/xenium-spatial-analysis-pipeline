$HOSTNAME = ""
params.outdir = 'results'  


if (!params.samplesheet){params.samplesheet = ""} 
if (!params.metadatasheet){params.metadatasheet = ""} 

if (params.samplesheet){
   Channel.fromPath(params.samplesheet, type: 'any').map{ file -> tuple(file.baseName, file) }.set{g_7_0_g_5}
} else {
	g_7_0_g_5 = Channel.empty()
}
g_9_1_g_0 = file(params.metadatasheet, type: 'any')
if (params.metadatasheet){
   Channel.fromPath(params.metadatasheet, type: 'any').map{ file -> tuple(file.baseName, file) }.set{g_9_2_g_0}
} else {
	g_9_2_g_0 = Channel.empty()
}


process Xenium_Download_Dataset {

input:
 tuple val(sample_name), file(xenium_path)

output:
 tuple val(sample_name), file("${sample_name}_out")  ,emit:g_5_outputDir00_g_0 

container "quay.io/viascientific/initialrun-docker:3.2"

script:

out_dir = "${sample_name}_out"
"""
out_dir="${out_dir}"
path_loc="${xenium_path}"

echo "Input path_loc: \$path_loc"
echo "Output dir: \$out_dir"

if [ -d "\$path_loc" ]; then
  ls -la "\$path_loc" || true
fi

mkdir -p "\$out_dir"

if [ -d "\$path_loc" ]; then
  src_dir=\$(cd "\$path_loc" && pwd -P)
  out_real=\$(cd "\$out_dir" && pwd -P)
  if [ "\$src_dir" != "\$out_real" ]; then
    if command -v rsync >/dev/null 2>&1; then
      rsync -a -- "\$src_dir/" "\$out_dir/"
    else
      find "\$src_dir" -mindepth 1 -maxdepth 1 -print0 | xargs -0 -I{} cp -a -- "{}" "\$out_dir"/
    fi
  fi
elif [ -f "\$path_loc" ]; then
  command -v unzip >/dev/null 2>&1 || { echo "Error: unzip not found" >&2; exit 1; }
  if unzip -tq -- "\$path_loc" >/dev/null 2>&1; then
    unzip -o -- "\$path_loc" -d "\$out_dir" >/dev/null
  else
    target=\$(readlink -f -- "\$path_loc" 2>/dev/null || realpath -- "\$path_loc" 2>/dev/null || printf "%s" "\$path_loc")
    lc_target=\$(printf "%s" "\$target" | tr '[:upper:]' '[:lower:]')
    case "\$lc_target" in
      *.zip) unzip -o -- "\$path_loc" -d "\$out_dir" >/dev/null ;;
      *) echo "Error: path_loc must be a directory or .zip" >&2; exit 1 ;;
    esac
  fi
else
  echo "Error: path_loc must be a directory or .zip" >&2
  exit 1
fi

while :; do
  dir_count=\$(find "\$out_dir" -mindepth 1 -maxdepth 1 -type d -not -name ".*" | wc -l | tr -d ' ')
  non_dir_count=\$(find "\$out_dir" -mindepth 1 -maxdepth 1 ! -type d -not -name ".*" | wc -l | tr -d ' ')
  if [ "\$dir_count" = "1" ] && [ "\$non_dir_count" = "0" ]; then
    parent=\$(find "\$out_dir" -mindepth 1 -maxdepth 1 -type d -not -name ".*" -print -quit)
    if [ "\$(find "\$parent" -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')" -gt 0 ]; then
      find "\$parent" -mindepth 1 -maxdepth 1 -exec mv -f -t "\$out_dir" {} +
      rmdir "\$parent" || true
      continue
    fi
  fi
  break
done

echo "Data moved/prepared in -> \$out_dir"
ls -la "\$out_dir" || true
"""

}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 6
    $MEMORY = 60
}
//* autofill

process Xenium_Data_Analysis {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /${sample_name}.analysis.rds$/) "Analysis_Results_RDS/$filename"}
publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /${sample_name}.analysis_report.html$/) "HTML_Report/$filename"}
input:
 tuple val(sample_name), file(Xenium_input)
 path metadatasheet
 tuple val(all), file(cellstats_file)

output:
 path "${sample_name}.analysis.rds"  ,emit:g_0_rdsFile00 
 path "${sample_name}.analysis_report.html"  ,emit:g_0_outputHTML11 

container "quay.io/ayush_praveen/ubuntu-seurat:5.3.0"

script:
println cellstats_file
lower_threshold = params.Xenium_Data_Analysis.lower_threshold
higher_threshold = params.Xenium_Data_Analysis.higher_threshold
segmentations = params.Xenium_Data_Analysis.segmentations

"""
mkdir -p cellstats
  
copied=0
for f in ${cellstats_file}; do
  bn=\$(basename "\$f")
  (cp -fL "\$f" "cellstats/\$bn" 2>/dev/null || cp -f "\$f" "cellstats/\$bn")
  echo "Copied -> cellstats/\$bn" >> report.log
  copied=\$((copied+1))
done

ls -l cellstats

ls ${Xenium_input}

ls ${Xenium_input}/*

echo "Boundary Segmentations selected: ${segmentations}"

path=\$(which Final_Report.Rmd) && cp \$path .

Rscript -e 'rmarkdown::render("Final_Report.Rmd","html_document", output_file = "${sample_name}.analysis_report.html",params = list(Xenium_output="${Xenium_input}",
  lower_threshold=${lower_threshold},
  higher_threshold=${higher_threshold},
  cell_stats_path="cellstats",
  metadata_sheet_path="${metadatasheet}",
  sample_name="${sample_name}",
  segmentations="${segmentations}"
))'

mv Output.rds ${sample_name}.analysis.rds
"""

}


workflow {


Xenium_Download_Dataset(g_7_0_g_5.map{i-> return i[1]}.splitCsv(header: true, sep: '\t').map { line -> tuple(line.sample_name, file(line.xenium_path))})
g_5_outputDir00_g_0 = Xenium_Download_Dataset.out.g_5_outputDir00_g_0


Xenium_Data_Analysis(g_5_outputDir00_g_0,g_9_1_g_0,g_9_2_g_0.flatten().splitCsv(header:true, sep:'\t').map { row -> file(row.cell_stats_path) }.toList().map { list -> tuple('all', list) })
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
