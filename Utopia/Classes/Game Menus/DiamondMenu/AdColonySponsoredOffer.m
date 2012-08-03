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
#import "GameState.h"

@implementation AdColonySponsoredOffer
@dynamic primaryTitle;
@dynamic secondaryTitle;
@dynamic price;
@dynamic rewardPic;
@dynamic isGold;

- (UIImage *) rewardPic
{
  return [Globals imageNamed:@"stack.png"];
}

- (BOOL) isGold {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  return ((gs.numAdColonyVideosWatched+1) % gl.adColonyVideosRequiredToRedeemGold) == 0;
}

- (NSString *) nextZone {
  return self.isGold ? ADZONE1 : ADZONE2;
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
  return [AdColony virtualCurrencyAwardAvailableForZone:[self nextZone]];
}

-(void) makePurchaseWithViewController:(UIViewController *)controller
{
  if ([self purchaseAvailable]) {
    [AdColony playVideoAdForZone:[self nextZone] 
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

- (NSString *) secondaryTitle
{
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSString *firstPart = [self purchaseAvailable] ? [NSString stringWithFormat:@"%d", [AdColony getVirtualCurrencyRewardAmountForZone:[self nextZone]]] : NO_CLIPS;
  NSString *secondPart = self.isGold ? @"" : [NSString stringWithFormat:@" (%d videos until gold)", gl.adColonyVideosRequiredToRedeemGold - (gs.numAdColonyVideosWatched % gl.adColonyVideosRequiredToRedeemGold) - 1];
  NSString *title = [NSString stringWithFormat:@"%@%@", firstPart, secondPart];
  
  return title;
}

-(id) initWithPrimaryTitle:(NSString *)primary
                  andPrice:(NSString *)curPrice
                 andLocale:(NSLocale *) locale
{
  self = [super init];
  if (self) {
    primaryTitle   = primary;
    price          = curPrice;
    priceLocale    = locale;
    
    [primaryTitle   retain];
    [price          retain];
    [priceLocale    retain];
  }
  return self;
}

-(void)dealloc
{
  [primaryTitle   release];
  [price          release];
  [priceLocale    release];  
  [super dealloc];
}

+(id<InAppPurchaseData>) create
{
  AdColonySponsoredOffer *offer = [[AdColonySponsoredOffer alloc] 
                                   initWithPrimaryTitle:@"Watch Video"
                                   andPrice:@"" 
                                   andLocale:nil];
  
  [offer autorelease];
  
  return offer;
}

@end
