#!/bin/bash
FUNCTION_NAME="tasks-getData"
ENTRY_POINT="getData"

# Deploy
gcloud functions deploy $FUNCTION_NAME \
  --region $FUNCTIONS_REGION \
  --trigger-http \
  --runtime "nodejs14" \
  --timeout 10 \
  --memory 1Gi \
  --allow-unauthenticated \
  --entry-point $ENTRY_POINT \
  --service-account $GETDATA_USERNAME@$PROJECT_ID.iam.gserviceaccount.com \
  --set-env-vars PROJECT_ID=$PROJECT_ID,TOPIC_ID=$TOPIC_ID

gcloud functions describe $FUNCTION_NAME --region $FUNCTIONS_REGION --format=json|jq .httpsTrigger.url|sed "s/\"//g" > $GET_DATA_URL_FILE
