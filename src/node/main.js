// src/node/main.js
const core = require('@actions/core');

async function run() {
  try {
    const whoToGreet = core.getInput('who-to-greet') || 'World';
    console.log(`Hello, ${whoToGreet}!`);

    const time = new Date().toISOString();
    core.setOutput('time', time);
  } catch (error) {
    core.setFailed(error.message);
  }
}

run();
