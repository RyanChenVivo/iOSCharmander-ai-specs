# UITest Automation Infrastructure

## Purpose

This directory contains tools and documentation for automated UITest failure analysis and test development guidance. It serves two main purposes:

1. **Failure Analysis:** Automated tools to fetch, analyze, and diagnose UITest failures from CI
2. **Test Development:** Knowledge base and guidelines for writing new UITests

## Target Audience

- **AI Assistants:** Primary consumers of this documentation for automated test development and failure diagnosis
- **Developers:** Reference for understanding test infrastructure and conventions
- **CI/CD:** Automated analysis tools integrated into testing workflow

## Directory Structure

```
uitest-automation/
├── PROJECT.md                          # This file - infrastructure overview
├── README.md                           # Quick start and usage guide
├── SETUP.md                            # Setup instructions
├── download_test_data.sh              # Download lightweight JSON from CI
├── config.example.sh                   # Configuration template
│
├── ci-scripts/                         # Scripts to run on CI machine
│   ├── extract_uitest_data.sh         # Extract data from .xcresult
│   └── README.md                      # CI scripts deployment guide
│
└── test-specs/                         # UITest Knowledge Base
    ├── ui-identifiers.md               # Accessibility IDs for UI elements
    ├── test-data.md                    # Test data requirements (UAT environment)
    ├── timing-guidelines.md            # Wait times and timeout values
    └── external-dependencies.md        # Known external API/service behaviors
```

## Two Modes of Operation

### Mode 1: Writing New UITests

**When:** Implementing UITests for new features or expanding test coverage

**Workflow:**
1. **Explore Feature** - Use `ios-simulator-mcp` to discover UI elements and behavior
2. **Check Knowledge Base** - Consult `test-specs/` for existing IDs and test data
3. **Review Conventions** - Follow patterns from `openspec/project.md` (UI Test Implementation Rules)
4. **Implement Test** - Write test code following project conventions
5. **Update Knowledge Base** - Add discovered IDs and data requirements to `test-specs/`

**Key Resources:**
- `openspec/project.md` - Testing conventions and patterns (lines 263-340)
- `test-specs/ui-identifiers.md` - UI element accessibility IDs
- `test-specs/test-data.md` - Available test accounts and data
- Claude command: `/write-uitest` (future)

### Mode 2: Fixing Failed UITests

**When:** UITests fail on CI and need diagnosis/repair

**Workflow:**
1. **Download Data** - Run `download_test_data.sh` to fetch lightweight JSON (~100KB, 10-30 sec)
2. **AI Triage** - Claude analyzes failures and categorizes them
3. **User Decision** - Choose action based on triage:
   - A: Create OpenSpec proposal
   - B: Download screenshots for deeper analysis
   - C: Observe tomorrow (likely transient)
   - D: No action (known issue)
4. **Apply Fix** (if chose A) - Implement fix via OpenSpec workflow
5. **Update Documentation** - Record patterns in `test-specs/` for future reference

**Key Resources:**
- `metadata.json` - Test statistics and summary
- `test_failures.json` - Detailed error messages
- `test_details.json` - Exact line numbers
- `attachments/*.png` - Screenshots (downloaded only when needed)
- `test-specs/external-dependencies.md` - Known external service issues
- Claude command: `/analyze-uitest`

## CI Test Environment

**CI Machine:**
- Host: `vivotekinc@10.15.254.191`
- XCResult: `/Users/vivotekinc/Documents/CICD/UITestReport/{YYYY-MM-DD}.xcresult`
- Extracted Data: `/Users/vivotekinc/Documents/CICD/UITestAnalysisData/{YYYY-MM-DD}/`
- Latest Link: `/Users/vivotekinc/Documents/CICD/UITestAnalysisData/latest` (symlink)

**Test Environment:**
- Simulator: iPhone 13 Pro Max
- iOS Version: 17.0+
- Backend: UAT environment (`https://uat.vivotek.com`)

**Access:**
- SSH key authentication required
- See `SETUP.md` for configuration instructions

**Data Flow:**
```
.xcresult (200-500 MB)
  → extract_uitest_data.sh (runs on CI)
  → UITestAnalysisData/ (5-20 MB)
  → download_test_data.sh (downloads to local, ~100KB JSON only)
  → AI Triage Analysis
```

## Analysis Output

**CI Location:** `/Users/vivotekinc/Documents/CICD/UITestAnalysisData/{YYYY-MM-DD}/`

**CI Contents:**
- `metadata.json` - Test statistics summary
- `test_summary.json` - Test results summary
- `test_details.json` - Full test tree with exact line numbers
- `test_failures.json` - Failure details (only if failures exist)
- `failed_test_ids.txt` - List of failed test IDs
- `attachments/` - Screenshots (videos removed to save space)
- `diagnostics/` - Crash reports and diagnostic data

**Local Location (after download):** `~/Downloads/UITestAnalysis/latest/`

**Local Contents:**
- `metadata.json` - Test statistics
- `test_summary.json` - Test results
- `test_details.json` - Full test tree
- `test_failures.json` - Failure details
- `failed_test_ids.txt` - Failed test IDs
- `attachments/` - (Downloaded separately if needed)

## Test Specs Knowledge Base

The `test-specs/` directory contains concrete, environment-specific information that complements the general principles in `openspec/project.md`:

### Purpose of Each Spec

| File | Contains | Used For |
|------|----------|----------|
| `ui-identifiers.md` | Accessibility IDs of UI elements | Writing tests, locating elements |
| `test-data.md` | Test accounts, devices, floor plans | Setting up test prerequisites |
| `timing-guidelines.md` | Wait times for different operations | Setting appropriate timeouts |
| `external-dependencies.md` | Known behaviors of external services | Understanding environmental failures |

### Why Separate from project.md?

**project.md** provides **principles and patterns** (how to write tests, naming conventions, architecture)

**test-specs/** provides **concrete data** (what IDs exist, what data is available, actual timeout values)

This separation allows:
- Project conventions to remain stable
- Environment-specific data to be updated independently
- Easy discovery of available test resources
- Knowledge accumulation from simulator exploration

## Relationship with OpenSpec

**UITest infrastructure changes** are managed through OpenSpec when they represent intentional modifications:

### Use OpenSpec For:
- External dependency behavior changes (e.g., Microsoft SSO UI change)
- Test framework upgrades
- New test pattern introductions
- CI environment modifications

### Fix Directly For:
- Test code bugs (wrong element ID, incorrect assertion)
- Timing adjustments
- Test data setup issues
- Documentation updates in test-specs/

## Development Workflow Integration

### Normal Development Flow:

```
1. Feature Development
   └─ openspec/changes/{feature}/
       ├─ proposal.md
       ├─ specs/{feature}/spec.md  (includes Testing Criteria)
       └─ tasks.md  (includes UITest implementation tasks)

2. UITest Implementation
   ├─ Use ios-simulator-mcp to explore feature
   ├─ Check test-specs/ for available resources
   ├─ Implement test following project.md patterns
   └─ Update test-specs/ with discoveries

3. CI Testing
   └─ Tests run automatically on push

4. Failure Analysis (if needed)
   ├─ Run download_test_data.sh
   ├─ Review analysis output
   └─ Fix and document patterns
```

## Configuration

**Local Setup:**
1. Verify CI machine connection: `ssh vivotekinc@10.15.254.191`
2. Test download: `./uitest-automation/download_test_data.sh`
3. Verify data: `ls ~/Downloads/UITestAnalysis/latest/`

**Configuration Variables (in download_test_data.sh):**
- `CI_MACHINE` - SSH connection string (vivotekinc@10.15.254.191)
- `CI_DATA_BASE` - Remote path to extracted data (/Users/vivotekinc/Documents/CICD/UITestAnalysisData)
- `OUTPUT_DIR` - Local analysis output directory ($HOME/Downloads/UITestAnalysis)

**CI Setup (one-time):**
1. Deploy `ci-scripts/extract_uitest_data.sh` to CI machine
2. Integrate into Jenkins UITest job
3. Verify data extraction after test run

See `SETUP.md` and `ci-scripts/README.md` for detailed setup instructions.

## Best Practices

### For Writing Tests:
1. **Always check test-specs/ first** - Avoid duplicating discovery work
2. **Use simulator-mcp** - Verify IDs exist before writing tests
3. **Document discoveries** - Update test-specs/ when you find new IDs or patterns
4. **Follow project.md** - Maintain consistency with established patterns

### For Fixing Tests:
1. **Read screenshots first** - They show ground truth of what happened
2. **Categorize failures** - Different root causes need different approaches
3. **Update documentation** - Record patterns in test-specs/ for future reference
4. **Consider OpenSpec** - If external dependency changed, document it properly

### For Maintaining Knowledge Base:
1. **Keep test-specs/ current** - Update when UAT environment changes
2. **Remove outdated info** - Clean up obsolete IDs or test data
3. **Add context** - Explain why certain timeouts or patterns exist
4. **Cross-reference** - Link to related OpenSpec changes when relevant

## Integration with iOS Simulator MCP

The `ios-simulator-mcp` tool is essential for UITest development:

**Discovery Phase:**
- `ui_view()` - Capture current screen state
- `ui_describe_all()` - List all accessible UI elements and their IDs
- `ui_describe_point(x, y)` - Identify specific element at coordinates
- `screenshot()` - Document UI states for comparison

**Validation Phase:**
- `ui_tap(x, y)` - Verify tap targets are accessible
- `ui_type(text)` - Test text input functionality
- `ui_swipe(...)` - Verify scrolling behavior

**Pattern:**
1. Navigate to feature using simulator-mcp
2. Use `ui_describe_all()` to discover accessibility IDs
3. Screenshot key states
4. Record findings in test-specs/ui-identifiers.md
5. Implement test using discovered IDs

## Future Enhancements

Planned improvements to this infrastructure:

- [ ] `/write-uitest` Claude command - Guided test implementation
- [ ] Automated test-specs/ updates from simulator discoveries
- [ ] Integration with OpenSpec for automatic change tracking
- [ ] Historical failure pattern analysis
- [ ] Automated flaky test detection and reporting

## Support

For questions or issues:
1. Check `README.md` for usage guide
2. Review `SETUP.md` for setup instructions
3. Check `ci-scripts/README.md` for CI deployment (admins only)
4. Contact: Ryan Chen (ryan.cl.chen@vivotek.com)
