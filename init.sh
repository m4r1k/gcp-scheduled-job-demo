export PROJECT_ID="set-your-project-name-here" # EDIT THIS!

export REGION="europe-north1"
export APPENGINE_REGION="europe-west"
export SCHEDULER_ID="tasks-scheduler"
export QUEUE_ID="tasks-queue"

export SCHEDULER_USERNAME="sa-scheduler"
export SCHEDULER_DISPLAYNAME="SA for scheduler"
export GETDATA_USERNAME="sa-get-data"
export GETDATA_DISPLAYNAME="SA for getData function"
export CREATEHTTPTASK_USERNAME="sa-create-http-task"
export CREATEHTTPTASK_DISPLAYNAME="SA for createHttpTask function"
export TASKHANDLER_USERNAME="sa-task-handler"
export TASKHANDLER_DISPLAYNAME="SA for task-handler Cloud Run service"

# Update gcloud
gcloud components update

# Set up new project
gcloud projects create $PROJECT_ID
gcloud config set project $PROJECT_ID
gcloud projects describe $PROJECT_ID
export PROJECT_NUMBER=$(gcloud projects list --filter="project_id:$PROJECT_ID" --format='value(project_number)')

# Enable billing
gcloud services enable cloudbilling.googleapis.com
gcloud alpha billing accounts list
export BILLING_ID="1234" # From above
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

# Create service accounts
gcloud iam service-accounts create $SCHEDULER_USERNAME \
  --display-name $SCHEDULER_DISPLAYNAME

gcloud iam service-accounts create $CREATEHTTPTASK_USERNAME \
  --display-name $CREATEHTTPTASK_DISPLAYNAME

gcloud iam service-accounts create $GETDATA_USERNAME \
  --display-name $GETDATA_DISPLAYNAME

gcloud iam service-accounts create $TASKHANDLER_USERNAME \
  --display-name $TASKHANDLER_DISPLAYNAME

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$CREATEHTTPTASK_USERNAME@$PROJECT_ID.iam.gserviceaccount.com \
  --role roles/cloudtasks.enqueuer

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$CREATEHTTPTASK_USERNAME@$PROJECT_ID.iam.gserviceaccount.com \
  --role roles/iam.serviceAccountUser

# Deploy Cloud Functions and Cloud Run
cd get-data
sh deploy.sh
cd ..
cd create-http-task
sh deploy.sh
cd ..
cd task-handler
sh deploy.sh
cd ..

# Activate App Engine (hosts Scheduler and Tasks?)
gcloud app create --region $APPENGINE_REGION

# Create scheduler
gcloud beta scheduler jobs create http $SCHEDULER_ID \
  --schedule "every 1 mins" \
  --uri "your-get-data-function-endpoint" \
  --http-method GET \
  --oidc-service-account-email $SCHEDULER_USERNAME@$PROJECT_ID.iam.gserviceaccount.com

# Create task queue
gcloud tasks queues create $QUEUE_ID

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$SCHEDULER_USERNAME@$PROJECT_ID.iam.gserviceaccount.com \
  --role roles/cloudscheduler.admin

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$SCHEDULER_USERNAME@$PROJECT_ID.iam.gserviceaccount.com \
  --role roles/cloudfunctions.invoker

# TODO: It seems our service account is not being used as a caller when using fetch(); we will set this as "public"
# gcloud projects add-iam-policy-binding $PROJECT_ID \
#   --member serviceAccount:$GETDATA_USERNAME@$PROJECT_ID.iam.gserviceaccount.com \
#   --role roles/cloudfunctions.invoker

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$CREATEHTTPTASK_USERNAME@$PROJECT_ID.iam.gserviceaccount.com \
  --role roles/run.invoker