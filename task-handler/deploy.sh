export SERVICE_NAME="task-handler"
export REGION="europe-north1"
SA_NAME="sa-task-handler" # Service account name

gcloud beta run deploy $SERVICE_NAME \
  --region $REGION \
  --platform managed \
  --source . \
  --memory 1Gi \
  --timeout 15 \
  --max-instances 100 \
  --service-account $SA_NAME