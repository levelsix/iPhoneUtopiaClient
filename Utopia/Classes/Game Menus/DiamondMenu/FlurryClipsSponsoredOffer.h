//
//  FlurryClipsSponsoredOffer.h
//  Utopia
//
//  Created by Kevin Calloway on 5/25/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InAppPurchaseData.h"

@interface FlurryClipsSponsoredOffer : NSObject <InAppPurchaseData> {
  NSString *primaryTitle;
  NSString *secondaryTitle;
  NSString *price;
  NSString *_rewardMsg;
}

+(id<InAppPurchaseData>) create;
@end
