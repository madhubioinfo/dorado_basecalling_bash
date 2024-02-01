#!/bin/bash

# Prompt the user for the directory containing fast5 files
read -p "Enter the directory path containing fast5 files: " fast5_directory 


# Check if the provided path is a valid directory
if [ ! -d "$fast5_directory" ]; then
    echo "Invalid directory path."
    exit 1
fi

# Specify the output directory for pod5 conversion
mkdir "${fast5_directory}/pod5"
pod5_output_directory="${fast5_directory}/pod5"

# Step 1: Convert fast5 to pod5
pod5 convert fast5 "${fast5_directory}"/*.fast5 --output "${pod5_output_directory}" --one-to-one "${fast5_directory}"

# Step 2: Barcoding the reads and writing it as a bam file
dorado_path="/home/mathum/dorado-0.5.1-linux-x64/bin/dorado"
dorado_model="/home/mathum/dorado-0.5.1-linux-x64/dna_r10.4.1_e8.2_400bps_hac@v4.2.0"
barcode_output_directory="${fast5_directory}"
reads_bam="${barcode_output_directory}/reads.bam"

"${dorado_path}" basecaller --batchsize 60 --device "cuda:all" "${dorado_model}" "${pod5_output_directory}" --kit-name SQK-RBK114-24 > "${reads_bam}"

# Step 3: Dorado demultiplexing
mkdir "${barcode_output_directory}/dorado_demux"
demux_output_directory="${barcode_output_directory}/dorado_demux"
"${dorado_path}" demux --kit-name SQK-RBK114-24 --emit-fastq --output-dir "${demux_output_directory}" "${reads_bam}"
echo "Dorado demultiplexing completed. Results are in: ${demux_output_directory}"
