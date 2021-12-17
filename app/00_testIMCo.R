library(parallel)
library(methods)
library(stringr)
library(fslr)
library(ANTsR)
library(extrantsr)
library(rlist)
library(dplyr)
library(neurobase)
library(isla)

# Arguments to get from command line job submit
if (! exists('argv')){
	argv = commandArgs(trailingOnly=TRUE)
} 

print(argv)
i = as.numeric(as.character(argv[1]))
nsize = as.numeric(as.character(argv[2])) # FWHM for neighborhood
x = as.character(argv[3])
y = as.character(argv[4])
gmthresh = as.numeric(as.character(argv[5]))



# Useful directories
rootdir = getwd()
datadir = 'data'
priordir = file.path (datadir)
maskdir = file.path(rootdir, 'masks')
xdir = file.path(datadir)
xend = "_atropos3class_prob02SubjToTemp2mm"

# GM mask
priorFile = file.path (priordir, paste0 ('prior_grey_thr', gmthresh, '_2mm.nii.gz'))
print(priorFile)
gmPrior = readnii (priorFile)

# Different sample/mask used depending on modality
if(y=='cbf'){
	ydir = file.path(datadir)
	yend = "_asl_quant_ssT1Std"	
    # Subject list
	sl = read.csv(file.path(rootdir, 'data/n1132_linnCoupling_ltnT1AslVox_subjects.csv'))
	scanid = sl$scanid[i]
	maskFile = file.path(ydir, 'n1601_PcaslCoverageMask.nii.gz')
	print("Reading mask") #<-delete
	maskImg = readnii(maskFile)
	maskImg = maskImg*gmPrior
} 
if(y=='alff'){
	ydir = file.path(datadir, 'neuroimaging/rest')
	yend = "_alffStd"
    # Subject list
	sl = read.csv(file.path(rootdir, 'subject_lists/n869_rest_subjList.csv'))
	scanid = sl$scanid[i]
	maskFile = file.path(ydir, 'n1601_RestCoverageMask.nii.gz')
	maskImg = readnii(maskFile)
	maskImg = maskImg*gmPrior
}
if(y=='reho'){
	ydir = file.path(datadir, 'neuroimaging/rest')
	yend = "_rehoStd"
    # Subject list
	sl = read.csv(file.path(rootdir, 'subject_lists/n869_rest_subjList.csv'))
	scanid = sl$scanid[i]
	maskFile = file.path(ydir, 'n1601_RestCoverageMask.nii.gz')
	maskImg = readnii(maskFile)
	maskImg = maskImg*gmPrior
}

# Output location
outdir = file.path(rootdir, paste0 ('coupling_maps_gm', gmthresh))
system(paste("mkdir", outdir, sep=" "))
outdir = file.path(outdir, paste0(x, '_', y, '_size', nsize))
system(paste("mkdir", outdir, sep=" "))

# All .nii.gz files
print("Reading data...")
yFiles = list.files(file.path(ydir, paste0('voxelwiseMaps_', y)))
xFiles = list.files(file.path(xdir, paste0('voxelwiseMaps_', x)))

# Images for IMCo
yName = grep(pattern=paste0(scanid, yend, ".nii.gz"), yFiles)
yFile = yFiles[yName]
xName = grep(pattern=paste0(scanid, xend, ".nii.gz"), xFiles)
xFile = xFiles[xName]
yInFile = file.path(ydir, paste0('voxelwiseMaps_', y), yFile)
xInFile = file.path(xdir, paste0('voxelwiseMaps_', x), xFile)

yRd = readnii(yInFile)
xRd = readnii(xInFile)
# GMD should not be < 0
xRd[xRd<0] = 0
# CBF should not be < 0
yRd[yRd<0] = 0

# Prepare list for input to imco main function
fls = list()
fls[[1]] = yRd
fls[[2]] = xRd
makeDir = file.path(outdir, scanid)
system(paste("mkdir", makeDir, sep=" "))

# Radius specification will override FWHM parameter
imco(files=fls, brainMask=maskImg, subMask=NULL, type="regression", ref=1, fwhm=nsize, thresh=0.005, radius=NULL, reverse=FALSE, verbose=TRUE, retimg=FALSE, outDir=makeDir)




# FOR GEE TESTING:
# test = imco(files=fls, brainMask=maskImg, subMask=NULL, type="gee", ref=1, fwhm=3, thresh=0.005, radius=nsize, reverse=FALSE, verbose=TRUE, retimg=TRUE, outDir=makeDir, propMiss=NULL, corstr='ar1')

