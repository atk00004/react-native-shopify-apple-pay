import Foundation
import PassKit
import MobileBuySDK

@objc(ShopifyApplePay)
class ShopifyApplePay: NSObject {
    private var client: Client?
    private var checkout: Storefront.Checkout?
    private var shippingRate: Storefront.ShippingRate?
    private var availableShippingRates: [Storefront.ShippingRate]?
    private var paymentIdentifier = UUID().uuidString;
    
    func createPaymentRequest(_ configData: NSDictionary, checkoutData: Storefront.Checkout) -> PKPaymentRequest {
//        let discount = NSDecimalNumber(value: checkoutData["discount"] as! Int);
        let totalPrice = NSDecimalNumber(decimal: checkoutData.totalPrice.amount)
        let subtotalPrice = NSDecimalNumber(decimal:checkoutData.subtotalPrice.amount)
                                            let totalTax = NSDecimalNumber(decimal:checkoutData.totalTax.amount)
        let companyName = configData["companyName"] as! String;
        
//        let discountItem = PKPaymentSummaryItem(label: "Discount", amount: discount)
        let taxItem = PKPaymentSummaryItem(label: "Tax", amount: totalTax)
        let subTotalItem = PKPaymentSummaryItem(label: "Sub Total", amount: subtotalPrice)
        let totalItem = PKPaymentSummaryItem(label: companyName, amount: NSDecimalNumber(string:"8.49"))
        
        let paymentRequest = PKPaymentRequest()
        paymentRequest.merchantIdentifier = configData["merchantID"] as! String
        paymentRequest.countryCode = configData["countryCode"] as! String
        paymentRequest.currencyCode = configData["currencyCode"] as! String
        paymentRequest.supportedNetworks = [.masterCard, .visa]
        paymentRequest.merchantCapabilities = .capability3DS
        paymentRequest.shippingMethods = [];
        paymentRequest.requiredBillingContactFields = [.postalAddress]
        paymentRequest.requiredShippingContactFields = [.postalAddress, .name, .emailAddress, .phoneNumber]
        
        paymentRequest.paymentSummaryItems = [subTotalItem, taxItem, totalItem]
        
        return paymentRequest
    }
    
    func createLineItems(_ checkoutData: NSDictionary) -> [Storefront.CheckoutLineItemInput] {
        let lineItems: [NSDictionary] = checkoutData["lineItems"] as! [NSDictionary];
        
        var lineItemsInput: [Storefront.CheckoutLineItemInput] = [];
        
        for item in lineItems {
            let quantity = item["quantity"] as! Int32;
            let variantId = GraphQL.ID(rawValue: item["variantId"] as! String)
            let inputLineItem = Storefront.CheckoutLineItemInput(quantity: quantity, variantId: variantId)
            lineItemsInput.append(inputLineItem)
        }
        
        return lineItemsInput;
    }
    
    @objc
    func runApplePay(_ configData: NSDictionary) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                //                reject("E_NO_ROOT_VIEW_CONTROLLER", "No root view controller", nil)
                return
            }
            
            let apiKey = configData["apiKey"];
            let shopDomain = configData["shopDomain"];
            
            let lineItems = self.createLineItems(configData)
            
            self.client = Client(shopDomain: shopDomain as! String, apiKey: apiKey as! String);
            
            self.client?.createCheckout(lineItem: lineItems, completion: { (checkout: Storefront.Checkout) in
                self.checkout = checkout
                let paymentRequest = self.createPaymentRequest(configData, checkoutData: checkout);
                
                guard let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) else {
                    //                reject("E_NO_PAYMENT_VIEW_CONTROLLER", "Unable to create payment view controller", nil)
                    return
                }
                
                paymentVC.delegate = self
                
                rootViewController.present(paymentVC, animated: true, completion: nil)
                
            })
        }
    }
    
    @objc
    func canMakePayments(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        let canMakePayments = PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: [.visa, .masterCard, .amex])
        resolve(canMakePayments)
    }
    
    private var paymentCompletion: ((Bool) -> Void)?
    
    private func buildPayAddress(_ contact: PKContact) -> PayAddress {
        var line1: String?
        var line2: String?
        
        if let address = contact.postalAddress {
            let street = address.street
            if !street.isEmpty {
                let lines  = street.components(separatedBy: .newlines)
                line1      = lines.count > 0 ? lines[0] : nil
                line2      = lines.count > 1 ? lines[1] : nil
            }
        }
        
        return PayAddress(addressLine1: line1, addressLine2: line2, city:         contact.postalAddress?.city,
                          country:      contact.postalAddress?.country,
                          province:     contact.postalAddress?.state,
                          zip:          contact.postalAddress?.postalCode,
                          firstName:    contact.name?.givenName,
                          lastName:     contact.name?.familyName,
                          phone:        contact.phoneNumber?.stringValue,
                          email:        contact.emailAddress)
    }
}


// ----------------------------------
//  MARK: - PKPaymentAuthorizationViewControllerDelegate -
//

extension ShopifyApplePay: PKPaymentAuthorizationViewControllerDelegate {
    @objc func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // Xử lý thanh toán thành công
        
        let billingAddress = self.buildPayAddress(payment.billingContact!)
        let shippingAddress = self.buildPayAddress(payment.shippingContact!)
        let applePayToken = String(data: payment.token.paymentData, encoding: .utf8)!

        self.client?.updateEmailCheckout((self.checkout?.id.rawValue)!, updatingEmail: (payment.shippingContact?.emailAddress)!) {
            _ in
            
            self.client?.updateShippingAddress((self.checkout?.id.rawValue)!, shippingAddress: shippingAddress) {
                _ in
                self.client?.completeCheckout(self.checkout!, billingAddress:  billingAddress, applePayToken: applePayToken, idempotencyToken: self.paymentIdentifier) {
                    _payment in
                    //TODO: check logic
                    print(_payment)
                    if let _payment = _payment, (self.checkout?.paymentDue.amount)! == (_payment.amount.amount) {
                        print("Checkout completed successfully.")
                    } else {
                        print("Checkout failed to complete.")
                    }
                    completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                }
            }
        }
    }
    
    @objc func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelectShippingContact contact: PKContact, handler completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void) {
        
        let shippingAddress = self.buildPayAddress(contact)
        
        self.client?.updateShippingAddress((self.checkout?.id.rawValue)!, shippingAddress: shippingAddress) {
            checkout in
                if let checkout = checkout {
                    //TODO: Update shipping method
                    self.checkout = checkout
                    let availableShippingRates = checkout.availableShippingRates?.shippingRates
                    self.availableShippingRates = availableShippingRates
                    
                    var shippingMethods: [PKShippingMethod] = []
                    if (availableShippingRates != nil) {
                        for item in availableShippingRates! {
                            let method = PKShippingMethod.init(label: item.title, amount: NSDecimalNumber(decimal: item.price.amount))
                            shippingMethods.append(method)
                        }
                    }
                    let update: PKPaymentRequestShippingContactUpdate = PKPaymentRequestShippingContactUpdate.init(errors: nil, paymentSummaryItems: [], shippingMethods: shippingMethods)
                    completion(update)
                    completion(PKPaymentRequestShippingContactUpdate())
                }
        }
    }
    
    @objc func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelect shippingMethod: PKShippingMethod, handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
        
        //TODO
        
        let shippingRate = PayShippingRate(handle: "shopify-Economy-7.49", title: shippingMethod.label, price: shippingMethod.amount as Decimal)
        
        self.client?.updateShippingRate((self.checkout?.id.rawValue)!, updatingShippingRate: shippingRate) {
            checkout in
            if let checkout = checkout {
                self.checkout = checkout
                completion(PKPaymentRequestShippingMethodUpdate())
            }
        }
    }
    
    @objc func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
