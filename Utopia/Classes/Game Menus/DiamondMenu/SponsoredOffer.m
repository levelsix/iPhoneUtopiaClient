//
//  SponsoredOffer.m
//  Utopia
//
//  Created by Kevin Calloway on 5/21/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "SponsoredOffer.h"
#import "Globals.h"
#import "IAPHelper.h"
#import "AdColonyPublic.h"
#define ADZONE1   @"vzdf3190ec43a042ab83fa7d"

@implementation SponsoredOffer
@dynamic primaryTitle;
@dynamic secondaryTitle;
@dynamic price;
@synthesize priceLocale;

- (void) makePurchase 
{
  if (_product) {
    [[IAPHelper sharedIAPHelper] buyProductIdentifier:_product];
  }
  else {
      [AdColony playVideoAdForZone:ADZONE1];
  }
}

-(NSString *) primaryTitle
{
  if (_product) {
    return _product.localizedTitle;
  }

  return primaryTitle;
}

-(NSString *) price
{
  if (_product) {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    [numberFormatter setLocale:_product.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:_product.price];
    [numberFormatter release];
    
    return formattedString;
  }
  
  return price;
}

-(NSString *) secondaryTitle
{
  if (_product) {
    return [NSString stringWithFormat:@"%@", 
            [[[Globals sharedGlobals] productIdentifiers] 
             objectForKey:_product.productIdentifier]];
  }

  return secondaryTitle;
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

-(id) initWithPrimaryTitle:(NSString *)primary 
         andSecondaryTitle:(NSString *)secondary
                  andPrice:(NSString *)curPrice
                 andLocale:(NSLocale *) locale
{
  self = [super init];
  if (self) {
    primaryTitle   = primary;
    secondaryTitle = secondary;
    price          = curPrice;
    priceLocale    = locale;
    
    [primaryTitle   retain];
    [secondaryTitle retain];
    [price          retain];
    [priceLocale    retain];
  }
  return self;
}

-(void)dealloc
{
  [primaryTitle   release];
  [secondaryTitle release];
  [price          release];
  [priceLocale    release];
  [_product       release];
  
  [super dealloc];
}

+(id<InAppPurchaseData>) createWithSKProduct:(SKProduct *)product
{
  SponsoredOffer *offer = [[SponsoredOffer alloc] initWithSKProduct:product];
  [offer autorelease];
  return offer;  
}

+(id<InAppPurchaseData>) createForAdColony
{
  SponsoredOffer *offer = [[SponsoredOffer alloc] 
                           initWithPrimaryTitle:@"Watch Video Earn Gold"
                           andSecondaryTitle:@"50" 
                           andPrice:@"" 
                           andLocale:nil];
  [offer autorelease];
  return offer;
}

+(NSArray *) allSponsoredOffers
{
  NSMutableArray *offers = [NSMutableArray array];
  [offers addObject:[SponsoredOffer createForAdColony]];
  return offers;
}

@end
