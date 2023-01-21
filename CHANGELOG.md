# Change log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.7.0] - 2023-01-21
### Added

- Add constructor option to build the card with the back face #56 - @Delgan
- Added tests for skew() & hint() - @ciriousjoker
- Added web platform to example - @ciriousjoker
- skew(), hint() & toggleCard() are now async and complete after the animation is done - @ciriousjoker
- Added one-time autoFlip feature without a FlipCardController. - @aydinfatih
- Added function toggleCardWithoutAnimation to the controller that toggles the card instantly. - @Moseco

### Fixed

- isFront is incorrectly updated for skew & hint #60 - @ciriousjoker
- Inaccurate controller state - @lwbvv

# 0.6.0
POSSIBLY BREAKING: Changed isFlip to change *after* the animation if finished or discarded.
Add: New expand option to size the front or back card to the other to maintain the illusion of an animation.

# 0.4.4
Change: Change back transform entry v  

# 0.4.3
Change: Change transform entry v to 0  

# 0.4.2
Add: Add animation completed callback

# 0.4.1
Change: Change animation to easeInOut from linear

# 0.4.0
Change: Stack layout fit to StackFit.passthrough from StackFit.expand

# 0.3.0
Added: Optional mode where the card can only be flipped programmatically

# 0.2.2
Added: Support speed params and expose call back when flip triggered
Fixed: Absorb the event for Back side

## 0.2.1
Updated: Description and screenshots

## 0.2.0
Added: Support vertical direction 
Added: Support speed as a params
