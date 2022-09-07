#!/bin/bash

# Inpot all varialbes
source ./environment

# Set up new project
gcloud projects create $PROJECT_ID
gcloud config set project $PROJECT_ID
gcloud projects describe $PROJECT_ID
export PROJECT_NUMBER=$(gcloud projects list --filter="project_id:$PROJECT_ID" --format='value(project_number)')

# Enable billing
gcloud services enable cloudbilling.googleapis.com
gcloud alpha billing projects link $PROJECT_ID --billing-account $BILLING_ID

# Enable APIs
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable cloudtasks.googleapis.com
gcloud services enable cloudscheduler.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable appengine.googleapis.com
gcloud services enable pubsub.googleapis.com
gcloud services enable appengine.googleapis.com
gcloud services enable artifactregistry.googleapis.com

# Create service accounts
gcloud iam service-accounts create $SCHEDULER_USERNAME \
  --display-name $"SCHEDULER_DISPLAYNAME"

gcloud iam service-accounts create $CREATEHTTPTASK_USERNAME \
  --display-name $"CREATEHTTPTASK_DISPLAYNAME"

gcloud iam service-accounts create $GETDATA_USERNAME \
  --display-name $"GETDATA_DISPLAYNAME"

gcloud iam service-accounts create $TASKHANDLER_USERNAME \
  --display-name $"TASKHANDLER_DISPLAYNAME"

# Set service account roles
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$SCHEDULER_USERNAME@$PROJECT_ID.iam.gserviceaccount.com \
  --role roles/cloudscheduler.admin

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$SCHEDULER_USERNAME@$PROJECT_ID.iam.gserviceaccount.com \
  --role roles/cloudfunctions.invoker

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$GETDATA_USERNAME@$PROJECT_ID.iam.gserviceaccount.com \
  --role roles/pubsub.publisher

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$CREATEHTTPTASK_USERNAME@$PROJECT_ID.iam.gserviceaccount.com \
  --role roles/cloudtasks.enqueuer

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$CREATEHTTPTASK_USERNAME@$PROJECT_ID.iam.gserviceaccount.com \
  --role roles/iam.serviceAccountUser

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$CREATEHTTPTASK_USERNAME@$PROJECT_ID.iam.gserviceaccount.com \
  --role roles/run.invoker

# Activate App Engine (hosts Scheduler and Tasks)
gcloud app create --region $APPENGINE_REGION

# Create Pub/Sub topic
gcloud pubsub topics create $TOPIC_ID

# Create task queue
gcloud tasks queues create $QUEUE_ID

# Deploy Cloud Functions and Cloud Run
cd task-handler
sh deploy.sh
cd ..
cd create-http-task
sh deploy.sh
cd ..
cd get-data
sh deploy.sh
cd ..

# Create Cloud Scheduler
gcloud beta scheduler jobs create http $SCHEDULER_ID \
  --schedule "every 1 mins" \
  --uri $GET_DATA_URL \
  --http-method GET \
  --oidc-service-account-email $SCHEDULER_USERNAME@$PROJECT_ID.iam.gserviceaccount.com

echo "Congratulations! The entire flow should now be up and running once every minute. Check the logs at https://console.cloud.google.com/logs/ and see what you find."
