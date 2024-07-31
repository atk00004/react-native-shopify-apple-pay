
import MobileBuySDK

extension Storefront.CheckoutQuery {
    
    @discardableResult
    func fragmentForCheckout() -> Storefront.CheckoutQuery { return self
        .id()
        .ready()
        .requiresShipping()
        .taxesIncluded()
        .email()
        .availableShippingRates{ $0
            .ready()
            .shippingRates{ $0
                .title()
                .price{ $0
                    .amount()
                    .currencyCode()
                }
                .handle()
            }
            
        }
        
        .discountApplications(first: 250) { $0
            .edges { $0
                .node { $0
                    .onDiscountCodeApplication { $0
                        .applicable()
                        .code()
                    }
                    .onManualDiscountApplication { $0
                        .title()
                    }
                    .onScriptDiscountApplication { $0
                        .title()
                    }
                }
            }
        }
        
        .shippingDiscountAllocations { $0
            .fragmentForDiscountAllocation()
        }
        
        .appliedGiftCards { $0
            .id()
            .balance { $0
                .amount()
                .currencyCode()
            }
            .amountUsed { $0
                .amount()
                .currencyCode()
            }
            .lastCharacters()
        }
        
        .shippingAddress { $0
            .firstName()
            .lastName()
            .phone()
            .address1()
            .address2()
            .city()
            .country()
            .countryCodeV2()
            .province()
            .provinceCode()
            .zip()
        }
        
        .shippingLine { $0
            .handle()
            .title()
            .price { $0
                .amount()
                .currencyCode()
            }
        }
        
        .order { $0
            .id()
            .financialStatus()
            .fulfillmentStatus()
            .orderNumber()
        }
        
        .note()
        .lineItems(first: 250) { $0
            .edges { $0
                .cursor()
                .node { $0
                    .variant { $0
                        .id()
                        .price { $0
                            .amount()
                            .currencyCode()
                        }
                    }
                    .title()
                    .quantity()
                    .discountAllocations { $0
                        .fragmentForDiscountAllocation()
                    }
                }
            }
        }
        .totalDuties { $0
            .amount()
            .currencyCode()
        }
        .webUrl()
        .currencyCode()
        .subtotalPrice { $0
            .amount()
            .currencyCode()
        }
        .totalTax { $0
            .amount()
            .currencyCode()
        }
        .totalPrice { $0
            .amount()
            .currencyCode()
        }
        .paymentDue { $0
            .amount()
            .currencyCode()
        }
    }
}

extension Storefront.DiscountAllocationQuery {
    
    @discardableResult
    func fragmentForDiscountAllocation() -> Storefront.DiscountAllocationQuery { return self
        .allocatedAmount { $0
            .amount()
            .currencyCode()
        }
        .discountApplication { $0
            .onDiscountCodeApplication { $0
                .applicable()
                .code()
            }
            .onManualDiscountApplication { $0
                .title()
            }
            .onScriptDiscountApplication { $0
                .title()
            }
        }
    }
}

extension Storefront.PaymentQuery {
    
    @discardableResult
    func fragmentForPayment() -> Storefront.PaymentQuery { return self
        .id()
        .ready()
        .test()
        .amount { $0
            .amount()
            .currencyCode()
        }
        .checkout { $0
            .fragmentForCheckout()
        }
        .creditCard { $0
            .firstDigits()
            .lastDigits()
            .maskedNumber()
            .brand()
            .firstName()
            .lastName()
            .expiryMonth()
            .expiryYear()
        }
        .transaction { $0
            .statusV2()
            .kind()
        }
        .errorMessage()
    }
}
