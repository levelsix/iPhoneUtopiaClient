//
//  ClanMenus.m
//  Utopia
//
//  Created by Ashwin Kamath on 9/11/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ClanMenus.h"
#import "OutgoingEventController.h"
#import "Globals.h"
#import "GameState.h"
#import "RefillMenuController.h"
#import "ClanMenuController.h"
#import "ProfileViewController.h"
#import "GenericPopupController.h"
#import "BattleLayer.h"

#define REFRESH_ROWS 20

@implementation ClanCreateView

@synthesize nameField, tagField;
@synthesize maxTagLengthLabel, createClanGoldLabel;
@synthesize headerLabel, subheaderLabel, buttonLabel;
@synthesize clanCreationView, notificationView;

- (void) awakeFromNib {
  Globals *gl = [Globals sharedGlobals];
  self.maxTagLengthLabel.text = [NSString stringWithFormat:@"Max %d characters.", gl.maxCharLengthForClanTag];
  self.createClanGoldLabel.text = [Globals commafyNumber:gl.diamondPriceToCreateClan];
  
  notificationView.frame = clanCreationView.frame;
  [self addSubview:notificationView];
}

- (void) loadClanCreationView {
  clanCreationView.hidden = NO;
  notificationView.hidden = YES;
  nameField.text = nil;
  tagField.text = nil;
}

- (void) loadAfterClanCreationView:(NSString *)clanName {
  clanCreationView.hidden = YES;
  notificationView.hidden = NO;
  headerLabel.text = [NSString stringWithFormat:@"You have created the clan %@.", clanName];
  subheaderLabel.text = @"Better start recruiting!";
  buttonLabel.text = @"GO TO MY CLAN";
  _goToMyClan = YES;
}

- (void) loadAlreadyInClanView {
  clanCreationView.hidden = YES;
  notificationView.hidden = NO;
  headerLabel.text = @"You are already in a clan.";
  subheaderLabel.text = @"You must leave your current clan before starting a clan.";
  buttonLabel.text = @"GO TO MY CLAN";
  _goToMyClan = YES;
}

- (void) loadNotInClanView {
  clanCreationView.hidden = YES;
  notificationView.hidden = NO;
  headerLabel.text = @"You are not in a clan yet.";
  subheaderLabel.text = @"You can join a clan by browsing the clan list.";
  buttonLabel.text = @"GO TO CLAN LIST";
  _goToMyClan = NO;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
  Globals *gl = [Globals sharedGlobals];
  int maxLen = textField == nameField ? gl.maxCharLengthForClanName : gl.maxCharLengthForClanTag;
  
  if (str.length > maxLen) {
    return NO;
  }
  return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

- (IBAction)createClanClicked:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  NSString *name = nameField.text;
  NSString *tag = tagField.text;
  
  if (name.length <= 0) {
    [Globals popupMessage:@"You must enter a clan name."];
  } else if (tag.length <= 0) {
    [Globals popupMessage:@"You must enter a clan tag."];
  } else if (name.length > gl.maxCharLengthForClanName || tag.length > gl.maxCharLengthForClanTag) {
    [Globals popupMessage:@"Name or tag is too long."];
  } else if (gs.gold < gl.diamondPriceToCreateClan) {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:gl.diamondPriceToCreateClan];
  } else {
    int msgTag = [[OutgoingEventController sharedOutgoingEventController] createClan:name tag:tag];
    [[ClanMenuController sharedClanMenuController] beginLoading:msgTag];
  }
}

- (IBAction)goToMyClanClicked:(id)sender {
  if (_goToMyClan) {
    [[ClanMenuController sharedClanMenuController] setState:kMyClan];
  } else {
    [[ClanMenuController sharedClanMenuController] setState:kBrowseClans];
  }
}

- (void) dealloc {
  self.nameField = nil;
  self.tagField = nil;
  self.maxTagLengthLabel = nil;
  self.createClanGoldLabel = nil;
  self.headerLabel = nil;
  self.subheaderLabel = nil;
  self.buttonLabel = nil;
  self.clanCreationView = nil;
  self.notificationView = nil;
  [super dealloc];
}

@end

@implementation ClanMemberCell

@synthesize user;
@synthesize typeLabel, nameButton, userIcon;
@synthesize battleRecordLabel;
@synthesize editMemberView, respondInviteView;

- (void) awakeFromNib {
  CGRect r = editMemberView.frame;
  r.origin.x = CGRectGetMaxX(battleRecordLabel.frame)-r.size.width;
  r.origin.y = CGRectGetMidY(battleRecordLabel.frame)-r.size.height/2;
  editMemberView.frame = r;
  
  r = respondInviteView.frame;
  r.origin.x = CGRectGetMaxX(battleRecordLabel.frame)-r.size.width;
  r.origin.y = CGRectGetMidY(battleRecordLabel.frame)-r.size.height/2;
  respondInviteView.frame = r;
  
  r = _attackView.frame;
  r.origin.x = CGRectGetMaxX(battleRecordLabel.frame)-r.size.width;
  r.origin.y = CGRectGetMidY(battleRecordLabel.frame)-r.size.height/2;
  _attackView.frame = r;
  
  [battleRecordLabel.superview addSubview:editMemberView];
  [battleRecordLabel.superview addSubview:respondInviteView];
  [battleRecordLabel.superview addSubview:_attackView];
}

- (void) loadForUser:(MinimumUserProtoForClans *)mup {
  MinimumUserProtoWithLevel *mupl = mup.minUserProto.minUserProtoWithLevel;
  self.user = mup;
  
  [nameButton setTitle:mupl.minUserProto.name forState:UIControlStateNormal];
  self.typeLabel.text = [NSString stringWithFormat:@"Level %d %@ %@", mupl.level, [Globals factionForUserType:mupl.minUserProto.userType], [Globals classForUserType:mupl.minUserProto.userType]];
  [userIcon setImage:[Globals squareImageForUser:mupl.minUserProto.userType] forState:UIControlStateNormal];
  
  self.battleRecordLabel.text = [NSString stringWithFormat:@"W: %@ - L: %@ - F: %@", [Globals commafyNumber:mup.minUserProto.battlesWon], [Globals commafyNumber:mup.minUserProto.battlesLost], [Globals commafyNumber:mup.minUserProto.battlesFled]];
  
  self.gainedLabel.text = nil;
  self.lostLabel.text = nil;
  self.slashLabel.text = nil;
}

- (void) editMemberConfiguration {
  self.editMemberView.hidden = NO;
  self.respondInviteView.hidden = YES;
  self.battleRecordLabel.hidden = YES;
  self.attackView.hidden = YES;
}

- (void) respondInviteConfiguration {
  self.editMemberView.hidden = YES;
  self.respondInviteView.hidden = NO;
  self.battleRecordLabel.hidden = YES;
  self.attackView.hidden = YES;
}

- (void) battleRecordConfiguration {
  self.editMemberView.hidden = YES;
  self.respondInviteView.hidden = YES;
  self.battleRecordLabel.hidden = NO;
  self.attackView.hidden = YES;
}

- (void) attackConfiguration {
  self.editMemberView.hidden = YES;
  self.respondInviteView.hidden = YES;
  self.battleRecordLabel.hidden = YES;
  self.attackView.hidden = NO;
  self.attackButton.hidden = YES;
  self.attackSpinner.hidden = NO;
  [self.attackSpinner startAnimating];
}

- (IBAction)makeLeaderClicked:(id)sender {
  int tag = [[OutgoingEventController sharedOutgoingEventController] transferClanOwnership:user.minUserProto.minUserProtoWithLevel.minUserProto.userId];
  [[ClanMenuController sharedClanMenuController] beginLoading:tag];
}

- (IBAction)bootClicked:(id)sender {
  int tag = [[OutgoingEventController sharedOutgoingEventController] bootPlayerFromClan:user.minUserProto.minUserProtoWithLevel.minUserProto.userId];
  [[ClanMenuController sharedClanMenuController] beginLoading:tag];
}

- (IBAction)acceptClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  FullClanProtoWithClanSize *c = [[ClanMenuController sharedClanMenuController] myClan];
  int maxClanSize = [gs clanTierForLevel:c.clan.currentTierLevel].maxSize;
  
  if (c.clanSize < maxClanSize) {
    int tag = [[OutgoingEventController sharedOutgoingEventController] approveOrRejectRequestToJoinClan:user.minUserProto.minUserProtoWithLevel.minUserProto.userId accept:YES];
    [[ClanMenuController sharedClanMenuController] beginLoading:tag];
  } else {
    [Globals popupMessage:@"Your clan is already at the max size! Go to the Clan Info Page to Upgrade."];
  }
}

- (IBAction)rejectClicked:(id)sender {
  int tag = [[OutgoingEventController sharedOutgoingEventController] approveOrRejectRequestToJoinClan:user.minUserProto.minUserProtoWithLevel.minUserProto.userId accept:NO];
  [[ClanMenuController sharedClanMenuController] beginLoading:tag];
}

- (IBAction)profileClicked:(id)sender {
  MinimumUserProto *mup = self.user.minUserProto.minUserProtoWithLevel.minUserProto;
  if (mup) {
    [[ProfileViewController sharedProfileViewController] loadProfileForMinimumUser:mup withState:kProfileState];
    [ProfileViewController displayView];
  }
}

- (void) dealloc {
  self.userIcon = nil;
  self.user = nil;
  self.typeLabel = nil;
  self.nameButton = nil;
  self.userIcon = nil;
  self.battleRecordLabel = nil;
  self.editMemberView = nil;
  self.respondInviteView = nil;
  self.attackButton = nil;
  self.attackSpinner = nil;
  self.attackView = nil;
  self.gainedLabel = nil;
  self.slashLabel = nil;
  self.lostLabel = nil;
  [super dealloc];
}

@end

@implementation ClanMembersView

@synthesize clanId;
@synthesize membersTable, spinner;
@synthesize members, requesters, leader;
@synthesize memberCell;
@synthesize leaderHeader, membersHeader, requestersHeader;
@synthesize editModeOn;

- (void) awakeFromNib {
  self.membersTable.tableFooterView = [[[UIView alloc] init] autorelease];
}

- (void) wakeup {
  self.userDict = [NSMutableDictionary dictionary];
  self.pointsGainedDict = [NSMutableDictionary dictionary];
  self.pointsLostDict = [NSMutableDictionary dictionary];
}

- (void) cleanup {
  [super cleanup];
  self.requesters = nil;
  self.members = nil;
  self.userDict = nil;
  self.pointsGainedDict = nil;
  self.pointsLostDict = nil;
}

- (void) preloadMembersForClan:(int)ci leader:(int)li orderByClosest:(BOOL)orderByClosest {
  if (ci > 0) {
    [[OutgoingEventController sharedOutgoingEventController] retrieveClanInfo:nil clanId:ci grabType:RetrieveClanInfoRequestProto_ClanInfoGrabTypeMembers isForBrowsingList:NO beforeClanId:0];
  }
  self.clanId = ci;
  leaderId = li;
  self.leader = nil;
  self.requesters = nil;
  self.members = nil;
  myClan = NO;
  editModeOn = NO;
  [membersTable reloadData];
  
  _orderByClosest = orderByClosest;
}

- (void) turnOnEditing {
  editModeOn = YES;
  [membersTable reloadData];
}

- (void) turnOffEditing {
  editModeOn = NO;
  [membersTable reloadData];
}

- (void) loadForMembers:(NSArray *)mem isMyClan:(BOOL)isMyClan {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *m = [NSMutableArray array];
  NSMutableArray *r = [NSMutableArray array];
  
  if (isMyClan) {
    leaderId = gs.clan.ownerId;
  }
  
  for (MinimumUserProtoForClans *mup in mem) {
    if (mup.minUserProto.minUserProtoWithLevel.minUserProto.userId == leaderId) {
      self.leader = mup;
    } else if (mup.clanStatus == UserClanStatusMember) {
      [m addObject:mup];
    } else {
      [r addObject:mup];
    }
  }
  
  if (_orderByClosest) {
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    [m sortUsingComparator:^NSComparisonResult(MinimumUserProtoForClans *obj1, MinimumUserProtoForClans *obj2) {
      int lvl1 = obj1.minUserProto.minUserProtoWithLevel.level;
      int lvl2 = obj2.minUserProto.minUserProtoWithLevel.level;
      int range1 = ABS(gs.level-lvl1);
      int range2 = ABS(gs.level-lvl2);
      bool inRange1 = range1 <= gl.maxLevelDiffForBattle;
      bool inRange2 = range2 <= gl.maxLevelDiffForBattle;
      if (inRange1 && inRange2) {
        if (range1 < range2) {
          return NSOrderedAscending;
        } else if (range1 > range2) {
          return NSOrderedDescending;
        } else {
          return NSOrderedSame;
        }
      } else if (inRange1) {
        return NSOrderedAscending;
      } else if (inRange2) {
        return NSOrderedDescending;
      } else {
        if (lvl1 < lvl2) {
          return NSOrderedDescending;
        } else if (lvl1 > lvl2) {
          return NSOrderedAscending;
        } else {
          return NSOrderedSame;
        }
      }
    }];
  } else {
    [m sortUsingComparator:^NSComparisonResult(MinimumUserProtoForClans *obj1, MinimumUserProtoForClans *obj2) {
      int score1 = obj1.minUserProto.battlesWon-obj1.minUserProto.battlesLost-obj1.minUserProto.battlesFled;
      int score2 = obj2.minUserProto.battlesWon-obj2.minUserProto.battlesLost-obj2.minUserProto.battlesFled;
      if (score1 > score2) {
        return  NSOrderedAscending;
      } else if (score1 < score2) {
        return NSOrderedDescending;
      }
      return NSOrderedSame;
    }];
  }
  
  self.members = m;
  self.requesters = r;
  
  if (!isMyClan || leaderId != gs.userId) {
    editModeOn = NO;
  }
  
  leaderId = 0;
  myClan = isMyClan;
  
  [self.membersTable reloadData];
}

- (void) receivedUsers:(RetrieveUsersForUserIdsResponseProto *)proto {
  BOOL changed = NO;
  for (int i = 0; i < proto.requestedUsersList.count; i++) {
    FullUserProto *fup = [proto.requestedUsersList objectAtIndex:i];
    NSNumber *pointsGained = [proto.potentialPointsGainedList objectAtIndex:i];
    NSNumber *pointsLost = [proto.potentialPointsLostList objectAtIndex:i];
    
    if (pointsGained && pointsLost) {
      changed = YES;
      [self.userDict setObject:fup forKey:[NSNumber numberWithInt:fup.userId]];
      [self.pointsGainedDict setObject:pointsGained forKey:[NSNumber numberWithInt:fup.userId]];
      [self.pointsLostDict setObject:pointsLost forKey:[NSNumber numberWithInt:fup.userId]];
    }
  }
  
  if (changed) {
    [self.membersTable reloadData];
  }
}

- (IBAction)attackClicked:(id)sender {
  ClanMemberCell *cell = (ClanMemberCell *)[[[[sender superview] superview] superview] superview];
  MinimumUserProto *mup = cell.user.minUserProto.minUserProtoWithLevel.minUserProto;
  FullUserProto *fup = [self.userDict objectForKey:[NSNumber numberWithInt:mup.userId]];
  if (fup) {
    [[BattleLayer sharedBattleLayer] beginBattleAgainst:fup];
  }
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 3;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  GameState *gs = [GameState sharedGameState];
  if (section == 0) {
    if (myClan && leader.minUserProto.minUserProtoWithLevel.minUserProto.userId == gs.userId) {
      return requesters.count;
    } else {
      return 0;
    }
  } else if (section == 1) {
    if (leader) {
      self.spinner.hidden = YES;
      [self.spinner stopAnimating];
    } else {
      self.spinner.hidden = NO;
      [self.spinner startAnimating];
    }
    return leader != nil;
  } else if (section == 2) {
    return members.count;
  }
  return 0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  GameState *gs = [GameState sharedGameState];
  if (section == 0 && myClan && leader.minUserProto.minUserProtoWithLevel.minUserProto.userId == gs.userId && requesters.count > 0) {
    return self.requestersHeader;
  } else if (section == 1 && leader != nil) {
    return self.leaderHeader;
  } else if (section == 2 && members.count > 0) {
    return self.membersHeader;
  }
  return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  GameState *gs = [GameState sharedGameState];
  if (section == 0 && myClan && leader.minUserProto.minUserProtoWithLevel.minUserProto.userId == gs.userId && requesters.count > 0) {
    return 22.f;
  } else if (section == 1 && leader != nil) {
    return 22.f;
  } else if (section == 2 && members.count > 0) {
    return 22.f;
  }
  return 0.f;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ClanMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClanMemberCell"];
  
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed:@"ClanMemberCell" owner:self options:nil];
    cell = self.memberCell;
  }
  
  NSNumber *ptsGained = nil;
  NSNumber *ptsLost = nil;
  if (indexPath.section == 0) {
    [cell loadForUser:[self.requesters objectAtIndex:indexPath.row]];
    [cell respondInviteConfiguration];
  } else if (indexPath.section == 1) {
    [cell loadForUser:self.leader];
    if (_orderByClosest) {
      [cell attackConfiguration];
      
      NSNumber *userId = [NSNumber numberWithInt:self.leader.minUserProto.minUserProtoWithLevel.minUserProto.userId];
      if ([self.userDict objectForKey:userId]) {
        cell.attackSpinner.hidden = YES;
        cell.attackButton.hidden = NO;
      }
      ptsGained = [self.pointsGainedDict objectForKey:userId];
      ptsLost = [self.pointsLostDict objectForKey:userId];
    } else {
      [cell battleRecordConfiguration];
    }
  } else if (indexPath.section == 2) {
    MinimumUserProtoForClans *mup = [self.members objectAtIndex:indexPath.row];
    [cell loadForUser:mup];
    if (editModeOn) {
      [cell editMemberConfiguration];
    } else {
      if (_orderByClosest) {
        [cell attackConfiguration];
        
        NSNumber *userId = [NSNumber numberWithInt:mup.minUserProto.minUserProtoWithLevel.minUserProto.userId];
        if ([self.userDict objectForKey:userId]) {
          cell.attackSpinner.hidden = YES;
          cell.attackButton.hidden = NO;
        }
        ptsGained = [self.pointsGainedDict objectForKey:userId];
        ptsLost = [self.pointsLostDict objectForKey:userId];
      } else {
        [cell battleRecordConfiguration];
      }
    }
  }
  
  
  if (ptsGained && ptsLost) {
    cell.gainedLabel.text = [NSString stringWithFormat:@"+%@", [Globals commafyNumber:ptsGained.intValue]];
    cell.lostLabel.text = [NSString stringWithFormat:@"-%@", [Globals commafyNumber:ptsLost.intValue]];
    cell.slashLabel.text = @"|";
    
    CGSize s = [cell.lostLabel.text sizeWithFont:cell.lostLabel.font];
    CGRect r = cell.lostLabel.frame;
    r.origin.x = CGRectGetMaxX(r)-s.width;
    r.size.width = s.width;
    cell.lostLabel.frame = r;
    
    s = [cell.slashLabel.text sizeWithFont:cell.slashLabel.font];
    r = cell.slashLabel.frame;
    r.origin.x = cell.lostLabel.frame.origin.x-2-s.width;
    r.size.width = s.width;
    cell.slashLabel.frame = r;
    
    s = [cell.gainedLabel.text sizeWithFont:cell.gainedLabel.font];
    r = cell.gainedLabel.frame;
    r.origin.x = cell.slashLabel.frame.origin.x-2-s.width;
    r.size.width = s.width;
    cell.gainedLabel.frame = r;
  }
  
  return cell;
}

- (void) dealloc {
  self.membersTable = nil;
  self.spinner = nil;
  self.members = nil;
  self.requesters = nil;
  self.leader = nil;
  self.memberCell = nil;
  self.leaderHeader = nil;
  self.membersHeader = nil;
  self.requestersHeader = nil;
  [super dealloc];
}

@end

@implementation BrowseClanCell

@synthesize clan, topLabel, membersLabel, typeLabel;

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
  
  self.selectedBackgroundView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
  self.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5f];
}

- (void) cleanup {
  [super cleanup];
  self.clan = nil;
}

- (void) loadForClan:(FullClanProtoWithClanSize *)c {
  GameState *gs = [GameState sharedGameState];
  
  self.clan = c;
  self.topLabel.text = [NSString stringWithFormat:@"[%@] %@", c.clan.tag, c.clan.name];
  self.membersLabel.text = [NSString stringWithFormat:@"Members: %d", c.clanSize];
  
  if (c.clan.requestToJoinRequired) {
    self.typeLabel.text = @"By Request Only";
    self.typeLabel.textColor = [Globals redColor];
  } else {
    self.typeLabel.text = @"Anyone Can Join";
    self.typeLabel.textColor = [Globals greenColor];
  }
  
  BOOL isGood = [Globals userTypeIsGood:gs.type];
  if (!gs.clan && ((isGood && c.clan.isGood) || (!isGood && !c.clan.isGood))) {
    self.buttonView.hidden = NO;
    if ([gs.requestedClans containsObject:[NSNumber numberWithInt:c.clan.clanId]]) {
     self.buttonLabel.text = @"CANCEL";
    } else {
      if (c.clan.requestToJoinRequired) {
        self.buttonLabel.text = @"REQUEST";
      } else {
        self.buttonLabel.text = @"JOIN";
      }
    }
    self.buttonView.hidden = NO;
    self.arrowView.hidden = YES;
  } else {
    self.buttonView.hidden = YES;
    self.arrowView.hidden = NO;
  }
}

- (IBAction)redButtonClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  int clanId = self.clan.clan.clanId;
  if ([gs.requestedClans containsObject:[NSNumber numberWithInt:clanId]]) {
    int tag = [[OutgoingEventController sharedOutgoingEventController] retractRequestToJoinClan:clanId];
    [[ClanMenuController sharedClanMenuController] beginLoading:tag];
  } else {
    int tag = [[OutgoingEventController sharedOutgoingEventController] requestJoinClan:clanId];
    [[ClanMenuController sharedClanMenuController] beginLoading:tag];
  }
}

- (void) dealloc {
  self.clan = nil;
  self.topLabel = nil;
  self.membersLabel = nil;
  self.typeLabel = nil;
  self.buttonLabel = nil;
  self.buttonView = nil;
  [super dealloc];
}

@end

@implementation ClanBrowseView

@synthesize state;
@synthesize legionClans, allianceClans, searchClans;
@synthesize browseClansTable, spinner;
@synthesize clanCell, searchCell;
@synthesize searchString;
@synthesize shouldReload;
@synthesize loadingCell;

- (void) awakeFromNib {
  self.legionClans = [NSMutableArray array];
  self.allianceClans = [NSMutableArray array];
  self.searchClans = [NSMutableArray array];
  
  [self setState:kBrowseAlliance];
  
  self.browseClansTable.tableFooterView = [[[UIView alloc] init] autorelease];
  
  [(UIActivityIndicatorView *)[self.loadingCell viewWithTag:31] startAnimating];
  
  loadingCell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void) wakeup {
  [super wakeup];
  
  GameState *gs = [GameState sharedGameState];
  if ([Globals userTypeIsGood:gs.type]) {
    [self setState:kBrowseAlliance];
  } else {
    [self setState:kBrowseLegion];
  }
  
  self.shouldReload = NO;
  _reachedEnd = NO;
}

- (void) cleanup {
  [super cleanup];
  [self.legionClans removeAllObjects];
  [self.allianceClans removeAllObjects];
  [self.searchClans removeAllObjects];
  [browseClansTable reloadData];
}

- (void) setState:(ClanBrowseState)s {
  state = s;
  [browseClansTable reloadData];
  [browseClansTable setContentOffset:ccp(0,0) animated:YES];
}

- (void) loadClans:(NSArray *)clans isForSearch:(BOOL)search {
  if (search) isSearching = NO;
  else if (clans.count == 0) {self.shouldReload = NO; _reachedEnd = YES;}
  else self.shouldReload = YES;
  
  for (FullClanProtoWithClanSize *fcp in clans) {
    NSMutableArray *arr = nil;
    if (search) {
      arr = searchClans;
    } else {
      if (fcp.clan.isGood) {
        arr = allianceClans;
      } else {
        arr = legionClans;
      }
    }
    
    BOOL canAdd = YES;
    for (FullClanProtoWithClanSize *c in arr) {
      if (c.clan.clanId == fcp.clan.clanId) {
        canAdd = NO;
      }
    }
    
    if (canAdd) {
      [arr addObject:fcp];
    }
  }
  [browseClansTable reloadData];
}

- (NSMutableArray *) arrayForCurrentState {
  if (state == kBrowseAlliance) {
    return allianceClans;
  } else if (state == kBrowseLegion) {
    return legionClans;
  } else if (state == kBrowseSearch) {
    return searchClans;
  }
  return nil;
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    return state == kBrowseSearch;
  } else if (section == 1) {
    int ct = [self arrayForCurrentState].count;
    
    if (ct > 0 || (state == kBrowseSearch && !isSearching) || (state != kBrowseSearch && _reachedEnd)) {
      self.spinner.hidden = YES;
      [self.spinner stopAnimating];
    } else {
      self.spinner.hidden = NO;
      [self.spinner startAnimating];
    }
    
    return ct == 0 ? 0 : ct+(state != kBrowseSearch && !_reachedEnd);
  }
  return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BrowseSearchCell"];
    
    if (!cell) {
      [[NSBundle mainBundle] loadNibNamed:@"BrowseSearchCell" owner:self options:nil];
      searchCell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell = self.searchCell;
    }
    
    return cell;
  } else if (indexPath.section == 1) {
    BrowseClanCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BrowseClanCell"];
    
    NSArray *arr = [self arrayForCurrentState];
    if (indexPath.row >= arr.count) {
      return self.loadingCell;
    }
    
    if (!cell) {
      [[NSBundle mainBundle] loadNibNamed:@"BrowseClanCell" owner:self options:nil];
      cell = self.clanCell;
    }
    
    [cell loadForClan:[arr objectAtIndex:indexPath.row]];
    
    return cell;
  }
  return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  
  NSArray *arr = [self arrayForCurrentState];
  if (indexPath.section == 1 && indexPath.row < arr.count) {
    BrowseClanCell *cell = (BrowseClanCell *)[tableView cellForRowAtIndexPath:indexPath];
    [[ClanMenuController sharedClanMenuController] viewClan:cell.clan];
  }
  [self endEditing:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  // Load more rows when we get low enough
  if (scrollView.contentOffset.y > -REFRESH_ROWS*self.browseClansTable.rowHeight) {
    if (shouldReload) {
      int alliance = [[self.allianceClans lastObject] clan].clanId;
      int legion = [[self.legionClans lastObject] clan].clanId;
      int min = 0;
      if (alliance == 0) {min = legion;}
      else if (legion == 0) {min = alliance;}
      else {min = MIN(alliance, legion);}
      if (min != 0) {
        [[OutgoingEventController sharedOutgoingEventController] retrieveClanInfo:nil clanId:0 grabType:RetrieveClanInfoRequestProto_ClanInfoGrabTypeClanInfo isForBrowsingList:YES beforeClanId:min];
      }
      self.shouldReload = NO;
    }
  }
  //  [super scrollViewDidScroll:scrollView];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
  if (textField.text.length > 0) {
    [[OutgoingEventController sharedOutgoingEventController] retrieveClanInfo:textField.text clanId:0 grabType:RetrieveClanInfoRequestProto_ClanInfoGrabTypeClanInfo isForBrowsingList:YES beforeClanId:0];
    [self.searchClans removeAllObjects];
    isSearching = YES;
    self.searchString = textField.text;
    [self.browseClansTable reloadData];
  }
  return YES;
}

- (void) dealloc {
  self.legionClans = nil;
  self.allianceClans = nil;
  self.searchClans = nil;
  self.browseClansTable = nil;
  self.spinner = nil;
  self.clanCell = nil;
  self.searchCell = nil;
  self.searchString = nil;
  self.loadingCell = nil;
  [super dealloc];
}

@end

@implementation ClanInfoView

@synthesize textView, titleLabel, bottomButtonLabel;
@synthesize membersLabel, typeIcon, leaderButton;
@synthesize foundedLabel, canEdit, clan;
@synthesize spinner;
@synthesize bottomButtonView;
@synthesize upgradeTierButton;

- (void) cleanup {
  [super cleanup];
  self.clan = nil;
}

- (void) setCanEdit:(BOOL)c {
  canEdit = c;
  textView.editable = canEdit;
}

- (void) loadForClan:(FullClanProtoWithClanSize *)c {
  GameState *gs = [GameState sharedGameState];
  self.clan = c;
  if (c) {
    FullClanProto *fcp = c.clan;
    int maxForTier = [gs clanTierForLevel:c.clan.currentTierLevel].maxSize;
    
    textView.text = fcp.description;
    titleLabel.text = [NSString stringWithFormat:@"About %@ [%@]", fcp.name, fcp.tag];
    membersLabel.text = [NSString stringWithFormat:@"Members: %d (%d max)", c.clanSize, maxForTier];
    
    if (c.clanSize >= maxForTier) {
      membersLabel.textColor = [Globals redColor];
    } else {
      membersLabel.textColor = [Globals creamColor];
    }
    
    [self.typeIcon setImage:[Globals imageNamed:[Globals headshotImageNameForUser:fcp.owner.userType]] forState:UIControlStateNormal];
    [self.leaderButton setTitle:fcp.owner.name forState:UIControlStateNormal];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:fcp.createTime/1000.0];
    foundedLabel.text = [NSString stringWithFormat:@"Founded: %@", [dateFormatter stringFromDate:date]];
    [dateFormatter release];
    
    [self.spinner stopAnimating];
    self.spinner.hidden = YES;
    
    if (gs.clan.clanId == c.clan.clanId && c.clan.owner.userId == gs.userId) {
      self.upgradeTierButton.hidden = NO;
      
      self.clanTypeView.hidden = YES;
      self.switchButtonView.hidden = NO;
    } else {
      self.upgradeTierButton.hidden = YES;
      
      self.clanTypeView.hidden = NO;
      self.switchButtonView.hidden = YES;
    }
    
    if (c.clan.requestToJoinRequired) {
      self.typeLabel.text = @"By Request Only";
      self.typeLabel.textColor = [Globals redColor];
      self.switchButton.isOn = NO;
    } else {
      self.typeLabel.text = @"Anyone Can Join";
      self.typeLabel.textColor = [Globals greenColor];
      self.switchButton.isOn = YES;
    }
    
    if (gs.clan) {
      if (gs.clan.clanId == c.clan.clanId) {
        bottomButtonView.hidden = NO;
        
        if (c.clanSize == 1 && gs.clan.ownerId == gs.userId) {
          bottomButtonLabel.text = @"DELETE CLAN";
        } else {
          bottomButtonLabel.text = @"LEAVE CLAN";
        }
      } else {
        bottomButtonView.hidden = YES;
      }
    } else {
      int isGood = [Globals userTypeIsGood:gs.type];
      if ((isGood && c.clan.isGood) || (!isGood && !c.clan.isGood)) {
        bottomButtonView.hidden = NO;
        if ([gs.requestedClans containsObject:[NSNumber numberWithInt:c.clan.clanId]]) {
          bottomButtonLabel.text = @"CANCEL REQUEST";
        } else {
          if (c.clan.requestToJoinRequired) {
            bottomButtonLabel.text = @"REQUEST INVITE";
          } else {
            bottomButtonLabel.text = @"JOIN CLAN";
          }
        }
      } else {
        bottomButtonView.hidden = YES;
      }
    }
  } else {
    textView.text = nil;
    titleLabel.text = nil;
    membersLabel.text = nil;
    [self.typeIcon setImage:nil forState:UIControlStateNormal];
    [self.leaderButton setTitle:nil forState:UIControlStateNormal];
    foundedLabel.text = nil;
    bottomButtonView.hidden = YES;
    upgradeTierButton.hidden = YES;
    
    [self.spinner startAnimating];
    self.spinner.hidden = NO;
    
    self.clanTypeView.hidden = YES;
    self.switchButtonView.hidden = YES;
  }
}

- (void) switchButtonWasTurnedOff:(SwitchButton *)b {
  
  ClanMenuController *cmc = [ClanMenuController sharedClanMenuController];
  int tag = [[OutgoingEventController sharedOutgoingEventController] changeClanJoinType:YES];
  [cmc beginLoading:tag];
}

- (void) switchButtonWasTurnedOn:(SwitchButton *)b {
  ClanMenuController *cmc = [ClanMenuController sharedClanMenuController];
  int tag = [[OutgoingEventController sharedOutgoingEventController] changeClanJoinType:NO];
  [cmc beginLoading:tag];
}

- (BOOL) textView:(UITextView *)t shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  Globals *gl = [Globals sharedGlobals];
  NSString *str = [t.text stringByReplacingCharactersInRange:range withString:text];
  
  if (str.length > gl.maxCharLengthForClanDescription) {
    return NO;
  }
  return YES;
}

- (IBAction)bottomButtonClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  int clanId = clan.clan.clanId;
  [self endEditing:YES];
  if (gs.clan) {
    if (gs.clan.clanId == clanId) {
      if (clan.clanSize == 1 && gs.clan.ownerId == gs.userId) {
        [GenericPopupController displayConfirmationWithDescription:@"Are you sure you would like to delete this clan?" title:@"Delete?" okayButton:@"Delete" cancelButton:@"Cancel" target:self selector:@selector(leaveClan)];
      } else if (gs.clan.ownerId == gs.userId) {
        [GenericPopupController displayConfirmationWithDescription:@"You must transfer ownership before leaving this clan." title:@"Transfer Ownership" okayButton:@"Transfer" cancelButton:@"Cancel" target:[ClanMenuController sharedClanMenuController] selector:@selector(loadTransferOwnership)];
      } else {
        [GenericPopupController displayConfirmationWithDescription:@"Are you sure you would like to leave this clan?" title:@"Leave?" okayButton:@"Leave" cancelButton:@"Cancel" target:self selector:@selector(leaveClan)];
      }
    }
  } else {
    if ([gs.requestedClans containsObject:[NSNumber numberWithInt:clanId]]) {
      int tag = [[OutgoingEventController sharedOutgoingEventController] retractRequestToJoinClan:clanId];
      [[ClanMenuController sharedClanMenuController] beginLoading:tag];
    } else {
      int tag = [[OutgoingEventController sharedOutgoingEventController] requestJoinClan:clanId];
      [[ClanMenuController sharedClanMenuController] beginLoading:tag];
    }
  }
}

- (void) leaveClan {
  int tag = [[OutgoingEventController sharedOutgoingEventController] leaveClan];
  [[ClanMenuController sharedClanMenuController] beginLoading:tag];
}

- (IBAction)profileClicked:(id)sender {
  MinimumUserProto *mup = self.clan.clan.owner;
  if (mup) {
    [[ProfileViewController sharedProfileViewController] loadProfileForMinimumUser:mup withState:kProfileState];
    [ProfileViewController displayView];
  }
}

- (void) dealloc {
  self.textView = nil;
  self.titleLabel = nil;
  self.bottomButtonLabel = nil;
  self.membersLabel = nil;
  self.typeIcon = nil;
  self.leaderButton = nil;
  self.foundedLabel = nil;
  self.clan = nil;
  self.spinner = nil;
  self.bottomButtonView = nil;
  self.upgradeTierButton = nil;
  self.clanTypeView = nil;
  self.switchButtonView = nil;
  self.typeLabel = nil;
  self.switchButton = nil;
  [super dealloc];
}

@end

@implementation ClanBoardCell

@synthesize postLabel, playerIcon, nameLabel, timeLabel;
@synthesize gradientLayer;

- (void) layoutSubviews {
  [super layoutSubviews];
  
  [self.gradientLayer removeFromSuperlayer];
  
  self.gradientLayer = [CAGradientLayer layer];
  gradientLayer.frame = self.bounds;
  UIColor *topColor = [UIColor colorWithRed:35/255.f green:35/255.f blue:35/255.f alpha:0.3f];
  UIColor *botColor = [UIColor colorWithRed:12/255.f green:12/255.f blue:12/255.f alpha:0.3f];
  gradientLayer.colors = [NSArray arrayWithObjects:(id)[topColor CGColor], (id)[botColor CGColor], nil];
  [self.contentView.layer insertSublayer:gradientLayer atIndex:0];
}

- (void) updateForBoardPost:(ClanBulletinPostProto *)boardPost {
  [playerIcon setImage:[Globals squareImageForUser:boardPost.poster.userType] forState:UIControlStateNormal];
  [nameLabel setTitle:boardPost.poster.name forState:UIControlStateNormal];
  timeLabel.text = [Globals stringForTimeSinceNow:[NSDate dateWithTimeIntervalSince1970:boardPost.timeOfPost/1000.0] shortened:NO];
  postLabel.text = boardPost.content;
  
  CGSize size = postLabel.frame.size;
  size.height = 9999;
  size = [postLabel.text sizeWithFont:postLabel.font constrainedToSize:size];
  
  CGRect rect = postLabel.frame;
  rect.size.height = size.height;
  postLabel.frame = rect;
}

- (void) dealloc {
  self.postLabel = nil;
  self.playerIcon = nil;
  self.nameLabel = nil;
  self.timeLabel = nil;
  self.gradientLayer = nil;
  [super dealloc];
}

@end

@implementation ClanBoardView

@synthesize spinner;
@synthesize boardCell, boardPosts, boardTableView;
@synthesize postView;
@synthesize boardTextField;

- (void) awakeFromNib {
  boardTextField.label.textColor = [UIColor whiteColor];
  
  // This will prevent empty cells from being made when the page is not full..
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
  boardTableView.tableFooterView = view;
  [view release];
}

- (void) wakeup {
  self.boardPosts = nil;
}

- (void) cleanup {
  self.boardPosts = nil;
}

- (void) loadForCurrentClan {
  GameState *gs = [GameState sharedGameState];
  if (gs.clan) {
    if (gs.userId == gs.clan.ownerId) {
      postView.hidden = NO;
      
      CGRect r = boardTableView.frame;
      float newY = CGRectGetMaxY(postView.frame);
      r.size.height = CGRectGetMaxY(r)-newY;
      r.origin.y = newY;
      boardTableView.frame = r;
    } else {
      postView.hidden = YES;
      
      CGRect r = boardTableView.frame;
      float newY = CGRectGetMinY(postView.frame);
      r.size.height = CGRectGetMaxY(r)-newY;
      r.origin.y = newY;
      boardTableView.frame = r;
    }
  }
}

- (void) setBoardPosts:(NSMutableArray *)w {
  if (boardPosts != w) {
    [boardPosts release];
    boardPosts = [w retain];
  }
  
  if (boardPosts == nil) {
    spinner.hidden = NO;
    [spinner startAnimating];
  } else {
    [spinner stopAnimating];
    spinner.hidden = YES;
  }
  
  [self.boardTableView reloadData];
  [self.boardTableView setContentOffset:CGPointZero];
}

- (void) endEditing {
  if ([boardTextField isFirstResponder]) {
    [boardTextField resignFirstResponder];
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [self endEditing];
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.boardPosts.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ClanBoardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClanBoardCell"];
  
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed:@"ClanBoardCell" owner:self options:nil];
    cell = self.boardCell;
  }
  
  CGRect r = cell.frame;
  r.size.width = tableView.frame.size.width;
  cell.frame = r;
  
  [cell updateForBoardPost:[self.boardPosts objectAtIndex:indexPath.row]];
  
  return cell;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
  [self endEditing];
}

static BOOL clanBoardCellLoaded = NO;
static float clanPostLabelMinY = 28.75f;
static UIFont *clanPostFont = nil;
static float clanPostCellOffset = 5.f;
static float clanPostLabelWidth = 10.f;

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (!clanBoardCellLoaded) {
    [[NSBundle mainBundle] loadNibNamed:@"ClanBoardCell" owner:self options:nil];
    clanBoardCellLoaded = YES;
    
    CGRect r = boardCell.frame;
    r.size.width = tableView.frame.size.width;
    boardCell.frame = r;
    
    clanPostLabelMinY = boardCell.postLabel.frame.origin.y;
    clanPostFont = [boardCell.postLabel.font retain];
    clanPostLabelWidth = boardCell.postLabel.frame.size.width;
  }
  
  ClanBulletinPostProto *boardPost = [self.boardPosts objectAtIndex:indexPath.row];
  
  CGSize size = CGSizeMake(clanPostLabelWidth, 9999);
  size = [boardPost.content sizeWithFont:clanPostFont constrainedToSize:size];
  
  return clanPostLabelMinY+size.height+clanPostCellOffset;
}

- (IBAction)postToBoard:(id)sender {
  if (!boardPosts) {
    [Globals popupMessage:@"Please wait! Retrieving current board posts."];
  } else {
    NSString *content = boardTextField.text;
    if (content.length > 0) {
      ClanBulletinPostProto *boardPost = [[OutgoingEventController sharedOutgoingEventController] postOnClanBulletin:content];
      
      if (boardPost) {
        [self.boardPosts insertObject:boardPost atIndex:0];
        [self displayNewBoardPost];
      }
      
      boardTextField.text = @"";
    }
  }
  [self endEditing];
}

- (void) displayNewBoardPost {
  int old = [self.boardTableView numberOfRowsInSection:0];
  int new = self.boardPosts.count;
  
  if (old+1 == new) {
    [self.boardTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
  }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  Globals *gl = [Globals sharedGlobals];
  NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
  if ([str length] > gl.maxLengthOfChatString) {
    return NO;
  }
  return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
  [self postToBoard:nil];
  return YES;
}

- (IBAction)visitProfile:(id)sender {
  UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
  NSIndexPath *path = [boardTableView indexPathForCell:cell];
  ClanBulletinPostProto *proto = [boardPosts objectAtIndex:path.row];
  
  [[ProfileViewController sharedProfileViewController] loadProfileForMinimumUser:proto.poster withState:kProfileState];
}

- (void) dealloc {
  self.boardPosts = nil;
  self.boardTableView = nil;
  self.boardTextField = nil;
  self.boardCell = nil;
  self.postView = nil;
  [super dealloc];
}

@end

@implementation BrowseSearchCell

@synthesize textField;

- (IBAction)clearClicked:(id)sender {
  self.textField.text = nil;
  [self.textField becomeFirstResponder];
}

- (void) dealloc {
  self.textField = nil;
  [super dealloc];
}

@end

@implementation ClanComingSoonView

- (void) awakeFromNib {
  [Globals imageNamed:@"spinner.png" withView:self.spinnerView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhiteLarge clearImageDuringDownload:YES];
}

- (void) loadForClanVault {
  self.topLabel.text = @"Clan Vault";
}

- (void) loadForClanBosses {
  self.topLabel.text = @"Clan Bosses";
}

- (void) dealloc {
  self.spinnerView = nil;
  self.topLabel = nil;
  [super dealloc];
}

@end