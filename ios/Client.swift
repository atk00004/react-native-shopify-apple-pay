import Foundation
import MobileBuySDK

final class Client {
    private let client: Graph.Client
    
    public init(shopDomain: String, apiKey: String) {
        self.client = Graph.Client(shopDomain: shopDomain, apiKey: apiKey)
    }
    
    @discardableResult
    func createCheckout(lineItem: [Storefront.CheckoutLineItemInput], completion: @escaping (Storefront.Checkout) -> Void) -> Task  {
        let mutation = ClientQuery.mutationForCreateCheckout(with: lineItem)
        let task     = self.client.mutateGraphWith(mutation) { response, error in
            error.debugPrint()
            
            completion((response?.checkoutCreate?.checkout)! as Storefront.Checkout)
        }
        
        task.resume()
        return task
    }
    
    func updateShippingAddress(_ id: String, shippingAddress address: PayAddress, completion: @escaping (Storefront.Checkout?) -> Void) {
        let mutation = ClientQuery.mutationForUpdateShippingAddressCheckout(id, shippingAddress: address)
        let task     = self.client.mutateGraphWith(mutation) { response, error in
            error.debugPrint()
            
            if let checkout = response?.checkoutShippingAddressUpdateV2?.checkout,
               let _ = checkout.shippingAddress {
                completion(checkout)
            } else {
                completion(nil)
                print("updateShippingAddress: No data reponse")
            }
        }
        
        task.resume()
    }
    
    @discardableResult
    func updateShippingRate(_ id: String, updatingShippingRate shippingRate: PayShippingRate, completion: @escaping (Storefront.Checkout?) -> Void) -> Task {
        let mutation = ClientQuery.mutationForUpdateShippingRateCheckout(id, updatingShippingRate: shippingRate)
        let task     = self.client.mutateGraphWith(mutation) { response, error in
            error.debugPrint()
            
            if let checkout = response?.checkoutShippingLineUpdate?.checkout,
               let _ = checkout.shippingLine {
                completion(checkout)
            } else {
                completion(nil)
                print("updateShippingRate: No data reponse")
            }
        }
        
        task.resume()
        return task
    }
    
    @discardableResult
    func updateEmailCheckout(_ id: String, updatingEmail email: String, completion: @escaping (Storefront.Checkout?) -> Void) -> Task {
        let mutation = ClientQuery.mutationForUpdateEmailCheckout(id, updatingEmail: email)
        let task     = self.client.mutateGraphWith(mutation) { response, error in
            error.debugPrint()
            
            if let checkout = response?.checkoutEmailUpdateV2?.checkout,
               let _ = checkout.email {
                completion(checkout)
            } else {
                completion(nil)
                print("updateEmailCheckout: No data reponse")
            }
        }
        
        task.resume()
        return task
    }
    
    func completeCheckout(_ checkout: Storefront.Checkout, billingAddress: PayAddress, applePayToken token: String, idempotencyToken: String, completion: @escaping (Storefront.Payment?) -> Void) {
        
        let mutation = ClientQuery.mutationForCompleteCheckoutUsingApplePay(checkout, billingAddress: billingAddress, token: token, idempotencyToken: idempotencyToken)
        let task     = self.client.mutateGraphWith(mutation) { response, error in
            error.debugPrint()
            print("response", response)
            if let payment = response?.checkoutCompleteWithTokenizedPaymentV3?.payment {
                
                print("Payment created, fetching status...")
                completion(payment)
                
            } else {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
}

extension Optional where Wrapped == Graph.QueryError {
    
    func debugPrint() {
        switch self {
        case .some(let value):
            print("Graph.QueryError: \(value)")
        case .none:
            break
        }
    }
}
