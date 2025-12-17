# Tasks

## Implementation

- [x] Add openDisableConfirmation method to SheetManager (manages loading with startLoading/stopLoading)
- [x] Update SheetManagerProtocol to include new method signature
- [x] Update MockSheetManager to implement new method
- [x] Refactor DisableConfirmation view to receive closures and remove internal loading state
- [x] Completely remove DisableConfirmationViewModifier and View extension
- [x] Update AIControlSettingsView to use SheetManager.openDisableConfirmation
- [ ] Manually test refactored implementation

## Testing & Validation

- [ ] Verify UI behavior matches previous implementation
- [ ] Test all DisableConfirmationType cases (aiControlAgreement, facialRecognition, licensePlateRecognition, aiControlSettingForceContinue)
- [ ] Run existing tests to ensure no regressions
- [ ] Build project to verify no compilation errors
