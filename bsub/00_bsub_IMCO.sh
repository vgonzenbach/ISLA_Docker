#!/bin/bash

# ToDo: change to bsub when singularity is ready
# Read arguments
if [ -z "$1" ]
  then
    echo "No argument supplied"
    exit
fi
mode=$1 # modes = {cbf, alff, reho}

# Set format string depending on 
if [ $mode == 'cbf' ]; then 
     # set format string for files
    f_brainmask="data/masks/CBF_GMD_thr%s_2mm_mask.nii.gz"
    f_yimg="data/voxelwiseMaps_cbf/%s_asl_quant_ssT1Std.nii.gz"
elif [ $mode == 'alff' ]; then echo 'Not implemented'; exit
elif [ $mode == 'reho' ]; then echo 'Not implemented'; exit; fi

# Create output directories if not found
if [ ! -e results ]; then mkdir results; fi
if [ ! -e results/"$mode" ]; then mkdir results/"$mode"; fi

# Run IMCo iteratively over all subjects
SUBJECTS=($(sed '1d' data/n1132_linnCoupling_ltnT1AslVox_subjects.csv | cut -d, -f2))

for subj in ${SUBJECTS[@]}; do 
    # Set subject-specific arguments

    subj=${subj:0:4} # Get only the first four digits
    
    if [ ! -e results/"$mode"/"$subj" ]; then mkdir results/"$mode"/"$subj"; fi

    ximg="data/voxelwiseMaps_gmd/${subj}_atropos3class_prob02SubjToTemp2mm.nii.gz"
    yimg=$(printf $f_yimg $subj)
    
    for thr in 10 20; do
        # Set brainmask depending on threshold
        brainmask=$(printf $f_brainmask $thr)
        
        for nsize in 2 3 4; do
            printf " ximg: %s\n yimg: %s\n brainmask: %s\n nsize: %s\n outdir: %s\n\n" $ximg $yimg $brainmask $nsize $outdir
            docker run --rm -it -v $(pwd)/data:/app/data -v $(pwd)/results:/app/results isla:main Rscript 00_testIMCo.R --ximg "$ximg" --yimg "$yimg" \
                --brainmask "$brainmask" --nsize "$nsize" --outdir "results/${mode}/${subj}"
            
        done
        exit
    done
done