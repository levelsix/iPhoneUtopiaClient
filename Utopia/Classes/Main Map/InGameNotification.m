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
#import "TopBar.h"

@implementation InGameNotification

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  self.hidden = YES;
  if (self.notification.type == kNotificationGeneral) {
    // Do nothing
  } else if (self.notification.type != kNotificationWallPost) {
    [ActivityFeedController displayView];
  } else {
    // This will remove the badge as well as displaying the profile
    [[[TopBar sharedTopBar] profilePic] button3Clicked:nil];
  }
}

@end
