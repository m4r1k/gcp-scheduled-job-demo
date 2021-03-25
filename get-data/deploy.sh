PROJECT_ID="your-project-id" # EDIT THIS!

TOPIC_ID="tasks-topic"
FUNCTION_NAME="tasks-getData"
REGION="europe-west1" # Needs to be a supported region
ENTRY_POINT="getData" # This is the actual exported function name
SA_NAME="sa-get-data" # Service account name

# Deploy
gcloud functions deploy $FUNCTION_NAME \
  --region $REGION \
  --trigger-http \
  --runtime "nodejs14" \
  --timeout 10 \
  --memory 1Gi \
  --entry-point $ENTRY_POINT \
  --service-account $SA_NAME@$PROJECT_ID.iam.gserviceaccount.com \
  --set-env-vars PROJECT_ID=$PROJECT_ID,TOPIC_ID=$TOPIC_ID