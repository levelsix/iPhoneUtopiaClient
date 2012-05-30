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

//1 week
#define MIN_REQ_WAIT -1*60*60*24*7 

@implementation FacebookSponsoredOffer
@synthesize primaryTitle;
@synthesize price;
@synthesize rewardPic;

#pragma mark InAppPurchaseData
-(NSString *) secondaryTitle
{
  if ([self purchaseAvailable]) {
    return secondaryTitle;
  }
  
  return MAXED_INVITES_SEC;
}

-(UIImage *) rewardPic
{
  return [Globals imageNamed:@"stack.png"];
}

#pragma InAppPurchaseData
- (BOOL) purchaseAvailable
{
  NSTimeInterval timeInterval = [_prevTimeUsed timeIntervalSinceNow];
  if (timeInterval < MIN_REQ_WAIT) {
    return YES;
  }

  return NO;
}

- (void) makePurchase 
{
    [fbDelegate attemptSignOn];
    [fbDelegate requestFriendToJoin];
}

#pragma Create/Destroy
-(id) initWithPrimaryTitle:(NSString *)primary 
         andSecondaryTitle:(NSString *)secondary
                  andPrice:(NSString *)curPrice 
               andDelegate:(id<FacebookGlobalDelegate>)delegate 
               andPrevDate:(NSDate *)prevReqDate
{
  self = [super init];
  if (self) {
    primaryTitle   = primary;
    secondaryTitle = secondary;
    price          = curPrice;
    fbDelegate     = delegate;
    _prevTimeUsed   = prevReqDate;
    
    [primaryTitle   retain];
    [secondaryTitle retain];
    [price          retain];
    [_prevTimeUsed   retain];
  }
  return self;
}

-(void)dealloc
{
  [primaryTitle   release];
  [secondaryTitle release];
  [price          release];
  [_prevTimeUsed   release];

  [super dealloc];
}

+(id<InAppPurchaseData>) create
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSDate *prevReqDate = [defaults objectForKey:PREV_FACEBOOK_FRIEND_REQ];
  
  if (!prevReqDate) {
    // Guarantee that the user will be able to perform
    // this action the first time.
    prevReqDate = [NSDate distantPast];
  }
  
  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  id<FacebookGlobalDelegate> sessionDelegate = appDelegate.facebookDelegate;
  FacebookSponsoredOffer *offer = [[FacebookSponsoredOffer alloc] 
                                      initWithPrimaryTitle:@"Invite friends on Facebook"
                                   andSecondaryTitle:@"50"
                                      andPrice:@"" 
                                   andDelegate:sessionDelegate 
                                   andPrevDate:prevReqDate];
  [offer autorelease];
  
  return offer;
}
@end
