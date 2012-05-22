//
//  SponsoredOffer.h
//  Utopia
//
//  Created by Kevin Calloway on 5/21/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol InAppPurchaseData <NSObject>
@property(nonatomic, readonly) NSString *primaryTitle;
@property(nonatomic, readonly) NSString *secondaryTitle;
@property(nonatomic, readonly) NSString *price;
@property(nonatomic, readonly) NSLocale *priceLocale;
- (void) makePurchase;
@end

@interface SponsoredOffer : NSObject <InAppPurchaseData> {
  NSString *primaryTitle;
  NSString *secondaryTitle;
  NSString *price;
  NSLocale *priceLocale;
  
  SKProduct *_product;
}


#pragma Factory Methods
+(id<InAppPurchaseData>) createForAdColony;
+(id<InAppPurchaseData>) createWithSKProduct:(SKProduct *)product;
+(NSArray *) allSponsoredOffers;

@end
