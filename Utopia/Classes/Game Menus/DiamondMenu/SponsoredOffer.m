//
//  SponsoredOffer.m
//  Utopia
//
//  Created by Kevin Calloway on 5/21/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "SponsoredOffer.h"

#define TEST_ADZONE1        @"vzdf3190ec43a042ab83fa7d"
#define PRODUCTION_ADZONE1  @"vze3ac5bd63ba3403db44644"

#ifdef DEBUG
#define ADZONE1   TEST_ADZONE1
#else
#define ADZONE1   PRODUCTION_ADZONE1
#endif 

#define NO_CLIPS  @"No Clips Available"
//#define NO_OFFERS @"No Offers Available"

@implementation SponsoredOffer
@dynamic primaryTitle;
@dynamic secondaryTitle;
@dynamic price;
@synthesize priceLocale;

#pragma InAppPurchaseData
- (BOOL) purchaseAvailable
{
  return [AdColony virtualCurrencyAwardAvailableForZone:ADZONE1];
}

- (void) makePurchase 
{
  if (![self purchaseAvailable]) {
  }
  else {
    [AdColony playVideoAdForZone:ADZONE1 withDelegate:self withV4VCPrePopup:YES andV4VCPostPopup:YES];    
  }
}

-(NSString *) primaryTitle
{
  return primaryTitle;
}

-(NSString *) price
{  
  return price;
}

-(NSString *) secondaryTitle
{  
  if (![self purchaseAvailable]) {
    return NO_CLIPS;
  }

  return secondaryTitle;
}

#pragma mark  Create/Destroy
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
  
  [super dealloc];
}

+(id<InAppPurchaseData>) createForAdColony
{
  NSString *secondary   = [NSString stringWithFormat:@"%d", 
                           [AdColony 
                            getVirtualCurrencyRewardAmountForZone:ADZONE1]];
  SponsoredOffer *offer = [[SponsoredOffer alloc] 
                           initWithPrimaryTitle:@"Watch Video Earn Gold"
                           andSecondaryTitle:secondary
                           andPrice:@"" 
                           andLocale:nil];
  [offer autorelease];
  
  return offer;
}


@end
