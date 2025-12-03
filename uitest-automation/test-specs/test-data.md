# UITest Test Data Requirements

## Purpose

This document defines the test data that must be available in the UAT environment for UITests to run successfully. It serves as:

- **Prerequisites checklist** for test execution
- **Data setup guide** for UAT environment configuration
- **Reference** for AI assistants writing tests

**Key Principle:** UITests should use consistent, well-known test data to ensure reproducible results.

## UAT Environment

**Backend:** `https://uat.vivotek.com`

**Access:** Tests run against UAT, not production
- Ensures test data isolation
- Allows destructive testing (delete, modify data)
- Consistent data state for CI runs

## Test Accounts

### Primary Test Account

| Field | Value | Purpose |
|-------|-------|---------|
| Email | `test@vivotek.com` | General UITest account |
| Password | `P@ssw0rd` | Standard test password |
| Organization | [To be documented] | Organization context |
| Permissions | Full access | Test all features |

**Usage:**
- Most UITests should use this account
- Sufficient permissions to test all features
- Coordinate with team to avoid concurrent test conflicts

### SSO Test Account

| Field | Value | Purpose |
|-------|-------|---------|
| Email | `test@vivotek.com` | Same as primary (supports SSO) |
| SSO Provider | Microsoft Entra ID | Test SSO login flow |
| Organization | [To be documented] | SSO-enabled org |

**Notes:**
- Same email as primary account but uses SSO authentication
- Microsoft passkey dialog may appear (see external-dependencies.md)
- Handle "Other Options" button if passkey dialog shows

### MFA Test Account

| Field | Value | Purpose |
|-------|-------|---------|
| Email | `mfa@vivotek.com` | MFA-enabled account |
| Password | `P@ssw0rd` | Standard test password |
| MFA Method | [To be documented] | Test MFA flow |

**Usage:**
- Testing multi-factor authentication flows
- Verify MFA setup and enforcement

## Devices & Cameras

### Test Cameras

Required cameras in UAT environment:

| Model | Serial/ID | Location | Purpose |
|-------|-----------|----------|---------|
| IB9365 | `IB9365-001` | Ungrouped Cameras | General device testing |
| [Add more as discovered] | | | |

**Notes:**
- Camera models should cover common VIVOTEK devices
- Keep device list stable for consistent test results
- Document any special device configurations (PTZ, fisheye, etc.)

### Device Groups

| Group Name | Purpose | Contains |
|-----------|---------|----------|
| Ungrouped Cameras | Default group | New devices |
| [Add groups as needed] | | |

## Floor Plans

### Required Floor Plan Data

| Site Name | Floor Plan Name | Purpose |
|-----------|----------------|---------|
| Ungrouped Cameras | main floor | Basic floor plan viewing test |
| Office Site | Office 1F | Search/filter testing |
| Office Site | Office 2F | Multi-floor plan testing |
| Warehouse Site | Warehouse | Negative search test case |

**Camera Placement:**
- "main floor" should have at least one camera placed
- Camera IDs should match devices in "Test Cameras" section above

**Search Testing:**
- Search "Office" should return "Office 1F" and "Office 2F"
- Search "Warehouse" should return only "Warehouse"
- Search "main" should return "main floor"

### Floor Plan Test Constants

When writing tests, use these constants:

```swift
// Floor Plan test data
private let testFloorPlanSite = "Ungrouped Cameras"
private let testFloorPlanName = "main floor"
private let testCamera1 = "IB9365-001"

// Search test data
private let testOfficeSite = "Office Site"
private let testOfficeFloorPlan1 = "Office 1F"
private let testOfficeFloorPlan2 = "Office 2F"
private let testWarehousePlan = "Warehouse"
```

## Messages & Notifications

### Test Message Data

[To be documented]

**Requirements:**
- Sample alarm messages
- Different message types (motion, sensor, AI event)
- Read/unread message states

## Archive & Video

### Test Archive Data

[To be documented]

**Requirements:**
- Recorded video segments
- Various durations and dates
- Different camera sources
- Thumbnail availability

## Organizations & Users

### Organization Structure

| Organization | Type | Purpose |
|-------------|------|---------|
| [To be documented] | Standard | Basic org testing |
| [To be documented] | Reseller | Multi-org testing |

### User Roles

| Role | Permissions | Test Account |
|------|------------|--------------|
| Admin | Full access | test@vivotek.com |
| [Add roles as needed] | | |

## Licenses

### Test License Data

[To be documented]

**Requirements:**
- Active licenses for testing
- Expired license scenarios
- Grace period testing
- Different license tiers

## Network & Connectivity

### Test Environment Constraints

**CI Machine Network:**
- Can access UAT backend (https://uat.vivotek.com)
- Can reach VIVOTEK devices on local network
- Stable internet connection for external SSO

**Firewall Rules:**
- Allow RTSP streaming from test cameras
- Allow WebRTC connections
- Allow Microsoft/Google SSO redirects

## Data Setup Workflow

### For New Tests:

1. **Identify data requirements**
   - What accounts/devices/data does the test need?

2. **Check this document**
   - Is required data already documented?
   - Is it available in UAT?

3. **Request missing data**
   - Contact team to add data to UAT
   - Document data once available

4. **Update this document**
   - Add new data requirements
   - Include purpose and usage notes

### For CI Setup:

1. Verify all documented data exists in UAT
2. Run test suite to validate data availability
3. Report any missing or inconsistent data

## Data Consistency Rules

### DO:
- ✅ Use data documented in this file
- ✅ Keep test data stable over time
- ✅ Document new data requirements
- ✅ Clean up obsolete data references

### DON'T:
- ❌ Create random test data in tests
- ❌ Hardcode production data
- ❌ Rely on temporary test accounts
- ❌ Use developers' personal accounts

## Data Isolation

**Important:** UITests should not interfere with each other

**Guidelines:**
- Use unique data for each test when possible
- Clean up created data in tearDown() if test modifies state
- Avoid tests that depend on specific data order
- Consider data conflicts when running tests in parallel

## Maintenance

### Regular Reviews:

**Monthly:**
- Verify test accounts are active
- Confirm test devices are online
- Check floor plan data integrity

**Quarterly:**
- Review and clean up obsolete data
- Update documentation with new requirements
- Validate consistency with actual UAT state

### When Tests Fail:

Check if failure is due to missing/changed test data:
1. Verify account credentials still work
2. Confirm devices are accessible
3. Check floor plans and camera placements exist
4. Update this document if data requirements changed

## Coordinate with Team

Before making UAT data changes:
- Notify team of planned changes
- Avoid changing data during CI test runs
- Document changes in git commits
- Update this file to reflect new state

## Future Requirements

As new features are tested, document required test data:

- [ ] Message filtering test data
- [ ] Archive video samples
- [ ] NVR configuration test data
- [ ] License tier test scenarios
- [ ] Organization hierarchy data
- [ ] User permission matrix

## Contact

For UAT environment access or data setup:
- Backend Team: [Contact info]
- QA Team: [Contact info]
- Test Account Manager: Ryan Chen (ryan.cl.chen@vivotek.com)
