#!/usr/bin/env bats 

# download test sce object from the link provided in package docs
@test "get experiment data" {
    if [ "$use_existing_outputs" = 'true' ] ; then
        skip "exists and use_existing_outputs is set to 'true'"
    fi

    run get_experiment_data.R\
                            --accesssion-code $accession_code\
                            --expr-data-type $expr_data_type\
                            --normalisation-method $normalisation_method\
			    --get-sdrf $get_sdrf\
			    --get-marker-genes $get_marker_genes\
			    --output-dir-name $data_download_dir\
			    --exp-data-dir '10x_data'


    echo "status = ${status}" #exit status
    echo "output = ${output}"

    [ "$status" -eq 0 ] #check if exit status = 0 . This is no error when running.
    #[ -fdd  "$markers_path" ] #There is no output of this process, data is just downloaded and droped to the output_10x_dir
}
#read downloaded data
@test "read 10X data" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$sce_object" ]; then
        skip "$sce_object exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $sce_object &&\
                        dropletutils-read-10x-counts.R\
                            --samples $data_dir\ 
			    --output-object-file $sce_object
    echo "status = ${status}" #exit status
    echo "output = ${output}"

    [ "$status" -eq 0 ] #check if exit status = 0 . This is no error when running.
    [ -f  "$sce_object" ] #cheks if the file is a regular file (not a directory or device file)

}
#compute sum factors
@test "compute counts factors" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$sum_factors_sce" ]; then
        skip "$sum_factors_sce exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $sum_factors_sce &&\
                        scran_computeSumFactors.R\
                            --input-sce-object $sce_object\
                            --assay-type $counts_factors_assay\
                            --output-sce-object $counts_factors_sce

    echo "status = ${status}" #exit status
    echo "output = ${output}"

    [ "$status" -eq 0 ] 
    [ -f  "$sum_factors_sce" ] 
}

#compute spike factors
@test "compute spike-in factors" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$spike_factors_sce" ]; then
        skip "$spike_factors_sce exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $spike_factors_sce &&\
                        scran_computeSumFactors.R\
                            --input-sce-object $sce_object\
                            --assay-type $spike_factors_assay\
                            --output-sce-object $spike_factors_sce

    echo "status = ${status}" #exit status
    echo "output = ${output}"

    [ "$status" -eq 0 ] 
    [ -f  "$spike_factors_sce" ] 
}

#compute spike factors
@test "compute spike-in factors" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$spike_factors_sce" ]; then
        skip "$spike_factors_sce exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $spike_factors_sce &&\
                        scran_computeSpikeFactors.R\
                            --input-sce-object $sce_object\
                            --assay-type $spike_factors_assay\
                            --output-sce-object $spike_factors_sce

    echo "status = ${status}" #exit status
    echo "output = ${output}"

    [ "$status" -eq 0 ] 
    [ -f  "$spike_factors_sce" ] 
}
#normalize
@test "normalize" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$lognorm_sce" ]; then
        skip "$lognorm_sce exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $lognorm_sce &&\
                        scran_normalize.R\
                            --input-sce-object $counts_factors_sce\
                            --assay-type $counts_factors_assay\
                            --output-sce-object $lognorm_sce

    echo "status = ${status}" #exit status
    echo "output = ${output}"

    [ "$status" -eq 0 ] 
    [ -f  "$lognorm_sce" ] 
}

#model gene variance
@test "model gene variance" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$modelGeneVar_table" ]; then
        skip "$modelGeneVar_table exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $modelGeneVar_table &&\
                        scran_modelGeneVar.R\
                            --input-sce-object $lognorm_sce\
                            --output-geneVar-table $GeneVar_table

    echo "status = ${status}" #exit status
    echo "output = ${output}"

    [ "$status" -eq 0 ] 
    [ -f  "$modelGeneVar_table" ] 
}

#model gene variance With Spikes
@test "model gene variance" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$GeneVarSpikes_table" ]; then
        skip "$GeneVarSpikes_table exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $GeneVarSpikes_table &&\
                        scran_modelGeneVarWithSpikes.R\
                            --input-sce-object $lognorm_sce\
                            --output-geneVarSpikes-table $GeneVarSpikes_table

    echo "status = ${status}" #exit status
    echo "output = ${output}"

    [ "$status" -eq 0 ] 
    [ -f  "$GeneVarSpikes_table" ] 
}

#denoise PCA
@test "denoise PCA" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$denoise_pca_sce" ]; then
        skip "$denoise_pca_sce exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $denoise_pca_sce &&\
                        scran_denoisePCA.R\
                            --input-sce-object $lognorm_sce\
                            --technical $GeneVar_table\
                            --output-sce-object $denoise_pca_sce

    echo "status = ${status}" #exit status
    echo "output = ${output}"

    [ "$status" -eq 0 ] 
    [ -f  "$denoise_pca_sce" ] 
}

#get clustered PCs
@test "get clustered PCs" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$cluster_PC_sce" ]; then
        skip "$cluster_PC_sce exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $cluster_PC_sce &&\
                        scran_getClusteredPCs.R\
                            --input-sce-object $denoise_pca_sce\
                            --output-sce-object $cluster_PC_sce

    echo "status = ${status}" #exit status
    echo "output = ${output}"

    [ "$status" -eq 0 ] 
    [ -f  "$cluster_PC_sce" ] 
}

#buildSNNGraph
@test "build Nearest Neighbour Graph" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$clusters_NN_sce" ]; then
        skip "$clusters_NN_sce exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $clusters_NN_sce &&\
                        scran_buildSNNGraph.R\
                            --input-sce-object $cluster_PC_sce\
                            --shared=$shared_nn_graph\
                            --use-dimred=$dim_red_NN\
                            --output-sce-object $clusters_NN_sce

    echo "status = ${status}" #exit status
    echo "output = ${output}"

    [ "$status" -eq 0 ] 
    [ -f  "$clusters_NN_sce" ] 
}

#Find Marker genes
@test "Find Marker genes" {
    if [ "$markers_list" = 'true' ] && [ -f "$markers_list" ]; then
        skip "$markers_list exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $markers_list &&\
                        scran_FindMarkers.R\
                            --input-sce-object $clusters_NN_sce\
                            --groups=$cluster_groups\
                            --output-markers $markers_list

    echo "status = ${status}" #exit status
    echo "output = ${output}"

    [ "$status" -eq 0 ] 
    [ -f  "$markers_list" ] 
}

#Identify correlated pairs of genes
@test "Identify correlated pairs of genes" {
    if [ "$corr_gene_pairs" = 'true' ] && [ -f "$corr_gene_pairs" ]; then
        skip "$corr_gene_pairs exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $corr_gene_pairs &&\
                        scran_FindMarkers.R\
                            --input-sce-object $lognorm_sce\
                            --output-pairs-df $corr_gene_pairs

    echo "status = ${status}" #exit status
    echo "output = ${output}"

    [ "$status" -eq 0 ] 
    [ -f  "$corr_gene_pairs" ] 
}

#Identify correlated Genes
@test "Identify correlated Genes" {
    if [ "$corr_genes" = 'true' ] && [ -f "$corr_genes" ]; then
        skip "$corr_genes exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $corr_genes &&\
                        scran_FindMarkers.R\
                            --input-corr-pairs $corr_gene_pairs\
                            --output-corr-genes $corr_genes

    echo "status = ${status}" #exit status
    echo "output = ${output}"

    [ "$status" -eq 0 ] 
    [ -f  "$corr_genes" ] 
}
#Convert SCE to other formats 
@test "Convert SCE to other formats " {
    if [ "$converted_object" = 'true' ] && [ -f "$converted_object" ]; then
        skip "$converted_object exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $corr_genes &&\
                        scran_convertTo.R\
                            --input-sce-object $lognorm_sce\
                            --type $convert_to\
                            --output-converted $converted_object

    echo "status = ${status}" #exit status
    echo "output = ${output}"

    [ "$status" -eq 0 ] 
    [ -f  "$converted_object" ] 
}
