//
//  AdColonyDelegate.m
//  Utopia
//
//  Created by Kevin Calloway on 5/23/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "AdColonyDelegate.h"
#import "OutgoingEventController.h"
#import "Globals.h"

#define ADCOLONY_APPID       @"app82f779c39f1c40c4a6dc82"

@implementation AdColonyDelegate

-(void) adColonyVirtualCurrencyAwardedByZone:(NSString *)zone
                                currencyName:(NSString *)name
                              currencyAmount:(int)amount 
{  
  //NOTE: The currency award transaction will be complete at this point
  //NOTE: This callback can be executed by AdColony at any time
  //NOTE: This is the ideal place for an alert about the successful reward
  EarnFreeDiamondsRequestProto_AdColonyRewardType type = 0;
  if ([zone isEqualToString:ADZONE1]) {
    type = EarnFreeDiamondsRequestProto_AdColonyRewardTypeDiamonds;
  } else if ([zone isEqualToString:ADZONE2]) {
    type = EarnFreeDiamondsRequestProto_AdColonyRewardTypeCoins;
  }
  [[OutgoingEventController sharedOutgoingEventController] adColonyRewardWithAmount:amount type:type];
}

-(void)adColonyVirtualCurrencyNotAwardedByZone:(NSString *)zone
                                  currencyName:(NSString *)name
                                currencyAmount:(int)amount 
                                        reason:(NSString *)reason
{
  //Update the user interface after calling virtualCurrencyAwardAvailable here
  [Globals popupMessage:[NSString stringWithFormat:@"Sorry, AdColony couldn't award you %@! Error:%@", 
                         name,
                         reason]];
}

- (NSString *) adColonyApplicationID
{
  return ADCOLONY_APPID;
}

- (NSDictionary *) adColonyAdZoneNumberAssociation
{
  return [NSDictionary dictionaryWithObjectsAndKeys:ADZONE1,
          [NSNumber numberWithInt:1],
          ADZONE2,
          [NSNumber numberWithInt:2],
          nil];
}

- (NSString *) adColonyApplicationVersion {
  return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+(id<AdColonyDelegate>) createAdColonyDelegate
{
  AdColonyDelegate *delegate = [[AdColonyDelegate alloc] init];
  [AdColony initAdColonyWithDelegate:delegate];
  [delegate autorelease];
  return delegate;
}

@end
