#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ShopifyApplePay, NSObject)

RCT_EXTERN_METHOD(runApplePay:(NSDictionary *)checkoutData)
RCT_EXTERN_METHOD(canMakePayments:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
