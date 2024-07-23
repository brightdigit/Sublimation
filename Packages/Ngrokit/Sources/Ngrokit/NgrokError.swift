//
//  NgrokError.swift
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

import Foundation

// swiftlint:disable line_length

/// An enumeration representing possible errors that can occur with Ngrok.
///
/// - invalidMetadataLength: The metadata length is invalid.
/// - accountLimitExceeded: The account limit for simultaneous ngrok agent sessions has been exceeded.
/// - unsupportedAgentVersion: The ngrok agent version is no longer supported.
/// - captchaFailed: The captcha solving failed.
/// - accountViolation: Creating an ngrok account is disallowed due to violation of the terms of service.
/// - gatewayError: Ngrok gateway error.
/// - tunnelNotFound: The tunnel was not found.
/// - accountBanned: The account associated with the hostname has been banned.
/// - passwordTooShort: The password is too short.
/// - accountCreationNotAllowed: Creating a new account is not allowed.
/// - invalidCredentials: The email or password entered is not valid.
/// - userAlreadyExists: A user with the email address already exists.
/// - disallowedEmailProvider: Sign-ups are disallowed for the email provider.
/// - htmlContentSignupRequired: Signing up for an ngrok account and installing the authtoken is required before serving HTML content.
/// - websiteVisitWarning: A warning before visiting a website served by ngrok.com.
/// - tunnelConnectionFailed: The ngrok agent failed to establish a connection to the upstream web service.
///
public enum NgrokError: Int, LocalizedError {
  case invalidMetadataLength = 100
  case accountLimitExceeded = 108
  case unsupportedAgentVersion = 120
  case captchaFailed = 1_205
  case accountViolation = 1_226
  case gatewayError = 3_004
  case tunnelNotFound = 3_200
  case accountBanned = 3_208
  case passwordTooShort = 4_011
  case accountCreationNotAllowed = 4_013
  case invalidCredentials = 4_100
  case userAlreadyExists = 4_101
  case disallowedEmailProvider = 4_108
  case htmlContentSignupRequired = 6_022
  case websiteVisitWarning = 6_024
  case tunnelConnectionFailed = 8_012

  public var errorDescription: String? {
    switch self {
    case .invalidMetadataLength:
      "Invalid metadata length"
    case .accountLimitExceeded:
      "You've hit your account limit for simultaneous ngrok agent sessions. Try stopping an existing agent or upgrading your account."
    case .unsupportedAgentVersion:
      "Your ngrok agent version is no longer supported. Only the most recent version of the ngrok agent is supported without an account. Update to a newer version with ngrok update or by downloading from https://ngrok.com/download. Sign up for an account to avoid forced version upgrades: https://ngrok.com/signup."
    case .captchaFailed:
      "You failed to solve the captcha, please try again."
    case .accountViolation:
      "You are disallowed from creating an ngrok account due to violation of the terms of service."
    case .gatewayError:
      "Ngrok gateway error. The server returned an invalid or incomplete HTTP response. Try starting ngrok with the full upstream service URL (e.g. ngrok http https://localhost:8081)"
    case .tunnelNotFound:
      "Tunnel not found. This could be because your agent is not online or your tunnel has been flagged by our automated moderation system."
    case .accountBanned:
      "The account associated with this hostname has been banned. We've determined this account to be in violation of ngrok's terms of service. If you are the account owner and believe this is a mistake, please contact support@ngrok.com."
    case .passwordTooShort:
      "Your password must be at least 10 characters."
    case .accountCreationNotAllowed:
      "You may not create a new account because you are already a member of a free account. Upgrade or delete that account first before creating a new account."
    case .invalidCredentials:
      "The email or password you entered is not valid."
    case .userAlreadyExists:
      "A user with the email address already exists."
    case .disallowedEmailProvider:
      "Sign-ups are disallowed for the email provider. Please sign up with a different email provider."
    case .htmlContentSignupRequired:
      "Before you can serve HTML content, you must sign up for an ngrok account and install your authtoken."
    case .websiteVisitWarning:
      "You are about to visit HOSTPORT, served by SERVINGIP. This website is served for free through ngrok.com. You should only visit this website if you trust whoever sent the link to you."
    case .tunnelConnectionFailed:
      "Traffic was successfully tunneled to the ngrok agent, but the agent failed to establish a connection to the upstream web service"
    }
  }
  // swiftlint:enable line_length
}
