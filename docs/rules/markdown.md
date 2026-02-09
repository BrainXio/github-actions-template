# Markdown Style Guide and Linting Rules

This document outlines the markdown style guide and linting rules used in this repository to ensure consistent formatting and quality.

## Linting Rules

### Blank Lines Around Headings (MD022)
Headings should be surrounded by blank lines.

**Bad:**
```markdown
# Heading 1
Content here.

## Heading 2
More content.
```

**Good:**
```markdown
# Heading 1

Content here.

## Heading 2

More content.
```

### Blank Lines Around Lists (MD032)
Lists should be surrounded by blank lines.

**Bad:**
```markdown
# Heading
- List item 1
- List item 2
Content after list.
```

**Good:**
```markdown
# Heading

- List item 1
- List item 2

Content after list.
```

### Trailing Newlines (MD047)
Files should end with a single newline character.

**Bad:**
```markdown
# Heading

Content here.
```

**Good:**
```markdown
# Heading

Content here.

```

## Common Issues and Solutions

### 1. Missing Blank Lines Around Headings
Always ensure there's a blank line before and after headings.

### 2. Missing Blank Lines Around Lists
Ensure lists are separated from surrounding content with blank lines.

### 3. Missing Trailing Newline
Always end files with a single newline character.

### 4. Code Block Formatting
Ensure code blocks are properly formatted with appropriate language identifiers.

## Tools Used

This repository uses markdownlint for linting. Configuration is stored in `.markdownlint.json`.

## Best Practices

1. Maintain consistent spacing throughout documents
2. Use proper heading hierarchy
3. Ensure lists are properly formatted
4. Always end files with a newline character
5. Use descriptive and consistent naming

## References

- [markdownlint Rules](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)
- [MD022 - Headings should be surrounded by blank lines](https://github.com/DavidAnson/markdownlint/blob/main/doc/md022.md)
- [MD032 - Lists should be surrounded by blank lines](https://github.com/DavidAnson/markdownlint/blob/main/doc/md032.md)
- [MD047 - Files should end with a single newline character](https://github.com/DavidAnson/markdownlint/blob/main/doc/md047.md)
