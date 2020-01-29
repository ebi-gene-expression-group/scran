#!/usr/bin/env bats 

# download test sce object from the link provided in package docs
@test "extract test data" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$test_sce" ]; then
        skip "$test_sce exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $test_sce && get_test_data.R #remove the output when test finishes
    echo "status = ${status}" #exit status
    echo "output = ${output}"

    [ "$status" -eq 0 ] #check if exit status = 0 . This is no error when running.
    [ -f  "$test_sce" ] #cheks if the file is a regular file (not a directory or device file)
  
}

@test "compute sum factors" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$output_sce_processed" ]; then
        skip "$output_sce_processed exists and use_existing_outputs is set to 'true'"
    fi
    run rm -f $output_sce_processed && scran_computeSumFactors.R\
                        --input-sce-object $test_sce\
                        --assay-type $assay_type\
                        --output-sce-object $sce_sum_factors

    echo "status = ${status}"
    echo "output = ${output}"

    [ "$status" -eq 0 ]
    [ -f  "$output_sce_processed" ]
}
