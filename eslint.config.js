import js from "@eslint/js";
import globals from "globals";

export default [
  { ignores: ["node_modules/**", ".husky/**", "deploy/*.enc"] },
  js.configs.recommended,
  {
    files: ["**/*.js"],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "module",
      globals: { ...globals.node }   // ✅ даёт process, console, __dirname и т.п.
    },
    rules: {}
  }
];
