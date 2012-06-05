//
//  KiipDelegate.m
//  Utopia
//
//  Created by Kevin Calloway on 6/4/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "KiipDelegate.h"

@implementation KiipDelegate

-(void)receivedAchievement:(NSNotification *)notification
{
  NSString *achievement = [notification.userInfo 
                           objectForKey:[KiipDelegate 
                                         earnedAchievementNotification]];
  [kpManager unlockAchievement:achievement];
}

+(NSString *)earnedAchievementNotification
{
  return @"earnedAchievementNotification";
}

+(void) postAchievementNotificationAchievement:(NSString *)achievement 
                                     andSender:(id)sender
{
  NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
  [userInfo setObject:achievement forKey:[KiipDelegate earnedAchievementNotification]];
  NSNotification *notif = [NSNotification 
                           notificationWithName:[KiipDelegate earnedAchievementNotification]
                                object:sender 
                              userInfo:userInfo];
   
  [[NSNotificationCenter defaultCenter] postNotification:notif];
}

#pragma mark Create/Destroy
-(id)initWithKPManager:(KPManager *)manager
{
  self = [super init];
  
  if (self) {
    kpManager = manager;
    [kpManager retain];
  }
  return self;
}

-(void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  [kpManager release];
  
  [super dealloc];
}

+(id<KPManagerDelegate>) create
{
  // Start and initialize when application starts
  KPManager *manager = [[KPManager alloc] 
                        initWithKey:@"d6c7530ce4dc64ecbff535e521a241e3" 
                        secret:@"da8d864f948ae2b4e83c1b6e6a8151ed"];

  // Set the shared instance after initialization
  // to allow easier access of the object throughout the project.
  [KPManager setSharedManager:manager];

  KiipDelegate *delegate = [[KiipDelegate alloc] initWithKPManager:manager];
  manager.delegate = delegate;
  [manager release];
  [delegate autorelease];

  // Register for notifications
  [[NSNotificationCenter defaultCenter] addObserver:delegate
                                           selector:@selector(receivedAchievement:) 
                                               name:[KiipDelegate
                                                     earnedAchievementNotification]
                                             object:nil];
  
  return delegate;
}

@end
