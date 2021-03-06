#!/bin/bash

# ToDo: change to bsub when singularity is ready
# Check arguments
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

# Run IMCo iteratively over all subjects
SUBJECTS=($(sed '1d' data/n1132_linnCoupling_ltnT1AslVox_subjects.csv | cut -d, -f2))

for  thr in 10 20; do 
    
    thr_dir=$(printf "results/coupling_maps_gm%s" $thr)
    if [ ! -e "$thr_dir" ]; then mkdir "$thr_dir"; fi

    for nsize in 2 3 4; do
        # Set brainmask depending on threshold
        size_dir=$(printf "%s/gmd_%s_size%s" $thr_dir $mode $nsize)
        if [ ! -e "$size_dir" ]; then mkdir "$size_dir"; fi

        for subj in ${SUBJECTS[@]}; do
            # Set subject-specific arguments    
            subj=${subj:0:4} # Get only the first four digits
            ximg="data/voxelwiseMaps_gmd/${subj}_atropos3class_prob02SubjToTemp2mm.nii.gz"
            yimg=$(printf $f_yimg $subj)
            brainmask=$(printf $f_brainmask $thr)
            outdir=$(printf "%s/%s" $size_dir $subj)
            if [ ! -e "$outdir" ]; then mkdir "$outdir"; fi

            printf " ximg: %s\n yimg: %s\n brainmask: %s\n nsize: %s\n outdir: %s\n\n" $ximg $yimg $brainmask $nsize $outdir
            docker run --rm -v $(pwd)/data:/data -v $(pwd)/results:/results isla "$yimg","$ximg" --fwhm "$nsize" --brainmask "$brainmask" --outdir "$outdir" -v 
        done
    done
done