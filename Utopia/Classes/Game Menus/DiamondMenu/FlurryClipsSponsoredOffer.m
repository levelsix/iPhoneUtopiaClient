//
//  FlurryClipsSponsoredOffer.m
//  Utopia
//
//  Created by Kevin Calloway on 5/25/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "FlurryClipsSponsoredOffer.h"
#import "Globals.h"
#import "FlurryClips.h"
#import "FlurryVideoOffer.h"
#import "SponsoredOffer.h"

#define FLURRY_REWARD 1
#define FLURRY_HOOK @"SPONSORED_OFFER_HOOK"

@implementation FlurryClipsSponsoredOffer
@synthesize primaryTitle;
@dynamic secondaryTitle;
@synthesize price;
@dynamic rewardPic;

-(UIImage *) rewardPic
{
  return [Globals imageNamed:@"stack.png"];
}

#pragma InAppPurchaseData
- (BOOL) purchaseAvailable
{
  return [FlurryClips videoAdIsAvailable:FLURRY_HOOK];
}

- (void) makePurchase 
{
  if ([self purchaseAvailable]) {
    [FlurryClips openVideoTakeover:FLURRY_HOOK
                       orientation:nil
                       rewardImage:self.rewardPic
                     rewardMessage:_rewardMsg 
                       userCookies:nil];
  }
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
                 andReward:(NSString *)reward
{
  self = [super init];
  if (self) {
    primaryTitle   = primary;
    secondaryTitle = secondary;
    price          = curPrice;
    _rewardMsg     = reward;
    
    [primaryTitle   retain];
    [secondaryTitle retain];
    [price          retain];
    [_rewardMsg     retain];
  }
  return self;
}

-(void)dealloc
{
  [primaryTitle   release];
  [secondaryTitle release];
  [price          release];
  [_rewardMsg     release];
  
  [super dealloc];
}

+(id<InAppPurchaseData>) create
{
  FlurryVideoOffer *video = [[FlurryVideoOffer alloc] init];
  [FlurryClips peekVideoOffer:FLURRY_HOOK withFlurryVideoOfferContainer:video];

  NSString *primary = [NSString stringWithFormat:@"Watch Trailers (%d remaining)",
                       [FlurryClips getVideoAdCount:FLURRY_HOOK]];
  NSString *secondary = [NSString stringWithFormat:@"%d", 
                         FLURRY_REWARD,
                         [FlurryClips getVideoAdCount:FLURRY_HOOK]];
  NSString *reward = [NSString stringWithFormat:@"%d Gold", FLURRY_REWARD];
  FlurryClipsSponsoredOffer *offer = [[FlurryClipsSponsoredOffer alloc] 
                           initWithPrimaryTitle:primary
                           andSecondaryTitle:secondary
                           andPrice:@"" 
                           andReward:reward];
  [offer autorelease];
  
  return offer;
}

@end
