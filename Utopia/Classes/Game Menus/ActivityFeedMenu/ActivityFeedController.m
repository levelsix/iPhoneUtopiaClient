//
//  ActivityFeedController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/17/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ActivityFeedController.h"
#import "SynthesizeSingleton.h"
#import "cocos2d.h"
#import "Globals.h"
#import "GameState.h"
#import "MarketplaceViewController.h"
#import "OutgoingEventController.h"
#import "BattleLayer.h"

@implementation ActivityFeedCell

@synthesize titleLabel, subtitleLabel, userIcon, button, buttonLabel;
@synthesize notification;

- (void) updateForNotification:(UserNotification *)n {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  self.notification = n;
  
  NSString *name = notification.otherPlayer.name;
  userIcon.image = [Globals squareImageForUser:notification.otherPlayer.userType];
  
  if (notification.type == kNotificationBattle) {
    FullEquipProto *fep = nil;
    if (notification.stolenEquipId != 0) {
      fep = [gs equipWithId:notification.stolenEquipId];
    }
    NSString *equipStr = fep ? [NSString stringWithFormat:@" and a %@", fep.name] : @"";
    
    BOOL won = notification.battleResult != BattleResultAttackerWin ? YES : NO;
    if (won) {
      titleLabel.text = [NSString stringWithFormat:@"You beat %@.", name ];
      subtitleLabel.text = [NSString stringWithFormat:@"You won %d silver%@.", notification.coinsStolen, equipStr];
      titleLabel.textColor = [UIColor colorWithRed:182/256.f green:191/256.f blue:46/256.f alpha:1.f];
    } else {
      titleLabel.text = [NSString stringWithFormat:@"You lost to %@.", name ];
      subtitleLabel.text = [NSString stringWithFormat:@"You lost %d silver%@.", notification.coinsStolen, equipStr];
      titleLabel.textColor = [UIColor colorWithRed:205/256.f green:57/256.f blue:57/256.f alpha:1.f];
    }
    
    [button setImage:[Globals imageNamed:@"revenge.png"] forState:UIControlStateNormal];
    buttonLabel.text = @"Revenge";
  } else if (notification.type == kNotificationMarketplace) {
    FullEquipProto *fep = [gs equipWithId:notification.marketPost.postedEquip.equipId];
    titleLabel.text = [NSString stringWithFormat:@"%@ bought your %@.", name, fep.name ];
    
    NSString *coinStr = notification.marketPost.coinCost > 0 ? [NSString stringWithFormat:@"%d silver", (int)floorf(notification.marketPost.coinCost*(1-gl.purchasePercentCut))] : [NSString stringWithFormat:@"%d gold", (int)ceilf(notification.marketPost.diamondCost*(1-gl.purchasePercentCut))];
        
    subtitleLabel.text = [NSString stringWithFormat:@"You have %@ waiting for you.", coinStr];
    titleLabel.textColor = [UIColor colorWithRed:255/256.f green:200/256.f blue:0/256.f alpha:1.f];
    [button setImage:[Globals imageNamed:@"afcollect.png"] forState:UIControlStateNormal];
    buttonLabel.text = @"Collect";
  } else if (notification.type == kNotificationReferral) {
    titleLabel.text = [NSString stringWithFormat:@"%@ used your referral code.", name];
    subtitleLabel.text = [NSString stringWithFormat:@"You received %d gold.", [[Globals sharedGlobals] diamondRewardForReferrer]];
    
    titleLabel.textColor = [UIColor colorWithRed:100/256.f green:200/256.f blue:200/256.f alpha:1.f];
    [button setImage:nil forState:UIControlStateNormal];
    buttonLabel.text = @"";
  }
}

- (IBAction)buttonClicked:(id)sender {
  if (notification.type == kNotificationMarketplace) {
    [ActivityFeedController removeView];
    [MarketplaceViewController displayView];
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
      [[BattleLayer sharedBattleLayer] beginBattleAgainst:user];
      [ActivityFeedController removeView];
    }
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

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(ActivityFeedController);

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated {
  NSArray *notifications = [[GameState sharedGameState] notifications];
  NSMutableArray *userIds = [NSMutableArray arrayWithCapacity:notifications.count];
  
  for (UserNotification *un in notifications) {
    if (un.type == kNotificationBattle) {
      [userIds addObject:[NSNumber numberWithInt:un.otherPlayer.userId]];
    }
  }
  
  self.users = nil;
  
  [[OutgoingEventController sharedOutgoingEventController] retrieveUsersForUserIds:userIds];
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[[GameState sharedGameState] notifications] count];
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
  
  return cell;
}

- (IBAction)closeClicked:(id)sender {
  [ActivityFeedController removeView];
}

- (void) receivedUsers:(RetrieveUsersForUserIdsResponseProto *)proto {
  self.users = proto.requestedUsersList;
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  self.activityTableView = nil;
  self.actCell = nil;
  self.users = nil;
}

@end
