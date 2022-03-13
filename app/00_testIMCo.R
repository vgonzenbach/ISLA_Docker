library(parallel)
library(methods)
library(stringr)
library(fslr)
library(ANTsR)
library(extrantsr)
library(rlist)
library(dplyr)
library(argparser)
library(neurobase)
library(isla)


## ToDo: Get rid of 'if' after testing
if (! exists('argv')){
	p <- arg_parser("Run IMCo")
    p <- add_argument(p, "--outdir", help = "Output directory", default = "tmp/out")
    p <- add_argument(p, "--ximg", help = "Path to X nifti image")
    p <- add_argument(p, "--yimg", help = "Path to Y nifti image")
    p <- add_argument(p, "--brainmask", help = "Path to nifti brain mask")
    p <- add_argument(p, "--submask", help = "Path to  subset of brain mask", default=NULL)
    p <- add_argument(p, "--nsize", help = "Size of sphere", default = 3)
    argv <- parse_args(p)
} 

# Are masks necessary?
# Add argument for whether to apply masks or not?
# sprintf("IMCo running with the following paramaters:\n Outdir: %s\n%s\n%s " ) #

outdir <- argv$outdir # create directory if it doesn't exist
print('Reading brainmask...'); brainmask <- neurobase::readnii(argv$brainmask)
print('Reading submask...'); submask <- ifelse(argv$submask != NULL, neurobase::readnii(argv$submask), NULL)

print('Reading ximg...'); ximg <- neurobase::readnii(argv$ximg) 
print('Reading yimg...'); yimg <- neurobase::readnii(argv$yimg)

nsize <- argv$nsize

print('Running IMCo...')
imco(files=list(yimg, ximg), brainMask=brainmask, subMask=submask, type="regression", ref=1, fwhm=nsize, thresh=0.005, radius=NULL, reverse=FALSE, verbose=TRUE, retimg=FALSE, outDir=outdir)

