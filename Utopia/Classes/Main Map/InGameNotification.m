//
//  InGameNotification.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/10/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "InGameNotification.h"
#import "ActivityFeedController.h"
#import "ProfileViewController.h"

@implementation InGameNotification

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  self.hidden = YES;
  if (self.notification.type != kNotificationWallPost) {
    [ActivityFeedController displayView];
  } else {
    [[ProfileViewController sharedProfileViewController] loadMyProfile];
    [[ProfileViewController sharedProfileViewController] setState:kProfileState];
    [ProfileViewController displayView];
  }
}

@end
