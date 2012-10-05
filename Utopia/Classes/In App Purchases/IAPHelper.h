#import <Foundation/Foundation.h>
#import "StoreKit/StoreKit.h"

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    NSArray * _products;
    SKProductsRequest * _request;
}

@property (retain) NSArray * products;
@property (retain) SKProductsRequest *request;

+ (IAPHelper *) sharedIAPHelper;
- (void)requestProducts;
- (void)buyProductIdentifier:(SKProduct *)product;
- (NSString *) priceForProduct:(SKProduct *)product;

@end
