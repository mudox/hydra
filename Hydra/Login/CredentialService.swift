import SwiftyUserDefaults

struct CredentialService {

  let gitHubApp = (id: "46cfca605f029f4fdb3e", secret: "fba5480ff4d87ce83daf3b452da1585ddb5f5857")

  var gitHubUser: (name: String, password: String)? {
    get {
      if let username = Defaults[.username], let password = Defaults[.password] {
        return (username, password)
      } else {
        return nil
      }
    }
    set {
      Defaults[.username] = newValue?.name
      Defaults[.password] = newValue?.password
    }

  }

  var accessToken: String? {
    get {
      return Defaults[.accessToken]
    }
    set {
      Defaults[.accessToken] = newValue
    }
  }

}
