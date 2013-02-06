//
//  ClanTowerScoresTab.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/24/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "ClanTowerScoresTab.h"
#import "GameState.h"
#import "Globals.h"
#import "ProfileViewController.h"
#import "OutgoingEventController.h"

@implementation ClanTowerTickerCell

- (void) updateForUserBattle:(ClanTowerUserBattle *)ctub {
  self.attackerLabel.text = [Globals fullNameWithName:ctub.attacker.name clanTag:ctub.attacker.clan.tag];
  self.attackerLabel.textColor = [Globals userTypeIsGood:ctub.attacker.userType] ? [Globals blueColor] : [Globals redColor];
  self.defenderLabel.text = [Globals fullNameWithName:ctub.defender.name clanTag:ctub.defender.clan.tag];
  self.defenderLabel.textColor = [Globals userTypeIsGood:ctub.defender.userType] ? [Globals blueColor] : [Globals redColor];
  
  self.endLabel.text = ctub.attackerWon ? @"and won." : @"and lost.";
  self.timeLabel.text = [Globals stringForTimeSinceNow:ctub.date shortened:YES];
  
  MinimumClanProto *mcp = ctub.attackerWon ? ctub.attacker.clan : ctub.defender.clan;
  self.pointsLabel.text = [NSString stringWithFormat:@"+%d %@", ctub.pointsGained, mcp.tag];
  
  CGSize s;
  CGRect r;
  
  s = [self.timeLabel.text sizeWithFont:self.timeLabel.font];
  r = self.timeLabel.frame;
  r.origin.x += r.size.width-s.width;
  r.size.width = s.width;
  self.timeLabel.frame = r;
  
  s = [self.attackerLabel.text sizeWithFont:self.attackerLabel.font];
  r = self.attackerLabel.frame;
  r.size.width = s.width;
  self.attackerLabel.frame = r;
  
  s = [self.middleLabel.text sizeWithFont:self.middleLabel.font];
  r = self.middleLabel.frame;
  r.origin.x = CGRectGetMaxX(self.attackerLabel.frame)+2;
  r.size.width = s.width;
  self.middleLabel.frame = r;
  
  s = [self.defenderLabel.text sizeWithFont:self.defenderLabel.font];
  r = self.defenderLabel.frame;
  r.origin.x = CGRectGetMaxX(self.middleLabel.frame)+2;
  r.size.width = s.width;
  self.defenderLabel.frame = r;
  
  s = [self.endLabel.text sizeWithFont:self.endLabel.font];
  r = self.endLabel.frame;
  r.origin.x = CGRectGetMaxX(self.defenderLabel.frame)+2;
  r.size.width = s.width;
  self.endLabel.frame = r;
  
  s = [self.pointsLabel.text sizeWithFont:self.pointsLabel.font];
  r = self.pointsLabel.frame;
  r.origin.x = CGRectGetMaxX(self.endLabel.frame)+2;
  r.size.width = s.width;
  self.pointsLabel.frame = r;
}

- (void) dealloc {
  self.attackerLabel = nil;
  self.defenderLabel = nil;
  self.middleLabel = nil;
  self.endLabel = nil;
  self.timeLabel = nil;
  self.pointsLabel = nil;
  [super dealloc];
}

@end

@implementation ClanTowerTickerDelegate

- (void) reloadUserBattles:(int)towerId {
  GameState *gs = [GameState sharedGameState];
  self.userBattles = [gs clanTowerUserBattlesForTowerId:towerId];
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.userBattles.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ClanTowerTickerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClanTowerTickerCell"];
  
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed:@"ClanTowerTickerCell" owner:self options:nil];
    cell = self.tickerCell;
  }
  
  ClanTowerUserBattle *mup = [self.userBattles objectAtIndex:indexPath.row];
  [cell updateForUserBattle:mup];
  
  return cell;
}

- (void) dealloc {
  self.userBattles = nil;
  [super dealloc];
}

@end

@implementation ClanTowerScoresCell

- (void) layoutSubviews {
  [super layoutSubviews];
  
  [self.gradientLayer removeFromSuperlayer];
  
  CAGradientLayer *gradient = [CAGradientLayer layer];
  gradient.frame = self.bounds;
  UIColor *topColor = [UIColor colorWithRed:35/255.f green:35/255.f blue:35/255.f alpha:0.5f];
  UIColor *botColor = [UIColor colorWithRed:12/255.f green:12/255.f blue:12/255.f alpha:0.5f];
  gradient.colors = [NSArray arrayWithObjects:(id)[topColor CGColor], (id)[botColor CGColor], nil];
  [self.contentView.layer insertSublayer:gradient atIndex:0];
  self.gradientLayer = gradient;
}

- (void) updateForUser:(MinimumUserProtoForClanTowerScores *)u rank:(int)rank {
  GameState *gs = [GameState sharedGameState];
  self.user = u;
  [self.nameLabel setTitle:u.minUserProtoWithLevel.minUserProto.name forState:UIControlStateNormal];
  [self.userIcon setImage:[Globals squareImageForUser:u.minUserProtoWithLevel.minUserProto.userType] forState:UIControlStateNormal];
  self.rankLabel.text = [Globals commafyNumber:rank];
  
  if (u.minUserProtoWithLevel.minUserProto.userId == gs.userId) {
    self.rankLabel.textColor = [Globals greenColor];
  } else {
    self.rankLabel.textColor = [Globals creamColor];
  }
  
  self.gainedLabel.text = [NSString stringWithFormat:@"+%@", [Globals commafyNumber:u.pointsGained]];
  self.lostLabel.text = [NSString stringWithFormat:@"-%@", [Globals commafyNumber:u.pointsLost]];
  
  CGSize s = [self.gainedLabel.text sizeWithFont:self.gainedLabel.font];
  CGRect r = self.gainedLabel.frame;
  r.size.width = s.width;
  self.gainedLabel.frame = r;
  
  s = [self.slashLabel.text sizeWithFont:self.slashLabel.font];
  r = self.slashLabel.frame;
  r.origin.x = CGRectGetMaxX(self.gainedLabel.frame)+2;
  r.size.width = s.width;
  self.slashLabel.frame = r;
  
  r = self.lostLabel.frame;
  r.origin.x = CGRectGetMaxX(self.slashLabel.frame)+2;
  self.lostLabel.frame = r;
}

- (IBAction)profileClicked:(id)sender {
  if (self.user) {
    [[ProfileViewController sharedProfileViewController] loadProfileForMinimumUser:self.user.minUserProtoWithLevel.minUserProto withState:kProfileState];
    [ProfileViewController displayView];
  }
}

- (void) dealloc {
  self.user = nil;
  self.userIcon = nil;
  self.nameLabel = nil;
  self.gainedLabel = nil;
  self.slashLabel = nil;
  self.lostLabel = nil;
  self.rankLabel = nil;
  [super dealloc];
}

@end

@implementation ClanTowerScoresTab

- (void) awakeFromNib {
  self.ownerTable.tableFooterView = [[[UIView alloc] init] autorelease];
  self.attackerTable.tableFooterView = [[[UIView alloc] init] autorelease];
  self.tickerTable.tableFooterView = [[[UIView alloc] init] autorelease];
  
  self.tickerDelegate = [[[ClanTowerTickerDelegate alloc] init] autorelease];
  self.tickerTable.delegate = self.tickerDelegate;
  self.tickerTable.dataSource = self.tickerDelegate;
}

- (NSArray *) sortedArray:(NSArray *)array {
  NSArray *newArray = [array sortedArrayUsingComparator:^NSComparisonResult(MinimumUserProtoForClanTowerScores *obj1, MinimumUserProtoForClanTowerScores *obj2) {
    int score1 = obj1.pointsGained-obj1.pointsLost;
    int score2 = obj2.pointsGained-obj2.pointsLost;
    
    if (score1 > score2) {
      return NSOrderedAscending;
    } else if (score1 < score2) {
      return NSOrderedDescending;
    } else if (obj1.pointsGained > obj2.pointsGained) {
      return NSOrderedAscending;
    } else if (obj1.pointsGained < obj2.pointsGained) {
      return NSOrderedDescending;
    }
    return NSOrderedSame;
  }];
  return newArray;
}

- (void) preloadForTowerId:(int)towerId {
  GameState *gs = [GameState sharedGameState];
  ClanTowerProto *t = [gs clanTowerWithId:towerId];
  
  self.ownerMembers = nil;
  self.attackerMembers = nil;
  
  self.towerId = towerId;
  
  self.ownerLabel.text = [Globals fullNameWithName:t.towerOwner.name clanTag:t.towerOwner.tag];
  self.ownerLabel.textColor = t.towerOwner.isGood ? [Globals blueColor] : [Globals redColor];
  self.attackerLabel.text = [Globals fullNameWithName:t.towerAttacker.name clanTag:t.towerAttacker.tag];
  self.attackerLabel.textColor = t.towerAttacker.isGood ? [Globals blueColor] : [Globals redColor];
  
  [self.ownerTable reloadData];
  [self.attackerTable reloadData];
  
  [self.tickerDelegate reloadUserBattles:towerId];
  [self.tickerTable reloadData];
  
  if (t.hasTowerAttacker && t.hasTowerOwner) {
    [[OutgoingEventController sharedOutgoingEventController] retrieveClanTowerScores:towerId];
  }
}

- (void) loadForOwnerMembers:(NSArray *)ownerMembers attackerMembers:(NSArray *)attackerMembers {
  self.ownerMembers = [self sortedArray:ownerMembers];
  self.attackerMembers = [self sortedArray:attackerMembers];
  
  [self.ownerTable reloadData];
  [self.attackerTable reloadData];
}

- (NSArray *) arrayForTableView:(UITableView *)tableView {
  if (tableView == self.ownerTable) {
    return self.ownerMembers;
  } else if (tableView == self.attackerTable) {
    return self.attackerMembers;
  }
  return nil;
}

- (UIActivityIndicatorView *) spinnerForTableView:(UITableView *)tableView {
  if (tableView == self.ownerTable) {
    return self.ownerSpinner;
  } else if (tableView == self.attackerTable) {
    return self.attackerSpinner;
  }
  return nil;
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSArray *a = [self arrayForTableView:tableView];
  UIActivityIndicatorView *spinner = [self spinnerForTableView:tableView];
  
  if (a.count > 0) {
    spinner.hidden = YES;
  } else {
    spinner.hidden = NO;
    [spinner startAnimating];
  }
  return a.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ClanTowerScoresCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClanTowerScoresCell"];
  
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed:@"ClanTowerScoresCell" owner:self options:nil];
    cell = self.scoresCell;
  }
  
  NSArray *arr = [self arrayForTableView:tableView];
  MinimumUserProtoForClanTowerScores *mup = [arr objectAtIndex:indexPath.row];
  [cell updateForUser:mup rank:indexPath.row+1];
  
  return cell;
}

- (void) addedUserBattle:(ClanTowerUserBattle *)ctub {
  if (ctub.towerId == _towerId) {
    [self.tickerDelegate reloadUserBattles:ctub.towerId];
    NSArray *ips = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]];
    [self.tickerTable insertRowsAtIndexPaths:ips withRowAnimation:UITableViewRowAnimationTop];
    
    // Increment the winner/loser's points
    GameState *gs = [GameState sharedGameState];
    ClanTowerProto *ctp = [gs clanTowerWithId:ctub.towerId];
    int ownerUserId = 0, attackerUserId = 0;
    BOOL ownerWon = YES;
    if (ctp.towerOwner.clanId == ctub.attacker.clan.clanId && ctp.towerAttacker.clanId == ctub.defender.clan.clanId) {
      ownerUserId = ctub.attacker.userId;
      attackerUserId = ctub.defender.userId;
      ownerWon = ctub.attackerWon;
    } else if (ctp.towerOwner.clanId == ctub.defender.clan.clanId && ctp.towerAttacker.clanId == ctub.attacker.clan.clanId) {
      ownerUserId = ctub.defender.userId;
      attackerUserId = ctub.attacker.userId;
      ownerWon = !ctub.attackerWon;
    }
    
    if (ownerUserId <= 0 || attackerUserId <= 0) {
      return;
    }
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.ownerMembers];
    for (MinimumUserProtoForClanTowerScores *mup in self.ownerMembers) {
      int userId = mup.minUserProtoWithLevel.minUserProto.userId;
      if (userId == ownerUserId) {
        [arr removeObject:mup];
        MinimumUserProtoForClanTowerScores_Builder *newMup = [MinimumUserProtoForClanTowerScores builderWithPrototype:mup];
        if (ownerWon) {
          newMup.pointsGained += ctub.pointsGained;
        } else {
          newMup.pointsLost += ctub.pointsGained;
        }
        [arr addObject:newMup];
      }
    }
    self.ownerMembers = [self sortedArray:arr];
    
    arr = [NSMutableArray arrayWithArray:self.attackerMembers];
    for (MinimumUserProtoForClanTowerScores *mup in self.attackerMembers) {
      int userId = mup.minUserProtoWithLevel.minUserProto.userId;
      if (userId == attackerUserId) {
        [arr removeObject:mup];
        MinimumUserProtoForClanTowerScores_Builder *newMup = [MinimumUserProtoForClanTowerScores builderWithPrototype:mup];
        if (ownerWon) {
          newMup.pointsLost += ctub.pointsGained;
        } else {
          newMup.pointsGained += ctub.pointsGained;
        }
        [arr addObject:newMup];
      }
    }
    self.attackerMembers = [self sortedArray:arr];
    
    // Reload visible rows
    NSArray *cells = [self.ownerTable visibleCells];
    for (ClanTowerScoresCell *cell in cells) {
      NSIndexPath *ip = [self.ownerTable indexPathForCell:cell];
      MinimumUserProtoForClanTowerScores *mup = [self.ownerMembers objectAtIndex:ip.row];
      [cell updateForUser:mup rank:ip.row+1];
    }
    
    cells = [self.attackerTable visibleCells];
    for (ClanTowerScoresCell *cell in cells) {
      NSIndexPath *ip = [self.attackerTable indexPathForCell:cell];
      MinimumUserProtoForClanTowerScores *mup = [self.attackerMembers objectAtIndex:ip.row];
      [cell updateForUser:mup rank:ip.row+1];
    }
  }
}

- (void) removedUserBattlesForTowerId:(int)towerId {
  if (towerId == _towerId) {
    [self.tickerDelegate reloadUserBattles:towerId];
    [self.tickerTable reloadData];
  }
}

- (IBAction)infoClicked:(id)sender {
  [Globals popupMessage:@"Green = Points won for clan. \nRed = Points lost for clan."];
}

- (void) dealloc {
  self.ownerMembers = nil;
  self.attackerMembers = nil;
  self.ownerTable = nil;
  self.attackerTable = nil;
  self.ownerSpinner = nil;
  self.attackerSpinner = nil;
  self.ownerLabel = nil;
  self.attackerLabel = nil;
  self.scoresCell = nil;
  self.tickerDelegate = nil;
  self.tickerTable = nil;
  [super dealloc];
}

@end
