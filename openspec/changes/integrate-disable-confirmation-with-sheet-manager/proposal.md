# Proposal: Integrate DisableConfirmation with SheetManager

## Problem

DisableConfirmation currently uses a ViewModifier pattern (`.disableConfirmation(type:onConfirm:cancelAction:)`), which is inconsistent with how other confirmation dialogs are managed in the app. This creates:

1. **Inconsistent Architecture**: Other confirmation dialogs use SheetManager, but DisableConfirmation uses ViewModifier
2. **Scattered State Management**: Loading state is managed within ViewModifier instead of centrally in SheetManager
3. **Code Duplication**: ViewModifier duplicates loading and error handling logic
4. **Different Patterns**: DeleteConfirmation uses SheetManager while DisableConfirmation doesn't

## Solution

Refactor DisableConfirmation to integrate with SheetManager:

1. Add `openDisableConfirmation(type:onConfirm:cancelAction:)` method to SheetManager
2. SheetManager manages loading state using `startLoading()` / `stopLoading()`
3. Completely remove DisableConfirmationViewModifier and View extension
4. Update SheetManagerProtocol to include the new method
5. Update MockSheetManager to implement the new method
6. Update AIControlSettingsView to use SheetManager instead of ViewModifier
7. DisableConfirmation view receives closures directly (no ViewModel needed)

## Design Decisions

1. **No ViewModel**: Unlike DeleteConfirmation, DisableConfirmation has no business logic of its own - it just receives closures from the caller
2. **Error Handling**: Calling view (AIControlSettingsView) handles errors through the onConfirm closure
3. **Loading State**: SheetManager manages loading centrally (consistent with DeleteConfirmation)
4. **Cancel Action**: Keep optional cancelAction parameter for flexibility
5. **Legacy Code**: Completely remove ViewModifier, unify on SheetManager

## Benefits

- **Consistency**: All confirmation dialogs use SheetManager
- **Maintainability**: Centralized loading state management
- **Simplicity**: No unnecessary ViewModel layer
- **Clarity**: Business logic stays in AIControlSettingsView where it belongs

## Impact

- **Breaking Change**: None (only AIControlSettingsView currently uses it)
- **Migration**: Update AIControlSettingsView.swift to use SheetManager
- **Testing**: No new unit tests needed (business logic remains in existing ViewModel)

## Related

References SheetManager pattern (SheetManager.swift:578)
