# External Dependencies in UITests

UITests depend on external services that we don't control. This document tracks known behaviors and failure patterns.

## Services Overview

| Service | Purpose | Stability | Impact if Down |
|---------|---------|-----------|----------------|
| Microsoft Entra ID | SSO authentication | 99.9% | SSO tests fail |
| Google OAuth | SSO authentication | 99.9% | SSO tests fail |
| UAT Backend | API/data | 99% | Most tests fail |
| VIVOTEK Devices | Camera streams | Variable | Device tests fail |

---

## Microsoft Entra ID (SSO)

**Endpoint:** `https://login.microsoftonline.com`

### Passwordless Authentication Flow (as of Dec 2025)

**Behavior:** Microsoft defaults to passwordless authentication requiring one-time codes.

**UI Flow:**
1. User enters email
2. Microsoft shows "Get a code to sign in" page (new as of 2025-12-19)
3. Must click "Use your password" link to bypass
4. Enter password
5. Proceed to "Stay signed in?" dialog

**Test Impact:** Tests expecting direct password entry fail without bypass handling.

### Passkey Setup Prompts (as of Dec 2025)

**Variants:**
- **Web-based:** "Setting up your passkey..." with Cancel button
- **Native dialog:** "Simulator requires enrolled biometrics to use passkeys."

**Test Impact:** May appear after password entry, must handle both variants.

### Page Load Times

- Normal: 5-8 seconds
- Slow (Monday mornings): 8-12 seconds
- Recommendation: Use 10-second timeout minimum

### Historical Changes

| Date | Change | Impact | Fix |
|------|--------|--------|-----|
| 2025-12-03 | Native passkey dialog | SSO tests failed | handlePasskeyDialogIfNeeded() |
| 2025-12-15 | Web passkey page | SSO tests failed | handlePasskeyWebPageIfNeeded() |
| 2025-12-19 | Passwordless default | SSO tests failed | Bypass "Get a code" page |

---

## UAT Backend API

**Endpoint:** `https://uat.vivotek.com`

### Monday Morning Slowness

**Pattern:** API responses 2-3x slower on Monday mornings (8-10 AM)

**Cause:** Weekend backup jobs finishing

**Recommendation:** Use standard UATHelper timeouts (10s). If seeing Monday failures, this is likely why.

### Rate Limiting

**Behavior:** Backend may throttle excessive requests

**Solution:** Run UITests sequentially on CI

---

## VIVOTEK Devices

### Device Discovery Time

- Normal: 10-15 seconds
- Slow: 20-25 seconds if network congested
- Recommendation: 20-second timeout for discovery

### Camera Connection

- Normal: 5-10 seconds for RTSP stream
- Slow: 15+ seconds if camera is booting
- Recommendation: 15-second timeout

---

## Simulator-Specific Issues

### Biometrics Not Enrolled

**Issue:** Simulator doesn't have Face ID enrolled by default

**Impact:** Passkey features fail

**Workaround:** Click "Cancel" or "Other Options" to skip passkey

---

## Troubleshooting Guide

### SSO Tests Fail

Check:
1. Is Microsoft SSO service up? (https://status.azure.com)
2. Has Microsoft changed their UI? (Check this document)
3. Is network blocking SSO redirects?

### API Timeouts

Check:
1. Is UAT backend up?
2. Is it Monday morning? (Known slow period)
3. Are other API tests passing?

### Device Not Found

Check:
1. Is device powered on and networked?
2. Can CI machine reach device IP?
3. Is device ID correct in test code?

---

## Service Status Pages

- **Microsoft Azure:** https://status.azure.com
- **Google Workspace:** https://www.google.com/appsstatus

---

**Last Updated:** 2025-02-09
