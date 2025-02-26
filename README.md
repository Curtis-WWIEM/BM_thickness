# 3D Electron Microscopy Analysis of Basement Membrane Thickness in Diabetic Retinal Disease

This MATLAB script automates the analysis of basement membrane thickness in retinal tissue using 3D electron microscopy images. It processes TIFF image stacks, performs distance transform analysis, and calculates thickness measurements for each slice. The output includes mean, max, and raw thickness values, with visualizations of the processed images. 

## Citation

If you find this script helpful, please cite our manuscript:

**Title**: "3D Electron Microscopy Reveals Novel Pathological Ultrastructural Changes in the Retinal Neurovascular Unit in Diabetic Retinal Disease"  
**Authors**: Mona J. Albargothy, Evan P. Troendle, Ross Laws, Peter Barabas, David H. W. Steel, Michael J. Taggart, Tim M. Curtis  
**Journal**: Diabetologia (2025)  
**DOI**: [doi:xxxx](https://doi.org/xxxx)

**Affiliations**:  
1. Biosciences Institute, Newcastle University, Newcastle upon Tyne, UK  
2. Wellcome-Wolfson Institute for Experimental Medicine, Queen’s University Belfast, UK

## Features

- Automated processing of 3D electron microscopy image stacks
- Binary image segmentation for basement membrane identification
- Euclidean distance transform for calculating basement membrane thickness
- Skeletonization of basement membrane structure
- Thickness statistics: mean, max, and raw measurements
- Visualisations of processed slices and thickness distributions

## Requirements

- MATLAB with Image Processing Toolbox
- 3D TIFF images (one per slice)

## Usage

1. Select the TIFF image stack using the file dialog.
2. The script will process the specified slice range (`slice_start` to `slice_end`).
3. For each slice, the script computes the basement membrane thickness and produces visualizations.
4. Results are plotted for mean thickness across slices, distribution of thicknesses, and the thickness of the first slice.

## Parameters

- **connectivity**: Connectivity for component labeling (4 or 8).
- **minimum_qualifying_component_size_px**: Minimum component size in pixels (set to 0 to include all).
- **slice_start**: First slice to process.
- **slice_end**: Last slice to process.
- **dist_step**: Step size for distance transform in nm.
- **pixel_nm_scale**: Scale factor to convert pixels to nanometers.

## Outputs

- Plots of thickness distributions
- The maximum thickness value and the slice it occurs in.

## Example

1. **Adjust Parameters**: Modify the slice range, pixel scale, and material identification parameters as needed.
2. **Run the Script**: 
3. **Select a File**: The script will prompt you to select a `.tif` or `.tiff` file for analysis.
The script will then analyze the stack, calculate BM thicknesses, and generate plots.