export default {
  testEnvironment: "node",
  transform: {}, // без Babel
  moduleNameMapper: { "^(\\.{1,2}/.*)\\.js$": "$1" },
  testMatch: ["**/__tests__/**/*.(mjs|js)", "**/?(*.)+(spec|test).(mjs|js)"],
  collectCoverage: true,
  collectCoverageFrom: ["src/**/*.js", "!src/**/__tests__/**"],
  coverageDirectory: "coverage",
  coverageReporters: ["text", "lcov", "html"],
  verbose: true
};
