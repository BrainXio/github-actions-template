// .github/scripts/workflow-reporter.js
// Reads job outcomes from env vars / context, generates summary, posts to PR if applicable

const fs = require('fs');
const { context, getOctokit } = require('@actions/github');

const token = process.env.GITHUB_TOKEN;
const octokit = getOctokit(token);

const outcomes = {
  validate: process.env.NEEDS_VALIDATE_RESULT || 'skipped',
  test: process.env.NEEDS_TEST_RESULT || 'skipped',
  preview: process.env.NEEDS_RELEASE_PREVIEW_RESULT || 'skipped',
  guard: process.env.NEEDS_RELEASE_GUARD_RESULT || 'skipped',
  release: process.env.NEEDS_RELEASE_RESULT || 'skipped',
};

const emojiMap = {
  success: '✅',
  failure: '❌',
  cancelled: '🚫',
  skipped: '⏭️',
  '': '❓',
};

function getJobName(key) {
  return {
    validate: 'Validate',
    test: 'Test',
    preview: 'Release Preview',
    guard: 'Release Guard',
    release: 'Release',
  }[key];
}

async function postComment() {
  if (process.env.EVENT_NAME !== 'pull_request' || !process.env.PR_NUMBER) {
    console.log('Not a PR → skipping comment');
    return;
  }

  let body = '### Workflow Status Summary\n\n';

  for (const [key, result] of Object.entries(outcomes)) {
    const emoji = emojiMap[result] || '❓';
    const name = getJobName(key);
    body += `${emoji} **${name}**: ${result}\n`;
  }

  body += `\n[View full run](${process.env.SERVER_URL}/${process.env.REPO}/actions/runs/${process.env.RUN_ID})\n`;

  try {
    await octokit.rest.issues.createComment({
      owner: context.repo.owner,
      repo: context.repo.repo,
      issue_number: process.env.PR_NUMBER,
      body,
    });
    console.log('Comment posted');
  } catch (error) {
    console.error('Failed to post comment:', error.message);
  }
}

postComment();
