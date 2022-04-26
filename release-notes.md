# Release Notes

## v1.4.0 - April 25th, 2022

Features:

- Updated SDK to version 1.7.0.
- Updated the SDK import name.
- Added support for authentication using QR Code scanning or manual typing an authentication code.
- Started supporting secured signing with Elliptic Curve algorithm, using the iOS secure enclave component (on devices using Apple A7 or later A-series processors).

Compatibility notes:
 
- Supports Xcode 13 and above.
- Increased minimum iOS supported version to iOS 12.
- SDK will use Elliptic Curve signature for fresh users only, not for users who upgrade from 1.6.0.

Known issues:

- The scanning screen (for pairing and QR authentication) sometimes displays a black band in the camera view. Usually restarting the application resolves the issue.

## v1.3.0 - August 1st, 2021
Features:

- Supports device integrity checks for rooted and jailbroken devices, using the latest SDK version 1.6.0.

## v1.2.0 - April 6th, 2021
Features:

- Updated SDK to version 1.4.0.
- Added one time passcode in users screen.

Compatibility notes:

- Supports Xcode 12 and above.

## v1.1.0 - June 18th, 2020
Features:

- Updated SDK to version 1.3.0.

## v1.0.0 - March 31st, 2020
Features:

- Pairing flow using QR code with camera scan or manual entry.
- Override usernames locally, or use names from PingOne directory.
- Authentication flow with push notifications using biometric FaceID and TouchID.
- Side menu with send logs option to track customer issues with support ID.

