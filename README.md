# Highrise Interview Client (iOS)

This is a stub application for building a basic backend using the `highrise-interview-model` base for model objects with Flatbuffers. The application requires the latest Xcode which can be installed on the Mac App Store.

_Line 18_ of `ViewController.swift` has a placeholder for a websocket address that needs to be updated before this will connect to any service.

- Required: Xcode 9
- Optional: Carthage (installed via Homebrew `brew install carthage`). Carthage builds are already included in repository so it should _just work_.
	- If required, execute `carthage update` to refresh required libraries.

## Setup

1. Clone repository.
2. Pull in submodules with `git submodule update --init`.
3. Open `ClientWorld.xcodeproj`
