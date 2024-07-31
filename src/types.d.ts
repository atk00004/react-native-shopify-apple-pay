interface CheckoutConfig {
  merchantID: string;
  companyName: string;
  currencyCode: string;
  countryCode: string;
  shopDomain: string;
  apiKey: string;
  lineItems: LineItem[];
}

interface LineItem {
  quantity: number;
  variantId: string;
}

interface ApplePayModule {
  runApplePay: (input: CheckoutConfig) => Promise<any>;
  canMakeApplePay: () => Promise<boolean>;
}
