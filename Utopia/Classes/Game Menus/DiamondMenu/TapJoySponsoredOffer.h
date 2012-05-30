//
//  TapJoySponsoredOffer.h
//  Utopia
//
//  Created by Kevin Calloway on 5/21/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InAppPurchaseData.h"

@interface TapJoySponsoredOffer : NSObject <InAppPurchaseData> {
  NSString *primaryTitle;
  NSString *secondaryTitle;
  NSString *price;
  NSLocale *priceLocale;
}

+(id<InAppPurchaseData>) create;
@end
