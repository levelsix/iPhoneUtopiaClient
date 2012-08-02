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
#import "OutgoingEventController.h"

#import "Globals.h"

@implementation AdColonySponsoredOffer
@dynamic primaryTitle;
@dynamic secondaryTitle;
@dynamic price;
@dynamic rewardPic;

- (UIImage *) rewardPic
{
  return [Globals imageNamed:@"stack.png"];
}

#pragma AdColony
- (void) pauseAudio
{
  [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
}

- (void) resumeAudio
{
  [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
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
                andV4VCPostPopup:NO];
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
