import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-shopify-apple-pay' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const ShopifyApplePay: ApplePayModule = NativeModules.ShopifyApplePay
  ? NativeModules.ShopifyApplePay
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export function runApplePay(checkoutData: CheckoutConfig): Promise<number> {
  return ShopifyApplePay.runApplePay(checkoutData);
}
