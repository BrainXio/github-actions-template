# Working with Claude Code

This repository is configured to work optimally with [Claude Code](https://claude.com/claude-code), Anthropic's AI-powered development assistant. The repository includes a `CLAUDE.md` file that provides guidance for Claude Code when working with this codebase.

## What's in CLAUDE.md?

The `CLAUDE.md` file contains:

1. **Project Overview** - A summary of what this repository does and its key components
2. **Key Architecture Components** - Explanation of how the different parts work together
3. **Development Commands** - Information about the Makefile commands and how to use them
4. **Key Files** - Descriptions of the most important files in the repository
5. **Development Process** - Step-by-step workflow for development
6. **Testing Events** - Information about different GitHub event types that can be simulated

## How Claude Code Uses This Information

When Claude Code opens this repository, it will automatically read the `CLAUDE.md` file and use that information to understand:

- The project's purpose and structure
- How to interact with the codebase
- What commands are available for development
- The repository's development workflow
- The testing approach and event simulation capabilities

## Using Claude with This Repository

To get the most benefit from Claude Code:

1. Open the repository in VS Code or Codespaces
2. Reopen in Container to trigger automatic setup
3. Claude Code will automatically read the `CLAUDE.md` file
4. When you ask Claude to help with development, it will have context about the project structure
5. You can ask Claude to:
   - Explain specific parts of the codebase
   - Help implement new features
   - Debug issues
   - Review changes
   - Explain development commands

## Customizing Claude's Understanding

If you need to modify how Claude Code understands this repository, you can update the `CLAUDE.md` file. Claude will read any changes you make to this file and adjust its understanding accordingly.

## Best Practices for Collaboration

When working with Claude Code:

1. **Be explicit** about what you want it to help with
2. **Ask for specific information** when you need to understand code structure
3. **Use the development commands** documented in CLAUDE.md
4. **Test changes locally** using the Makefile commands
5. **Follow the established workflow** for branching and commits
