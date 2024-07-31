import { useCallback } from 'react';
import { StyleSheet, View, Text, TouchableOpacity } from 'react-native';
import { runApplePay } from 'react-native-shopify-apple-pay';

const checkoutConfig: CheckoutConfig = {
  currencyCode: 'USD',
  countryCode: 'US',
  merchantID: 'merchant.com.jmango360.bigcommerce.v5',
  companyName: 'Anh Hùng đẹp trai',
  shopDomain: '0e58bd-74.myshopify.com',
  apiKey: '7f4d80d5f94673e8f78e2fc17633b93a',
  lineItems: [
    {
      quantity: 1,
      variantId: 'gid://shopify/ProductVariant/46124368625896',
    },
  ],
};
export default function App() {
  const onPress = useCallback(() => {
    runApplePay(checkoutConfig as CheckoutConfig);
  }, []);

  return (
    <View style={styles.container}>
      <TouchableOpacity
        onPress={onPress}
        style={{
          width: 200,
          height: 40,
          backgroundColor: 'green',
          justifyContent: 'center',
          alignItems: 'center',
          borderRadius: 5,
        }}
      >
        <Text>Pay</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
