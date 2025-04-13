module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "plugin:import/errors",
    "plugin:import/warnings",
    "plugin:import/typescript",
    "google",
    "plugin:@typescript-eslint/recommended",
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    project: ["tsconfig.json", "tsconfig.dev.json"],
    sourceType: "module",
  },
  ignorePatterns: [
    "/lib/**/*", // Ignore built files.
    "/generated/**/*", // Ignore generated files.
  ],
  plugins: [
    "@typescript-eslint",
    "import",
  ],
  rules: {
    "quotes": ["error", "double"],
    "import/no-unresolved": 0,
    "indent": ["error", 2],
    "max-len": [
      "warn",
      {
        code: 100, // Enforce max line length of 100 characters
        ignoreUrls: true, // Ignore long URLs
        ignoreStrings: true, // Ignore string literals
        ignoreTemplateLiterals: true, // Ignore template literals
        ignoreComments: true, // Ignore comments
      },
    ],
    "camelcase": ["warn", {properties: "always"}], // Enforce camelCase for variable names
  },
};
