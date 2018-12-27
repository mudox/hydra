import XCTest

import Nimble
import Quick

import JacKit

import SwiftyUserDefaults

private let jack = Jack("Test.Defaults")

@testable import Hydra

extension DefaultsKeys {
  static let testKey = DefaultsKey<String?>("aTestKey", defaultValue: nil)
}

class DefaultsSpec: QuickSpec { override func spec() {

  describe("Defaults") {

    afterEach {
      Defaults.remove(.testKey)
    }

    /// See https://github.com/radex/SwiftyUserDefaults/issues/162
    it("optional string defaults to nil") {
      Defaults[.testKey] = "hello world"
      expect(Defaults[.testKey]) == "hello world"

      Defaults[.testKey] = nil
      expect(Defaults[.testKey]).to(beNil())
    }

    it("all value become nil after remove all") {
      Defaults.removeAll()
      expect(Defaults[.accessToken]).to(beNil())
    }

  }

} }