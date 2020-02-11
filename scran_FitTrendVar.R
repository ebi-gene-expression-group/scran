#!/usr/bin/env Rscript 

#Fit a mean-dependent trend to the variances of the log-normalized expression values derived from count data.

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
    c("-m", "--min-mean"),
    action = "store",
    default = 0.1,
    type = 'numeric',
    help = 'A numeric scalar specifying the minimum mean to use for trend fitting.'
  ),
  make_option(
    c("-p", "--parametric"),
    action = "store",
    default = TRUE,
    type = 'logical',
    help = 'A logical scalar indicating whether a parametric fit should be attempted.'
  ),
 make_option(
    c("-a", "--assay-type"),
    action = "store",
    default = "logcounts",
    type = 'character',
    help = 'String or integer scalar specifying the assay containing the log-expression values.'
  ),
  make_option(
    c("-o", "--output-trend-var"),
    action = "store",
    default = NA,
    type = 'character',
    help = 'Path to the RDS object with A function that returns the fitted value of the trend at any value of the mean'
  )
)

opt = wsc_parse_args(option_list, mandatory = c("input_sce_object", "output_trend_var"))

#read SCE object
if(!file.exists(opt$input_sce_object)) stop("Input file does not exist.")
sce <- readRDS(opt$input_sce_object)
print(sce)

#Compute fitTrendVar
suppressPackageStartupMessages(require(scran))
fit_trend_var <-fitTrendVar(means = rowMeans(assay(sce, opt$assay_type)), vars = rowVars(as.matrix(assay(sce, opt$assay_type))), min.mean =opt$min_mean, parametric=opt$parametric) 

#save RDS object
saveRDS(sce, opt$output_sce_object)
