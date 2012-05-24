//
//  AdColonyDelegate.m
//  Utopia
//
//  Created by Kevin Calloway on 5/23/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "AdColonyDelegate.h"

#define ADCOLONY_APPID       @"app82f779c39f1c40c4a6dc82"

@implementation AdColonyDelegate

- (NSString *) adColonyApplicationID
{
  return ADCOLONY_APPID;
}

- (NSDictionary *) adColonyAdZoneNumberAssociation
{
  return [NSDictionary dictionaryWithObjectsAndKeys:ADZONE1,
          [NSNumber numberWithInt:1],
          nil];
}

+(id<AdColonyDelegate>) createAdColonyDelegate
{
  AdColonyDelegate *delegate = [[AdColonyDelegate alloc] init];
  [AdColony initAdColonyWithDelegate:delegate];
  [delegate autorelease];
  return delegate;
}

@end
