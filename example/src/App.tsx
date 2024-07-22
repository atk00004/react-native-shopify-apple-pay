import { useCallback } from 'react';
import { StyleSheet, View, Text, TouchableOpacity } from 'react-native';
import { runApplePay } from 'react-native-shopify-apple-pay';

const checkoutConfig: CheckoutConfig = {
  currencyCode: 'USD',
  countryCode: 'US',
  discount: 5,
  merchantID: 'sandbox_rzqjhfv6_mxtqjkx82q8zy799',
  companyName: 'Anh Hùng đẹp trai',
  subTotal: 20,
  tax: 4,
  total: 20,
  shippingMethods: [],
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
