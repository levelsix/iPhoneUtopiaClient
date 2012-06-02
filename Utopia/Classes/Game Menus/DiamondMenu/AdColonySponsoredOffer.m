//
//  AdColonySponsoredOffer.m
//  Utopia
//
//  Created by Kevin Calloway on 5/28/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "AdColonySponsoredOffer.h"
#import "AdColonyDelegate.h"
#import "SimpleAudioEngine.h"

#import "Globals.h"

@implementation AdColonySponsoredOffer
@dynamic primaryTitle;
@dynamic secondaryTitle;
@dynamic price;
@dynamic rewardPic;

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
    return [AdColony virtualCurrencyAwardAvailableForZone:ADZONE1];    
}

-(void) makePurchaseWithViewController:(UIViewController *)controller
{
  if ([self purchaseAvailable]) {
    [AdColony playVideoAdForZone:ADZONE1 
                    withDelegate:self
                withV4VCPrePopup:YES
                andV4VCPostPopup:YES];
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

+(id<InAppPurchaseData>) create
{
  NSString *secondary   = [NSString stringWithFormat:@"%d", 
                           [AdColony 
                            getVirtualCurrencyRewardAmountForZone:ADZONE1]];
  AdColonySponsoredOffer *offer = [[AdColonySponsoredOffer alloc] 
                           initWithPrimaryTitle:@"Watch Video"
                           andSecondaryTitle:secondary
                           andPrice:@"" 
                           andLocale:nil];

  [offer autorelease];
  
  return offer;
}

@end
