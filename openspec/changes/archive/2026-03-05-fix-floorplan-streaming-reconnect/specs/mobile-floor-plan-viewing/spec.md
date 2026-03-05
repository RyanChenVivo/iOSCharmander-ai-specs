## MODIFIED Requirements

### Requirement: Split-Screen Layout with Streaming
The system SHALL display floor plan and live streaming in adaptive split-screen layout based on device orientation, using a persistent view structure that preserves streaming connection across layout changes.

#### Scenario: Portrait split-screen layout
- **WHEN** device is in portrait orientation
- **AND** camera is selected
- **THEN** system displays floor plan in top half
- **AND** displays streaming panel in bottom half
- **AND** each section occupies 50% of screen height

#### Scenario: Landscape split-screen layout
- **WHEN** device is in landscape orientation
- **AND** camera is selected
- **THEN** system displays floor plan in left half
- **AND** displays streaming panel in right half
- **AND** each section occupies 50% of screen width

#### Scenario: Orientation change with active streaming
- **WHEN** device orientation changes
- **AND** streaming is active
- **THEN** system animates layout transition with 0.3s easeInOut
- **AND** streaming connection SHALL NOT be interrupted or reconnected
- **AND** adapts split direction to new orientation
- **AND** StreamingViewWrapper identity SHALL remain unchanged across orientation transitions

#### Scenario: Streaming panel view identity persistence
- **WHEN** layout changes due to orientation change or fullscreen toggle
- **THEN** SelectedDeviceInfoPanel SHALL be a single persistent instance in the view tree
- **AND** system SHALL NOT use conditional view branches (if-else) that create different SwiftUI view identities for the streaming panel
- **AND** layout differences SHALL be achieved through frame, alignment, and opacity properties

### Requirement: Full-Screen Streaming Mode
The system SHALL provide full-screen streaming mode with smooth transitions that preserve streaming connection.

#### Scenario: Enter full-screen streaming
- **WHEN** user taps fullscreen button in streaming header
- **THEN** system transitions to full-screen mode
- **AND** floor plan view hides (opacity 0)
- **AND** streaming panel expands to fill entire screen
- **AND** header remains visible with controls
- **AND** animation duration is 0.3s easeInOut
- **AND** streaming connection SHALL NOT be interrupted

#### Scenario: Exit full-screen streaming
- **WHEN** user taps minimize button in full-screen mode
- **THEN** system transitions back to split-screen
- **AND** floor plan view reappears (opacity 1)
- **AND** streaming panel returns to 50% size
- **AND** animation duration is 0.3s easeInOut
- **AND** streaming connection SHALL NOT be interrupted

#### Scenario: Orientation change during full-screen streaming
- **WHEN** device orientation changes during full-screen streaming mode
- **THEN** streaming panel remains full-screen
- **AND** streaming connection SHALL NOT be interrupted
- **AND** safe area handling adapts to new orientation
