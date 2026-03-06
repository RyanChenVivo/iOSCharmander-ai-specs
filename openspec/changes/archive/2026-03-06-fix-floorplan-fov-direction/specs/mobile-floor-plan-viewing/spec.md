## MODIFIED Requirements

### Requirement: Camera Field of View Overlay
The system SHALL display pre-configured camera field-of-view (FOV) sectors on the floor plan with unified color scheme based on device status and selection state.

#### Scenario: Display FOV sector for camera
- **WHEN** camera has FOV configuration (angle, direction, depth)
- **THEN** system renders FOV sector overlay
- **AND** sector originates from camera marker position
- **AND** sector displays configured angle, direction, and depth

#### Scenario: FOV direction uses geographic-to-SwiftUI coordinate conversion
- **WHEN** system renders FOV sector direction
- **THEN** system SHALL convert `fovDirection` from geographic coordinate system (0° = North, clockwise) to SwiftUI rendering coordinate system (0° = East, clockwise with Y-axis down)
- **AND** the conversion formula SHALL be: `renderAngle = fovDirection - 90°`
- **AND** a `fovDirection` of 0° (North) SHALL render the FOV sector pointing upward on screen
- **AND** a `fovDirection` of 90° (East) SHALL render the FOV sector pointing right on screen
- **AND** a `fovDirection` of 180° (South) SHALL render the FOV sector pointing downward on screen
- **AND** a `fovDirection` of 270° (West) SHALL render the FOV sector pointing left on screen

#### Scenario: Online device FOV color
- **WHEN** device status is online
- **AND** device is not selected
- **THEN** FOV sector displays in green (#2FBB00) at 0.2 opacity

#### Scenario: Offline device FOV color
- **WHEN** device status is offline
- **AND** device is not selected
- **THEN** FOV sector displays in gray (#8F8F8F) at 0.2 opacity

#### Scenario: Updating device FOV color
- **WHEN** device is updating firmware
- **AND** device is not selected
- **THEN** FOV sector displays in orange (#FF9600) at 0.2 opacity

#### Scenario: Selected device FOV color
- **WHEN** device is selected
- **THEN** FOV sector displays in blue (#2986FF) at 0.3 opacity
- **AND** blue color overrides status-based color

#### Scenario: 360-degree camera FOV
- **WHEN** device FOV angle is 360 degrees
- **THEN** system renders full circle instead of cone sector
- **AND** circle is centered at camera marker position
- **AND** color follows same status/selection rules

#### Scenario: FOV depth animation
- **WHEN** device selection state changes
- **THEN** FOV depth animates smoothly with spring animation
- **AND** selected device FOV extends slightly for emphasis

### Requirement: Camera Device Visualization
The system SHALL display multiple camera devices on the floor plan at their configured positions with visual markers indicating device status.

#### Scenario: Display camera markers at positions
- **WHEN** floor plan detail view loads device positions
- **THEN** system displays camera marker for each device at normalized coordinates (0-1)
- **AND** each marker shows camera icon
- **AND** markers are positioned accurately on floor plan image

#### Scenario: Camera marker size
- **WHEN** displaying camera marker on floor plan
- **THEN** marker circle SHALL be 24x24 pt
- **AND** device type icon inside marker SHALL be 20x20 pt
- **AND** marker size SHALL be consistent across all device states (online, offline, updating)

#### Scenario: Selected device marker highlight
- **WHEN** device is selected
- **THEN** marker displays blue background (#2986FF)
- **AND** marker displays blue border (#154380, 4px stroke)
- **AND** device type icon remains white
- **AND** animation uses spring effect
