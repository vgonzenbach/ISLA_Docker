suppressMessages(library(parallel))
suppressMessages(library(methods))
suppressMessages(library(stringr))
suppressMessages(library(fslr))
suppressMessages(library(ANTsR))
suppressMessages(library(extrantsr))
suppressMessages(library(rlist))
suppressMessages(library(dplyr))
suppressMessages(library(argparser))
suppressMessages(library(neurobase))
suppressMessages(library(isla))


## ToDo: Get rid of 'if' after testing
if (! exists('argv')){
	p <- arg_parser("Run IMCo")
    p <- add_argument(p, "--outdir", help = "Output directory", default = "tmp/out")
    p <- add_argument(p, "--ximg", help = "Path to X nifti image")
    p <- add_argument(p, "--yimg", help = "Path to Y nifti image")
    p <- add_argument(p, "--brainmask", help = "Path to nifti brain mask")
    p <- add_argument(p, "--submask", help = "Path to  subset of brain mask")
    p <- add_argument(p, "--nsize", help = "Size of sphere", default = 3)
    argv <- parse_args(p)
} 

# Are masks necessary?
# Add argument for whether to apply masks or not?
# sprintf("IMCo running with the following paramaters:\n Outdir: %s\n%s\n%s " ) #

outdir <- argv$outdir # create directory if it doesn't exist
message('Reading brainmask...'); brainmask <- neurobase::readnii(argv$brainmask)
message('Reading submask...');
if (is.na(argv$submask)){
    submask = NULL
} else {
    submask = neurobase::readnii(argv$submask)
}

message('Reading ximg...'); ximg <- neurobase::readnii(argv$ximg) 
message('Reading yimg...'); yimg <- neurobase::readnii(argv$yimg)

nsize <- argv$nsize

print('Running IMCo...')
options(fsl.path = "/fsl-6.0.1", fsl.outputtype = "NIFTI_GZ")
imco(files=list(yimg, ximg), brainMask=brainmask, subMask=submask, type="regression", ref=1, fwhm=nsize, thresh=0.005, radius=NULL, reverse=FALSE, verbose=TRUE, retimg=FALSE, outDir=outdir)

