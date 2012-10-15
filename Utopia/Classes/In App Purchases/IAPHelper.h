#import <Foundation/Foundation.h>
#import "StoreKit/StoreKit.h"

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    NSDictionary * _products;
    SKProductsRequest * _request;
}

@property (retain) NSDictionary *products;
@property (retain) SKProductsRequest *request;

+ (IAPHelper *) sharedIAPHelper;
- (void)requestProducts;
- (void)buyProductIdentifier:(SKProduct *)product;
- (NSString *) priceForProduct:(SKProduct *)product;

@end
