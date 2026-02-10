---
name: swift-coding-standards
description: Use when writing Swift code, reviewing Swift PRs, fixing Swift bugs, or refactoring iOS code. Triggers on force unwrap, retain cycle, memory leak, @State vs @Binding confusion, stringly-typed code, magic numbers.
---

# Swift Coding Standards

## Critical Rules

| Rule | Do | Don't |
|------|----|----|
| Optionals | `guard let x else { return }` | `x!` force unwrap |
| Closures | `[weak self]` | Strong `self` capture |
| Data models | `struct` | `class` for plain data |
| Fixed values | `enum Quality { case low, high }` | `String` parameters |
| Variables | `let` by default | `var` unless mutated |
| Errors | `enum MyError: LocalizedError` | `NSError` or empty `catch {}` |
| Async | `async/await` | Completion handlers |
| UI updates | `@MainActor` | Implicit main thread |

## Pre-Commit Checklist

- [ ] No `!` force unwraps without justification comment
- [ ] All closures with `self` use `[weak self]`
- [ ] No magic numbers (use `enum Constants`)
- [ ] No stringly-typed code (use enums)
- [ ] Errors are typed and handled (not swallowed)
- [ ] ViewModels < 200 lines

## Detailed References

Load these when you need comprehensive examples:

| Topic | File | When to Load |
|-------|------|--------------|
| Language | `reference/language.md` | Optionals, naming, error handling, async/await |
| SwiftUI | `reference/swiftui.md` | @State/@Binding, view structure, performance |
| Memory | `reference/memory.md` | ARC, weak/unowned, retain cycles, testing |
| Anti-patterns | `reference/anti-patterns.md` | Code review, refactoring |

**Path**: `.claude/skills/swift-coding-standards/reference/`
