interface CheckoutConfig {
  merchantID: string;
  companyName: string;
  currencyCode: string;
  countryCode: string;
  shippingMethods: [];
  discount: number;
  tax: number;
  subTotal: number;
  total: number;
}

interface ApplePayModule {
  runApplePay: (input: CheckoutConfig) => Promise<any>;
  canMakeApplePay: () => Promise<boolean>;
}
