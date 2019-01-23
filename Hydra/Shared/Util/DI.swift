import Swinject

import GitHub
import MudoxKit

import JacKit

private let jack = Jack().set(format: .short)

// swiftlint:disable:next identifier_name
let di = makeContainer()

private func makeContainer() -> Container {
  let container = Container()

  registerTrendServiceType(to: container)
  registerLanguagesServiceType(to: container)
  registerCredentialServiceType(to: container)

  return container
}

private func registerTrendServiceType(to container: Container) {
  container.register(TrendServiceType.self) { _ in
    if Environs.stubTrendService {
      jack.verbose("🐡 Stub `TrendServiceType`", format: .bare)
      return TrendServiceStub()
    } else {
      return TrendService()
    }
  }
}

private func registerLanguagesServiceType(to container: Container) {
  container.register(LanguagesServiceType.self) { _ in
    return LanguagesService()
  }
}

private func registerCredentialServiceType(to container: Container) {
  container.register(CredentialServiceType.self) { _ in
    if Environs.stubCredentialService {
      jack.verbose("🐡 Stub `CredentialServiceType`", format: .bare)
      return CredentialServiceStub()
    } else {
      return CredentialService()
    }
  }
}
