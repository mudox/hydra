import Swinject

import GitHub
import MudoxKit

import Then

import JacKit

private let jack = Jack().set(format: .short)

extension Container: Then {}

// swiftlint:disable:next identifier_name
let di = Container().then {
  registerCredentialServiceType(to: $0)
  registerTrendServiceType(to: $0)
  registerLanguagesServiceType(to: $0)
}

private func registerTrendServiceType(to container: Container) {
  container.register(TrendServiceType.self) { _ in
    if Environs.stubTrendService {
      jack.verbose("🐡 TrendServiceType", format: .bare)
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
      jack.verbose("🐡 CredentialServiceType", format: .bare)
      return CredentialServiceStub()
    } else {
      return CredentialService()
    }
  }
}
