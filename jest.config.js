export default {
  testEnvironment: "node",
  extensionsToTreatAsEsm: [".js"],
  globals: { "ts-jest": { useESM: true } },
  moduleNameMapper: { "^(\\\\.{1,2}/.*)\\\\.js$": "$1" },
  transform: {},
  collectCoverage: true,
  collectCoverageFrom: [
    "src/**/*.js",
    "!src/**/__tests__/**",
    "!src/**/*.test.js"
  ],
  coverageDirectory: "coverage",
  coverageReporters: ["text","lcov","html"],
  coverageThreshold: { global: { branches: 80, functions: 80, lines: 80, statements: 80 } },
  testMatch: ["**/__tests__/**/*.js","**/?(*.)+(spec|test).js"],
  verbose: true
};
