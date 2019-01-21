import XCTest

import Nimble
import Quick

import JacKit

@testable import Hydra

private let jack = Jack("Test.Environs")

@testable import Hydra

class EnvironsSpec: QuickSpec { override func spec() {
  
  let boolKey = "testBooleanKey"
  let stringKey = "testStringKey"
  let tokensKey = "testTokensKey"
  
  afterEach {
    Environs.reset()
  }

  it("write read bool") {
    expect(Environs.boolean(forKey: boolKey)) == false
    
    Environs.set(boolean: true, forKey: boolKey)
    expect(Environs.boolean(forKey: boolKey)) == true
    
    Environs.set(boolean: false, forKey: boolKey)
    expect(Environs.boolean(forKey: boolKey)) == false
  }

  it("wirte read string") {
    expect(Environs.string(forKey: stringKey)).to(beNil())
    
    Environs.set(string: "test", forKey: stringKey)
    expect(Environs.string(forKey: stringKey)) == "test"
    
    Environs.set(string: "", forKey: stringKey)
    expect(Environs.string(forKey: stringKey)) == ""
  }
  
  
  it("wirte read tokens") {
    expect(Environs.tokens(forKey: tokensKey)) == []
    
    Environs.set(tokens: ["swift", "objective-c", "c", "c++"], forKey: tokensKey)
    expect(Environs.tokens(forKey: tokensKey)) == ["swift", "objective-c", "c", "c++"]
    
    Environs.set(tokens: [], forKey: tokensKey)
    expect(Environs.tokens(forKey: tokensKey)) == []
  }
} }
