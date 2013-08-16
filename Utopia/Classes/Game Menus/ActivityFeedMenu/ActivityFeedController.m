//
//  ActivityFeedController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/17/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ActivityFeedController.h"
#import "LNSynthesizeSingleton.h"
#import "cocos2d.h"
#import "Globals.h"
#import "GameState.h"
#import "MarketplaceViewController.h"
#import "OutgoingEventController.h"
#import "BattleLayer.h"
#import "ProfileViewController.h"
#import "ForgeMenuController.h"
#import "GameLayer.h"

@implementation ActivityFeedCell

@synthesize notiView;

- (void) updateForNotification:(UserNotification *)n {
  [self.notiView updateForNotification:n];
}

- (void) dealloc {
  self.notiView = nil;
  [super dealloc];
}

@end

@implementation NotificationView

@synthesize titleLabel, subtitleLabel, userIcon, button, buttonLabel, timeLabel;
@synthesize notification;

- (void) updateForNotification:(UserNotification *)n {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  self.notification = n;
  
  NSString *name = [Globals fullNameWithName:notification.otherPlayer.name clanTag:notification.otherPlayer.clan.tag];
  
  [userIcon setBackgroundImage:[Globals squareImageForUser:notification.otherPlayer.userType] forState:UIControlStateNormal];
  
  timeLabel.text = [Globals stringForTimeSinceNow:n.time shortened:NO];
  
  if (notification.type == kNotificationBattle) {
    FullEquipProto *fep = nil;
    if (notification.stolenEquipId != 0) {
      fep = [gs equipWithId:notification.stolenEquipId];
    }
    
    NSString *equipStr = fep ? [NSString stringWithFormat:@" and a lvl %d %@", notification.stolenEquipLevel, fep.name] : @"";
    
    BOOL won = notification.battleResult != BattleResultAttackerWin ? YES : NO;
    if (won) {
      titleLabel.text = [NSString stringWithFormat:@"You beat %@.", name ];
      subtitleLabel.text = [NSString stringWithFormat:@"You won %d silver%@.", notification.coinsStolen, equipStr];
      titleLabel.textColor = [Globals greenColor];
      buttonLabel.text = @"Attack";
    } else {
      titleLabel.text = [NSString stringWithFormat:@"You lost to %@.", name ];
      subtitleLabel.text = [NSString stringWithFormat:@"You lost %d silver%@.", notification.coinsStolen, equipStr];
      titleLabel.textColor = [Globals redColor];
      buttonLabel.text = @"Revenge";
    }
    
    [button setBackgroundImage:[Globals imageNamed:@"revenge.png"] forState:UIControlStateNormal];
  } else if (notification.type == kNotificationMarketplace) {
    FullEquipProto *fep = [gs equipWithId:notification.marketPost.postedEquip.equipId];
    titleLabel.text = [NSString stringWithFormat:@"%@ bought your %@.", name, fep.name ];
    
    float percentReceived = n.sellerHadLicense ? 1.f : (1-gl.purchasePercentCut);
    NSString *coinStr = notification.marketPost.coinCost > 0 ? [NSString stringWithFormat:@"%d silver", (int)floorf(notification.marketPost.coinCost*percentReceived)] : [NSString stringWithFormat:@"%d gold", (int)floorf(notification.marketPost.diamondCost*percentReceived)];
    
    subtitleLabel.text = [NSString stringWithFormat:@"You have %@ waiting for you.", coinStr];
    titleLabel.textColor = [Globals goldColor];
    [button setImage:[Globals imageNamed:@"afcollect.png"] forState:UIControlStateNormal];
    buttonLabel.text = @"Collect";
  } else if (notification.type == kNotificationReferral) {
    titleLabel.text = [NSString stringWithFormat:@"%@ used your referral code.", name];
    subtitleLabel.text = [NSString stringWithFormat:@"You received %d gold.", [[Globals sharedGlobals] diamondRewardForReferrer]];
    
    titleLabel.textColor = [UIColor colorWithRed:100/256.f green:200/256.f blue:200/256.f alpha:1.f];
    [button setImage:nil forState:UIControlStateNormal];
    buttonLabel.text = @"";
  } else if (notification.type == kNotificationForge) {
    FullEquipProto *fep = [gs equipWithId:notification.forgeEquipId];
    titleLabel.text = [NSString stringWithFormat:@"The Blacksmith has forged your %@.", fep.name];
    subtitleLabel.text = @"Visit to check if it succeeded.";
    
    titleLabel.textColor = [Globals orangeColor];
    [button setBackgroundImage:[Globals imageNamed:@"checkstatus.png"] forState:UIControlStateNormal];
    [userIcon setBackgroundImage:[Globals imageNamed:@"blacksmithicon.png"] forState:UIControlStateNormal];
    
    buttonLabel.text = @"Visit";
  } else if (notification.type == kNotificationEnhance) {
    FullEquipProto *fep = [gs equipWithId:notification.forgeEquipId];
    titleLabel.text = [NSString stringWithFormat:@"The Blacksmith has enhanced your %@.", fep.name];
    subtitleLabel.text = @"Visit to collect it.";
    
    titleLabel.textColor = [Globals orangeColor];
    [button setBackgroundImage:[Globals imageNamed:@"checkstatus.png"] forState:UIControlStateNormal];
    [userIcon setBackgroundImage:[Globals imageNamed:@"blacksmithicon.png"] forState:UIControlStateNormal];
    
    buttonLabel.text = @"Visit";
  } else if (notification.type == kNotificationGoldmine) {
    if (notification.goldmineCollect) {
      titleLabel.text = [NSString stringWithFormat:@"The Gold Mine has produced %d gold.", gl.goldAmountFromGoldminePickup];
      subtitleLabel.text = @"Visit to pick up your gold!";
      titleLabel.textColor = [Globals goldColor];
    } else {
      titleLabel.text = @"The Gold Mine workers have gone on strike.";
      subtitleLabel.text = @"Visit to pay them off!";
      titleLabel.textColor = [Globals redColor];
    }
    
    [button setBackgroundImage:[Globals imageNamed:@"afcollect.png"] forState:UIControlStateNormal];
    [userIcon setBackgroundImage:[Globals imageNamed:@"goldmineicon.png"] forState:UIControlStateNormal];
    
    buttonLabel.text = @"Visit";
  } else if (notification.type == kNotificationWallPost) {
    // This will only be used in the drop down notifications
    titleLabel.text = [NSString stringWithFormat:@"%@ has posted on your wall.", name];
    subtitleLabel.text = notification.wallPost;
    
    titleLabel.textColor = [Globals blueColor];
  } else if (notification.type == kNotificationPrivateChat) {
    // This will only be used in the drop down notifications
    titleLabel.text = [NSString stringWithFormat:@"%@ has sent you a message.", name];
    subtitleLabel.text = notification.wallPost;
    
    titleLabel.textColor = [Globals blueColor];
  } else if (notification.type == kNotificationGeneral) {
    titleLabel.text = notification.title;
    subtitleLabel.text = notification.subtitle;
    
    titleLabel.textColor = notification.color;
  }
  
  NSArray *users = [[ActivityFeedController sharedActivityFeedController] users];
  if (users) {
    button.hidden = NO;
    buttonLabel.hidden = NO;
  } else {
    button.hidden = YES;
    buttonLabel.hidden = YES;
  }
  
  if (gs.marketplaceGoldEarnings == 0 && gs.marketplaceSilverEarnings == 0 && notification.type == kNotificationMarketplace) {
    button.hidden = YES;
    buttonLabel.hidden = YES;
  }
}

- (IBAction)buttonClicked:(id)sender {
  if (notification.type == kNotificationMarketplace) {
    [[ActivityFeedController sharedActivityFeedController] close];
    [MarketplaceViewController displayView];
    
    [Analytics clickedCollect];
  } else if (notification.type == kNotificationBattle) {
    NSArray *users = [[ActivityFeedController sharedActivityFeedController] users];
    
    FullUserProto *user = nil;
    for (FullUserProto *fup in users) {
      if (fup.userId == notification.otherPlayer.userId) {
        user = fup;
        break;
      }
    }
    
    if (user) {
      BOOL success = [[BattleLayer sharedBattleLayer] beginBattleAgainst:user];
      if (success) {
        [[ActivityFeedController sharedActivityFeedController] close];
      }
    }
    
    [Analytics clickedRevenge];
  } else if (notification.type == kNotificationForge) {
    [ForgeMenuController displayView];
    [[ActivityFeedController sharedActivityFeedController] close];
  } else if (notification.type == kNotificationEnhance) {
    [ForgeMenuController displayView];
    [[ForgeMenuController sharedForgeMenuController] displayEnhanceMenu];
    [[ActivityFeedController sharedActivityFeedController] close];
  } else if (notification.type == kNotificationGoldmine) {
    [[GameLayer sharedGameLayer] loadBazaarMap];
    [[BazaarMap sharedBazaarMap] moveToCritStruct:BazaarStructTypeGoldMine animated:YES];
    [[ActivityFeedController sharedActivityFeedController] close];
  }
}

- (IBAction)profilePicClicked:(id)sender {
  if (notification.type == kNotificationForge || notification.type == kNotificationGoldmine) {
    [self buttonClicked:nil];
  } else {
    NSArray *users = [[ActivityFeedController sharedActivityFeedController] users];
    
    FullUserProto *user = nil;
    for (FullUserProto *fup in users) {
      if (fup.userId == notification.otherPlayer.userId) {
        user = fup;
        break;
      }
    }
    
    if (user) {
      [[ProfileViewController sharedProfileViewController] loadProfileForPlayer:user buttonsEnabled:YES];
    } else {
      [[ProfileViewController sharedProfileViewController] loadProfileForMinimumUser:notification.otherPlayer withState:kProfileState];
    }
    [ProfileViewController displayView];
  }
}

- (void) dealloc {
  self.titleLabel = nil;
  self.subtitleLabel = nil;
  self.userIcon = nil;
  self.button = nil;
  self.buttonLabel = nil;
  self.notification = nil;
  [super dealloc];
}

@end

@implementation ActivityFeedController

@synthesize activityTableView, actCell, users;
@synthesize mainView, bgdView;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(ActivityFeedController);

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  self.users = [NSMutableArray array];
}

- (void) viewWillAppear:(BOOL)animated {
  NSArray *notifications = [[GameState sharedGameState] notifications];
  NSMutableArray *userIds = [NSMutableArray arrayWithCapacity:notifications.count];
  
  for (UserNotification *un in notifications) {
    [userIds addObject:[NSNumber numberWithInt:un.otherPlayer.userId]];
  }
  
  [self.users removeAllObjects];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  [[OutgoingEventController sharedOutgoingEventController] retrieveUsersForUserIds:userIds];
  
  [self.activityTableView reloadData];
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  GameState *gs = [GameState sharedGameState];
  self.noNotificationLabel.hidden = gs.notifications.count > 0;
  return gs.notifications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"ActivityFeed";
  
  ActivityFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"ActivityFeedCell" owner:self options:nil];
    cell = self.actCell;
  }
  
  UserNotification *un = [[[GameState sharedGameState] notifications] objectAtIndex:indexPath.row];
  [cell updateForNotification:un];
  
  [[cell.contentView viewWithTag:1001] removeFromSuperview];
  if (!un.hasBeenViewed) {
    UIView *view = [[UIView alloc] initWithFrame:cell.bounds];
    view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.08f];
    view.tag = 1001;
    [cell.contentView insertSubview:view atIndex:0];
    [view release];
  }
  
  if (un.type == kNotificationBattle) {
    FullUserProto *user = nil;
    for (FullUserProto *fup in users) {
      if (fup.userId == un.otherPlayer.userId) {
        user = fup;
        break;
      }
    }
    if (user) {
      cell.notiView.button.hidden = NO;
      cell.notiView.buttonLabel.hidden = NO;
    } else {
      cell.notiView.button.hidden = YES;
      cell.notiView.buttonLabel.hidden = YES;
    }
  }
  
  return cell;
}

- (IBAction)closeClicked:(id)sender {
  [self close];
}

- (void) close {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [ActivityFeedController removeView];
  }];
  
  // Set all the notifications as viewed.
  for (UserNotification *un in [GameState sharedGameState].notifications) {
    un.hasBeenViewed = YES;
  }
}

- (void) receivedUsers:(RetrieveUsersForUserIdsResponseProto *)proto {
  GameState *gs = [GameState sharedGameState];
  NSArray *notifications = gs.notifications;
  for (FullUserProto *fup in proto.requestedUsersList) {
    for (UserNotification *un in notifications) {
      if (un.otherPlayer.userId == fup.userId) {
        [self.users addObject:fup];
      }
    }
  }
  [self.activityTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  if (self.isViewLoaded && !self.view.superview) {
    self.view = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.activityTableView = nil;
    self.actCell = nil;
    self.users = nil;
    self.mainView = nil;
    self.noNotificationLabel = nil;
    self.bgdView = nil;
  }
}

@end
