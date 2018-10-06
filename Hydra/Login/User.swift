import Foundation

struct User {
  
  let name: String
  let password: String

  static var current: User?
}

struct App {
  static let id = "46cfca605f029f4fdb3e"
  static let secret = "fba5480ff4d87ce83daf3b452da1585ddb5f5857"
}
