--- name: apidog-internal-api description: Use when managing Apidog project resources programmatically - renaming component responses, creating/deleting endpoints, listing schemas, or any CRUD operation on Apidog projects that the public API doesn't support. Also use when needing to authenticate to Apidog internal API via cookie session.
---
 
# Apidog Internal API
 
Undocumented internal API for Apidog's web UI. Full CRUD on project resources.
 
## Login
 
```bash curl -s -c /tmp/apidog_cookies.jar \   -X POST 'https://api.apidog.com/api/v1/login?locale=en-US' \   -H 'content-type: application/x-www-form-urlencoded;charset=UTF-8' \   --data-urlencode 'account=<YOUR_EMAIL>' \   --data-urlencode 'password=<YOUR_PASSWORD>' ```
 
Use `-b /tmp/apidog_cookies.jar` on all subsequent requests. Re-login if you get 302.
 
## Required Headers
 
```bash -H "x-project-id: $PID" -H "x-branch-id: $BID" \ -H 'x-client-mode: web' -H 'x-client-version: 2.8.22' ```
 
## Vortex Backend Project
 
| Resource | ID | |---|---| | Project | 626117 | | Team | 152248 | | Main Branch | 593811 | | Module | 444393 |
 
## Verified Endpoints (Full CRUD)
 
Base: `https://api.apidog.com/api/v1`. All need `?locale=en-US`.
 
### Projects
 
| Op | Method | Path | Body (form) | |---|---|---|---| | List | GET | `/teams/{teamId}/projects` | - | | Create | POST | `/projects` | `name`, `teamId` | | Delete | DELETE | `/projects/{id}` | - | | Branches | GET | `/projects/{pid}/sprint-branches` | - | | Modules | GET | `/projects/{pid}/modules` | - |
 
### Endpoints
 
| Op | Method | Path | Body | |---|---|---|---| | List | GET | `/api-details` | - | | Tree | GET | `/projects/{pid}/api-tree-list` | - | | Create | POST | `/api-details` | **JSON**: `name`, `method`, `path`, `status` | | Update | PUT | `/api-details/{id}` | form: `name`, `method`, `path`, `status` | | Delete | DELETE | `/api-details/{id}` | - |
 
### Endpoint Folders
 
| Op | Method | Path | Body (form) | |---|---|---|---| | List | GET | `/projects/{pid}/api-detail-folders` | - | | Create | POST | `/api-detail-folders` | `name`, `parentId`, `moduleId`, `type=http` | | Update | PUT | `/api-detail-folders/{id}` | `name` | | Delete | DELETE | `/api-detail-folders/{id}` | - |
 
`parentId` = root folder ID from list. `moduleId` from `/projects/{pid}/modules`.
 
### Schemas
 
**Write** uses `/api-schemas`, **Read** uses `/data-schemas`.
 
| Op | Method | Path | Body (form) | |---|---|---|---| | List | GET | `/projects/{pid}/data-schemas` | - | | Tree | GET | `/schemas-tree-list` | - | | Create | POST | `/api-schemas` | `name`, `jsonSchema`, `moduleId`, `folderId`, `visibility=INHERITED` | | Update | PUT | `/api-schemas/{id}` | `name`, `jsonSchema`, `moduleId`, `folderId` | | Delete | DELETE | `/api-schemas/{id}` | - |
 
### Schema Folders
 
| Op | Method | Path | Body (form) | |---|---|---|---| | List | GET | `/api-schema-folders` | - | | Create | POST | `/api-schema-folders` | `name`, `parentId`, `moduleId` | | Update | PUT | `/api-schema-folders/{id}` | `name` | | Delete | DELETE | `/api-schema-folders/{id}` | - |
 
### Component Responses
 
| Op | Method | Path | Body (form) | |---|---|---|---| | List | GET | `/projects/{pid}/api-responses` | - | | Create | POST | `/api-responses` | `name`, `code`, `contentType`, `defaultEnable` | | Update | PUT | `/api-responses/{id}` | `name`, `code`, `contentType`, `jsonSchema`, `responseExamples`, `defaultEnable` | | Delete | DELETE | `/api-responses/{id}` | - |
 
### Environments
 
| Op | Method | Path | Body (form) | |---|---|---|---| | List | GET | `/projects/{pid}/environments` | - | | Create | POST | `/environments` | `name` | | Update | PUT | `/environments/{id}` | `name`, `baseUrl` | | Delete | DELETE | `/environments/{id}` | - |
 
### Security Schemes
 
| Op | Method | Path | Body (**JSON**) | |---|---|---|---| | List | GET | `/projects/{pid}/security-schemes` | - | | Create | POST | `/projects/{pid}/security-schemes` | `name`, `authType`, `authConfigs`, `oasAuthType`, `folderId`, `moduleId` | | Update | PUT | `/projects/{pid}/security-schemes/{id}` | `name`, `authType`, `authConfigs`, `oasAuthType` | | Delete | DELETE | `/projects/{pid}/security-schemes/{id}` | - |
 
authType values: `apikey`, `bearer`, `basic`, `oauth2`, etc. Example authConfigs for API Key: `{"type":"apiKey","in":"header","paramName":"X-API-Key"}`
 
### Other Read-Only
 
| Resource | Path | |---|---| | Response Folders | `GET /projects/{pid}/http-api-response-folders` | | User | `GET /user` | | Teams | `GET /user-teams` |
 
## Content Types
 
- **Most endpoints**: `application/x-www-form-urlencoded;charset=UTF-8` - **Endpoint create** (`POST /api-details`): `application/json` - **Security schemes** (all writes): `application/json`
 
## Common Errors
 
| Symptom | Cause | Fix | |---|---|---| | HTTP 302 | Cookie expired | Re-login | | 400105 "Client version too low" | Missing `x-client-version` header | Add `-H 'x-client-version: 2.8.22'` | | 422 "Invalid Parameter" | Wrong body format or missing required fields | Check content-type and required fields | | 500 "Internal Error" | Missing `moduleId` or `parentId` | Get IDs from list endpoints first |
 
## Browser Login Flow
 
```bash B=~/.claude/skills/gstack/browse/dist/browse $B goto 'https://app.apidog.com/user/login' $B fill '#account' '<YOUR_EMAIL>' $B click 'text=Continue with Email'; sleep 2 $B click 'text=Continue with password'; sleep 2 $B fill '[placeholder="Password"]' '<YOUR_PASSWORD>' $B click 'text=Continue with password' ```
 
## Intercepting New APIs
 
To discover additional undocumented endpoints, inject this fetch interceptor in the browser, perform the action in UI, then read `window.__cap`:
 
```javascript const of=window.fetch; window.__cap=[]; window.fetch=async function(...a){const[u,o]=a; if(u.includes('api.apidog.com')&&o?.method!=='GET') window.__cap.push({url:u.replace(/\?.*/, ''),method:o.method,body:o.body}); return of.apply(this,a);}; ```
 
## MCP Cache Behavior
 
Apidog MCP Server caches the spec on startup and does NOT auto-refresh. After making changes via UI or internal API, call `refresh_project_oas` to get updated data. Without refresh, MCP returns stale data (hours/days old).
