fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios unit_tests
```
fastlane ios unit_tests
```
Run unit tests
### ios automation_tests
```
fastlane ios automation_tests
```
Run automation test
### ios tests
```
fastlane ios tests
```
Run all tests
### ios release_core
```
fastlane ios release_core
```
Publish Core SDK
### ios release_ui
```
fastlane ios release_ui
```
Publish UI SDK
### ios release
```
fastlane ios release
```
Release core and UI SDKs
### ios release_objc
```
fastlane ios release_objc
```
Publish ObjC Wrapper SDK
### ios linter
```
fastlane ios linter
```
Run linter
### ios documentation
```
fastlane ios documentation
```
Generate documentation
### ios update_documentation
```
fastlane ios update_documentation
```
Update remote documentation

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
