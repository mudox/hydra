import XCTest

import Then

class UITests: XCTestCase {

  let app = XCUIApplication()
  let username = XCUIApplication().textFields["usernameField"]
  let password = XCUIApplication().secureTextFields["passwordField"]

  override func setUp() {
    continueAfterFailure = false

    app.launch()
  }

  override func tearDown() {
  }

  func testLogin() {

    username.tap()
    username.typeText("cement_ce@163.com\n")
    password.typeText("zheshi1geceshihao\n")

    username.tap()
    username.typeText("cement_ce@163.com")
    password.tap()
    password.typeText("zheshi1geceshihao")

    app.buttons["dismissLogin"].tap()
  }

}
