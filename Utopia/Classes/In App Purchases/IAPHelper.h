//
//  IAPHelper.h
//  InAppRage
//
//  Created by Ray Wenderlich on 2/28/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoreKit/StoreKit.h"

#define kProductsLoadedNotification         @"ProductsLoaded"
#define kProductPurchasedNotification       @"ProductPurchased"
#define kProductPurchaseFailedNotification  @"ProductPurchaseFailed"

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    NSSet * _productIdentifiers;    
    NSArray * _products;
    SKProductsRequest * _request;
}

@property (retain) NSSet *productIdentifiers;
@property (retain) NSArray * products;
@property (retain) SKProductsRequest *request;

+ (IAPHelper *) sharedIAPHelper;
- (void)requestProducts;
- (void)buyProductIdentifier:(SKProduct *)product;

@end
