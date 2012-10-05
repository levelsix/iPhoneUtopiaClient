//
//  TwitterSponsoredOffer.h
//  Utopia
//
//  Created by Kevin Calloway on 5/31/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InAppPurchaseData.h"
#import "OperationWaitCounter.h"

@interface TwitterSponsoredOffer : NSObject <InAppPurchaseData> {
  NSString *primaryTitle;
  NSString *secondaryTitle;
  NSString *price;
  id<OperationWaitCounter> _waitCounter;
}

+(id<InAppPurchaseData>) create;

@end
