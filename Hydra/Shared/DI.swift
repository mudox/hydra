import Swinject

import JacKit

private let jack = Jack().set(format: .short)

// swiftlint:disable:next identifier_name
let di = makeContainer()

private func makeContainer() -> Container {
  let container = Container()

  // MARK: Trend Flow

  let env = ProcessInfo.processInfo.environment

  container.register(TrendServiceType.self) { _ in
    if env.keys.contains("STUB_TREND_SERVICE") {
      jack.verbose("🐡 Stub `TrendServiceType`", format: .bare)
      return TrendServiceStub()
    } else {
      return TrendService()
    }
  }

  return container
}
