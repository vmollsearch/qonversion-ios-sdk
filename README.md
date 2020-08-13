<p align="center">
 <a href="https://qonversion.io" target="_blank"><img width="460" height="150" src="https://qonversion.io/img/q_brand.svg"></a>
</p>

<p align="center">
     <a href="https://qonversion.io"><img width="660" src="https://qonversion.io/img/images/product-center.svg"></a></p>

<p>
Qonversion provides full in-app purchases infrastructure, so you do not need to build your own server for receipt validation.
</p>

<p>
Implement in-app subscriptions, validate user receipts, check subscription status, and provide access to your app features and content using our StoreKit wrapper and Google Play Billing wrapper.
</p>

Read more in [documentation](https://docs.qonversion.io).


[![Version](https://img.shields.io/cocoapods/v/Qonversion.svg?style=flat)](https://cocoapods.org/pods/Qonversion)
[![Platform](https://img.shields.io/cocoapods/p/Qonversion.svg?style=flat)](https://cocoapods.org/pods/Qonversion)


## Product Center

![A111](https://qonversion.io/img/images/product-center-scheme.svg)

1. Application calls the purchase method to initialize Qonversion SDK.
2. Qonversion SDK communicates with StoreKit or Google Billing Client to make a purchase.
3. If a purchase is successful, the SDK sends a request to Qonversion API for server-to-server validation of purchase. Qonversion server unlocks permissions associated with the product.
4. SDK returns control to the application with a processing state

## Analytics

Monitor your in-app revenue metrics. Understand your customers and make better decisions with precise subscription revenue data.

![A111](https://qonversion.io/img/screenshots/desktop/mobile_subscription_analytics.jpg)

## Integraitons

Share your iOS and Android in-app subscription data with your favorite platforms.

![A111](https://qonversion.io/img/illustrations/pic-integration.svg)


## License

Qonversion SDK is available under the MIT license.
