# Hydra

![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)
[![GitHub license](https://img.shields.io/github/license/mudox/hydra.svg)](https://github.com/mudox/hydra/blob/master/LICENSE)
[![Travis (.com)](https://img.shields.io/travis/com/mudox/hydra.svg)](https://travis-ci.com/mudox/hydra)
[![Codecov](https://img.shields.io/codecov/c/github/mudox/hydra.svg)](https://codecov.io/gh/mudox/mudox-kit)
[![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/mudox/hydra.svg)](https://codeclimate.com/github/mudox/hydra/maintainability)

Hydra is an unofficial iOS client app for GitHub. I use it to practice various
technologies I learned in community. It uses [GitHubKit] to access GitHub APIs.

## Technologies

### Requirements

- [x] Xcode 10
- [x] Swift 4.2

### Architecture

- [x] MVVM with [RxSwift]
- [x] Flow

Simply put, flow + view model + view controller + view.

### Network technique stack

- [x] [Alamofire]
- [x] [RxAlamofire] for simple request case
- [x] [Moya] to construct network abstraction layer
- [x] [RxSwift] to provide reactive interface
- [x] [GitHubKit] as Swift client of GitHub API

### F.R.P (Functional Reactive Programming)

- [x] [RxSwift]
- [x] [RxSwiftExt] as complementary library for [RxSwift]
- [x] [RxDataSources] to drive table views and collection views
- [x] [RxGesture] to install and use gesture recognizers reactively
- [ ] [RxRealm] to interact with Realm mobile database reactively

### Testing

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

## Author

Mudox

## License

Hydra is available under the MIT license. See the LICENSE file for more info.

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
