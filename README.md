# Hydra

![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)
[![Swift Version](https://img.shields.io/badge/swift-4.2-F16D39.svg?style=flat)](https://developer.apple.com/swift)
[![GitHub license](https://img.shields.io/github/license/mudox/hydra.svg)](https://github.com/mudox/hydra/blob/master/LICENSE)
[![Travis (.com)](https://img.shields.io/travis/com/mudox/hydra.svg)](https://travis-ci.com/mudox/hydra)
[![codecov](https://codecov.io/gh/mudox/hydra/branch/master/graph/badge.svg)](https://codecov.io/gh/mudox/hydra)
[![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/mudox/hydra.svg)](https://codeclimate.com/github/mudox/hydra/maintainability)

Hydra is an unofficial iOS client app for GitHub. I use it to keep practicing
various technologies I learned in community.

## Project Targets

- [x] UI/UX designing process.
- [x] [MVVM] (with [RxSwift]) architecture.
- [x] Use [FRP] paradigm as much as possible, use it correctly.
- [x] Construct solid network abstraction layer ([GitHubKit]) using state-of-arts techniques.
- [x] Utilize CI automation tools.
- [x] Get rid of interface builder (no .xib, .storyboard files), full code which is git friendly and good for future maintaining.
- [ ] Unit tested.
- [ ] UI tested.
- [ ] Decent code coverage.

## Technologies

### Requirements

- [x] Xcode 10
- [x] Swift 4.2

### Architecture

- [x] MVVM with [RxSwift]
- [x] Flow

Simply put, flow + view model + view controller + view.

### Network technique stack

- [x] [Alamofire] + [RxAlamofire] for simple request case
- [x] [Moya] to construct network abstraction layer
- [x] [RxSwift] to provide reactive interface
- [x] [GitHubKit] as Swift client of GitHub API

### F.R.P (Functional Reactive Programming)

- [x] [RxSwift] the Swift implementation of [ReactiveX]
- [x] [RxSwiftExt] as extension library for [RxSwift]
- [x] [RxDataSources] + [RxRealmDataSources] to drive table views and collection views
- [x] [RxGesture] to install and use gesture recognizers reactively

### UI

- [x] [Sketch.app] for static scene & artwork design
- [ ] [Principle.app] for UI interaction design

### Data Model

- [x] [SwiftyUserDefaults] to access UserDefaults safely
- [ ] [Realm] + [RxRealm] +  to construct local data model layer

### Testing

- [x] [JacKit] for better logging
- [x] [Quick] + [Nimble] + [RxNimble] to write test cases
- [x] [RxTest] + [RxBlocking] to test RxSwift observables
- [x] [OHHTTPStubs] to stub network requests
- [ ] [Swinject] to inverse dependencies

### Code quality

- [x] [SwiftFormat] to prettify Swift code
- [x] [SwiftLint] to keep code's quality

### CI solution

- [x] [fastlane] to automate development steps
- [x] [Travis CI] as CI provider
- [x] [codecov.io] as code coverage service
- [x] [Code Climate] to keep code maintainability
- [ ] [Danger] to automate pull request managements and other developing chores

### Other

- [ ] [SocialKit] for social sharing
- [x] [Graffle.app] to draw concept designing charts

## Author

Mudox

## License

Hydra is available under the MIT license. See the LICENSE file for more info.

[FRP]: https://en.wikipedia.org/wiki/Functional_reactive_programming
[GitHub APIv3]: https://developer.github.com/v3
[Moya]: https://github.com/Moya/Moya
[Quick]: https://github.com/Quick/Quick
[Nimble]: https://github.com/Quick/Nimble
[RxSwift]: https://github.com/ReactiveX/RxSwift
[RxTest]: https://github.com/ReactiveX/RxSwift
[RxBlocking]: https://github.com/ReactiveX/RxSwift
[Alamofire]: https://github.com/Alamofire/Alamofire
[GitHubKit]: https://github.com/mudox/github-kit
[SwiftLint]: https://github.com/realm/SwiftLint
[SwiftFormat]: https://github.com/nicklockwood/SwiftFormat
[fastlane]: https://fastlane.tools
[Travis CI]: https://travis-ci.com
[codecov.io]: https://codecov.io
[Code Climate]: https://codeclimate.com
[RxNimble]: https://github.com/RxSwiftCommunity/RxNimble
[OHHTTPStubs]: https://github.com/AliSoftware/OHHTTPStubs
[Danger]: https://danger.systems/rub
[RxGesture]: https://github.com/RxSwiftCommunity/RxGesture
[RxAlamofire]: https://github.com/RxSwiftCommunity/RxAlamofire
[Action]: https://github.com/RxSwiftCommunity/Action
[RxDataSources]: https://github.com/RxSwiftCommunity/RxDataSources
[RxSwiftExt]: https://github.com/RxSwiftCommunity/RxSwiftExt
[RxRealm]: https://github.com/RxSwiftCommunity/RxRealm
[Swinject]: https://github.com/Swinject/Swinject
[SwiftyUserDefaults]: https://github.com/radex/SwiftyUserDefaults
[Realm]: https://realm.io
[RxRealm]: https://github.com/RxSwiftCommunity/RxRealm
[RxRealmDataSources]: https://github.com/RxSwiftCommunity/RxRealmDataSources
[SocialKit]: https://github.com/mudox/social-kit
[JacKit]: https://github.com/mudox/jac-kit
[Sketch.app]: https://www.sketchapp.com/com
[Principle.app]: http://principleformac.com
[ReactiveX]: http://reactivex.io
[MVVM]: https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel
