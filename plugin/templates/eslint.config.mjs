// Lint for the apps and the shared helpers. Tests (TypeScript) and scripts (Node) are checked other ways.
import js from '@eslint/js';
import compat from 'eslint-plugin-compat';

const browser = {
  window: 'readonly',
  document: 'readonly',
  navigator: 'readonly',
  console: 'readonly',
  fetch: 'readonly',
  Response: 'readonly',
  Intl: 'readonly',
  FormData: 'readonly',
  SubmitEvent: 'readonly',
  HTMLFormElement: 'readonly',
  HTMLTableSectionElement: 'readonly',
  setTimeout: 'readonly',
  clearTimeout: 'readonly',
  localStorage: 'readonly',
  crypto: 'readonly',
  URL: 'readonly',
  Papa: 'readonly',
  Steadyship: 'readonly',
};

export default [
  {
    ignores: [
      'node_modules/**',
      'lib/papaparse.min.js',
      'playwright-report/**',
      'test-results/**',
      'tests/**',
      'scripts/**',
    ],
  },
  js.configs.recommended,
  compat.configs['flat/recommended'], // browser features outside the baseline (see package.json "browserslist")
  {
    files: ['apps/**/*.js', 'lib/**/*.js'],
    languageOptions: { ecmaVersion: 2022, sourceType: 'script', globals: browser },
    rules: {
      'no-alert': 'error', // the regret list: alert() and confirm()
      'no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
      'no-empty': ['error', { allowEmptyCatch: false }], // a swallowed catch is a swallowed error
    },
  },
];
