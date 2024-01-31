//
//  NgrokServerErrorTests.swift
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

import XCTest

import XCTest

class NgrokErrorCodeTests: XCTestCase {
  func testErrorDescriptions() {
    XCTAssertEqual(NgrokErrorCode.invalidMetadataLength.errorDescription, "Invalid metadata length")
    XCTAssertEqual(NgrokErrorCode.accountLimitExceeded.errorDescription, "You've hit your account limit for simultaneous ngrok agent sessions. Try stopping an existing agent or upgrading your account.")
    XCTAssertEqual(NgrokErrorCode.unsupportedAgentVersion.errorDescription, "Your ngrok agent version is no longer supported. Only the most recent version of the ngrok agent is supported without an account. Update to a newer version with ngrok update or by downloading from https://ngrok.com/download. Sign up for an account to avoid forced version upgrades: https://ngrok.com/signup.")
    XCTAssertEqual(NgrokErrorCode.captchaFailed.errorDescription, "You failed to solve the captcha, please try again.")
    XCTAssertEqual(NgrokErrorCode.accountViolation.errorDescription, "You are disallowed from creating an ngrok account due to violation of the terms of service.")
    XCTAssertEqual(NgrokErrorCode.gatewayError.errorDescription, "Ngrok gateway error. The server returned an invalid or incomplete HTTP response. Try starting ngrok with the full upstream service URL (e.g. ngrok http https://localhost:8081)")
    XCTAssertEqual(NgrokErrorCode.tunnelNotFound.errorDescription, "Tunnel not found. This could be because your agent is not online or your tunnel has been flagged by our automated moderation system.")
    XCTAssertEqual(NgrokErrorCode.accountBanned.errorDescription, "The account associated with this hostname has been banned. We've determined this account to be in violation of ngrok's terms of service. If you are the account owner and believe this is a mistake, please contact support@ngrok.com.")
    XCTAssertEqual(NgrokErrorCode.passwordTooShort.errorDescription, "Your password must be at least 10 characters.")
    XCTAssertEqual(NgrokErrorCode.accountCreationNotAllowed.errorDescription, "You may not create a new account because you are already a member of a free account. Upgrade or delete that account first before creating a new account.")
    XCTAssertEqual(NgrokErrorCode.invalidCredentials.errorDescription, "The email or password you entered is not valid.")
    XCTAssertEqual(NgrokErrorCode.userAlreadyExists.errorDescription, "A user with the email address already exists.")
    XCTAssertEqual(NgrokErrorCode.disallowedEmailProvider.errorDescription, "Sign-ups are disallowed for the email provider. Please sign up with a different email provider.")
    XCTAssertEqual(NgrokErrorCode.htmlContentSignupRequired.errorDescription, "Before you can serve HTML content, you must sign up for an ngrok account and install your authtoken.")
    XCTAssertEqual(NgrokErrorCode.websiteVisitWarning.errorDescription, "You are about to visit HOSTPORT, served by SERVINGIP. This website is served for free through ngrok.com. You should only visit this website if you trust whoever sent the link to you.")
    XCTAssertEqual(NgrokErrorCode.tunnelConnectionFailed.errorDescription, "Traffic was successfully tunneled to the ngrok agent, but the agent failed to establish a connection to the upstream web service")
  }

  func testLocalizedDescriptions() {
    XCTAssertEqual(NgrokErrorCode.invalidMetadataLength.localizedDescription, NSLocalizedString("Invalid metadata length", comment: ""))
    XCTAssertEqual(NgrokErrorCode.accountLimitExceeded.localizedDescription, NSLocalizedString("You've hit your account limit for simultaneous ngrok agent sessions. Try stopping an existing agent or upgrading your account.", comment: ""))
    XCTAssertEqual(NgrokErrorCode.unsupportedAgentVersion.localizedDescription, NSLocalizedString("Your ngrok agent version is no longer supported. Only the most recent version of the ngrok agent is supported without an account. Update to a newer version with ngrok update or by downloading from https://ngrok.com/download. Sign up for an account to avoid forced version upgrades: https://ngrok.com/signup.", comment: ""))
    XCTAssertEqual(NgrokErrorCode.captchaFailed.localizedDescription, NSLocalizedString("You failed to solve the captcha, please try again.", comment: ""))
    XCTAssertEqual(NgrokErrorCode.accountViolation.localizedDescription, NSLocalizedString("You are disallowed from creating an ngrok account due to violation of the terms of service.", comment: ""))
    XCTAssertEqual(NgrokErrorCode.gatewayError.localizedDescription, NSLocalizedString("Ngrok gateway error. The server returned an invalid or incomplete HTTP response. Try starting ngrok with the full upstream service URL (e.g. ngrok http https://localhost:8081)", comment: ""))
    XCTAssertEqual(NgrokErrorCode.tunnelNotFound.localizedDescription, NSLocalizedString("Tunnel not found. This could be because your agent is not online or your tunnel has been flagged by our automated moderation system.", comment: ""))
    XCTAssertEqual(NgrokErrorCode.accountBanned.localizedDescription, NSLocalizedString("The account associated with this hostname has been banned. We've determined this account to be in violation of ngrok's terms of service. If you are the account owner and believe this is a mistake, please contact support@ngrok.com.", comment: ""))
    XCTAssertEqual(NgrokErrorCode.passwordTooShort.localizedDescription, NSLocalizedString("Your password must be at least 10 characters.", comment: ""))
    XCTAssertEqual(NgrokErrorCode.accountCreationNotAllowed.localizedDescription, NSLocalizedString("You may not create a new account because you are already a member of a free account. Upgrade or delete that account first before creating a new account.", comment: ""))
    XCTAssertEqual(NgrokErrorCode.invalidCredentials.localizedDescription, NSLocalizedString("The email or password you entered is not valid.", comment: ""))
    XCTAssertEqual(NgrokErrorCode.userAlreadyExists.localizedDescription, NSLocalizedString("A user with the email address already exists.", comment: ""))
    XCTAssertEqual(NgrokErrorCode.disallowedEmailProvider.localizedDescription, NSLocalizedString("Sign-ups are disallowed for the email provider. Please sign up with a different email provider.", comment: ""))
    XCTAssertEqual(NgrokErrorCode.htmlContentSignupRequired.localizedDescription, NSLocalizedString("Before you can serve HTML content, you must sign up for an ngrok account and install your authtoken.", comment: ""))
    XCTAssertEqual(NgrokErrorCode.websiteVisitWarning.localizedDescription, NSLocalizedString("You are about to visit HOSTPORT, served by SERVINGIP. This website is served for free through ngrok.com. You should only visit this website if you trust whoever sent the link to you.", comment: ""))
    XCTAssertEqual(NgrokErrorCode.tunnelConnectionFailed.localizedDescription, NSLocalizedString("Traffic was successfully tunneled to the ngrok agent, but the agent failed to establish a connection to the upstream web service", comment: ""))
  }

  func testRawValues() {
    XCTAssertEqual(NgrokErrorCode.invalidMetadataLength.rawValue, 100)
    XCTAssertEqual(NgrokErrorCode.accountLimitExceeded.rawValue, 108)
    XCTAssertEqual(NgrokErrorCode.unsupportedAgentVersion.rawValue, 120)
    XCTAssertEqual(NgrokErrorCode.captchaFailed.rawValue, 1_205)
    XCTAssertEqual(NgrokErrorCode.accountViolation.rawValue, 1_226)
    XCTAssertEqual(NgrokErrorCode.gatewayError.rawValue, 3_004)
    XCTAssertEqual(NgrokErrorCode.tunnelNotFound.rawValue, 3_200)
    XCTAssertEqual(NgrokErrorCode.accountBanned.rawValue, 3_208)
    XCTAssertEqual(NgrokErrorCode.passwordTooShort.rawValue, 4_011)
    XCTAssertEqual(NgrokErrorCode.accountCreationNotAllowed.rawValue, 4_013)
    XCTAssertEqual(NgrokErrorCode.invalidCredentials.rawValue, 4_100)
    XCTAssertEqual(NgrokErrorCode.userAlreadyExists.rawValue, 4_101)
    XCTAssertEqual(NgrokErrorCode.disallowedEmailProvider.rawValue, 4_108)
    XCTAssertEqual(NgrokErrorCode.htmlContentSignupRequired.rawValue, 6_022)
    XCTAssertEqual(NgrokErrorCode.websiteVisitWarning.rawValue, 6_024)
    XCTAssertEqual(NgrokErrorCode.tunnelConnectionFailed.rawValue, 8_012)
  }
}
