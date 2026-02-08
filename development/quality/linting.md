# Linting & Formatting Standards

*How we enforce code consistency at Friends Innovation Lab.*

---

## Overview

We use **ESLint** for code quality and **Prettier** for formatting. This combination catches bugs, enforces patterns, and keeps code consistent across the team.

| Tool | Purpose |
|------|---------|
| ESLint | Code quality, catch bugs, enforce patterns |
| Prettier | Code formatting (spacing, semicolons, etc.) |
| TypeScript | Type checking |

---

## Setup

### Install Dependencies

```bash
npm install -D eslint prettier eslint-config-prettier eslint-plugin-react eslint-plugin-react-hooks @typescript-eslint/parser @typescript-eslint/eslint-plugin
```

For Next.js projects (already includes some of these):

```bash
npm install -D prettier eslint-config-prettier
```

### Package.json Scripts

```json
{
  "scripts": {
    "lint": "next lint",
    "lint:fix": "next lint --fix",
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "typecheck": "tsc --noEmit"
  }
}
```

---

## ESLint Configuration

### Next.js (Recommended)

```javascript
// eslint.config.mjs (ESLint 9+ flat config)
import { dirname } from "path";
import { fileURLToPath } from "url";
import { FlatCompat } from "@eslint/eslintrc";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const compat = new FlatCompat({
  baseDirectory: __dirname,
});

const eslintConfig = [
  ...compat.extends(
    "next/core-web-vitals",
    "next/typescript",
    "prettier"
  ),
  {
    rules: {
      // TypeScript
      "@typescript-eslint/no-unused-vars": ["error", {
        argsIgnorePattern: "^_",
        varsIgnorePattern: "^_"
      }],
      "@typescript-eslint/no-explicit-any": "warn",
      "@typescript-eslint/prefer-as-const": "error",

      // React
      "react/jsx-no-target-blank": "error",
      "react/self-closing-comp": "error",
      "react-hooks/rules-of-hooks": "error",
      "react-hooks/exhaustive-deps": "warn",

      // General
      "no-console": ["warn", { allow: ["warn", "error"] }],
      "prefer-const": "error",
      "no-var": "error",
    },
  },
  {
    ignores: [
      ".next/",
      "node_modules/",
      "dist/",
      "build/",
      "*.config.js",
      "*.config.mjs",
    ],
  },
];

export default eslintConfig;
```

### Legacy Config (.eslintrc.json)

```json
{
  "extends": [
    "next/core-web-vitals",
    "next/typescript",
    "prettier"
  ],
  "rules": {
    "@typescript-eslint/no-unused-vars": ["error", {
      "argsIgnorePattern": "^_",
      "varsIgnorePattern": "^_"
    }],
    "@typescript-eslint/no-explicit-any": "warn",
    "react/self-closing-comp": "error",
    "no-console": ["warn", { "allow": ["warn", "error"] }],
    "prefer-const": "error"
  },
  "ignorePatterns": [
    ".next/",
    "node_modules/",
    "dist/"
  ]
}
```

---

## Prettier Configuration

### .prettierrc

```json
{
  "semi": false,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100,
  "bracketSpacing": true,
  "arrowParens": "avoid",
  "endOfLine": "lf",
  "plugins": ["prettier-plugin-tailwindcss"]
}
```

### Options Explained

| Option | Value | Why |
|--------|-------|-----|
| `semi` | `false` | Cleaner, JS handles ASI fine |
| `singleQuote` | `true` | Easier to type, more common |
| `tabWidth` | `2` | Standard for JS/TS |
| `trailingComma` | `es5` | Cleaner diffs |
| `printWidth` | `100` | Reasonable line length |
| `arrowParens` | `avoid` | `x => x` not `(x) => x` |

### .prettierignore

```
# Dependencies
node_modules/

# Build outputs
.next/
dist/
build/
out/

# Generated files
*.min.js
*.min.css
package-lock.json
pnpm-lock.yaml

# Misc
.git/
coverage/
.vercel/
```

---

## Tailwind CSS Plugin

Sort Tailwind classes automatically:

```bash
npm install -D prettier-plugin-tailwindcss
```

The plugin is already referenced in `.prettierrc` above.

**Before:**
```tsx
<div className="p-4 flex bg-white items-center rounded-lg shadow-md">
```

**After (auto-sorted):**
```tsx
<div className="flex items-center rounded-lg bg-white p-4 shadow-md">
```

---

## TypeScript Configuration

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

### Key Strict Options

| Option | What It Does |
|--------|--------------|
| `strict` | Enables all strict type checks |
| `noImplicitAny` | Error on implicit `any` types |
| `strictNullChecks` | `null` and `undefined` must be handled |
| `noUnusedLocals` | Error on unused variables |
| `noUnusedParameters` | Error on unused function parameters |

---

## Editor Integration

### VS Code Settings

```json
// .vscode/settings.json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit",
    "source.organizeImports": "explicit"
  },
  "typescript.preferences.importModuleSpecifier": "relative",
  "typescript.suggest.autoImports": true,
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescriptreact]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  }
}
```

### Recommended Extensions

```json
// .vscode/extensions.json
{
  "recommendations": [
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "bradlc.vscode-tailwindcss",
    "formulahendry.auto-rename-tag"
  ]
}
```

---

## Git Hooks

### Install Husky + lint-staged

```bash
npm install -D husky lint-staged
npx husky init
```

### Configure lint-staged

```json
// package.json
{
  "lint-staged": {
    "*.{ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{json,md,css}": [
      "prettier --write"
    ]
  }
}
```

### Husky Pre-Commit Hook

```bash
# .husky/pre-commit
npx lint-staged
```

This runs linting only on staged files, keeping commits fast.

---

## CI Integration

### GitHub Actions

```yaml
# .github/workflows/lint.yml
name: Lint

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'

      - run: npm ci

      - name: Type Check
        run: npm run typecheck

      - name: Lint
        run: npm run lint

      - name: Format Check
        run: npm run format:check
```

---

## Common Rules Explained

### ESLint Rules

```javascript
rules: {
  // Catches unused variables (prefix with _ to ignore)
  "@typescript-eslint/no-unused-vars": ["error", {
    argsIgnorePattern: "^_"
  }],

  // Warns about `any` (try to be specific)
  "@typescript-eslint/no-explicit-any": "warn",

  // Enforces React hooks rules
  "react-hooks/rules-of-hooks": "error",
  "react-hooks/exhaustive-deps": "warn",

  // No console.log in production code
  "no-console": ["warn", { allow: ["warn", "error"] }],

  // Use const when variable isn't reassigned
  "prefer-const": "error",

  // No var, use let/const
  "no-var": "error",

  // Self-close components without children
  // <Component /> not <Component></Component>
  "react/self-closing-comp": "error",
}
```

### Disabling Rules

```typescript
// Disable for one line
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const data: any = response

// Disable for block
/* eslint-disable no-console */
console.log('debugging')
console.log('more debugging')
/* eslint-enable no-console */

// Disable for file (top of file)
/* eslint-disable @typescript-eslint/no-explicit-any */
```

**Use sparingly.** If you're disabling rules often, reconsider the rule or the code.

---

## Fixing Common Issues

### "X is defined but never used"

```typescript
// ❌ Error
function Component({ id, name, unused }) {
  return <div>{name}</div>
}

// ✅ Prefix unused with underscore
function Component({ id, name, _unused }) {
  return <div>{name}</div>
}

// ✅ Or remove it
function Component({ id, name }) {
  return <div>{name}</div>
}
```

### "React Hook useEffect has missing dependencies"

```typescript
// ❌ Warning
useEffect(() => {
  fetchUser(userId)
}, []) // Missing userId

// ✅ Add dependency
useEffect(() => {
  fetchUser(userId)
}, [userId])

// ✅ Or disable if intentional (rare)
useEffect(() => {
  fetchUser(userId)
  // eslint-disable-next-line react-hooks/exhaustive-deps
}, [])
```

### "Unexpected console statement"

```typescript
// ❌ Warning
console.log('debug')

// ✅ Use proper logging or remove
console.error('Failed to fetch:', error)  // Allowed

// ✅ Or for debugging, remove before commit
```

### Import Sorting

If you want auto-sorted imports, add:

```bash
npm install -D eslint-plugin-import
```

```javascript
// eslint.config.mjs
{
  rules: {
    "import/order": ["error", {
      "groups": [
        "builtin",
        "external",
        "internal",
        "parent",
        "sibling",
        "index"
      ],
      "newlines-between": "always",
      "alphabetize": { "order": "asc" }
    }]
  }
}
```

---

## Quick Reference

### Commands

```bash
# Check for lint errors
npm run lint

# Fix auto-fixable errors
npm run lint:fix

# Check formatting
npm run format:check

# Fix formatting
npm run format

# Type check
npm run typecheck

# Run all checks
npm run lint && npm run format:check && npm run typecheck
```

### Files to Create

```
project/
├── eslint.config.mjs       # ESLint config
├── .prettierrc             # Prettier config
├── .prettierignore         # Prettier ignore
├── tsconfig.json           # TypeScript config
├── .vscode/
│   ├── settings.json       # Editor settings
│   └── extensions.json     # Recommended extensions
└── .husky/
    └── pre-commit          # Git hook
```

---

*See also: [Code Review](code-review.md) · [PR Template](pr-template.md)*
