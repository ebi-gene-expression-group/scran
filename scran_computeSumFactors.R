#!/usr/bin/env Rscript 

#This script is to perform a  scaling normalization of single-cell RNA-seq data by deconvolving size factors from cell pools. 

suppressPackageStartupMessages(require(optparse))
suppressPackageStartupMessages(require(workflowscriptscommon))


# argument parsing 
option_list = list(
  make_option(
    c("-i", "--input-sce-object"),
    action = "store",
    default = NA,
    type = 'character',
    help = 'Path to the input SCE object in rds format'
  ),
    make_option(
    c("-a", "--assay-type"),
    action = "store",
    default = "logcounts",
    type = 'character',
    help = 'Specify which assay values to use. Default: "logocunts'
  ),

   make_option(
    c("-s", "--subset-row"),
    action = "store",
    default = NULL,
    type = 'character',
    help = 'Logical, integer or character vector indicating the rows of the SCE object to use'
  ),
  make_option(
    c("-o", "--output-sce-object"),
    action = "store",
    default = NA,
    type = 'character',
    help = 'Path to the output SCE object containing the vector of size factors in sizeFactors(x)'
  )
)

opt = wsc_parse_args(option_list, mandatory = c("input_sce_object", "output_sce_object"))

# Check parameter values defined
if ( ! file.exists(opt$input_sce_object)){
  stop((paste('File object or matrix', opt$input_sce_object, 'does not exist')))
}

#read SCE object
sce <- readRDS(file = opt$input_sce_object)

# Check assay type present in object
# If not, compute sum factors over "counts"
if ( ! opt$assay_type %in% names(assays(sce))){
   opt$assay_type <- "counts"
}

# Once arguments are satisfcatory, load scran package
suppressPackageStartupMessages(require(scran))

#compute size Factors
sce <- computeSumFactors(x = sce, subset.row = subset_row, assay.type = opt$assay_type)

#TODO: could add the get.spikes argument. Spikes are now a separate SummarizedExperiment. No longer logical vector. 

#save SCE object with size Factors
saveRDS(sce, opt$output_sce_object)