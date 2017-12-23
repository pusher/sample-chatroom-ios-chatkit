# PusherPlatform (pusher-platform-swift)

[![BuddyBuild](https://dashboard.buddybuild.com/api/statusImage?appID=59c51e712ffc62000182d7c9&branch=master&build=latest)](https://dashboard.buddybuild.com/apps/59c51e712ffc62000182d7c9/build/latest?branch=master)
[![Twitter](https://img.shields.io/badge/twitter-@Pusher-blue.svg?style=flat)](http://twitter.com/Pusher)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/pusher/pusher-platform-swift/master/LICENSE.md)


## Table of Contents

* [Installation](#installation)
* [Testing](#testing)
* [Communication](#communication)
* [License](#license)


## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects and is our recommended method of installing PusherPlatform and its dependencies.

If you don't already have the Cocoapods gem installed, run the following command:

```bash
$ gem install cocoapods
```

Then run `pod init` to create your `Podfile` (if you don't already have one).

Next, add the following lines to it:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0' # change this if you're not making an iOS app!
use_frameworks!

# Replace `<Your Target Name>` with your app's target name.
target '<Your Target Name>' do
  pod 'PusherPlatform'
end
```

Then, run the following command:

```bash
$ pod install
```

If you find that you're not having the most recent version installed when you run `pod install` then try running:

```bash
$ pod repo update
$ pod install
```

Also you'll need to make sure that you've not got the version of PusherPlatform locked to an old version in your `Podfile.lock` file.

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate PusherPlatform into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "pusher/pusher-platform-swift"
```

### Directly using a framework

```
TODO
```


### Getting started

First we need to have an instance of an `Instance`. To create an `Instance` we need to pass in `instanceId`, `serviceName`, and `serviceVersion`. You can get your instance ID from the dashboard.

```swift
let instance = Instance(instanceId: "instance-id", serviceName: "service-name", serviceVersion: "service-version")
```

The `Instance` instance allows you to interact with the service using the Elements protocol. The high level methods it exposes are:

- `request` and `requestWithRetry` for standard HTTP requests
- `subscribe` for subscriptions
- `subscribeWithResume` for subscriptions that you can resume from the last received event ID


## Testing

There are a set of tests for the library that can be run using the standard method (Command-U in Xcode).

The tests also get run on [buddybuild](https://dashboard.buddybuild.com/apps/59c51e712ffc62000182d7c9/build/latest?branch=master). See [buddybuild_postbuild.sh](https://github.com/pusher/pusher-platform-swift/blob/master/buddybuild_postbuild.sh) for details on how the tests are run.


## Communication

- Found a bug? Please open an [issue](https://github.com/pusher/pusher-platform-swift/issues).
- Have a feature request. Please open an [issue](https://github.com/pusher/pusher-platform-swift/issues).
- If you want to contribute, please submit a [pull request](https://github.com/pusher/pusher-platform-swift/pulls) (preferrably with some tests 🙂 ).


## License

PusherPlatform is released under the MIT license. See [LICENSE](https://github.com/pusher/pusher-platform-swift/blob/master/LICENSE.md) for details.
