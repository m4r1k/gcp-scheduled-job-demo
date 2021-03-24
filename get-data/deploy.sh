# EDIT THESE!
PROJECT_ID="your-project-id"
TASK_ENDPOINT="your-task-endpoint"

FUNCTION_NAME="tasks-getData"
REGION="europe-west1" # Needs to be a supported region
ENTRY_POINT="getData" # This is the actual exported function name
SA_NAME="sa-get-data" # Service account name

# Deploy; this will be public because I haven't successfully managed to get the fetch call to use the service account credentials
gcloud functions deploy $FUNCTION_NAME \
  --region $REGION \
  --trigger-http \
  --runtime "nodejs14" \
  --timeout 10 \
  --memory 1Gi \
  --entry-point $ENTRY_POINT \
  --allow-unauthenticated \
  --service-account $SA_NAME@$PROJECT_ID.iam.gserviceaccount.com \
  --set-env-vars TASK_ENDPOINT=$TASK_ENDPOINT