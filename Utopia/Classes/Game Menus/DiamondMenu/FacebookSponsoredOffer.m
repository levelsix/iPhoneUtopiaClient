//
//  FacebookSponsoredOffer.m
//  Utopia
//
//  Created by Kevin Calloway on 5/28/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "FacebookSponsoredOffer.h"
#import "Globals.h"
#import "AppDelegate.h"
#import "GameState.h"

#define MAXED_INVITES_SEC  @"0 (Reached Weekly Max)"

@implementation FacebookSponsoredOffer
@synthesize primaryTitle;
@synthesize secondaryTitle;
@synthesize isGold;
@synthesize price;
@synthesize salePrice;
@synthesize rewardPicName;
@synthesize discount;

-(NSString *) rewardPicName
{
  return @"facebookshare.png";
}

- (BOOL)isGold {
  return YES;
}

#pragma InAppPurchaseData
- (BOOL) purchaseAvailable
{
  return YES;
}

- (NSString *) secondaryTitle {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  return gs.hasReceivedfbReward ? @"0 (Already Claimed)" : [Globals commafyNumber:gl.fbConnectRewardDiamonds];
}

-(void) makePurchaseWithViewController:(UIViewController *)controller
{
    [fbDelegate attemptSignOn];
}

#pragma Create/Destroy
-(id) initWithPrimaryTitle:(NSString *)primary 
         andSecondaryTitle:(NSString *)secondary
                  andPrice:(NSString *)curPrice 
               andDelegate:(id<FacebookGlobalDelegate>)delegate 
{
  self = [super init];
  if (self) {
    primaryTitle   = primary;
    secondaryTitle = secondary;
    price          = curPrice;
    fbDelegate     = delegate;
    
    [primaryTitle   retain];
    [secondaryTitle retain];
    [price          retain];
  }
  return self;
}

-(void)dealloc
{
  [primaryTitle   release];
  [secondaryTitle release];
  [price          release];

  [super dealloc];
}

+(id<InAppPurchaseData>) create
{
  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  id<FacebookGlobalDelegate> sessionDelegate = appDelegate.facebookDelegate;
  FacebookSponsoredOffer *offer = [[FacebookSponsoredOffer alloc] 
                                      initWithPrimaryTitle:@"Connect to Facebook"
                                   andSecondaryTitle:@""
                                      andPrice:@"" 
                                   andDelegate:sessionDelegate];
  [offer autorelease];
  
  return offer;
}
@end
