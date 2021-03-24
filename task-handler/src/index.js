const fastify = require('fastify');
const PORT = process.env.PORT || 8080;
const app = fastify();

/**
 * @description This route handles doing something with incoming data, passed in from Cloud Tasks.
 * In this demo, it just logs and returns a simple message based on the incoming data.
 */
app.post('/', async (request, reply) => {
  const body = typeof request.body === 'string' ? JSON.parse(request.body) : request.body;
  const { name, email, appointmentTime } = body;
  const message = `Hey ${name}! We are reaching out to you at your address ${email} to remind you of your appointment at ${appointmentTime}! Welcome :)`;

  console.log(message);
  reply.code(200).header('Content-Type', 'text/plain').send(message);
});

const start = async () => {
  try {
    await app.listen(PORT, '0.0.0.0');
    app.log.info(`server listening on ${app.server.address().port}`);
  } catch (error) {
    app.log.error(error);
    process.exit(1);
  }
};

start();
