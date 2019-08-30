# Apto UI SDK for iOS [![CocoaPods](https://img.shields.io/cocoapods/v/AptoUISDK.svg?style=plastic)](https://cocoapods.org/pods/AptoUISDK)

Welcome to the Apto iOS UI SDK. This SDK gives access to the Apto's mobile platform. Using this SDK you just start the SDK and it will onboard new users, issue cards, obtain card activity information and manage the card (set pin, freeze / unfreeze, etc.) without you doing anything else, just:

```swift
private func showCardSDK() {
  let features: [FeatureKey: Bool] = [
    .showActivateCardButton: true,
    .showStatsButton: true
  ]
  let descriptors = ThemeFontDescriptors(regular: UIFontDescriptor(name:"XYZ-Regular", size: 10),
                                         medium: UIFontDescriptor(name:"XYZ-Medium", size: 10),
                                         semibold: UIFontDescriptor(name:"XYZ-Semibold", size: 10),
                                         bold: UIFontDescriptor(name:"XYZ-Bold", size: 10))
  let options = CardOptions(features: features, fontCustomizationOptions: .fontDescriptors(descriptors))
  AptoPlatform.defaultManager().startCardFlow(from: self, mode: .standalone, options: options) { [weak self] result in
    switch result {
    case .failure(let error):
      // handle error
    case .success(let module):
      // SDK successfully initialized
    }
  }
}
```

## Requirements

    * Xcode 10
    * Swift 5
    * CocoaPods
    * AptoSDK

### Installation (Using [CocoaPods](https://cocoapods.org))

1. In your `Podfile`, add the following dependency:

    ```
    platform :ios, '10.0'
    use_frameworks!

    pod 'AptoSDK'
    pod 'AptoUISDK'
    ```

2. Run `pod install`.

## Initializing the SDK

To start the Apto UI SDK you must first register a project in order to get a `API KEY`. Please contact Apto to create a project for you. Then, initialize the SDK by passing the public api key:

```swift
AptoPlatform.defaultManager().initializeWithApiKey("API KEY")
```

For other options and methods check the [Apto SDK documentation](https://github.com/AptoPayments/apto-sdk-ios).

## Starting the SDK

Once the SDK has been initialized you just have to call the `startCardFlow` method. This method has three required parameters and some optionals:

### from parameter

`UIViewController` subclass from where the SDK is started. This is a required parameter used to present the SDK to the user.

### mode parameter

A `ShiftCardModuleMode` value that defines how the SDK is opened and closed.

1. `embedded`: if this mode is specified a close option will be added to the manage card screen so the user can close it and return to the _host app_. This is the recommended mode when you are starting the Apto UI SDK from an existing app.
2. `standalone`: if this case the SDK can only be closed via logout. Use this mode when the _host app_ has no other features than starting the Apto UI SDK.

### initialUserData parameter

This is an optional parameter defaulted to `nil`. If can be used to sent user data to the SDK avoiding the user to enter that information again.

### options parameter

A `CardOptions` instance that allows SDK customization. This is a default parameter defaulted to `nil`. Using this parameter you can decide the features that are available to your users, or the font type to be used in the app.

```swift
let options = CardOptions(features:fontCustomizationOptions:)
```

`features: [FeatureKey: Bool]` is a dictionary that contains the state for each feature. The available `FeatureKey` are:

1. `showActivateCardButton` control if the SDK allows (shows) the user to activate the physical card or not. **Default to true**.
2. `showStatsButton` control if the user can see his monthly consume stats. **Default to false**.
3. `showNotificationPreferences` control if the user can customize the notification channels. **Default to false**.
4. `showDetailedCardActivityOption` control if the user can show other transaction types (like declined transactions). **Default to false**.

`fontCustomizationOptions: FontCustomizationOptions` is an optional parameter that specify a custom font to be used in the app. If no font customization options is specified the SDK will use the system font. There are two ways of specifying a custom font:

1. using a `ThemeFontDescriptors` where you specify a custom font for regular, medium, semi-bold and bold fonts.

```swift
let descriptors = ThemeFontDescriptors(regular: UIFontDescriptor(name:"XYZ-Regular", size: 10),
                                       medium: UIFontDescriptor(name:"XYZ-Medium", size: 10),
                                       semibold: UIFontDescriptor(name:"XYZ-Semibold", size: 10),
                                       bold: UIFontDescriptor(name:"XYZ-Bold", size: 10))
let options = CardOptions(features: [:], fontCustomizationOptions: .fontDescriptors(descriptors))
```

2. using a `UIFontProviderProtocol`. You will have to adopt the protocol in one of your classes and implement the different styles. This allows you to have complete control over the fonts types and size shown in the app, but **handle with care** as it _might break_ the look and feel of the SDK.

```swift
let provider = MyCustomFontProvider()
let options = CardOptions(features: [:], fontCustomizationOptions: .fontProvider(provider))
```

### googleMapsApiKey parameter

This is an optional parameter defaulted to `nil` and allows you to specify a Google Maps Api Key to be used by the SDK. This parameter is required if you are using our UI to collect an address from your user, otherwise you can just ignore it.

### completion parameter

A callback closure called once the Apto UI SDK has been initialized or if initialization failed. The closure has a single `Result<UIModule, NSError>` parameter.
