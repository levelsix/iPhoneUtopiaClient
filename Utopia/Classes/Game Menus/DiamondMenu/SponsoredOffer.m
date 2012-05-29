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

#define FLURRY_HOOK @"SPONSORED_OFFER_HOOK"

@implementation SponsoredOffer
@dynamic primaryTitle;
@dynamic secondaryTitle;
@dynamic price;
@dynamic rewardPic;

@synthesize isAdColony;
@synthesize isTapJoy;

-(UIImage *) rewardPic
{
  return [Globals imageNamed:@"stack.png"];
}

#pragma AdColony
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
  //NOTE: The currency award transaction will be complete at this point
  //NOTE: This callback can be executed by AdColony at any time
  //NOTE: This is the ideal place for an alert about the successful reward
#warning find out from ashwin how to message the server about gold increases
  [Globals popupMessage:[NSString stringWithFormat:@"You just received %d %@", 
                         amount,
                         name]];
}

-(void)adColonyVirtualCurrencyNotAwardedByZone:(NSString *)zone
                                  currencyName:(NSString *)name
                                currencyAmount:(int)amount 
                                        reason:(NSString *)reason
{
  //Update the user interface after calling virtualCurrencyAwardAvailable here
  [Globals popupMessage:[NSString stringWithFormat:@"Sorry, we couldn't award you %@! Error:%@", 
                         name,
                         reason]];
}

- (void) adColonyTakeoverBeganForZone:(NSString *)zone 
{
  [self pauseAudio];
}

- (void) adColonyTakeoverEndedForZone:(NSString *)zone
                               withVC:(BOOL)withVirtualCurrencyAward 
{
  [self resumeAudio];
  [InAppPurchaseData postAdTakeoverResignedNotificationForSender:self];
}
//Is called when the video zone is ready to serve ads
//-(void)adColonyVideoAdsReadyInZone:(NSString *)zone;

#pragma InAppPurchaseData
- (BOOL) purchaseAvailable
{
  if (isAdColony) {
    return [AdColony virtualCurrencyAwardAvailableForZone:ADZONE1];    
  }
  else 
    return YES;
}

- (void) makePurchase 
{
  if (isAdColony && [self purchaseAvailable]) {
    [AdColony playVideoAdForZone:ADZONE1 
                      withDelegate:self
                  withV4VCPrePopup:YES
                  andV4VCPostPopup:YES];
  }
  else if (isTapJoy && [self purchaseAvailable]) {
    [TapjoyConnect showOffersWithViewController:[GameViewController
                                                 sharedGameViewController]];
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
                           initWithPrimaryTitle:@"Watch Video"
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
                           initWithPrimaryTitle:@"Complete Free offers"
                           andSecondaryTitle:@"??"
                           andPrice:@"" 
                           andLocale:nil];
  offer.isTapJoy = YES;
  [offer autorelease];
  
  return offer;
}

@end
