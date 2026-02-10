// eslint.config.js – bare minimum flat config, no imports, no deps needed
export default [
  {
    rules: {
      // Add your rules here later
      'no-unused-vars': 'warn',
      'no-console': 'off'  // common for action code
    }
  },
  {
    files: ['src/node/**/*.js']
  }
];
