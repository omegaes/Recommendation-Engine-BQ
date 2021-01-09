PROJECT_ID=$GCP_ID
LOCATION=$GCP_BQ_DATA_LOCATION
DATASET_NAME=test_data


# 10 days = 864000
#php data-generator.php

bq --location=$LOCATION mk \
--dataset \
--default_table_expiration 864000 \
--description "a dataset to be used in recommending personalized items for users" \
$PROJECT_ID:$DATASET_NAME

for file in $(ls ./data/*.csv)
    do
        tableName=$(basename $file .csv) 
        bq load --autodetect --replace --source_format=CSV $DATASET_NAME.$tableName $file
        echo "Table $tableName has been created!"
    done



