//
//  NgrokErrorTests.swift
//  Sublimation
//
//  Created by Leo Dion.
//  Copyright © 2024 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the “Software”), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Ngrokit
import XCTest

internal class NgrokErrorTests: XCTestCase {
  // swiftlint:disable line_length
  internal func testErrorDescriptions() {
    XCTAssertEqual(NgrokError.invalidMetadataLength.errorDescription, "Invalid metadata length")
    XCTAssertEqual(NgrokError.accountLimitExceeded.errorDescription, "You've hit your account limit for simultaneous ngrok agent sessions. Try stopping an existing agent or upgrading your account.")
    XCTAssertEqual(NgrokError.unsupportedAgentVersion.errorDescription, "Your ngrok agent version is no longer supported. Only the most recent version of the ngrok agent is supported without an account. Update to a newer version with ngrok update or by downloading from https://ngrok.com/download. Sign up for an account to avoid forced version upgrades: https://ngrok.com/signup.")
    XCTAssertEqual(NgrokError.captchaFailed.errorDescription, "You failed to solve the captcha, please try again.")
    XCTAssertEqual(NgrokError.accountViolation.errorDescription, "You are disallowed from creating an ngrok account due to violation of the terms of service.")
    XCTAssertEqual(NgrokError.gatewayError.errorDescription, "Ngrok gateway error. The server returned an invalid or incomplete HTTP response. Try starting ngrok with the full upstream service URL (e.g. ngrok http https://localhost:8081)")
    XCTAssertEqual(NgrokError.tunnelNotFound.errorDescription, "Tunnel not found. This could be because your agent is not online or your tunnel has been flagged by our automated moderation system.")
    XCTAssertEqual(NgrokError.accountBanned.errorDescription, "The account associated with this hostname has been banned. We've determined this account to be in violation of ngrok's terms of service. If you are the account owner and believe this is a mistake, please contact support@ngrok.com.")
    XCTAssertEqual(NgrokError.passwordTooShort.errorDescription, "Your password must be at least 10 characters.")
    XCTAssertEqual(NgrokError.accountCreationNotAllowed.errorDescription, "You may not create a new account because you are already a member of a free account. Upgrade or delete that account first before creating a new account.")
    XCTAssertEqual(NgrokError.invalidCredentials.errorDescription, "The email or password you entered is not valid.")
    XCTAssertEqual(NgrokError.userAlreadyExists.errorDescription, "A user with the email address already exists.")
    XCTAssertEqual(NgrokError.disallowedEmailProvider.errorDescription, "Sign-ups are disallowed for the email provider. Please sign up with a different email provider.")
    XCTAssertEqual(NgrokError.htmlContentSignupRequired.errorDescription, "Before you can serve HTML content, you must sign up for an ngrok account and install your authtoken.")
    XCTAssertEqual(NgrokError.websiteVisitWarning.errorDescription, "You are about to visit HOSTPORT, served by SERVINGIP. This website is served for free through ngrok.com. You should only visit this website if you trust whoever sent the link to you.")
    XCTAssertEqual(NgrokError.tunnelConnectionFailed.errorDescription, "Traffic was successfully tunneled to the ngrok agent, but the agent failed to establish a connection to the upstream web service")
  }

  // swiftlint:disable nslocalizedstring_require_bundle
  internal func testLocalizedDescriptions() {
    XCTAssertEqual(NgrokError.invalidMetadataLength.localizedDescription, NSLocalizedString("Invalid metadata length", comment: ""))
    XCTAssertEqual(NgrokError.accountLimitExceeded.localizedDescription, NSLocalizedString("You've hit your account limit for simultaneous ngrok agent sessions. Try stopping an existing agent or upgrading your account.", comment: ""))
    XCTAssertEqual(NgrokError.unsupportedAgentVersion.localizedDescription, NSLocalizedString("Your ngrok agent version is no longer supported. Only the most recent version of the ngrok agent is supported without an account. Update to a newer version with ngrok update or by downloading from https://ngrok.com/download. Sign up for an account to avoid forced version upgrades: https://ngrok.com/signup.", comment: ""))
    XCTAssertEqual(NgrokError.captchaFailed.localizedDescription, NSLocalizedString("You failed to solve the captcha, please try again.", comment: ""))
    XCTAssertEqual(NgrokError.accountViolation.localizedDescription, NSLocalizedString("You are disallowed from creating an ngrok account due to violation of the terms of service.", comment: ""))
    XCTAssertEqual(NgrokError.gatewayError.localizedDescription, NSLocalizedString("Ngrok gateway error. The server returned an invalid or incomplete HTTP response. Try starting ngrok with the full upstream service URL (e.g. ngrok http https://localhost:8081)", comment: ""))
    XCTAssertEqual(NgrokError.tunnelNotFound.localizedDescription, NSLocalizedString("Tunnel not found. This could be because your agent is not online or your tunnel has been flagged by our automated moderation system.", comment: ""))
    XCTAssertEqual(NgrokError.accountBanned.localizedDescription, NSLocalizedString("The account associated with this hostname has been banned. We've determined this account to be in violation of ngrok's terms of service. If you are the account owner and believe this is a mistake, please contact support@ngrok.com.", comment: ""))
    XCTAssertEqual(NgrokError.passwordTooShort.localizedDescription, NSLocalizedString("Your password must be at least 10 characters.", comment: ""))
    XCTAssertEqual(NgrokError.accountCreationNotAllowed.localizedDescription, NSLocalizedString("You may not create a new account because you are already a member of a free account. Upgrade or delete that account first before creating a new account.", comment: ""))
    XCTAssertEqual(NgrokError.invalidCredentials.localizedDescription, NSLocalizedString("The email or password you entered is not valid.", comment: ""))
    XCTAssertEqual(NgrokError.userAlreadyExists.localizedDescription, NSLocalizedString("A user with the email address already exists.", comment: ""))
    XCTAssertEqual(NgrokError.disallowedEmailProvider.localizedDescription, NSLocalizedString("Sign-ups are disallowed for the email provider. Please sign up with a different email provider.", comment: ""))
    XCTAssertEqual(NgrokError.htmlContentSignupRequired.localizedDescription, NSLocalizedString("Before you can serve HTML content, you must sign up for an ngrok account and install your authtoken.", comment: ""))
    XCTAssertEqual(NgrokError.websiteVisitWarning.localizedDescription, NSLocalizedString("You are about to visit HOSTPORT, served by SERVINGIP. This website is served for free through ngrok.com. You should only visit this website if you trust whoever sent the link to you.", comment: ""))
    XCTAssertEqual(NgrokError.tunnelConnectionFailed.localizedDescription, NSLocalizedString("Traffic was successfully tunneled to the ngrok agent, but the agent failed to establish a connection to the upstream web service", comment: ""))
  }

  // swiftlint:enable nslocalizedstring_require_bundle
  // swiftlint:enable line_length

  internal func testRawValues() {
    XCTAssertEqual(NgrokError.invalidMetadataLength.rawValue, 100)
    XCTAssertEqual(NgrokError.accountLimitExceeded.rawValue, 108)
    XCTAssertEqual(NgrokError.unsupportedAgentVersion.rawValue, 120)
    XCTAssertEqual(NgrokError.captchaFailed.rawValue, 1_205)
    XCTAssertEqual(NgrokError.accountViolation.rawValue, 1_226)
    XCTAssertEqual(NgrokError.gatewayError.rawValue, 3_004)
    XCTAssertEqual(NgrokError.tunnelNotFound.rawValue, 3_200)
    XCTAssertEqual(NgrokError.accountBanned.rawValue, 3_208)
    XCTAssertEqual(NgrokError.passwordTooShort.rawValue, 4_011)
    XCTAssertEqual(NgrokError.accountCreationNotAllowed.rawValue, 4_013)
    XCTAssertEqual(NgrokError.invalidCredentials.rawValue, 4_100)
    XCTAssertEqual(NgrokError.userAlreadyExists.rawValue, 4_101)
    XCTAssertEqual(NgrokError.disallowedEmailProvider.rawValue, 4_108)
    XCTAssertEqual(NgrokError.htmlContentSignupRequired.rawValue, 6_022)
    XCTAssertEqual(NgrokError.websiteVisitWarning.rawValue, 6_024)
    XCTAssertEqual(NgrokError.tunnelConnectionFailed.rawValue, 8_012)
  }
}
