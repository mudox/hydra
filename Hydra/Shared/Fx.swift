import Swinject
import SwinjectAutoregistration

import Then

import GitHub
import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

extension Container: Then {}

// MARK: - The Singleton Container

private let container = Container().then {
  // Shared
  registerCredentialServiceType(to: $0)
  registerGitHubService(to: $0)
  // Login
  registerLoginServiceType(to: $0)
  // Trend
  registerTrendServiceType(to: $0)
  // Languages
  registerLanguagesServiceType(to: $0)
  registerLanguagesModelType(to: $0)
}

/// Called at app launch in order to logout all stubbing
func initSwinject() {
  _ = container
}

/// The word `fx` means __Factory__
///
/// The return type is inferred by compiler.
/// ```swift
/// let service: LoginServiceType = fx()
/// ```
///
/// - Returns: The resolved instance.
func fx<T>() -> T {
  return container.resolve(T.self)!
}

/// The word `fx` means __Factory__
///
/// The return type is inferred by compiler.
/// ```swift
/// let value = fx(LanguagesServiceType.self).pinned
/// ```
///
/// - Parameter type: The type explicitly provided.
/// - Returns: The resolved instance.
func fx<T>(_ type: T.Type) -> T {
  return container.resolve(T.self)!
}

// MARK: - Shared

private func registerCredentialServiceType(to container: Container) {
  if Environs.stubCredentialService {
    logStub("CredentialServiceType")
    container.autoregister(
      CredentialServiceType.self,
      initializer: CredentialServiceStub.init
    )
  } else {
    container.autoregister(
      CredentialServiceType.self,
      initializer: CredentialService.init
    )
  }
}

private func registerGitHubService(to container: Container) {
  container.autoregister(
    GitHub.Service.self,
    initializer: GitHub.Service.init
  )
}

// MARK: - Login

private func registerLoginServiceType(to container: Container) {
  container.autoregister(
    LoginServiceType.self,
    initializer: LoginService.init
  )
}

// MARK: - Trend

private func registerTrendServiceType(to container: Container) {
  if Environs.stubTrendService {
    logStub("TrendService")
    container.autoregister(
      TrendServiceType.self,
      initializer: TrendServiceStub.init
    )
  } else {
    container.autoregister(
      TrendServiceType.self,
      initializer: TrendService.init
    )
  }
}

// MARK: - Languages

private func registerLanguagesServiceType(to container: Container) {
  if Environs.stubLanguagesService != nil {
    logStub("LanguagesService")
    container.autoregister(
      LanguagesServiceType.self,
      initializer: LanguagesServiceStub.init
    )
  } else {
    container.autoregister(
      LanguagesServiceType.self,
      initializer: LanguagesService.init
    )
  }
}

private func registerLanguagesModelType(to container: Container) {
  container.autoregister(
    LanguagesModelType.self,
    initializer: LanguagesModel.init
  )
}

// MARK: - Helper

private func logStub(_ name: String) {
  jack.verbose("🦋 \(name)", format: .bare)
}
