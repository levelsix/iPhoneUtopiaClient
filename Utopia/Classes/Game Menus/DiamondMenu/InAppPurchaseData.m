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
#import "TwitterSponsoredOffer.h"
#import "FacebookSponsoredOffer.h"
//#import "AdColonySponsoredOffer.h"

@implementation InAppPurchaseData
@dynamic primaryTitle;
@dynamic secondaryTitle;
@dynamic price;
@dynamic rewardPicName;
@dynamic isGold;
@dynamic salePrice;
@dynamic discount;

-(NSString *) rewardPicName
{
  Globals *gl = [Globals sharedGlobals];
  InAppPurchasePackageProto *p = [gl packageForProductId:_product.productIdentifier];
  return p.imageName;
}

- (BOOL) isGold {
  Globals *gl = [Globals sharedGlobals];
  InAppPurchasePackageProto *p = [gl packageForProductId:_product.productIdentifier];
  return p.isGold;
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
  [[IAPHelper sharedIAPHelper] buyProductIdentifier:_saleProduct ? _saleProduct : _product];
}

-(NSString *) primaryTitle
{
  return _product.localizedTitle;
}

-(NSString *) price
{
  return [[IAPHelper sharedIAPHelper] priceForProduct:_product];
}

- (NSString *) salePrice {
  return _saleProduct ? [[IAPHelper sharedIAPHelper] priceForProduct:_saleProduct] : nil;
}

- (int) discount {
  if (_saleProduct) {
    float normPrice = _product.price.floatValue;
    float salePrice = _saleProduct.price.floatValue;
    return (int)roundf((normPrice-salePrice)/normPrice*100.f);
  }
  return 0;
}

-(NSString *) secondaryTitle
{
  Globals *gl = [Globals sharedGlobals];
  InAppPurchasePackageProto *p = [gl packageForProductId:_product.productIdentifier];
  return [NSString stringWithFormat:@"%@",[Globals commafyNumber:p.currencyAmount]];
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
-(id) initWithProduct:(SKProduct *)product saleProduct:(SKProduct *)saleProduct
{
  self = [super init];
  if (self) {
    _product  = product;
    [_product retain];
    _saleProduct = saleProduct;
    [_saleProduct retain];
  }
  return self;
}

-(void)dealloc
{
  [_product release];
  [_saleProduct release];
  
  [super dealloc];
}

+(id<InAppPurchaseData>) createWithProduct:(SKProduct *)product saleProduct:(SKProduct *)saleProduct
{
  InAppPurchaseData *offer = [[InAppPurchaseData alloc] initWithProduct:product saleProduct:saleProduct];
  [offer autorelease];
  return offer;
}

+(NSArray *) allSponsoredOffers
{
  NSMutableArray *offers = [NSMutableArray array];
  //  [offers addObject:[AdColonySponsoredOffer    create]];
  //  [offers addObject:[TapJoySponsoredOffer      create]];
  /*
   * Disabled Sponsored offers:(Short Term)
   *
   [offers addObject:[FlurryClipsSponsoredOffer create]];
   [offers addObject:[TapJoySponsoredOffer      create]];
   [offers addObject:[TwitterSponsoredOffer     create]];
   *
   */
  [offers addObject:[FacebookSponsoredOffer    create]];
  return offers;
}
@end
