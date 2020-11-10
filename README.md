# Apto UI SDK for iOS [![CocoaPods](https://img.shields.io/cocoapods/v/AptoUISDK.svg?style=plastic)](https://cocoapods.org/pods/AptoUISDK)

Welcome to the Apto iOS UI SDK. This SDK provides access to Apto's mobile platform, and is designed for you to control the UI/UX.

You can quickly set up a cardholder experience (UI/UX for cards) by dropping the SDK into your existing application or distributing it as a standalone mobile application. The UI/UX may be configured to match your organization's branding look and feel.

With this SDK you can quickly:

* [Set up a UI/UX for a card.](#user-content-start-the-card-ui-flow-process)
* [Customize the UI/UX for a card.](#user-content-cardoptions-parameters)

**Note:** The Apto Mobile API has a request rate limit of 1 request per 30 seconds for the verification and login endpoints.

This document provides an overview of how to:

* [Install the SDK](#user-content-install-the-sdk)
* [Initialize the SDK](#user-content-initialize-the-sdk)
* [Start the Card UI Flow Process](#user-content-start-the-card-ui-flow-process)

For more information, see the [Apto Developer Docs](http://docs.aptopayments.com) or the [Apto API Docs](https://docs.aptopayments.com/api/MobileAPI.html).

To contribute to the SDK development, see [Contributions & Development](#user-content-contributions--development)

## Requirements

* iOS 10.0 (minimum version)
* Xcode 10.2 (minimum version)
* Swift 5 (minimum version)
* CocoaPods. No minimum version is required, but version 1.8.3 or higher is recommended.

### Get the Mobile API key

A Mobile API Key is required to run the SDK. To retrieve your Mobile API Key:

1. Register for an account or login into the [Apto Developer Portal](https://developer.aptopayments.com). 
	
	**Note:** In order to register or login to your [Apto Developer Portal](https://developer.aptopayments.com) account, you will need to download a 2FA app such as the [Google Authenticator App](https://apps.apple.com/us/app/google-authenticator/id388497605) for your mobile device.

2. 	Your account has different Mobile API Keys: Sandbox and Production. Ensure you choose the correct environment from the dropdown located in the lower left of the page. 
	
	![Mobile API Key](readme_images/environment.jpg)

3. Select **Developers** from the left menu. Your **Mobile API Key** is listed on this page.

	![Mobile API Key](readme_images/devPortal_mobileApiKey.jpg)

	**Note:** `MOBILE_API_KEY` is used throughout this document to represent your Mobile API key. Ensure you replace `MOBILE_API_KEY` with the Mobile API Key in your account.

## Install the SDK 

1. We suggest using [CocoaPods](https://cocoapods.org) to install the SDK:

2. In your project's `Podfile`:

	* At the top of the document, ensure the platform specified is set to iOS 10 and frameworks are enabled:
	
	    ```
	    platform :ios, '10.0'
	    
	    ...
	    
	    use_frameworks!
	    ```
    
	* Add the Apto iOS SDK pod dependency:

		```
		def runtimepods
			
			...
			
	   		pod 'AptoUISDK'
	   		
	   		...
	   	```

3. Open your Terminal app, and navigate to your project's folder containing the `Podfile` using `cd`:

	```bash
	cd PATH_TO_PROJECT_FOLDER
	```

4. Install the SDK by running the following command:

	```bash
	pod install
	```

## Initialize the SDK

The SDK must be initialized with your `MOBILE_API_KEY`.

Invoke the `initializeWithApiKey` SDK method and pass in the `MOBILE_API_KEY` from the [Apto Developer Portal](https://developer.aptopayments.com). This fully initializes the SDK for your application.


```swift
AptoPlatform.defaultManager().initializeWithApiKey("MOBILE_API_KEY")
```

**Note:** By default, the SDK is initialized for production mode. 

To use the SDK in sandbox mode, append the `environment` parameter during initialization and set the environment to `.sandbox`:

```swift
AptoPlatform.defaultManager().initializeWithApiKey("MOBILE_API_KEY", environment: .sandbox)
```

## Start the Card UI Flow Process

Once the SDK is initialized, you can initiate the card UI flow process with the `startCardFlow` SDK method.

To start the card UI flow process, invoke the `startCardFlow` method, passing in your `UIViewController` subclass and `ShiftCardModuleMode` values:

```swift
  AptoPlatform.defaultManager().startCardFlow(from: self, mode: .standalone) { [weak self] result in
    switch result {
    case .failure(let error):
      // handle error
    case .success(let module):
      // SDK successfully initialized
    }
  }
```

The callback closure has a single `Result<UIModule, NSError>` parameter. Use the `result` object for error handling, or to add additional features once the SDK is successfully initialized.

The `startCardFlow` method has two required parameters and two optional parameters:

Parameter|Description
---|---
`from`|The `UIViewController` subclass where the SDK is initialized. This is used to present the SDK to the user.
`mode`|A `ShiftCardModuleMode` value defining how the SDK is opened and closed. The available modes are: <ul><li>`embedded`: This mode displays a close option on the manage card screen, enabling the to close the card UI and return to the main application view. We recommend using this mode when starting the Apto UI SDK from an existing app.</li><li>`standalone`: This mode enables the SDK to only be closed via the logout process. We recommend using this mode if your application is only using the Apto UI SDK and no has other features.</li><ul>
`options` (optional)|This is a `CardOptions` object enabling SDK customization. Use this parameter to: <ul><li>Enable / disable available features for your users</li><li>Specify the font type for the card UI.</li></ul>The default value is `nil`.<br><br>See [CardOptions Parameters](#user-content-cardoptions-parameters) for more information.
`initialUserData` (optional)|Use this parameter to send user data to the SDK, to free the user from having to re-enter their information. The default value is `nil`.

### CardOptions Parameters

Use the `CardOptions` object to customize the UI/UX of your card.

```swift
let options = CardOptions(features:fontCustomizationOptions:)
```

**Note:** If you need to customize the logo and/or card design, it will need to be configured on our servers. You will need to send us a 969px × 612px png file of the entire card, including the background, company logo, and network logo (IE Visa, Mastercard, etc). Please [contact us](mailto:developers@aptopayments.com) for more information.

The `CardOptions` object has two parameters:

Parameter|Description
---|---
`features`|This parameter accepts a dictionary of `FeatureKey`-`Bool` key-value pairs. Each key-value pair represents a feature.<br><br>See [FeatureKey Options](#user-content-featurekey-options) for more information.
`fontCustomizationOptions` (optional)|This is a `ThemeFontDescriptors` object used to specify a custom font for the card UI. If no font customization options are specified, the SDK will use the system font.<br><br>See [The `fontCustomizationOptions` Parameter](#user-content-the-fontcustomizationoptions-parameter) for more information.

#### FeatureKey Options

The available `FeatureKey` options are:

Parameter|Default Value|Description
---|---|---
`showActivateCardButton`|`true`|Controls if the SDK displays the **Activate Card** button. This button enables the user to activate a physical card.
`showStatsButton`|`false`|Controls the Stats button is displayed. This enables the user to see their monthly consumption statistics.<br><br>![Stats button](readme_images/stats.jpg)
`showNotificationPreferences`|`false`|Controls if the user can customize their notification preferences.
`showDetailedCardActivityOption`|`false`|Controls if the user can view detailed transaction activity. For example, declined transactions.
`showAccountSettingsButton`|`true`|Controls if the Account Settings button is displayed. This enables the user to see the account settings screen.<br><br>![Account Settings button](readme_images/accounts.jpg)
`showMonthlyStatementsOption`|`true`|Controls if the user can view their monthly statements.
`authenticateOnStartup`|`false`|Controls if the user must authenticate their account (using a Passcode or Biometrics), when the app starts or after returning from background mode.
`authenticateWithPINOnPCI`|`false`|Controls if the user must authenticate using their Passcode, prior to viewing their full card data. <br><br>**Note:** If biometric authentication is enabled, it will appear first. The user may choose to cancel biometric authentication and use their Passcode instead.
`supportDarkMode`|`false`|Controls if the UI's dark theme is enabled.

#### The fontCustomizationOptions Parameter

The `fontCustomizationOptions` parameter specifies custom fonts for the UI. The parameter may be one of the following object types:

* [`ThemeFontDescriptors`](#user-content-themefontdescriptors-object) - Use this object to specify pre-existing fonts.
* [Custom class with a `UIFontProviderProtocol`](#user-content-uifontproviderprotocol-object) - Use this object for custom fonts.

##### ThemeFontDescriptors Object

The `ThemeFontDescriptors` object can have up to 4 type face parameters:

* `regular`
* `medium`
* `semibold`
* `bold`

**Note:** Although no parameters are required to create a `ThemeFontDescriptors` object, we recommend you:

* Set no type faces, and use the default phone fonts for the UI.
* Set all 4 type faces to provide consistent fonts throughout the UI.

To create a `ThemeFontDescriptors` object, pass in a `UIFontDescriptor` object for each font type:

```swift
let descriptors = ThemeFontDescriptors(regular: UIFontDescriptor(name:"XYZ-Regular", size: 10),
                                       medium: UIFontDescriptor(name:"XYZ-Medium", size: 10),
                                       semibold: UIFontDescriptor(name:"XYZ-Semibold", size: 10),
                                       bold: UIFontDescriptor(name:"XYZ-Bold", size: 10))
```

Use the resulting `ThemeFontDescriptors` object as the `fontCustomizationOptions` parameter for the `CardOptions` object:

```swift
let options = CardOptions(features: [:], fontCustomizationOptions: .fontDescriptors(descriptors))
```

##### UIFontProviderProtocol Object

To use a custom font, create a custom class implementing the `UIFontProviderProtocol`. This protocol enables you to have complete control over the fonts types and sizes shown in the card UI.

**Note:** You will need to modify the protocol within one of your classes to implement the different styles, but *handle with care*, as it _may break_ the look and feel of the card UI.

To specify the `fontCustomizationOptions` parameter with a custom class implementing the `UIFontProviderProtocol`, wrap the `provider` in the `.fontProvider()` method:

```swift
let provider = MyCustomFontProvider()
let options = CardOptions(features: [:], fontCustomizationOptions: .fontProvider(provider))
```

### Google Maps API Key parameter

This is an optional parameter defaulted to `nil` and allows you to specify a Google Maps Api Key to be used by the SDK. This parameter is required if you are using our UI to collect an address from your user, otherwise you can just ignore it.

## Contributions & Development

We look forward to receiving your feedback, including new feature requests, bug fixes and documentation improvements.

If you would like to help: 

1. Refer to the [issues](issues) section of the repository first, to ensure your feature or bug doesn't already exist (The request may be ongoing, or newly finished task).
2. If your request is not in the [issues](issues) section, please feel free to [create one](issues/new). We'll get back to you as soon as possible.

If you want to help improve the SDK by adding a new feature or bug fix, we'd be happy to receive [pull requests](compare)!
