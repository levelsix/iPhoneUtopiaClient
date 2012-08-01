//
//  AdColonySponsoredOffer.h
//  Utopia
//
//  Created by Kevin Calloway on 5/28/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InAppPurchaseData.h"
#import "AdColonyPublic.h"

@interface AdColonySponsoredOffer : NSObject <InAppPurchaseData, AdColonyTakeoverAdDelegate> {
  NSString *primaryTitle;
  NSString *secondaryTitle;
  NSString *price;
  NSLocale *priceLocale;
}

+(id<InAppPurchaseData>) create;

@end