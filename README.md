# Hydra

![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)
[![Swift Version](https://img.shields.io/badge/swift-4.2-F16D39.svg?style=flat)](https://developer.apple.com/swift)
[![GitHub license](https://img.shields.io/github/license/mudox/hydra.svg)](https://github.com/mudox/hydra/blob/master/LICENSE)
[![Travis (.com)](https://img.shields.io/travis/com/mudox/hydra.svg)](https://travis-ci.com/mudox/hydra)
[![codecov](https://codecov.io/gh/mudox/hydra/branch/master/graph/badge.svg)](https://codecov.io/gh/mudox/hydra)
[![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/mudox/hydra.svg)](https://codeclimate.com/github/mudox/hydra/maintainability)

Hydra is an unofficial iOS client app for GitHub. I use it to keep practicing
various technologies I learned in community.

- [Project Targets](#project-targets)
- [Technologies](#technologies)
  - [Requirements](#requirements)
  - [Designing](#designing)
  - [Architecture](#architecture)
  - [FRP](#frp)
  - [Network](#network)
  - [Data Model](#data-model)
  - [UI](#ui)
  - [Testing](#testing)
  - [Code quality](#code-quality)
  - [CI](#ci)
  - [My Own Libraries](#my-own-libraries)
  - [Other](#other)
- [Author](#author)
- [License](#license)

## Project Targets

- [x] Practice UI/UX designing tool ([Sketch.app] etc.)
- [x] [MVVM] (with [RxSwift]) architecture.
- [x] Use [FRP] paradigm as much as possible, use it correctly and
      efficiently.
- [x] Stand-alone network abstraction layer ([GitHubKit]) using state-of-art
      techniques.
- [x] Utilize CI automation tools.
- [x] Experiment IB-less UI developing (i.e. no .xib, .storyboard files, only
      source code). The key is to draw out design first in dedicated tools (Omini
      Graffle.app, Sketch.app etc.)
- [ ] Localization for 🇨🇳 , 🇺🇸.
- [ ] Unit & UI tested with decent code coverage.

## Technologies

### Requirements

- [x] Xcode 10
- [x] Swift 4.2

### Designing

- [x] [Graffle.app] to do concept designing, like class hierarchies, reactive
      data flow of view models, dependencies graphs etc.
- [x] [Sketch.app] for static scene & artwork design.
- [ ] [Principle.app] for dynamic UI design.

### Architecture

- [x] MVVM with [RxSwift]
- [x] Flow

Simply put, flow + view model + view controller + view.

### FRP

- [x] [RxSwift] the Swift implementation of [ReactiveX].
- [x] [RxSwiftExt] as extension library for [RxSwift].
- [x] [RxDataSources] + [RxRealmDataSources] to drive table views and collection views.
- [x] [Action] to bridge between background transactions and UI states.
- [x] [RxGesture] to install and use gesture recognizers reactively.
- [ ] [RxTheme] to implement theme switching.

### Network

The network stack listed from bottom to top:

- [x] [URLSession] Foundation URL loading system.
- [x] [Alamofire] + [RxAlamofire] for simple request case.
- [x] [Moya] to construct network abstraction layer.
- [x] [RxSwift] to provide reactive interface.

### Data Model

- [x] [SwiftyUserDefaults] to access UserDefaults type-safely.
- [x] [Realm] + [RxRealm] to construct local data model layer.
- [x] [Valet] to store user password and app authorization token into Keychain.

### UI

- [x] [Kingfisher] + [RxKingfisher] to manage images loading.
- [ ] [Texture] to optimize essential UI components.
- [ ] [Hero] to provide vivid transitions between view controllers.

### Testing

- [x] [Swinject] + [SwinjectAutoregistration] to inject dependencies.
- [x] [OHHTTPStubs] to stub network requests.
- [x] [Quick] + [Nimble] + [RxNimble] to as basic unit testing frameworks.
- [x] [RxTest] + [RxBlocking] to write view model white tests.
- [x] [EarlGray] to write in-process integration tests.

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
- [x] [GitHubKit] as main part of data model layer, which is a Swift client
      of GitHub APIv3.
- [x] [MudoxKit] as my own iOS tool belt library.
- [x] [SocialKit] for social sharing.

### Other

- [ ] [Sourcery] to get rid of flow boilderplates.


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
[SwinjectAutoregistration]: https://github.com/Swinject/SwinjectAutoregistration
[Travis CI]: https://travis-ci.com
[codecov.io]: https://codecov.io
[fastlane]: https://fastlane.tools
[Kingfisher]: https://github.com/onevcat/Kingfisher
[RxKingfisher]: https://github.com/RxSwiftCommunity/RxKingfisher
[Texture]: https://github.com/TextureGroup/Texture
[Hero]: https://github.com/HeroTransitions/Hero
[Valet]: https://github.com/square/Valet
[EarlGrey]: https://github.com/google/EarlGrey
[URLSession]: https://developer.apple.com/documentation/foundation/url_loading_system
[Sourcery]: https://github.com/krzysztofzablocki/Sourcery 