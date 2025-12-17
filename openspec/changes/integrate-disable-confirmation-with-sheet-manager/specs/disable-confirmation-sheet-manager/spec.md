# Spec: DisableConfirmation SheetManager Integration

## ADDED Requirements

### Requirement: SheetManager provides DisableConfirmation presentation interface

SheetManager MUST provide a method to present DisableConfirmation and manage loading state.

#### Scenario: Open DisableConfirmation through SheetManager

**Given** user needs to display DisableConfirmation
**When** calling `SheetManager.shared.openDisableConfirmation(type:onConfirm:cancelAction:)`
**Then** SheetManager presents DisableConfirmation view using `present()`
**And** DisableConfirmation receives the onConfirm and cancelAction closures

#### Scenario: Execute confirm action with loading management

**Given** DisableConfirmation is displayed
**When** user types "DISABLE" and taps confirm button
**Then** DisableConfirmation calls dismiss on SheetManager
**And** SheetManager calls `startLoading(isAutoClose: false)`
**And** DisableConfirmation executes the onConfirm closure
**And** if onConfirm succeeds, SheetManager calls `stopLoading()`
**And** if onConfirm throws error, SheetManager calls `stopLoading()` and caller handles error

#### Scenario: Execute custom action when canceling

**Given** DisableConfirmation is displayed
**When** user taps cancel button
**And** cancelAction callback was provided
**Then** executes cancelAction callback
**And** calls `SheetManager.shared.dismiss()`

#### Scenario: Cancel without custom action

**Given** DisableConfirmation is displayed
**When** user taps cancel button
**And** no cancelAction was provided (nil)
**Then** calls `SheetManager.shared.dismiss()`

### Requirement: SheetManagerProtocol includes DisableConfirmation method

SheetManagerProtocol MUST define openDisableConfirmation method for protocol conformance.

#### Scenario: Protocol defines openDisableConfirmation

**Given** SheetManagerProtocol definition
**When** checking protocol method list
**Then** includes `openDisableConfirmation(type:onConfirm:cancelAction:)` method signature

#### Scenario: MockSheetManager implements openDisableConfirmation

**Given** MockSheetManager is used for testing
**When** calling `openDisableConfirmation(type:onConfirm:cancelAction:)`
**Then** MockSheetManager correctly records the call
**And** can be verified in tests

## MODIFIED Requirements

### Requirement: DisableConfirmation View receives closures directly

DisableConfirmation view MUST receive onConfirm and cancelAction closures as parameters instead of managing them in ViewModifier.

#### Scenario: DisableConfirmation handles confirm through closure

**Given** DisableConfirmation view is initialized with onConfirm closure
**When** user types "DISABLE" and taps confirm button
**Then** executes the onConfirm closure
**And** SheetManager manages loading state
**And** errors are thrown back to caller (AIControlSettingsView)

#### Scenario: DisableConfirmation handles cancel through closure

**Given** DisableConfirmation view is initialized with optional cancelAction
**When** user taps cancel button
**Then** executes cancelAction if provided
**And** calls SheetManager.dismiss()

### Requirement: DisableConfirmation removes internal loading state

DisableConfirmation view MUST NOT manage its own loading state - SheetManager handles it.

#### Scenario: No internal loading state in DisableConfirmation

**Given** DisableConfirmation view implementation
**When** checking view properties
**Then** does not have @State isLoading property
**And** does not have .fullScreenProgressView modifier
**And** SheetManager manages all loading state

## REMOVED Requirements

### Requirement: DisableConfirmationViewModifier is removed

ViewModifier pattern is completely removed, unified to use SheetManager.

#### Scenario: No longer use .disableConfirmation() modifier

**Given** View needs to display DisableConfirmation
**When** checking available APIs
**Then** `.disableConfirmation()` View extension does not exist
**And** DisableConfirmationViewModifier does not exist
**And** must use `SheetManager.shared.openDisableConfirmation()`
