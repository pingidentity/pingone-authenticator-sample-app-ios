# Authenticator sample app

This sample application demonstrates an authenticator-only application that uses PingOne for Customers mobile SDK. An iOS developer can easily build a branded and customized Authenticator application using this sample.

## What’s in the sample app?

  - Full native application written in Swift 5.1, compatible for all iOS devices from iOS 10 or above.
  - Integration with [PingOne mobile SDK] version 1.3.0.
  - UI customization can be done easily to get your company flavor on the app.
  - All app texts can be easily localized and modified in one file.

## Features

  - Pairing flow using QR code with camera scan or manual entry.
  - Override usernames locally, or use names from PingOne directory.
  - Authentication flow with push notifications using biometric FaceID and TouchID.
  - Side menu with send logs option to track customer issues with support ID.

## Prerequisites

The Authenticator sample app requires Xcode 11 and above to compile and run.

To set up your application for  working with push messages in iOS refer to [PingOne mobile SDK].

## Installation

1. Download the latest code from this repo.
2. Go to the **Target General** setting and update the **Display Name** and **Bundle Identifier** with your app's values.
3. To update the UI, replace the following images in the `Assets.xcassets` folder:
    - Splash screen image: `launch_image`
    - Banner logo in navigation bar: `logo_navbar`
    - App Icon: `AppIcon`
    ##### Note:
    It is mandatory to replace these images before submitting the app to AppStore, in order to create a unique app complying with Apple's restrictions. For more information, refer to [App Store Review Guidelines].

4. If needed, update the `Localizable.strings` file, to customize any string in the app.
5. Build and run the project.
##### Note: For further understanding the code implementation of this app, refer to [Setup a mobile app] using the PingOne SDK sample code.


[PingOne mobile SDK]: <https://github.com/pingidentity/pingone-customers-mobile-sdk-ios>
[Setup a mobile app]: <https://github.com/pingidentity/pingone-customers-mobile-sdk-ios>
[App Store Review Guidelines]:<https://developer.apple.com/app-store/review/guidelines/>
[PingOne mobile SDK]:<https://github.com/pingidentity/pingone-customers-mobile-sdk-ios/blob/master/README.md>
