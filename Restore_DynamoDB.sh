#!/bin/bash
#scripted by Salah.Cherkaoui (DevOps) June 5th 2019
#AWS DynamoDB does not allow to restore to same Table 
#This script will be used to restore into new tables from latest point of Time

echo $# arguments as Tables
if [ $# -lt 1 ];
    then echo "illegal number of parameters"
    exit 1 
fi

for var in "$@"
do

   #Check if Table exists 
   aws dynamodb wait table-exists --table-name "$var" && echo "Table $var exists"
   #Check if Table backup exists
   #Restore Table from latest backup 
   aws dynamodb restore-table-to-point-in-time --source-table-name "$var" --target-table-name "${var}"_new --use-latest-restorable-time
   #Check if the newly created Table is available 
   status="CREATING"
   while [ "$status" != "ACTIVE" ]
         do
         sleep 10
         status=$(aws dynamodb describe-table --table-name "${var}"_new  --query Table.TableStatus --output text)
         echo "Still waiting for Table $var to be active"
         done
done
