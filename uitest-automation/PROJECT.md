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
├── TESTING_GUIDE.md                    # How to fix UITest failures (future)
├── analyze_uitest_failures.sh          # Main analysis script
├── analyze-uitest-command.md           # Legacy command documentation
├── config.example.sh                   # Configuration template
├── README.md                           # Quick start guide
├── SETUP.md                            # Detailed setup instructions
├── GUIDE.md                            # Usage guide
├── CHECKLIST.md                        # Setup verification checklist
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
1. **Fetch Results** - Run `analyze_uitest_failures.sh -d today` to download CI test results
2. **Analyze Failures** - Review `ANALYSIS_REPORT.md`, screenshots, and error messages
3. **Diagnose Root Cause** - Categorize: external dependency, timing, test bug, or app change
4. **Apply Fix** - Either create OpenSpec proposal or fix test directly
5. **Update Documentation** - Record patterns in `test-specs/` for future reference

**Key Resources:**
- `ANALYSIS_REPORT.md` - Generated failure summary
- `attachments/*.png` - Screenshots showing actual UI state
- `test_failures.json` - Detailed error messages
- `test-specs/external-dependencies.md` - Known external service issues
- Claude command: `/analyze-uitest` (existing)

## CI Test Environment

**CI Machine:**
- Host: `vivotekinc@10.15.254.191`
- Reports: `/Users/vivotekinc/Documents/CICD/UITestReport/`
- Format: `{YYYY-MM-DD}.xcresult`

**Test Environment:**
- Simulator: iPhone 13 Pro Max
- iOS Version: 17.0+
- Backend: UAT environment (`https://uat.vivotek.com`)

**Access:**
- SSH key authentication required
- See `SETUP.md` for configuration instructions

## Analysis Output

**Location:** `~/Downloads/UITestAnalysis/{YYYY-MM-DD}/`

**Contents:**
- `ANALYSIS_REPORT.md` - Human-readable summary
- `test_summary.json` - Test statistics
- `test_failures.json` - Failure details
- `test_details.json` - Full test tree
- `attachments/` - Screenshots (34 PNG), videos (3 MP4), logs (14 TXT)
- `diagnostics/` - Crash reports and diagnostic data

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
   ├─ Run analyze_uitest_failures.sh
   ├─ Review analysis output
   └─ Fix and document patterns
```

## Configuration

**Local Setup:**
1. Copy `config.example.sh` to `config.sh` (in repository root, not tracked by git)
2. Verify CI machine connection: `ssh vivotekinc@10.15.254.191`
3. Test analysis: `./uitest-automation/analyze_uitest_failures.sh -d today`

**Configuration Variables:**
- `CI_MACHINE` - SSH connection string (default: vivotekinc@10.15.254.191)
- `CI_REPORT_BASE` - Remote path to test reports
- `IOSCHARMANDER_PATH` - Local path to main project
- `OUTPUT_DIR` - Local analysis output directory

See `SETUP.md` for detailed setup instructions.

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

- [ ] `TESTING_GUIDE.md` - Comprehensive guide for failure diagnosis
- [ ] `/write-uitest` Claude command - Guided test implementation
- [ ] Automated test-specs/ updates from simulator discoveries
- [ ] Integration with OpenSpec for automatic change tracking
- [ ] Historical failure pattern analysis
- [ ] Automated flaky test detection and reporting

## Support

For questions or issues:
1. Check `README.md` for quick answers
2. Review `GUIDE.md` for detailed usage
3. Consult `CHECKLIST.md` for setup verification
4. Contact: Ryan Chen (ryan.cl.chen@vivotek.com)
