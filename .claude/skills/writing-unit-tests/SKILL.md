---
name: writing-unit-tests
description: Writes unit tests using Swift Testing framework. Use when creating tests with @Test, @Suite, #expect, #require, or MockAppManager patterns.
---

# Unit Testing with Swift Testing

**IMPORTANT**: All new tests MUST use Swift Testing (`import Testing`), not XCTest.

## Key Points

- Use `#expect()` for assertions
- Use `#require()` to unwrap or fail
- Use `MockAppManager` with closures for ViewModel error testing
- Use `arguments:` parameter for parameterized tests

## Coverage Requirements

- 80%+ for critical business logic
- All new ViewModels must have tests
- Mock all external dependencies

**Examples**: See [example.md](example.md)
