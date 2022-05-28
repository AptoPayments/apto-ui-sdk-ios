fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios unit_tests

```sh
[bundle exec] fastlane ios unit_tests
```

Run unit tests

### ios automation_tests

```sh
[bundle exec] fastlane ios automation_tests
```

Run automation test

### ios tests

```sh
[bundle exec] fastlane ios tests
```

Run all tests

### ios release_core

```sh
[bundle exec] fastlane ios release_core
```

Publish Core SDK

### ios release_twilio_voip

```sh
[bundle exec] fastlane ios release_twilio_voip
```

Publish Twilio VoIP wrapper

### ios test_implementation

```sh
[bundle exec] fastlane ios test_implementation
```

test_implementation

### ios release_ui

```sh
[bundle exec] fastlane ios release_ui
```

Publish UI SDK

### ios release

```sh
[bundle exec] fastlane ios release
```

Release core and UI SDKs

### ios release_objc

```sh
[bundle exec] fastlane ios release_objc
```

Publish ObjC Wrapper SDK

### ios linter

```sh
[bundle exec] fastlane ios linter
```

Run linter

### ios documentation

```sh
[bundle exec] fastlane ios documentation
```

Generate documentation

### ios update_documentation

```sh
[bundle exec] fastlane ios update_documentation
```

Update remote documentation

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
