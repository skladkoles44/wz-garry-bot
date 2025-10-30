/**
 * Jest 30 ESM config for wz-garry-bot
 * Без Babel: используем нативный Node ESM.
 */
export default {
  testEnvironment: "node",
  transform: {},                 // не трогаем код
  moduleNameMapper: { "^(\\.{1,2}/.*)\\.js$": "$1" },
  testMatch: ["**/__tests__/**/*.(mjs|js)", "**/?(*.)+(spec|test).(mjs|js)"],
  collectCoverage: true,
  collectCoverageFrom: ["src/**/*.js", "!src/**/__tests__/**"],
  coverageDirectory: "coverage",
  coverageReporters: ["text", "lcov", "html"],
  verbose: true
};
