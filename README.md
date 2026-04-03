# Xenium 10x Genomics Pipeline Summary

The **Xenium pipeline** from **10x Genomics** is a comprehensive solution for **spatial transcriptomics**, enabling high-resolution, subcellular RNA imaging across tissue sections. It integrates **Xenium In Situ** chemistry with advanced image processing and data analysis tools to provide quantitative spatial gene expression maps.

## Key Steps in the Xenium Pipeline:
1. **Tissue Preparation & Probe Hybridization**  
   - Tissues are fixed, permeabilized, and hybridized with barcoded probe sets targeting specific transcripts.

2. **Rolling Circle Amplification (RCA) & Signal Amplification**  
   - Hybridized probes undergo **RCA**, forming compact amplicon structures to enhance signal detection.

3. **High-Resolution Imaging & Signal Detection**  
   - The Xenium instrument captures **fluorescent signals** corresponding to individual RNA molecules at subcellular resolution.

4. **Image Processing & Spot Calling**  
   - Advanced computational algorithms identify RNA spots, correct for background noise, and generate spatial expression maps.

5. **Gene Expression Quantification & Spatial Mapping**  
   - The pipeline assigns transcripts to cells, integrates single-cell segmentation, and reconstructs gene expression landscapes within tissue architecture.

6. **Data Output & Visualization**  
   - Processed data is exported in standardized formats for visualization in **Xenium Explorer, Seurat, Squidpy, and other bioinformatics tools**.

## Applications of the Xenium Pipeline:
- Mapping **cellular organization** and **tissue microenvironments**  
- Studying **tumor heterogeneity** and **immune infiltration**  
- Integrating with **single-cell and spatial multiomics** for deeper insights  

The Xenium pipeline enables **high-throughput, multiplexed in situ transcriptomics**, revolutionizing spatial genomics research with **scalability, precision, and automation**.
Typical Xenium data in a zip file.
 
├── analysis.tar.gz
├── analysis.zarr.zip
├── analysis_summary.html
├── aux_outputs
   ├── morphology_fov_locations.json
   ├── overview_scan.png
   ├── overview_scan_fov_locations.json
   └── per_cycle_channel_images
       ├── cycle_01_blu.tiff
       ├── cycle_01_grn.tiff
       ├── cycle_01_red.tiff

├── aux_outputs.tar.gz
├── cell_boundaries.csv.gz
├── cell_boundaries.parquet
├── cell_feature_matrix
   ├── barcodes.tsv.gz
   ├── features.tsv.gz
   └── matrix.mtx.gz
├── cell_feature_matrix.h5
├── cell_feature_matrix.tar.gz
├── cell_feature_matrix.zarr
   └── cell_features
       ├── cell_id
           └── 0.0
       ├── data
          └── 0
       ├── indices
          └── 0
       └── indptr
           └── 0
├── cell_feature_matrix.zarr.zip
├── cells.csv.gz
├── cells.parquet
├── cells.zarr.zip
├── experiment.xenium
├── gene_panel.json
├── metrics_summary.csv
├── morphology.ome.tif
├── morphology_focus.ome.tif
├── morphology_mip.ome.tif
├── nucleus_boundaries.csv.gz
├── nucleus_boundaries.parquet
├── transcripts.csv.gz
├── transcripts.parquet
└── transcripts.zarr.zip