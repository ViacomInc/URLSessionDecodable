# Contributing

> Before contributing, please read our [code of conduct](CODE_OF_CONDUCT.md).

When contributing to this repository, please first discuss the change you wish to make by opening an issue on this repository.

Please note we have a code of conduct, please follow it in all your interactions with the project.

## Setup

Make sure you have Xcode installed, at least in 11.4 version.

## Running Tests

To run the unit tests from terminal you can use a following command:

```bash
# runs all unit tests
swift test
```

You can also run them from an Xcode project, by opening `Package.swift` with Xcode.

For Linux, all tests to be run are specified under `Tests/URLSessionDecodableTests/XCTestManifests.swift`. This is because the XCTest runtime is not able to find them on Linux systems. If you are adding tests, make sure to run `swift test --generate-linuxmain` which will update the file.

## Code Standards

**Linting and formatting**

We use [SwiftLint](https://github.com/realm/SwiftLint) to take care of proper formatting and linting. You can run the linter from Terminal by following its installation guide and executing `swiftlint` in the repository's root folder.

## Pull Request Process

1. Fork it
2. Create your feature branch `git checkout -b feature/my-new-feature`
3. Commit your changes through `git commit`
4. Push to the branch `git push origin feature/my-new-feature`
5. Create a new [Pull Request](https://github.com/ViacomInc/URLSessionDecodable/compare)
