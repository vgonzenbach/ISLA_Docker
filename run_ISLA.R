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


## Read in arguments
p <- arg_parser("Run Inter-Modal Coupling (IMCo)", hide.opts = FALSE)
p <- add_argument(p, "--outdir", help = "Full path to directory where maps should be written")
p <- add_argument(p, "images", help = "Full image paths separated by commas. First image serve as reference, e.g., dependent modality")
p <- add_argument(p, "--brainmask", short = '-b', help = "Full path to brain mask")
p <- add_argument(p, "--submask", short = '-s', help = "Full path to a mask that is a subset of brainmask where coupling should be computed", default = NULL)
p <- add_argument(p, "--fwhm", help = "Full width half max (FWHM) in mm. Used to compute sigma for the kernel weights.")
p <- add_argument(p, "--type", short = '-t', help = '"regression" or "pca"', default = "regression")
# p <- add_argument(p, "--reference", short = "-ref", help = 'Reference modality when type="pca" or dependent modality when type="regression"', default = 1, type=integer())
p <- add_argument(p, "--propmiss", help = "Maximum proportion of missing voxels in a neighborhood to tolerate, i.e., return NA if missing more than propmiss in the neighborhood of the center voxel")
p <- add_argument(p, "--reverse", short = "-r", flag = TRUE, help = 'Calculate both regressions if type="regression", otherwise ignored')
p <- add_argument(p, "--verbose", short = "-v", flag = TRUE, help = "Give updates on computation")
p <- add_argument(p, "--corstr", short = "-c", help = "Correlation structure for the GEE (only 'exchangeable' implemented so far)", default="exchangeable")
argv <- parse_args(p)

# Preprocess inputs
message('Checking inputs...')

argv$images <- as.list(strsplit(argv$images, ",", fixed=TRUE)[[1]])

if (is.na(argv$fwhm)) stop("Missing value after --fwhm") else argv$fwhm <- as.numeric(argv$fwhm)

if (is.na(argv$propmiss)) argv$propmiss <- NULL else argv$propmiss <- as.numeric(argv$propmiss)

if (is.na(argv$brainmask)) stop("Missing brainmask. Enter path to mask after '-b'")

if (is.na(argv$submask)) argv$submask <- NULL

if (is.na(argv$outdir)) stop("Missing output directory. Enter output path after '-o'")


options(fsl.path = "/fsl-6.0.1", fsl.outputtype = "NIFTI_GZ")
message('Running IMCo...')
res = isla::imco(files=argv$images, brainMask=argv$brainmask, subMask=argv$submask, type=argv$type, ref=1, fwhm=argv$fwhm, thresh=0.005, radius=NULL, reverse=argv$reverse, verbose=argv$verbose, retimg=TRUE, outDir=argv$outdir)

predicted = res$intercept[[1]] + res$slopes[[1]]
neurobase::writenii(predicted, file.path(argv$outdir, "predictedGMD1"))
message(sprintf("Results saved at %s", argv$outdir))
