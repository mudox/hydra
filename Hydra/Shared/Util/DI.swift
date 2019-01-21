import Swinject

import JacKit

private let jack = Jack().set(format: .short)

// swiftlint:disable:next identifier_name
let di = makeContainer()

private func makeContainer() -> Container {
  let container = Container()

  // MARK: Trend Flow

  container.register(TrendServiceType.self) { _ in
    if Environs.stubTrendService {
      jack.verbose("🐡 Stub `TrendServiceType`", format: .bare)
      return TrendServiceStub()
    } else {
      return TrendService()
    }
  }

  container.register(LanguagesServiceType.self) { _ in
    return LanguagesService()
  }

  return container
}
