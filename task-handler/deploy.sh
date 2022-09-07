#!/bin/bash
SERVICE_NAME="task-handler"

gcloud artifacts repositories create $REGISTRY_NAME \
  --location=$RUN_REGION \
  --repository-format=docker

gcloud run deploy $SERVICE_NAME \
  --region $RUN_REGION \
  --platform managed \
  --source . \
  --memory 1Gi \
  --timeout 15 \
  --max-instances 100 \
  --allow-unauthenticated \
  --service-account $TASKHANDLER_USERNAME

export TASK_URL=$(gcloud run services describe $SERVICE_NAME --region $RUN_REGION --format=json|jq .status.url|sed "s/\"//g")
