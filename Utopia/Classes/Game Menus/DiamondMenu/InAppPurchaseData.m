//
//  InAppPurchaseData.m
//  Utopia
//
//  Created by Kevin Calloway on 5/22/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "InAppPurchaseData.h"
#import "TapJoySponsoredOffer.h"
#import "Globals.h"
#import "IAPHelper.h"
#import "FlurryClipsSponsoredOffer.h"
#import "AdColonySponsoredOffer.h"
#import "FacebookSponsoredOffer.h"
#import "TwitterSponsoredOffer.h"

@implementation InAppPurchaseData
@dynamic primaryTitle;
@dynamic secondaryTitle;
@dynamic price;
@dynamic rewardPic;

-(UIImage *) rewardPic
{
  return [Globals imageNamed:@"stack.png"];
}

+(void) postAdTakeoverResignedNotificationForSender:(id)sender
{
  [[NSNotificationCenter defaultCenter] 
   postNotificationName:[InAppPurchaseData adTakeoverResignedNotification] 
   object:sender];
}

+(NSString *) adTakeoverResignedNotification
{
  return @"adTakeoverResignedNotification";
}

#pragma InAppPurchaseData
- (BOOL) purchaseAvailable
{
    return YES;
}

-(void) makePurchaseWithViewController:(UIViewController *)controller
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


#pragma Constant Strings
+(NSString *) unknownPrice
{
  return UNKNOWN_PRICE_STR;
}

+(NSString *) freePrice
{
  return FREE_PRICE_STR;
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
  [offers addObject:[AdColonySponsoredOffer    create]];
  [offers addObject:[FlurryClipsSponsoredOffer create]];
  [offers addObject:[TapJoySponsoredOffer      create]];
  [offers addObject:[FacebookSponsoredOffer    create]];
  [offers addObject:[TwitterSponsoredOffer     create]];

  return offers;
}
@end
