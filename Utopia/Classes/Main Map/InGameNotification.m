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
#import "GameState.h"
#import "ClanMenuController.h"
#import "ChatMenuController.h"

@implementation InGameNotification

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  self.hidden = YES;
  if (self.notification.type == kNotificationGeneral) {
    // Check if a clan tower is mentioned inside
    GameState *gs = [GameState sharedGameState];
    for (ClanTowerProto *ctp in gs.clanTowers) {
      if ([self.notification.title rangeOfString:ctp.towerName].length > 0) {
        [ClanMenuController displayView];
        [[ClanMenuController sharedClanMenuController] viewTower:ctp.towerId];
        break;
      }
    }
  } else if (self.notification.type == kNotificationWallPost) {
    // This will remove the badge as well as displaying the profile
    [[[TopBar sharedTopBar] profilePic] button2Clicked:nil];
    [[ProfileViewController sharedProfileViewController] setState:kWallState];
  } else if (self.notification.type == kNotificationPrivateChat) {
    [ChatMenuController displayView];
    [[ChatMenuController sharedChatMenuController] loadPrivateChatsForUserId:self.notification.otherPlayer.userId animated:NO];
  } else {
    [ActivityFeedController displayView];
  }
}

@end
