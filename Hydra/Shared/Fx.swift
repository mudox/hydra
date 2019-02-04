import Swinject
import SwinjectAutoregistration

import Then

import GitHub
import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

extension Container: Then {}

// MARK: The Singleton Container

let swinject = Container().then {
  // Shared
  registerCredentialServiceType(to: $0)
  registerGitHubService(to: $0)
  // Flows
  registerLoginTypes(to: $0)
  registerTrendTypes(to: $0)
  registerLanguagesTypes(to: $0)
  registerExploreTypes(to: $0)
  registerSearchTypes(to: $0)
  registerUserTypes(to: $0)
}

/// Called at app launch to logout all stubbing
func initSwinject() {
  _ = swinject
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
  return swinject.resolve(T.self)!
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
  return swinject.resolve(T.self)!
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

// MARK: - Flows

private func registerLoginTypes(to container: Container) {
  // Service
  container.autoregister(
    LoginServiceType.self,
    initializer: LoginService.init
  )

  // Model
  container.autoregister(
    LoginModelType.self,
    initializer: LoginModel.init
  )
}

private func registerTrendTypes(to container: Container) {
  // Service
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

  // Model
  container.autoregister(
    TrendModelType.self,
    initializer: TrendModel.init
  )
}

private func registerLanguagesTypes(to container: Container) {
  // Service
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

  // Model
  container.autoregister(
    LanguagesModelType.self,
    initializer: LanguagesModel.init
  )
}

private func registerExploreTypes(to container: Container) {
  // Model
  container.autoregister(
    ExploreModelType.self,
    initializer: ExploreModel.init
  )
}

private func registerSearchTypes(to container: Container) {
  // Model
  container.autoregister(
    SearchModelType.self,
    initializer: SearchModel.init
  )
}

private func registerUserTypes(to container: Container) {
  // Model
  container.autoregister(
    UserModelType.self,
    initializer: UserModel.init
  )
}

// MARK: - Helper

private func logStub(_ name: String) {
  jack.verbose("🦋 \(name)", format: .bare)
}
