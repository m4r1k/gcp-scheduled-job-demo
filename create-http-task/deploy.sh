#!/bin/bash
FUNCTION_NAME="tasks-createHttpTask"
ENTRY_POINT="createHttpTask"

TASK_URL=$(cat $TASK_URL_FILE)

# Deploy
gcloud functions deploy $FUNCTION_NAME \
  --region $FUNCTIONS_REGION \
  --trigger-topic $TOPIC_ID \
  --runtime "nodejs14" \
  --timeout 10 \
  --memory 1Gi \
  --entry-point $ENTRY_POINT \
  --service-account $CREATEHTTPTASK_USERNAME@$PROJECT_ID.iam.gserviceaccount.com \
  --set-env-vars PROJECT_ID=$PROJECT_ID,QUEUE_ID=$QUEUE_ID,REGION=$FUNCTIONS_REGION,TASK_URL=$TASK_URL,SERVICE_ACCOUNT_NAME=$CREATEHTTPTASK_USERNAME
