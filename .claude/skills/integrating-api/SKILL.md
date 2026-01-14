---
name: integrating-api
description: Integrates RESTful and GraphQL APIs in VortexFeatures. Use when adding endpoints, creating VortexBackendModel response models, or handling API errors.
---

# API Integration

## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| RESTful | HTTP verb prefix | `getDeviceList()`, `postCreateUser()` |
| GraphQL | Operation name | `listMyOrganization()`, `createDevice()` |

## Response Models

- All models conform to `VortexBackendModel`
- Enums use `SafeDecodableEnum` with `unknownCase`

## Model Separation (Critical)

- **API Model** → matches API response structure
- **Internal Model** → app-specific transformation in Manager/Dependency layer

## Error Handling

- Always convert to `VortexError`
- Never expose raw API errors to ViewModels
- Use `handleErrorData` for common HTTP errors

## GraphQL Fragments

Define reusable fragments in `VortexApiKey`.

**Examples**: See [example.md](example.md)
