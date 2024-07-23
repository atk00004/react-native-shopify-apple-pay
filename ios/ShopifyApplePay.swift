import Foundation
import PassKit

@objc(ShopifyApplePay)
class ShopifyApplePay: NSObject {
    func createPaymentRequest(_ checkoutData: NSDictionary) -> PKPaymentRequest {
        let discount = NSDecimalNumber(value: checkoutData["discount"] as! Int);
        let totalPrice = NSDecimalNumber(value: checkoutData["total"] as! Int);
        let subtotalPrice = NSDecimalNumber(value: checkoutData["subTotal"] as! Int);
        let totalTax = NSDecimalNumber(value: checkoutData["tax"] as! Int);
        let companyName = checkoutData["companyName"] as! String;
        
        let discountItem = PKPaymentSummaryItem(label: "Discount", amount: discount)
        let taxItem = PKPaymentSummaryItem(label: "Tax", amount: totalTax)
        let subTotalItem = PKPaymentSummaryItem(label: "Sub Total", amount: subtotalPrice)
        let totalItem = PKPaymentSummaryItem(label: companyName, amount: totalPrice)
        
        let paymentRequest = PKPaymentRequest()
        paymentRequest.merchantIdentifier = checkoutData["merchantID"] as! String
        paymentRequest.countryCode = checkoutData["countryCode"] as! String
        paymentRequest.currencyCode = checkoutData["currencyCode"] as! String
        paymentRequest.supportedNetworks = [.masterCard, .visa]
        paymentRequest.merchantCapabilities = .capability3DS
        paymentRequest.shippingMethods = [];
        paymentRequest.requiredBillingContactFields = [.postalAddress]
        paymentRequest.requiredShippingContactFields = [.postalAddress, .name, .emailAddress, .phoneNumber]
        
        paymentRequest.paymentSummaryItems = [subTotalItem, discountItem, taxItem, totalItem]
        
        return paymentRequest
    }
    
    @objc
    func runApplePay(_ checkoutData: NSDictionary) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
//                reject("E_NO_ROOT_VIEW_CONTROLLER", "No root view controller", nil)
                return
            }
            
            let paymentRequest = self.createPaymentRequest(checkoutData);
            
            
            guard let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) else {
//                reject("E_NO_PAYMENT_VIEW_CONTROLLER", "Unable to create payment view controller", nil)
                return
            }
            
            paymentVC.delegate = self
            
            rootViewController.present(paymentVC, animated: true, completion: nil)
            
//            self.paymentCompletion = { success in
//                if success {
//                    resolve("Payment successful")
//                } else {
//                    reject("E_PAYMENT_FAILED", "Payment failed", nil)
//                }
//            }
        }
    }
    
    @objc
    func canMakePayments(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        let canMakePayments = PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: [.visa, .masterCard, .amex])
        resolve(canMakePayments)
    }
    
    private var paymentCompletion: ((Bool) -> Void)?
}


// ----------------------------------
//  MARK: - PKPaymentAuthorizationViewControllerDelegate -
//

extension ShopifyApplePay: PKPaymentAuthorizationViewControllerDelegate {
    @objc func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // Xử lý thanh toán thành công
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }
    
    @objc func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
