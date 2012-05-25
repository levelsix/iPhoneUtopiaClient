//
//  InAppPurchaseData.h
//  Utopia
//
//  Created by Kevin Calloway on 5/22/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol InAppPurchaseData <NSObject>
@property(nonatomic, readonly) NSString *primaryTitle;
@property(nonatomic, readonly) NSString *secondaryTitle;
@property(nonatomic, readonly) NSString *price;
@property(nonatomic, readonly) NSLocale *priceLocale;
@property(nonatomic, readonly) UIImage  *rewardPic;

- (void) makePurchase;
- (BOOL) purchaseAvailable;
@end

@interface InAppPurchaseData : NSObject<InAppPurchaseData> {
  SKProduct *_product;
}

+(NSString *) unknownPrice;
+(NSString *) freePrice;
#pragma Factory Methods
+(id<InAppPurchaseData>) createWithSKProduct:(SKProduct *)product;
+(NSArray *) allSponsoredOffers;
@end
