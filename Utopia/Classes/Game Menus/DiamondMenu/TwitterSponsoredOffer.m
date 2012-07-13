//
//  TwitterSponsoredOffer.m
//  Utopia
//
//  Created by Kevin Calloway on 5/31/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TwitterSponsoredOffer.h"
#import "Globals.h"
#import <Twitter/Twitter.h>

#define GAME_ICON_NAME          @"Icon-72.png"
#define MAXED_INVITES_SEC       @"0 (Reached Weekly Max)"
#define PREV_TWITTER_FRIEND_REQ @"PREV_TWITTER_FRIEND_REQ"
#define ITUNES_LINK             @"http://itunes.apple.com/gb/app/lost-nations/id517585291?mt=8"
#define TWEET_TEXT              @"I've been playing Lost Nations and it's pretty fun.  Check it out!"

@implementation TwitterSponsoredOffer

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
-(void)presentTwitterControllerWithParent:(UIViewController *)parentCont
{
  // Create the view controller
  TWTweetComposeViewController *twitter = [[[TWTweetComposeViewController alloc]
                                           init] autorelease];
  
  // Optional: set an image, url and initial text
  [twitter addImage:[UIImage imageNamed:GAME_ICON_NAME]];
  [twitter addURL:[NSURL URLWithString:ITUNES_LINK]];
  [twitter setInitialText:TWEET_TEXT];
  
  // Show the controller
  [parentCont presentModalViewController:twitter animated:YES];
  
  // Called when the tweet dialog has been closed
  twitter.completionHandler = ^(TWTweetComposeViewControllerResult result) 
  {
    if (result == TWTweetComposeViewControllerResultDone) {
      // We only want to increase the user's waitCounter if they recieved gold
      if ([self purchaseAvailable]) {
        [_waitCounter performedOperation];
        [_waitCounter serialize];
      }
      [InAppPurchaseData postAdTakeoverResignedNotificationForSender:self];
    }
    
    // Dismiss the controller
    [parentCont dismissModalViewControllerAnimated:YES];
  };
}

-(void) makePurchaseWithViewController:(UIViewController *)controller
{
  [self presentTwitterControllerWithParent:controller];  
}

- (BOOL) purchaseAvailable
{
  return [_waitCounter canPerfomOperation];
}

#pragma Create/Destroy
-(id) initWithPrimaryTitle:(NSString *)primary 
         andSecondaryTitle:(NSString *)secondary
                  andPrice:(NSString *)curPrice 
            andWaitCounter:(id<OperationWaitCounter>)waitCounter
{
  self = [super init];
  if (self) {
    primaryTitle   = primary;
    secondaryTitle = secondary;
    price          = curPrice;
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
                                          createForKey:PREV_TWITTER_FRIEND_REQ 
                                          andTimeInterval:SECONDS_PER_WEEK];
  [waitCounter deserialize];
  TwitterSponsoredOffer *offer = [[TwitterSponsoredOffer alloc] 
                                  initWithPrimaryTitle:@"Invite friends on Twitter"
                                  andSecondaryTitle:@"50"
                                  andPrice:@""                                    
                                  andWaitCounter:waitCounter];

  [offer autorelease];
  
  return offer;
}

@end
