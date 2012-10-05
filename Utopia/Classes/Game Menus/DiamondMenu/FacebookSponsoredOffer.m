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

#define MAXED_INVITES_SEC  @"0 (Reached Weekly Max)"

@implementation FacebookSponsoredOffer
@synthesize primaryTitle;
@synthesize price;
@synthesize rewardPic;

#pragma mark InAppPurchaseData
-(NSString *) secondaryTitle
{
  if (![self purchaseAvailable]) {
    return MAXED_INVITES_SEC;
  }
  return secondaryTitle;  
}

-(UIImage *) rewardPic
{
  return [Globals imageNamed:@"stack.png"];
}

#pragma InAppPurchaseData
- (BOOL) purchaseAvailable
{
  return [_waitCounter canPerfomOperation];
}

-(void) makePurchaseWithViewController:(UIViewController *)controller
{
    [fbDelegate attemptSignOn];
    [fbDelegate requestFriendToJoin];
}

#pragma Create/Destroy
-(id) initWithPrimaryTitle:(NSString *)primary 
         andSecondaryTitle:(NSString *)secondary
                  andPrice:(NSString *)curPrice 
               andDelegate:(id<FacebookGlobalDelegate>)delegate 
            andWaitCounter:(id<OperationWaitCounter>)waitCounter
{
  self = [super init];
  if (self) {
    primaryTitle   = primary;
    secondaryTitle = secondary;
    price          = curPrice;
    fbDelegate     = delegate;
    _waitCounter   = waitCounter;
    
    [primaryTitle   retain];
    [secondaryTitle retain];
    [price          retain];
    [_waitCounter   retain];
  }
  return self;
}

-(void)dealloc
{
  [primaryTitle   release];
  [secondaryTitle release];
  [price          release];
  [_waitCounter   release];

  [super dealloc];
}

+(id<InAppPurchaseData>) create
{
  id<OperationWaitCounter> waitCounter = [OperationWaitCounter 
                                          createForKey:PREV_FACEBOOK_FRIEND_REQ 
                                          andTimeInterval:SECONDS_PER_WEEK];
  [waitCounter deserialize];
  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  id<FacebookGlobalDelegate> sessionDelegate = appDelegate.facebookDelegate;
  FacebookSponsoredOffer *offer = [[FacebookSponsoredOffer alloc] 
                                      initWithPrimaryTitle:@"Invite friends on Facebook"
                                   andSecondaryTitle:@"50"
                                      andPrice:@"" 
                                   andDelegate:sessionDelegate 
                                   andWaitCounter:waitCounter];
  [offer autorelease];
  
  return offer;
}
@end
