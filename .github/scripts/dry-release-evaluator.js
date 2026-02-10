// .github/scripts/dry-release-evaluator.js
// Parses semantic-release --dry-run output from stdin and outputs GitHub Actions outputs

const fs = require('fs');

const output = fs.readFileSync(0, 'utf-8'); // Read from stdin
const lines = output.split('\n');

let status = 'failed';
let nextVersion = 'No release detected';
let notes = [];
let inNotes = false;

for (const line of lines) {
  // Clean line: remove ANSI codes, trim
  const cleanLine = line.replace(/\x1B\[[0-9;]*m/g, '').trim();

  // Detect next version (common patterns from logs)
  const versionMatch = cleanLine.match(/The next release version is\s*([0-9]+\.[0-9]+\.[0-9]+(-[\w\-.+]+)?)/i) ||
                       cleanLine.match(/next release version:\s*([0-9]+\.[0-9]+\.[0-9]+(-[\w\-.+]+)?)/i);
  if (versionMatch) {
    nextVersion = versionMatch[1];
  }

  // Start of notes block
  if (/release notes/i.test(cleanLine) || /changelog preview/i.test(cleanLine)) {
    inNotes = true;
    continue;
  }

  // Collect notes lines (skip log prefixes like [time] [semantic-release] ›)
  if (inNotes) {
    if (cleanLine === '' || cleanLine.startsWith('[') && cleanLine.includes('semantic-release')) {
      // End of notes on blank or new log section
      inNotes = false;
    } else if (!cleanLine.startsWith('[')) {
      notes.push(cleanLine);
    }
  }

  // If we found a version, assume success (even if notes empty)
  if (nextVersion !== 'No release detected') {
    status = 'passed';
  }
}

// Build result markdown
let result;
if (status === 'passed') {
  const preview = notes.length > 0
    ? notes.join('\n').replace(/^\s+|\s+$/g, '')
    : 'No changes qualifying for a release (e.g., chore, docs, style commits only).';
  result = `**Dry-run passed!** Next version would be: **${nextVersion}**\n\n**Changelog preview:**\n\`\`\`markdown\n${preview}\n\`\`\``;
} else {
  // For failed: show truncated output
  const errorPreview = lines.slice(-20).join('\n');
  result = `**Dry-run failed**\n\nError output (last lines):\n\`\`\`text\n${errorPreview}\n\`\`\`\nFull output in workflow logs/artifacts.`;
}

console.log(`status=${status}`);
console.log(`next_version=${nextVersion}`);
console.log(`result=${result}`);
