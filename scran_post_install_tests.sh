#!/usr/bin/env bash 

#REMOVE BEFOR PUSHING
export PATH=$(pwd):$PATH

script_name=$0 

# This is a test script designed to test that everything works in the various
# accessory scripts in this package. Parameters used have absolutely NO
# relation to best practice and this should not be taken as a sensible
# parameterisation for a workflow.

function usage {
    echo "usage: scran_post_install_tests.sh [action] [use_existing_outputs]"
    echo "  - action: what action to take, 'test' or 'clean'"
    echo "  - use_existing_outputs, 'true' or 'false'"
    exit 1
}

action=${1:-'test'}
use_existing_outputs=${2:-'false'}

if [ "$action" != 'test' ] && [ "$action" != 'clean' ]; then
    echo "Invalid action"
    usage
fi

if [ "$use_existing_outputs" != 'true' ] && [ "$use_existing_outputs" != 'false' ]; then
    echo "Invalid value ($use_existing_outputs) for 'use_existing_outputs'"
    usage
fi

test_working_dir=`pwd`/'post_install_tests'
output_dir=$test_working_dir/outputs

# Clean up if specified
if [ "$action" = 'clean' ]; then
    echo "Cleaning up $test_working_dir ..."
    rm -rf $test_working_dir
    exit 0
elif [ "$action" != 'test' ]; then
    echo "Invalid action '$action' supplied"
    exit 1
fi

# Initialise directories
mkdir -p $test_working_dir
mkdir -p $output_dir

################################################################################
# List tool outputs/inputs & parameters 
################################################################################

#GET TEST DATA
export accession_code='E-MTAB-5727'
export expr_data_type='filtered'
export normalisation_method='CPM'
#READ 10X DATA
export sce_object=$test_working_dir/'output_10X.rds'
#READ MARKER FILE
#export input_marker_file=$markers_path
#export filtered_marker_file=$output_dir/'markers_filtered.tsv'

#compute Sum Factors
export counts_factors_assay='counts'
export counts_factors_sce=$test_working_dir/'counts_factors_sce.rds'

#compute Spike Factors
export spike_factors_assay='counts'
export spike_factors_sce=$test_working_dir/'spike_factors_sce.rds'

#normalize
export lognorm_sce=$test_working_dir/'normalised_sce.rds'
#model gene variance
export GeneVar_table=$test_working_dir/'GeneVar_table.txt'
#model gene variance With Spieks
export GeneVarSpikes_table=$test_working_dir/'GeneVarSpikes_table.txt'

#denoise PCA
export denoise_pca_sce=$test_working_dir/'denoised_pca_sce.rds'
#get clustered PCA
export cluster_PC_sce=$test_working_dir/'cluster_PCs_sce.rds'
#biuldSNNGraph
export shared_nn_graph="TRUE"
export dim_red_NN="PCA_sub"
export clusters_NN_sce=$test_working_dir/'clusters_NN_sce.rds'
#FindMarkers
export cluster_groups="cluster"
export markers_list=$test_working_dir/'markers.rds'
#correlated pairs of genes
export corr_gene_pairs=$test_working_dir/'correlated_gene_pairs.rds'
#correlated genes
export corr_genes=$test_working_dir/'correlated_genes.rds'
--------------------

export processed_sce=$output_10X_obj
export processed_marker_file=$output_dir/'markers_processed.tsv'
export output_labels=$output_dir/'labels.txt'

### Workflow parameters

export normalised_counts_slot='normcounts'
export marker_filter_field='pvals_adj' #Note: should be "pvals_adj" but on the test data (E-MTAB-6386)
export thres_filter=0.05

################################################################################
# Test individual scripts
################################################################################

# Make the script options available to the tests so we can skip tests e.g.
# where one of a chain has completed successfullly.

export use_existing_outputs

# Derive the tests file name from the script name

tests_file="${script_name%.*}".bats

# Execute the bats tests
$tests_file
