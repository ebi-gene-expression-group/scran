#!/usr/bin/env Rscript 

#Compute log-transformed normalized expression values from a count matrix in a SingleCellExperiment object. 
# SizeFactors are computed if not present in the SCE object. 

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
    c("-s", "--size-factors"),
    action = "store",
    default = NULL,
    type = 'numeric',
    help = 'A numeric vector of cell-specific size factors. Alternatively NULL, in which case the size factors are extracted or computed from x.'
  ),
    make_option(
    c("-l", "--log"),
    action = "store",
    default = TRUE,
    type = 'logical',
    help = 'Logical scalar indicating whether normalized values should be log2-transformed.'
  ),
  make_option(
    c("-p", "--pseudo-count"),
    action = "store",
    default = 1,
    type = 'numeric',
    help = 'Numeric scalar specifying the pseudo_count to add when log-transforming expression values.'
  ),
  make_option(
    c("-c", "--center-size-factors"),
    action = "store",
    default = TRUE,
    type = 'logical',
    help = 'Logical scalar indicating whether size factors should be centered at unity before being used.'
  ),
  make_option(
    c("-a", "--assay-type"),
    action = "store",
    default = "counts",
    type = 'character',
    help = 'A string or integer scalar specifying the assay of x containing the count matrix.'
  ),
  make_option(
    c("-n", "--name"),
    action = "store",
    default = "logcounts",
    type = 'character',
    help = 'String containing an assay name for storing the output normalized values. Defaults to "logcounts" when log=TRUE and "normcounts" otherwise.'
  ),
make_option(
    c("-e", "--use_altexps"),
    action = "store",
    default = FALSE,
    type = 'logical',
    help = 'Logical scalar indicating whether normalization should be performed for alternative experiments in x. Alternatively, a character vector specifying the names of the alternative experiments to be normalized. Alternatively, NULL in which case alternative experiments are not used.'
  ),
  make_option(
    c("-o", "--output-sce-object"),
    action = "store",
    default = NA,
    type = 'character',
    help = 'Path to the output SCE with normalized counts'
  )
)

opt = wsc_parse_args(option_list, mandatory = c("input_sce_object", "output_sce_object"))

#read SCE object
if(!file.exists(opt$input_sce_object)) stop("Input file does not exist.")
sce <- readRDS(opt$input_sce_object)

#compute size Factors
suppressPackageStartupMessages(require(scran))
sce <- logNormCounts(sce, size_factors = opt$size_factors, log = opt$log, exprs_values = opt$assay_type, name = opt$name, 
                    pseudo_count = opt$pseudo_count, center_size_factors = opt$center_size_factors,  use_altexps = opt$use_altexps, name = opt$name)

#save SCE object with size Factors
saveRDS(sce, opt$output_sce_object)
