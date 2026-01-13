---
name: integrating-api
description: Integrates RESTful and GraphQL APIs in VortexFeatures. Use when adding endpoints, creating VortexBackendModel response models, or handling API errors.
---

# API Integration

## Location

- **RESTful**: `VortexFeatures/Sources/VortexFeatures/VortexRestfulApi/`
- **GraphQL**: `VortexFeatures/Sources/VortexFeatures/VortexApi/`
- **Models**: `VortexFeatures/Sources/VortexFeatures/VortexBackend/Model/`

## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| RESTful | HTTP verb prefix | `getDeviceList()`, `postCreateUser()` |
| GraphQL | Operation name | `listMyOrganization()`, `createDevice()` |

## Response Models

- All models conform to `VortexBackendModel`
- Enums use `SafeDecodableEnum` with `unknownCase`

## Model Separation (Critical)

- **API Model** → `VortexBackend/Model/` (matches API response)
- **Internal Model** → Manager/Dependency layer (app-specific transformation)

## Error Handling

- Always convert to `VortexError`
- Never expose raw API errors to ViewModels
- Use `handleErrorData` for common HTTP errors

## GraphQL Fragments

Define reusable fragments in `VortexApiKey`.

## Quick Reference

| Aspect | RESTful | GraphQL |
|--------|---------|---------|
| Naming | `getXxx()`, `postXxx()` | `listXxx()`, `createXxx()` |
| Location | `VortexRestfulApi/` | `VortexApi/` |
| Fragments | N/A | `VortexApiKey` |

**Examples**: See [example.md](example.md)
