//
//  FacebookSponsoredOffer.h
//  Utopia
//
//  Created by Kevin Calloway on 5/28/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InAppPurchaseData.h"
#import "FacebookDelegate.h"
#import "OperationWaitCounter.h"

@interface FacebookSponsoredOffer : NSObject <InAppPurchaseData> {
  NSString *primaryTitle;
  NSString *secondaryTitle;
  NSString *price;
  id<FacebookGlobalDelegate> fbDelegate;
}

+(id<InAppPurchaseData>) create;

@end
