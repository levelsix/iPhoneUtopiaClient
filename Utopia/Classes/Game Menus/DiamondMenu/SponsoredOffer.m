//
//  SponsoredOffer.m
//  Utopia
//
//  Created by Kevin Calloway on 5/21/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "SponsoredOffer.h"
#import "SimpleAudioEngine.h"
#import "TapjoyConnect.h"
#import "GameViewController.h"
#import "AdColonyDelegate.h"
#import "FlurryClips.h"

#define NO_CLIPS  @"No Clips Available"
//#define NO_OFFERS @"No Offers Available"

@implementation SponsoredOffer
@dynamic primaryTitle;
@dynamic secondaryTitle;
@dynamic price;
@synthesize priceLocale;
@synthesize isAdColony;
@synthesize isTapJoy;

#pragma TapJoy


#pragma AdZone
-(void) pauseAudio
{
  [[SimpleAudioEngine sharedEngine] setMute:YES];
}

-(void) resumeAudio
{
  [[SimpleAudioEngine sharedEngine] setMute:NO];
}

-(void) adColonyVirtualCurrencyAwardedByZone:(NSString *)zone
                               currencyName:(NSString *)name
                             currencyAmount:(int)amount 
{
#warning find out from ashwin how to message the server about gold increases
#warning find out from ashwin how to post user notifications

  //Update virtual currency balance by contacting the game server here
  //NOTE: The currency award transaction will be complete at this point
  //NOTE: This callback can be executed by AdColony at any time
  //NOTE: This is the ideal place for an alert about the successful reward
}

-(void)adColonyVirtualCurrencyNotAwardedByZone:(NSString *)zone
                                  currencyName:(NSString *)name
                                currencyAmount:(int)amount 
                                        reason:(NSString *)reason
{
  //Update the user interface after calling virtualCurrencyAwardAvailable here
#warning find out from ashwin how to post user notifications
}

- (void) adColonyTakeoverBeganForZone:(NSString *)zone {
//  NSLog(@"AdColony video ad launched for zone %@", zone);
  
  [self pauseAudio];
}

- (void) adColonyTakeoverEndedForZone:(NSString *)zone
                               withVC:(BOOL)withVirtualCurrencyAward {
//  NSLog(@"AdColony video ad finished for zone %@", zone);
  [self resumeAudio];
}

#pragma InAppPurchaseData
- (BOOL) purchaseAvailable
{
  return [AdColony virtualCurrencyAwardAvailableForZone:ADZONE1];
}

- (void) makePurchase 
{
  if (isAdColony) {
    if (![self purchaseAvailable]) {
    }
    else {
      [AdColony playVideoAdForZone:ADZONE1 
                      withDelegate:self
                  withV4VCPrePopup:YES
                  andV4VCPostPopup:YES];    
    }
  }
  else if (isTapJoy) {
    [TapjoyConnect showOffersWithViewController:[GameViewController
                                                 sharedGameViewController]];
  }
  else {
    [FlurryClips openVideoTakeover:@"VIDEO_SPLASH_HOOK" 
                       orientation:nil
                       rewardImage:nil
                     rewardMessage:@"you got it" 
                       userCookies:nil];
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
  if (![self purchaseAvailable] && isAdColony) {
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
  offer.isAdColony = YES;
  [offer autorelease];
  
  return offer;
}

+(id<InAppPurchaseData>) createForTapJoy
{
  SponsoredOffer *offer = [[SponsoredOffer alloc] 
                           initWithPrimaryTitle:@"TapJoy"
                           andSecondaryTitle:@""
                           andPrice:@"" 
                           andLocale:nil];
  offer.isTapJoy = YES;
  [offer autorelease];
  
  return offer;
}

+(id<InAppPurchaseData>) createForFlurry
{
  SponsoredOffer *offer = [[SponsoredOffer alloc] 
                           initWithPrimaryTitle:@"Flurry"
                           andSecondaryTitle:@""
                           andPrice:@"" 
                           andLocale:nil];
  [offer autorelease];
  
  return offer;
}

@end
