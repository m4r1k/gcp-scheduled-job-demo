const { PubSub } = require('@google-cloud/pubsub');

const PROJECT_ID = process.env.PROJECT_ID || 'your-project-id';
const TOPIC_ID = process.env.TOPIC_ID || 'my-topic';

const demoData = [
  {
    name: 'Clara',
    email: 'clara@somewhere.net',
    appointmentTime: '15:30'
  },
  {
    name: 'Hassan',
    email: 'hassan@where.com',
    appointmentTime: '16:45'
  },
  {
    name: 'Guillermo',
    email: 'guillermo@overthere.org',
    appointmentTime: '18:00'
  },
  {
    name: 'Ming',
    email: 'ming@there.xyz',
    appointmentTime: '20:00'
  },
  {
    name: 'Hildur',
    email: 'hildur@everywhere.io',
    appointmentTime: '21:00'
  }
];

/**
 * @description This function is fired by Cloud Scheduler. It simply fetches and returns a small set of data.
 * It then offloads the data processing to Pub/Sub, which in turn will fire a function to slice data into a task queue.
 */
exports.getData = async (req, res) => {
  console.log('Getting data and sending it along...');

  const pubSubClient = new PubSub({ projectId: PROJECT_ID });
  const dataBuffer = Buffer.from(JSON.stringify(demoData));

  try {
    const messageId = await pubSubClient.topic(TOPIC_ID).publish(dataBuffer);
    console.log(`Message ${messageId} published.`);
    res.status(200).send(demoData);
  } catch (error) {
    console.error(`Received error while publishing: ${error.message}`);
    res.status(400).send('An error occured!');
  }
};
