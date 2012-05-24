//
//  InAppPurchaseData.m
//  Utopia
//
//  Created by Kevin Calloway on 5/22/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "InAppPurchaseData.h"
#import "SponsoredOffer.h"
#import "Globals.h"
#import "IAPHelper.h"

@implementation InAppPurchaseData
@dynamic primaryTitle;
@dynamic secondaryTitle;
@dynamic price;
@synthesize priceLocale;

#pragma InAppPurchaseData
- (BOOL) purchaseAvailable
{
    return YES;
}

- (void) makePurchase 
{
  [[IAPHelper sharedIAPHelper] buyProductIdentifier:_product];
}

-(NSString *) primaryTitle
{
  return _product.localizedTitle;
}

-(NSString *) price
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    [numberFormatter setLocale:_product.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:_product.price];
    [numberFormatter release];
    
    return formattedString;
}

-(NSString *) secondaryTitle
{
  return [NSString stringWithFormat:@"%@", 
          [[[Globals sharedGlobals] productIdentifiers] 
           objectForKey:_product.productIdentifier]];
}


#pragma mark  Create/Destroy
-(id) initWithSKProduct:(SKProduct *)product
{
  self = [super init];
  if (self) {
    _product  = product;
    [_product retain];
  }
  return self;
}

-(void)dealloc
{
  [_product release];
  
  [super dealloc];
}

+(id<InAppPurchaseData>) createWithSKProduct:(SKProduct *)product
{
  InAppPurchaseData *offer = [[InAppPurchaseData alloc] initWithSKProduct:product];
  [offer autorelease];
  return offer;  
}

+(NSArray *) allSponsoredOffers
{
  NSMutableArray *offers = [NSMutableArray array];
  [offers addObject:[SponsoredOffer createForAdColony]];
  [offers addObject:[SponsoredOffer createForTapJoy]];
  return offers;
}
@end
