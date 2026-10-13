# Plan for F-<id>: <short title>

## Goal

<One paragraph: the hand-written code that goes away, and the package feature that replaces it.>

## Behavior to keep

<Each behavior of the current code that users or other code depend on: inputs, outputs, errors, edge cases, timing, side effects. Mark each one that the package does not give by default, and say how the plan keeps it.>

## Target design

<The classes, configuration and package features after the change. Follow the core rules and the "Changed in" section of the details file.>

## Steps

1. <Step: the file to change and the change. One step per commit-sized change.>

## Dependencies and configuration

<composer require commands with version constraints, configuration files to add or change, environment variables. "None" if none.>

## Tests

<The tests to add or change. Use the test setup that the project already has. Test the project code and its integration with the package, not the package itself.>

## Verification

<The commands to run and the results to expect, for example the test suite, static analysis, and a manual check.>

## Rollback

<How to undo the change.>

## Order

<The plans that must come before this one, or "None".>
