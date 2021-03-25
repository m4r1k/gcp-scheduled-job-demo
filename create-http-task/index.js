const { CloudTasksClient } = require('@google-cloud/tasks');

const client = new CloudTasksClient();

const PROJECT_ID = process.env.PROJECT_ID || 'your-project-id';
const QUEUE_ID = process.env.QUEUE_ID || 'your-queue-id';
const REGION = process.env.REGION || 'europe-west1';
const URL = process.env.TASK_URL || 'your-cloud-run-task-handler-endpoint'; // Task handler endpoint
const SERVICE_ACCOUNT_EMAIL =
  `${process.env.SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com` ||
  `sa-create-http-task@${PROJECT_ID}.iam.gserviceaccount.com`;
const PARENT = client.queuePath(PROJECT_ID, REGION, QUEUE_ID);
const WAIT_FOR_SECONDS = 0;

/**
 * @description This function creates a set of tasks of the incoming data (data pulled with Cloud Scheduler).
 */
exports.createHttpTask = async (message, context) => {
  const _data = Buffer.from(message.data, 'base64').toString();
  const payload = typeof _data === 'string' ? JSON.parse(_data) : _data;

  try {
    if (payload && payload.length > 0) {
      const createTasks = payload.map(async (reminderItem) => {
        const { name, email, appointmentTime } = reminderItem;

        const data = {
          name,
          email,
          appointmentTime
        };

        const task = {
          httpRequest: {
            httpMethod: 'POST',
            url: URL,
            oidcToken: {
              serviceAccountEmail: SERVICE_ACCOUNT_EMAIL
            }
          }
        };

        if (payload) {
          task.httpRequest.httpMethod = 'POST';
          task.httpRequest.body = Buffer.from(JSON.stringify(data)).toString('base64');
          task.httpRequest.headers = { 'Content-Type': 'application/json' };
        }

        if (WAIT_FOR_SECONDS)
          task.scheduleTime = {
            seconds: WAIT_FOR_SECONDS + Date.now() / 1000
          };

        const request = { parent: PARENT, task };
        const [response] = await client.createTask(request);
        console.log(`Created task ${response.name}`);
      });

      await Promise.all(createTasks);
    }

    console.log('Done');
  } catch (error) {
    console.error(error);
  }
};
