# EDIT THESE!
PROJECT_ID="your-project-id"
QUEUE_ID="your-queue-id"
TASK_URL="your-cloud-run-task-handler-endpoint" # Task handler endpoint

FUNCTION_NAME="tasks-createHttpTask"
REGION="europe-west1" # Needs to be a supported region
ENTRY_POINT="createHttpTask"
SA_NAME="sa-create-http-task" # Service account name

# Deploy
gcloud functions deploy $FUNCTION_NAME \
  --region $REGION \
  --trigger-http \
  --runtime "nodejs14" \
  --timeout 10 \
  --memory 1Gi \
  --entry-point $ENTRY_POINT \
  --service-account $SA_NAME@$PROJECT_ID.iam.gserviceaccount.com \
  --set-env-vars PROJECT_ID=$PROJECT_ID,QUEUE_ID=$QUEUE_ID,REGION=$REGION,TASK_URL=$TASK_URL,SERVICE_ACCOUNT_EMAIL=$SA_NAME