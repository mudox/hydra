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

- [x] Practice UI/UX designing tool ([Sketch.app] etc.)
- [x] [MVVM] (with [RxSwift]) architecture.
- [x] Use [FRP] paradigm as much as possible, use it correctly.
- [x] Stand-alone network abstraction layer ([GitHubKit]) using state-of-art techniques.
- [x] Utilize CI automation tools.
- [x] Experiment IB-less UI developing (i.e. no .xib, .storyboard files, only source code).
- [ ] Unit tested.
- [ ] UI tested.
- [ ] Decent code coverage.

## Technologies

### Requirements

- [x] Xcode 10
- [x] Swift 4.2

### Designing

- [x] [Graffle.app] to do concept designing.
- [x] [Sketch.app] for static scene & artwork design.
- [ ] [Principle.app] for UI interaction design.

### Architecture

- [x] MVVM with [RxSwift]
- [x] Flow

Simply put, flow + view model + view controller + view.

### FRP

- [x] [RxSwift] the Swift implementation of [ReactiveX].
- [x] [RxSwiftExt] as extension library for [RxSwift].
- [x] [RxDataSources] + [RxRealmDataSources] to drive table views and collection views.
- [x] [Action] to bridge between background transactions and UI states.
- [ ] [RxGesture] to install and use gesture recognizers reactively.
- [ ] [RxTheme] to implement theme switching.

### Network

- [x] [Alamofire] + [RxAlamofire] for simple request case.
- [x] [Moya] to construct network abstraction layer.
- [x] [RxSwift] to provide reactive interface.

### Data Model

- [x] [SwiftyUserDefaults] to access UserDefaults type-safely.
- [ ] [Realm] + [RxRealm] +  to construct local data model layer.

### UI

- [ ] [Kingfisher] + [RxKingfisher] to manage images.

### Testing

- [x] [Quick] + [Nimble] + [RxNimble] to write test cases.
- [x] [RxTest] + [RxBlocking] to test RxSwift observables.
- [x] [OHHTTPStubs] to stub network requests.
- [ ] [Swinject] to inverse dependencies.

### Code quality

- [x] [SwiftFormat] to prettify Swift code.
- [x] [SwiftLint] to keep code's quality.

### CI

- [x] [fastlane] to automate development steps.
- [x] [Travis CI] as CI provider.
- [x] [codecov.io] as code coverage service.
- [x] [Code Climate] to keep code maintainability.
- [ ] [Danger] to automate pull request managements and other developing chores.

### My Own Libraries

- [x] [JacKit] for better logging.
- [x] [GitHubKit] as Swift client of GitHub API.
- [x] [MudoxKit] as my own iOS tool belt library.
- [x] [SocialKit] for social sharing.

### Other


## Author

Mudox

## License

Hydra is available under the MIT license. See the LICENSE file for more info.

[Action]: https://github.com/RxSwiftCommunity/Action
[Alamofire]: https://github.com/Alamofire/Alamofire
[Code Climate]: https://codeclimate.com
[Danger]: https://danger.systems/rub
[FRP]: https://en.wikipedia.org/wiki/Functional_reactive_programming
[GitHub APIv3]: https://developer.github.com/v3
[GitHubKit]: https://github.com/mudox/github-kit
[Graffle.app]: https://www.omnigroup.com/omnigraffle
[JacKit]: https://github.com/mudox/jac-kit
[MVVM]: https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel
[Moya]: https://github.com/Moya/Moya
[MudoxKit]: https://github.com/mudox/mudox-kit
[Nimble]: https://github.com/Quick/Nimble
[OHHTTPStubs]: https://github.com/AliSoftware/OHHTTPStubs
[Principle.app]: http://principleformac.com
[Quick]: https://github.com/Quick/Quick
[ReactiveX]: http://reactivex.io
[Realm]: https://realm.io
[RxAlamofire]: https://github.com/RxSwiftCommunity/RxAlamofire
[RxBlocking]: https://github.com/ReactiveX/RxSwift
[RxDataSources]: https://github.com/RxSwiftCommunity/RxDataSources
[RxGesture]: https://github.com/RxSwiftCommunity/RxGesture
[RxNimble]: https://github.com/RxSwiftCommunity/RxNimble
[RxRealmDataSources]: https://github.com/RxSwiftCommunity/RxRealmDataSources
[RxRealm]: https://github.com/RxSwiftCommunity/RxRealm
[RxRealm]: https://github.com/RxSwiftCommunity/RxRealm
[RxSwiftExt]: https://github.com/RxSwiftCommunity/RxSwiftExt
[RxSwift]: https://github.com/ReactiveX/RxSwift
[RxTest]: https://github.com/ReactiveX/RxSwift
[RxTheme]: https://github.com/RxSwiftCommunity/RxTheme
[Sketch.app]: https://www.sketchapp.com/com
[SocialKit]: https://github.com/mudox/social-kit
[SwiftFormat]: https://github.com/nicklockwood/SwiftFormat
[SwiftLint]: https://github.com/realm/SwiftLint
[SwiftyUserDefaults]: https://github.com/radex/SwiftyUserDefaults
[Swinject]: https://github.com/Swinject/Swinject
[Travis CI]: https://travis-ci.com
[codecov.io]: https://codecov.io
[fastlane]: https://fastlane.tools
[Kingfisher]: https://github.com/onevcat/Kingfisher
[RxKingfisher]: https://github.com/RxSwiftCommunity/RxKingfisher
