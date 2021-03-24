const fetch = require('node-fetch');

const endpoint = process.env.TASK_ENDPOINT || 'your-create-http-task-function-endpoint';

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
 */
exports.getData = async (req, res) => {
  console.log('Getting data and sending it along...');

  const options = {
    method: 'POST',
    body: JSON.stringify(demoData),
    headers: {
      'Content-Type': 'application/json'
    }
  };

  // Offload data to task queue
  // TODO: Doing it this way requires (?) that the endpoint is public, at least I am not sure how to make it private and actually have it working...
  // --> It seems our service account is not being used as a caller?
  await fetch(endpoint, options)
    .then(() => res.status(200).send(demoData))
    .catch(() => res.status(400).send('An error occured!'));
};
