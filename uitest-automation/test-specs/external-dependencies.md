# External Dependencies in UITests

## Purpose

UITests depend on external services and APIs that we don't control. This document tracks known behaviors, quirks, and failure patterns of these dependencies.

**Why This Matters:**
- External services change without notice
- Understanding dependencies helps diagnose "random" failures
- Documents workarounds for known issues
- Guides timeout/retry strategies

## External Services Overview

| Service | Purpose | Stability | Impact if Down |
|---------|---------|-----------|----------------|
| Microsoft Entra ID | SSO authentication | 99.9% | SSO tests fail |
| Google OAuth | SSO authentication | 99.9% | SSO tests fail |
| UAT Backend | API/data | 99% | Most tests fail |
| VIVOTEK Devices | Camera streams | Variable | Device tests fail |

## Microsoft Entra ID (SSO)

### Service Details

**Purpose:** Enterprise SSO authentication for work/school accounts

**Endpoint:** `https://login.microsoftonline.com`

**Used By:**
- `SigninWithSSOUITest`
- Any test requiring SSO authentication

### Known Behaviors

#### 1. Passkey Dialog (as of Dec 2025)

**Behavior:** Microsoft now prompts to set up passkey authentication

**UI:** System alert with:
- Title: "Sign In"
- Message: "Simulator requires enrolled biometrics to use passkeys."
- Buttons: "Cancel", "Other Options"

**Test Impact:**
- Tests expecting direct password prompt fail
- Must handle optional dialog appearance

**Workaround:**
```swift
// After triggering SSO
app.buttons["sign_in_sso_button"].tap()

// Wait briefly for dialog to appear if it will
Thread.sleep(forTimeInterval: 1.0)

// Handle passkey dialog if present
if app.alerts["Sign In"].exists {
    app.buttons["Other Options"].tap()
}

// Continue with password input
```

**History:**
- **2025-12**: Passkey dialog introduced
- **Prior:** "Stay signed in?" dialog was shown
- **Trend:** Microsoft frequently updates auth UI

**Monitoring:** Check monthly if behavior changed

#### 2. Page Load Times

**Normal:** 5-8 seconds for login page to appear

**Slow scenarios:**
- Monday mornings (8-12 seconds) - backend maintenance
- After Microsoft service updates (variable)
- Network congestion (10+ seconds)

**Recommendation:** Use 10-second timeout minimum

#### 3. Session Persistence

**Behavior:** Microsoft may cache previous login

**Impact:** Test may skip login page if recently authenticated

**Test Strategy:**
- Clear app data before SSO tests
- Or handle "already logged in" state

### Failure Patterns

| Symptom | Likely Cause | Solution |
|---------|--------------|----------|
| "Sign In" alert not found | Passkey dialog removed | Update test to skip dialog handling |
| Login page doesn't load | Network issue or Microsoft outage | Retry test, check Microsoft status |
| Random timeouts | Slow response time | Increase timeout to 15 seconds |

## Google OAuth

### Service Details

**Purpose:** Google account authentication

**Endpoint:** `https://accounts.google.com`

**Used By:**
- Google SSO tests (if implemented)

### Known Behaviors

[To be documented as Google SSO is tested]

**Placeholder for:**
- UI flow patterns
- Known dialogs
- Timeout behaviors
- Common failures

## UAT Backend API

### Service Details

**Endpoint:** `https://uat.vivotek.com`

**Purpose:** Application backend (GraphQL, REST APIs)

**Stability:** ~99% uptime

### Known Behaviors

#### 1. Monday Morning Slowness

**Pattern:** API responses 2-3x slower on Monday mornings (8-10 AM)

**Cause:** Weekend backup jobs finishing

**Impact:** Tests with tight timeouts may fail

**Recommendation:**
- Use standard UATHelper timeouts (10s)
- If seeing Monday failures, this is likely why

#### 2. Rate Limiting

**Behavior:** Backend may throttle excessive requests

**Impact:** Parallel test runs might hit rate limits

**Solution:**
- Run UITests sequentially on CI
- Add small delays between rapid API calls if needed

### Maintenance Windows

**Scheduled:** [To be documented]

**Notification:** Backend team announces in advance

**Test Strategy:**
- Disable UITest CI runs during maintenance
- Or expect failures and ignore

## VIVOTEK Device SDK

### Service Details

**Purpose:** Direct communication with VIVOTEK cameras/NVRs

**Protocol:** Proprietary SDK via network

**Stability:** Depends on device availability

### Known Behaviors

#### 1. Device Discovery Time

**Normal:** 10-15 seconds for network scan

**Slow:** 20-25 seconds if network is congested

**Timeout:** Use 20-second timeout for discovery

#### 2. Camera Connection

**Normal:** 5-10 seconds for RTSP stream connection

**Slow:** 15+ seconds if camera is booting or network congested

**Recommendation:**  15-second timeout

#### 3. Device Offline

**Behavior:** Devices may go offline unexpectedly

**Impact:** Tests expecting specific devices fail

**Detection:**
- Check device status before test
- Or handle "device offline" state gracefully

### Test Data Dependencies

Devices used in tests (from test-data.md):
- IB9365-001 (must be online and accessible)
- [Add others as documented]

**Verification:** Ping devices before CI test run

## Network & Connectivity

### CI Machine Network

**Location:** Office network (10.15.254.x subnet)

**Internet Access:** Via office firewall

**Known Issues:**

#### 1. VPN Interference

**Problem:** VPN sometimes blocks external SSO redirects

**Symptom:** SSO page never loads

**Solution:** Ensure VPN allows Microsoft/Google domains

#### 2. Firewall Rules

**Required Access:**
- https://login.microsoftonline.com (Microsoft SSO)
- https://accounts.google.com (Google OAuth)
- https://uat.vivotek.com (Backend)
- RTSP ports for camera access

## Simulator-Specific Issues

### iOS Simulator Limitations

#### 1. Biometrics Not Enrolled

**Issue:** Simulator doesn't have Face ID/Touch ID enrolled by default

**Impact:** Passkey features fail (Microsoft SSO)

**Workaround:**
- Click "Other Options" to skip passkey
- Or enable Face ID in Simulator: Features > Face ID > Enrolled

#### 2. Network Simulation

**Issue:** Simulator uses host machine's network

**Impact:** Different from real device network behavior

**Test Strategy:** If possible, verify flaky tests on real device

## Dependency Change Tracking

### When External Service Changes

**Process:**
1. Identify the change (new UI, different flow, etc.)
2. Update this document with new behavior
3. Create OpenSpec proposal for test updates
4. Update affected tests
5. Document in git commit

**Example:**
```
# OpenSpec proposal
changes/fix-sso-passkey-handling/
  - proposal.md (explains Microsoft changed their UI)
  - tasks.md (update tests to handle passkey dialog)
```

### Historical Changes

| Date | Service | Change | Impact |
|------|---------|--------|--------|
| 2025-12 | Microsoft SSO | Added passkey dialog | testSignInWithSSO_Success failed |
| [Add future changes] | | | |

## Troubleshooting Guide

### Failure Pattern: SSO Tests Fail

**Check:**
1. Is Microsoft SSO service up? (https://status.azure.com)
2. Has Microsoft changed their UI? (Check this document)
3. Is network blocking SSO redirects?
4. Are timeouts sufficient?

### Failure Pattern: API Timeouts

**Check:**
1. Is UAT backend up?
2. Is it Monday morning? (Known slow period)
3. Is network connection stable?
4. Are other API tests passing?

### Failure Pattern: Device Not Found

**Check:**
1. Is device powered on and networked?
2. Can CI machine reach device IP?
3. Is device ID correct in test code?
4. Check test-data.md for required devices

## Monitoring Recommendations

### Automated Checks

**Before CI Test Run:**
- Ping UAT backend
- Ping test devices
- Verify SSO endpoints reachable

**During Test Run:**
- Log external API response times
- Track timeout occurrences

**After Test Run:**
- Flag tests that hit timeouts
- Report external service issues

### Manual Reviews

**Monthly:**
- Check Microsoft/Google for announced auth changes
- Review backend maintenance schedules
- Verify device availability

**After Failures:**
- Check external service status pages
- Review this document for known issues
- Update document if new pattern discovered

## Service Status Pages

Quick links for checking service health:

- **Microsoft Azure:** https://status.azure.com
- **Google Workspace:** https://www.google.com/appsstatus
- **UAT Backend:** [To be added]
- **VIVOTEK Device Status:** [To be added]

## Future Work

Services to document as they're integrated:

- [ ] AWS Amplify (if used in tests)
- [ ] Firebase services (if used in tests)
- [ ] Google Maps API (if used in tests)
- [ ] Push notification services
- [ ] Cloud storage access

## Contact

For external service issues:
- **Microsoft SSO:** IT team, Azure admin
- **UAT Backend:** Backend team
- **Devices:** Hardware team, network admin
- **General:** Ryan Chen (ryan.cl.chen@vivotek.com)
