//
//  SponsoredOffer.h
//  Utopia
//
//  Created by Kevin Calloway on 5/21/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdColonyPublic.h"
#import "InAppPurchaseData.h"
#define UNKNOWN_PRICE_STR   @"$$$"
#define FREE_PRICE_STR      @"Free"
#define NO_CLIPS            @"No Clips Available"

@interface SponsoredOffer : NSObject <InAppPurchaseData, AdColonyTakeoverAdDelegate> {
  NSString *primaryTitle;
  NSString *secondaryTitle;
  NSString *price;
  NSLocale *priceLocale;
  
  BOOL      isAdColony;
  BOOL      isTapJoy;
}
@property BOOL isAdColony;
@property BOOL isTapJoy;
+(id<InAppPurchaseData>) createForAdColony;
+(id<InAppPurchaseData>) createForTapJoy;
@end
