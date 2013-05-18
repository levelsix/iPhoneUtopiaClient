//
//  ProfileViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/26/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ProfileViewController.h"
#import "LNSynthesizeSingleton.h"
#import "GameState.h"
#import "Globals.h"
#import "OutgoingEventController.h"
#import "BattleLayer.h"
#import "GenericPopupController.h"
#import "EquipMenuController.h"
#import "EquipDeltaView.h"
//#import "KiipDelegate.h"
#import "RefillMenuController.h"
#import "CharSelectionViewController.h"
#import "ArmoryViewController.h"
#import "ClanMenuController.h"
#import "FAQMenuController.h"
#import "ChatMenuController.h"

#define EQUIPPING_DURATION 0.5f

@implementation ProfileViewController

@synthesize state = _state;
@synthesize clanButton;
@synthesize userNameLabel, typeLabel, levelLabel, attackLabel, defenseLabel, codeLabel;
@synthesize winsLabel, lossesLabel, fleesLabel;
@synthesize profilePicture, profileBar;
@synthesize equippingView, skillTabView, wallTabView;
@synthesize attackStatLabel, defenseStatLabel, staminaStatLabel, energyStatLabel;
@synthesize attackStatButton, defenseStatButton, staminaStatButton, energyStatButton;
@synthesize enemyAttackLabel, enemyMiddleView;
@synthesize staminaCostLabel, skillPointsLabel;
@synthesize selfLeftView, friendLeftView;
@synthesize visitButton, smallAttackButton, bigAttackButton;
@synthesize spinner;
@synthesize mainView, bgdView, loadingView;
@synthesize fup = _fup;
@synthesize userId;
@synthesize equipPopup;
@synthesize specialTabView, profileTabView;
@synthesize nameChangeView, nameChangeTextField;
@synthesize noEquipLabel, noEquipMiddleView, noEquipButtonView;
@synthesize clanView, equipTabView;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(ProfileViewController);

- (void) viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  skillTabView.frame = profileTabView.frame;
  [self.mainView insertSubview:skillTabView aboveSubview:profileTabView];
  
  specialTabView.frame = profileTabView.frame;
  [self.mainView insertSubview:specialTabView aboveSubview:profileTabView];
  
  wallTabView.frame = profileTabView.frame;
  [self.mainView insertSubview:wallTabView aboveSubview:profileTabView];
  
  enemyMiddleView.frame = equipTabView.frame;
  [equipTabView.superview addSubview:enemyMiddleView];
  
  friendLeftView.frame = selfLeftView.frame;
  [selfLeftView.superview addSubview:friendLeftView];
  
  // Start state at 0 so that when it gets loaded it won't be ignored
  _state = 0;
  self.state = kProfileState;
  _curScope = kEquipScopeWeapons;
  
  [self.equipTabView setUpCurEquipViewsWithDelegate:self];
}

- (void) viewWillAppear:(BOOL)animated {
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  [self refreshSkillPointsButtons];
}

- (void) viewDidDisappear:(BOOL)animated {
  [Globals endPulseForView:attackStatButton];
  [Globals endPulseForView:defenseStatButton];
  [Globals endPulseForView:energyStatButton];
  [Globals endPulseForView:staminaStatButton];
  
  self.fup = nil;
}

- (void) setState:(ProfileState)state {
  switch (state) {
    case kProfileState:
      profileTabView.hidden = NO;
      wallTabView.hidden = YES;
      skillTabView.hidden = YES;
      specialTabView.hidden = YES;
      [self.profileBar setProfileState:state];
      break;
      
    case kWallState:
      profileTabView.hidden = YES;
      wallTabView.hidden = NO;
      skillTabView.hidden = YES;
      specialTabView.hidden = YES;
      [self.profileBar setProfileState:state];
      break;
      
    case kSkillsState:
      profileTabView.hidden = YES;
      wallTabView.hidden = YES;
      skillTabView.hidden = NO;
      specialTabView.hidden = YES;
      [self.profileBar setProfileState:state];
      break;
      
    case kSpecialState:
      profileTabView.hidden = YES;
      wallTabView.hidden = YES;
      skillTabView.hidden = YES;
      specialTabView.hidden = NO;
      [self.profileBar setProfileState:state];
      break;
      
    default:
      break;
  }
  _state = state;
  [wallTabView endEditing];
}

- (void) doEquip:(UserEquip *)equip {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:equip.equipId];
  BOOL isForPrestigeSlot = self.equipBrowseView.isFlipped;
  if (!isForPrestigeSlot || (isForPrestigeSlot && gs.prestigeLevel >= fep.equipType+1)) {
    BOOL success =[[OutgoingEventController sharedOutgoingEventController] wearEquip:equip.userEquipId forPrestigeSlot:isForPrestigeSlot];
    if (success) {
      [self.equipBrowseView doEquippingAnimation:equip withNewCurEquipArray:[gs getUserEquipArray]];
    }
  } else {
    [Globals popupMessage:@"Sorry. You must prestige in order to use this equip slot."];
  }
}

- (void) equipViewSelected:(EquipView *)ev {
  GameState *gs = [GameState sharedGameState];
  int tag = ev.tag;
  
  if (tag == EQUIP_BROWSE_VIEW_TAG) {
    UserEquip *ue = ev.equip;
    if (profileBar.state == kMyProfile && ue.userId == gs.userId) {
      // The fuep is actually a UserEquip.. see @selector(loadMyProfile)
      [equipPopup updateForUserEquip:ue];
      [self.view addSubview:equipPopup];
      [Globals bounceView:equipPopup.mainView fadeInBgdView:equipPopup.bgdView];
      equipPopup.frame = self.view.bounds;
    } else {
      [EquipMenuController displayViewForEquip:ue.equipId level:ue.level enhancePercent:ue.enhancementPercentage];
    }
  } else {
    if (profileBar.state == kMyProfile && tag-2 > gs.prestigeLevel) {
      self.state = kSpecialState;
    } else {
      [self.view addSubview:self.equipBrowseView];
      [Globals bounceView:self.equipBrowseView.mainView fadeInBgdView:self.equipBrowseView.bgdView];
      self.equipBrowseView.frame = self.view.bounds;
      
      [self.equipBrowseView updateForScope:tag%3+1 isSlot2:tag>2];
    }
  }
}

- (NSArray *) sortEquips:(NSArray *)equips {
  NSMutableArray *arr = [equips mutableCopy];
  Globals *gl = [Globals sharedGlobals];
  
  [arr sortUsingComparator:^NSComparisonResult(UserEquip *obj1, UserEquip *obj2) {
    int compAttack = [gl calculateAttackForEquip:obj1.equipId level:obj1.level enhancePercent:obj1.enhancementPercentage];
    int compDefense = [gl calculateDefenseForEquip:obj1.equipId level:obj1.level enhancePercent:obj1.enhancementPercentage];
    int bestAttack = [gl calculateAttackForEquip:obj2.equipId level:obj2.level enhancePercent:obj2.enhancementPercentage];
    int bestDefense = [gl calculateDefenseForEquip:obj2.equipId level:obj2.level enhancePercent:obj2.enhancementPercentage];
    
    if (compAttack+compDefense > bestDefense+bestAttack) {
      return NSOrderedAscending;
    } else if (compAttack+compDefense < bestDefense+bestAttack) {
      return NSOrderedDescending;
    } else {
      return NSOrderedSame;
    }
  }];
  
  return arr;
}

- (IBAction)goToArmoryClicked:(id)sender {
  [ArmoryViewController displayView];
}

- (void) loadEquips:(NSArray *)equips curEquips:(NSArray *)curEquips prestigeLevel:(int)prestigeLevel {
  BOOL isMe = profileBar.state == kMyProfile;
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *sortedEquips;
  
  if (isMe) {
    //Sort equips by equippable and then non-equippable.
    NSMutableArray *equippables = [NSMutableArray array];
    NSMutableArray *unequippables = [NSMutableArray array];
    
    for (UserEquip *ue in equips) {
      FullEquipProto *fep = [gs equipWithId:ue.equipId];
      // this will prevent a crash..
      if (!fep) return;
      if ([Globals canEquip:fep]) {
        [equippables addObject:ue];
      } else {
        [unequippables addObject:ue];
      }
    }
    sortedEquips = [[self sortEquips:equippables].mutableCopy autorelease];
    [sortedEquips addObjectsFromArray:[self sortEquips:unequippables]];
  } else {
    sortedEquips = [[self sortEquips:equips].mutableCopy autorelease];
  }
  
  if (curEquips == nil) {
    // This will make it an array of nulls
    curEquips = [Globals getUserEquipArrayFromFullUserProto:nil];
  }
  
  for (int i = 0; i < sortedEquips.count; i++) {
    UserEquip *ue = [sortedEquips objectAtIndex:i];
    if ([curEquips containsObject:ue]) {
      [sortedEquips removeObjectAtIndex:i];
      [sortedEquips insertObject:ue atIndex:0];
    }
  }
  
  [self.equipTabView updateForEquips:curEquips isMine:isMe prestigeLevel:prestigeLevel];
  [self.equipBrowseView loadForEquips:sortedEquips curEquips:curEquips prestigeLevel:prestigeLevel isMe:isMe];
}

- (void) loadProfileForPlayer:(FullUserProto *)fup buttonsEnabled:(BOOL)enabled {
  if (fup.userId == [[GameState sharedGameState] userId]) {
    [self loadMyProfile];
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  BOOL isEnemy = ![Globals userType:gs.type isAlliesWith:fup.userType];
  
  if (userId != fup.userId) {
    wallTabView.wallPosts = nil;
    [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentWallPostsForPlayer:fup.userId];
  }
  
  self.fup = fup;
  self.userId = fup.userId;
  
  userNameLabel.text = fup.name;
  profilePicture.image = [Globals profileImageForUser:fup.userType];
  winsLabel.text = [Globals commafyNumber:fup.battlesWon];
  lossesLabel.text = [Globals commafyNumber:fup.battlesLost];
  fleesLabel.text = [Globals commafyNumber:fup.flees];
  levelLabel.text = [NSString stringWithFormat:@"%d", fup.level];
  typeLabel.text = [NSString stringWithFormat:@"%@ %@", [Globals factionForUserType:fup.userType], [Globals classForUserType:fup.userType]];
  attackLabel.text = @"?";
  defenseLabel.text = @"?";
  
  if (fup.hasClan) {
    [self setClanName:fup.clan.name];
    clanButton.enabled = YES;
  } else {
    [self setClanName:@"No Clan"];
    clanButton.enabled = NO;
  }
  
  _curScope = kEquipScopeWeapons;
  
  enemyMiddleView.hidden = !isEnemy;
  
  friendLeftView.hidden = NO;
  selfLeftView.hidden = YES;
  
  // Check if this user is currently online
  uint64_t curTime = [[NSDate date] timeIntervalSince1970]*1000;
  NSLog(@"%@, %@", [NSDate dateWithTimeIntervalSince1970:fup.lastLoginTime/1000.], [NSDate dateWithTimeIntervalSince1970:fup.lastLogoutTime/1000.]);
  self.onlineView.hidden = !(fup.lastLoginTime > fup.lastLogoutTime && curTime > fup.lastLoginTime-60*60*1000);
  
  CGRect r = self.chatButtonView.frame;
  r.origin.y = self.onlineView.hidden ? self.friendLeftView.frame.size.height/2-self.chatButtonView.frame.size.height/2 : CGRectGetMaxY(self.onlineView.frame);
  self.chatButtonView.frame = r;
  
  [UIView animateWithDuration:1.f delay:0.f options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
    self.greenGlow.alpha = 0.5f;
  } completion:nil];
  
  enemyAttackLabel.text = [NSString stringWithFormat:@"Attack %@ to see Equipment", fup.name];
  
  self.profileBar.state = kOtherPlayerProfile;
  [self.profileBar setProfileState:self.state];
  
  [self loadEquips:nil curEquips:nil prestigeLevel:0];
  
  visitButton.enabled = enabled;
  smallAttackButton.enabled = enabled;
  bigAttackButton.enabled = enabled;
  
  if (self.state == kSkillsState || self.state == kSpecialState) {
    self.state = kProfileState;
  }
  
  if (!isEnemy && !_waitingForEquips) {
    _waitingForEquips = YES;
    [[OutgoingEventController sharedOutgoingEventController] retrieveEquipsForUser:fup.userId];
    [spinner startAnimating];
    self.spinner.hidden = NO;
    equipTabView.hidden = YES;
    self.changeButtonView.hidden = YES;
  } else {
    [spinner stopAnimating];
    self.spinner.hidden = YES;
    equipTabView.hidden = isEnemy;
    self.changeButtonView.hidden = isEnemy;
    self.changeButtonLabel.text = @"see all";
  }
}

- (NSArray *) createFakeEquipsForFakePlayer:(FullUserProto *)fup {
  
  // Fake the equips for fake players
  NSMutableArray *equips = [NSMutableArray arrayWithCapacity:3];
  
  UserEquip *ue = nil;
  if (fup.weaponEquippedUserEquip.equipId > 0) {
    ue = [UserEquip userEquipWithProto:fup.weaponEquippedUserEquip];
    [equips addObject:ue];
  }
  
  if (fup.armorEquippedUserEquip.equipId > 0) {
    ue = [UserEquip userEquipWithProto:fup.armorEquippedUserEquip];
    [equips addObject:ue];
  }
  
  if (fup.amuletEquippedUserEquip.equipId > 0) {
    ue = [UserEquip userEquipWithProto:fup.amuletEquippedUserEquip];
    [equips addObject:ue];
  }
  return equips;
}

- (void) loadProfileForPlayer:(FullUserProto *)fup equips:(NSArray *)equips attack:(int)attack defense:(int)defense {
  // This method is only used from battle
  
  if (userId != fup.userId) {
    wallTabView.wallPosts = nil;
    [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentWallPostsForPlayer:fup.userId];
  }
  
  self.fup = fup;
  self.userId = fup.userId;
  
  [self loadProfileForPlayer:fup buttonsEnabled:YES];
  
  enemyMiddleView.hidden = YES;
  
  Globals *globals = [Globals sharedGlobals];
  attack  = [globals calculateAttackForAttackStat:_fup.attack
                                           weapon:_fup.hasWeaponEquippedUserEquip ? (UserEquip *)_fup.weaponEquippedUserEquip : nil
                                            armor:_fup.hasArmorEquippedUserEquip ? (UserEquip *)_fup.armorEquippedUserEquip : nil
                                           amulet:_fup.hasAmuletEquippedUserEquip ? (UserEquip *)_fup.amuletEquippedUserEquip : nil
                                          weapon2:_fup.hasWeaponTwoEquippedUserEquip ? (UserEquip *)_fup.weaponTwoEquippedUserEquip : nil
                                           armor2:_fup.hasArmorTwoEquippedUserEquip ? (UserEquip *)_fup.armorTwoEquippedUserEquip : nil
                                          amulet2:_fup.hasAmuletTwoEquippedUserEquip ? (UserEquip *)_fup.amuletTwoEquippedUserEquip : nil];
  
  defense = [globals calculateDefenseForDefenseStat:_fup.defense
                                             weapon:_fup.hasWeaponEquippedUserEquip ? (UserEquip *)_fup.weaponEquippedUserEquip : nil
                                              armor:_fup.hasArmorEquippedUserEquip ? (UserEquip *)_fup.armorEquippedUserEquip : nil
                                             amulet:_fup.hasAmuletEquippedUserEquip ? (UserEquip *)_fup.amuletEquippedUserEquip : nil
                                            weapon2:_fup.hasWeaponTwoEquippedUserEquip ? (UserEquip *)_fup.weaponTwoEquippedUserEquip : nil
                                             armor2:_fup.hasArmorTwoEquippedUserEquip ? (UserEquip *)_fup.armorTwoEquippedUserEquip : nil
                                            amulet2:_fup.hasAmuletTwoEquippedUserEquip ? (UserEquip *)_fup.amuletTwoEquippedUserEquip : nil];
  attackLabel.text = [NSString stringWithFormat:@"%d", attack];
  defenseLabel.text = [NSString stringWithFormat:@"%d", defense];
  
  if (fup.isFake) {
    equips = [self createFakeEquipsForFakePlayer:fup];
  } else if (equips) {
    equips = [self userEquipArrayFromFullUserEquipProtos:equips];
  }
  
  if (equips) {
    [self loadEquips:equips curEquips:[Globals getUserEquipArrayFromFullUserProto:fup] prestigeLevel:fup.prestigeLevel];
    equipTabView.hidden = NO;
    self.changeButtonView.hidden = NO;
    self.changeButtonLabel.text = @"see all";
  } else {
    equipTabView.hidden = YES;
    self.changeButtonView.hidden = YES;
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
    _waitingForEquips = YES;
  }
}

- (NSArray *) userEquipArrayFromFullUserEquipProtos:(NSArray *)equips {
  // Create user equips and squash into quantities
  NSMutableArray *newEquips = [NSMutableArray array];
  for (FullUserEquipProto *fuep in equips) {
    UserEquip *ue = [UserEquip userEquipWithProto:fuep];
    [newEquips addObject:ue];
  }
  return newEquips;
}

- (void) receivedFullUserProtos:(NSArray *)protos {
  GameState *gs = [GameState sharedGameState];
  for (FullUserProto *fup in protos) {
    if (fup.userId == userId) {
      ProfileState st = self.state;
      [self loadProfileForPlayer:fup buttonsEnabled:YES];
      self.state = st;
      
      if (_queuedEquips || _fup.isFake) {
        if ([Globals userType:_fup.userType isAlliesWith:gs.type]) {
          // Just set this so that updateEquips runs
          _waitingForEquips = YES;
          
          NSArray *equips = _fup.isFake ? [self createFakeEquipsForFakePlayer:_fup] : _queuedEquips;
          [self updateEquips:equips];
          [_queuedEquips release];
          _queuedEquips = nil;
        }
      } else {
        _waitingForEquips = YES;
        
        if ([Globals userType:fup.userType isAlliesWith:gs.type]) {
          self.spinner.hidden = NO;
          [self.spinner startAnimating];
          
          equipTabView.hidden = YES;
          self.changeButtonView.hidden = YES;
          
          [self loadEquips:nil curEquips:nil prestigeLevel:0];
        }
      }
    }
  }
}

- (void) receivedWallPosts:(RetrievePlayerWallPostsResponseProto *)proto {
  if (proto.relevantUserId == userId) {
    // Wall Tab View will take control of updating the wall posts
    // Make sure to send empty list if there are no wall posts so that spinner stops..
    wallTabView.wallPosts = proto.playerWallPostsList ? [proto.playerWallPostsList.mutableCopy autorelease] : [NSMutableArray array];
  }
}

- (void) receivedEquips:(RetrieveUserEquipForUserResponseProto *)proto {
  if (proto.relevantUserId == userId) {
    if (_fup) {
      NSArray *equips = _fup.isFake ? [self createFakeEquipsForFakePlayer:_fup] : proto.userEquipsList;
      [self updateEquips:equips];
    } else {
      _queuedEquips = [proto.userEquipsList retain];
    }
  }
}

- (void) updateEquips:(NSArray *)equips {
  if (_waitingForEquips) {
    // Make sure to create UserEquip array
    _waitingForEquips = NO;
    [self loadEquips:[self userEquipArrayFromFullUserEquipProtos:equips] curEquips:[Globals getUserEquipArrayFromFullUserProto:_fup] prestigeLevel:_fup.prestigeLevel];
    
    self.spinner.hidden = YES;
    [self.spinner stopAnimating];
    
    equipTabView.hidden = NO;
    self.changeButtonView.hidden = NO;
  }
}

- (void) loadProfileForMinimumUser:(MinimumUserProto *)user withState:(ProfileState)pState {
  if (userId == user.userId) {
    [ProfileViewController displayView];
    return;
  } else if (user.userId == [[GameState sharedGameState] userId]) {
    [ProfileViewController displayView];
    [self loadMyProfile];
    self.state = pState;
    return;
  }
  
  self.state = pState;
  self.profileBar.state = kOtherPlayerProfile;
  [self.profileBar setProfileState:pState];
  self.userId = user.userId;
  self.fup = nil;
  [_queuedEquips release];
  _queuedEquips = nil;
  
  [[OutgoingEventController sharedOutgoingEventController] retrieveUsersForUserIds:[NSArray arrayWithObject:[NSNumber numberWithInt:userId]]];
  
  [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentWallPostsForPlayer:user.userId];
  
  GameState *gs = [GameState sharedGameState];
  if ([Globals userType:gs.type isAlliesWith:user.userType]) {
    [[OutgoingEventController sharedOutgoingEventController] retrieveEquipsForUser:user.userId];
    _waitingForEquips = YES;
  }
  
  userNameLabel.text = user.name;
  profilePicture.image = [Globals profileImageForUser:user.userType];
  winsLabel.text = @"";
  lossesLabel.text = @"";
  fleesLabel.text = @"";
  levelLabel.text = @"?";
  typeLabel.text = @"";
  attackLabel.text = @"";
  defenseLabel.text = @"";
  
  [self setClanName:@"Loading..."];
  self.clanButton.enabled = NO;
  
  selfLeftView.hidden = YES;
  friendLeftView.hidden = YES;
  
  wallTabView.wallPosts = nil;
  
  [self loadEquips:nil curEquips:nil prestigeLevel:0];
  
  // Make equip spinner spin
  self.enemyMiddleView.hidden = YES;
  equipTabView.hidden = YES;
  self.changeButtonView.hidden = YES;
  self.changeButtonLabel.text = @"see all";
  self.spinner.hidden = NO;
  [self.spinner startAnimating];
  
  [ProfileViewController displayView];
}

- (void) loadMyProfileWithLevelUp {
  [self loadMyProfile];
  _displayKiipOnClose = YES;
}

- (void) loadMyProfile {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  self.fup = nil;
  self.userId = gs.userId;
  
  userNameLabel.text = gs.name;
  profilePicture.image = [Globals profileImageForUser:gs.type];
  winsLabel.text = [Globals commafyNumber:gs.battlesWon];
  lossesLabel.text = [Globals commafyNumber:gs.battlesLost];
  fleesLabel.text = [Globals commafyNumber:gs.flees];
  levelLabel.text = [NSString stringWithFormat:@"%d", gs.level];
  typeLabel.text = [NSString stringWithFormat:@"%@ %@", [Globals factionForUserType:gs.type], [Globals classForUserType:gs.type]];
  codeLabel.text = gs.referralCode;
  
  if (gs.clan) {
    [self setClanName:gs.clan.name];
    clanButton.enabled = YES;
  } else {
    [self setClanName:@"No Clan"];
    clanButton.enabled = NO;
  }
  
  if (self.profileBar.state != kMyProfile) {
    self.profileBar.state = kMyProfile;
    self.state = kProfileState;
    
  }
  [self loadSkills];
  
  [self loadEquips:gs.myEquips curEquips:[gs getUserEquipArray] prestigeLevel:gs.prestigeLevel];
  
  enemyMiddleView.hidden = YES;
  equipTabView.hidden = NO;
  self.changeButtonView.hidden = NO;
  self.changeButtonLabel.text = @"change";
  
  self.spinner.hidden = YES;
  [self.spinner stopAnimating];
  
  friendLeftView.hidden = YES;
  selfLeftView.hidden = NO;
  
  wallTabView.wallPosts = [[GameState sharedGameState] wallPosts];
  
  // Update calculate labels
  staminaCostLabel.text = [NSString stringWithFormat:@"(%d skill %@ = %d)", gl.staminaBaseCost, gl.staminaBaseCost != 1 ? @"points" : @"point", gl.staminaBaseGain];
}

-(void)setupSkillPointButton:(UIButton *)curButton forCost:(int)stateCost
{
  GameState *gs = [GameState sharedGameState];
  
  if (stateCost <= gs.skillPoints) {
    if (!curButton.enabled) {
      curButton.enabled = YES;
    }
    UIColor *pulseColor = [UIColor colorWithRed:156/255.f
                                          green:202/255.f
                                           blue:16/255.f
                                          alpha:0.8f];
    
    [Globals beginPulseForView:curButton andColor:pulseColor];
  }
  else {
    curButton.enabled = NO;
    [Globals endPulseForView:curButton];
  }
}

- (void) setClanName:(NSString *)name {
  [self.clanButton setTitle:name forState:UIControlStateNormal];
  
  CGSize size = [name sizeWithFont:clanButton.titleLabel.font constrainedToSize:clanButton.frame.size lineBreakMode:clanButton.titleLabel.lineBreakMode];
  CGRect r = clanView.frame;
  r.size.width = clanButton.frame.origin.x+size.width;
  clanView.frame = r;
  
  CGPoint pt = clanView.center;
  pt.x = userNameLabel.center.x;
  clanView.center = pt;
}

- (void) loadSkills {
  GameState *gs = [GameState sharedGameState];
  
  attackStatLabel.text = [NSString stringWithFormat:@"%d", gs.attack];
  defenseStatLabel.text = [NSString stringWithFormat:@"%d", gs.defense];
  energyStatLabel.text = [NSString stringWithFormat:@"%d", gs.maxEnergy];
  staminaStatLabel.text = [NSString stringWithFormat:@"%d", gs.maxStamina];
  
  skillPointsLabel.text = [NSString stringWithFormat:@"%d", gs.skillPoints];
  
  [self refreshSkillPointsButtons];
}

- (void) openSkillsMenu {
  self.state = kSkillsState;
}

-(void)refreshSkillPointsButtons
{
  Globals *gl = [Globals sharedGlobals];
  
  [self setupSkillPointButton:attackStatButton  forCost:gl.attackBaseCost];
  [self setupSkillPointButton:defenseStatButton forCost:gl.defenseBaseCost];
  [self setupSkillPointButton:energyStatButton  forCost:gl.energyBaseCost];
  [self setupSkillPointButton:staminaStatButton forCost:gl.staminaBaseCost];
}

- (IBAction)clanClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  if (gs.level < gl.minLevelConstants.clanHouseMinLevel && gs.prestigeLevel <= 0) {
    [Globals popupMessage:[NSString stringWithFormat:@"You cannot access the clan house until level %d.", gl.minLevelConstants.clanHouseMinLevel]];
  } else if (_fup.clan) {
    [ClanMenuController displayView];
    [[ClanMenuController sharedClanMenuController] loadForClan:_fup.clan];
  } else if (profileBar.state == kMyProfile && gs.clan) {
    [ClanMenuController displayView];
    [[ClanMenuController sharedClanMenuController] loadForClan:gs.clan];
  }
}

- (IBAction)skillButtonClicked:(id)sender {
  if ([sender isKindOfClass:[UIGestureRecognizer class]]) {
    sender = [(UIGestureRecognizer *)sender view];
  }
  
  OutgoingEventController *oec = [OutgoingEventController sharedOutgoingEventController];
  
  if (sender == attackStatButton) {
    [oec addAttackSkillPoint];
    [Analytics addedSkillPoint:@"Attack"];
  }
  else if (sender == defenseStatButton) {
    [oec addDefenseSkillPoint];
    [Analytics addedSkillPoint:@"Defense"];
  }
  else if (sender == energyStatButton) {
    [oec addEnergySkillPoint];
    [Analytics addedSkillPoint:@"Energy"];
  }
  else if (sender == staminaStatButton) {
    [oec addStaminaSkillPoint];
    [Analytics addedSkillPoint:@"Stamina"];
  }
  
  [self refreshSkillPointsButtons];
  [self loadSkills];
}

- (BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
  return YES;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
  return YES;
}

// Special screen IBActions
- (IBAction)resetSkillsClicked:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  int cost = gl.diamondCostToResetSkillPoints;
  NSString *str = [NSString stringWithFormat:@"Would you like to reset your skill points%@?", cost > 0 ? [NSString stringWithFormat:@" for %d gold", cost] : @""];
  [GenericPopupController displayConfirmationWithDescription:str title:nil okayButton:@"Yes" cancelButton:@"No" target:self selector:@selector(resetSkills)];
  
  [Analytics attemptedStatReset];
}

- (void) resetSkills {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int cost = gl.diamondCostToResetSkillPoints;
  if (gs.gold >= cost) {
    [self.loadingView display:self.view];
    [[OutgoingEventController sharedOutgoingEventController] resetStats];
    [self loadSkills];
    
    [Analytics statReset];
  } else {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:cost];
  }
}

- (IBAction)changeTypeClicked:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  int cost = gl.diamondCostToChangeCharacterType;
  NSString *str = [NSString stringWithFormat:@"Would you like to change your character%@?", cost > 0 ? [NSString stringWithFormat:@" for %d gold", cost] : @""];
  [GenericPopupController displayConfirmationWithDescription:str title:nil okayButton:@"Yes" cancelButton:@"No" target:self selector:@selector(changeType)];
  
  [Analytics attemptedTypeChange];
}

- (void) changeType {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int cost = gl.diamondCostToChangeCharacterType;
  if (gs.gold >= cost) {
    // This will be released by the controller
    CharSelectionViewController *csvc = [[CharSelectionViewController alloc] initWithNibName:nil bundle:nil];
    [Globals displayUIView:csvc.view];
  } else {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:cost];
  }
}

- (IBAction)resetGame:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  int cost = gl.diamondCostToResetCharacter;
  NSString *str = [NSString stringWithFormat:@"Would you like to reset your game%@?", cost > 0 ? [NSString stringWithFormat:@" for %d gold", cost] : @""];
  [GenericPopupController displayConfirmationWithDescription:str title:nil okayButton:@"Yes" cancelButton:@"No" target:self selector:@selector(resetGame)];
  
  [Analytics attemptedResetGame];
}

- (void) resetGame {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int cost = gl.diamondCostToResetCharacter;
  if (gs.clan) {
    [Globals popupMessage:@"You must leave your clan before resetting the game."];
  } else if (gs.gold >= cost) {
    [self.loadingView display:self.view];
    [[OutgoingEventController sharedOutgoingEventController] resetGame];
    
    [Analytics resetGame];
  } else {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:cost];
  }
}

- (IBAction)prestigeClicked:(id)sender {
  NSString *str = @"Would you like to prestige for an extra equip slot?";
  [GenericPopupController displayConfirmationWithDescription:str title:nil okayButton:@"Yes" cancelButton:@"No" target:self selector:@selector(prestige)];
  
  [Analytics attemptedResetGame];
}

- (void) prestige {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  if (gs.level < gl.minLevelForPrestige) {
    [Globals popupMessage:[NSString stringWithFormat:@"You must be at least level %d to prestige.", gl.minLevelForPrestige]];
  } else if (gs.prestigeLevel >= gl.maxPrestigeLevel) {
    [Globals popupMessage:@"You have already reached the max prestige level!"];
  } else {
    [self.loadingView display:self.view];
    [[OutgoingEventController sharedOutgoingEventController] prestige];
  }
}

- (IBAction)changeName:(id)sender {
  [GenericPopupController displayNotificationViewWithMiddleView:self.nameChangeView title:@"Change Name?" okayButton:nil target:self selector:@selector(changeName)];
  [self.nameChangeTextField becomeFirstResponder];
}

- (void) changeName {
  [self.nameChangeTextField resignFirstResponder];
  
  NSString *realStr = nameChangeTextField.text;
  realStr = [realStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  Globals *gl = [Globals sharedGlobals];
  if ([gl validateUserName:realStr]) {
    int cost = gl.diamondCostToChangeName;
    NSString *str = [NSString stringWithFormat:@"Would you like to change your name%@?", cost > 0 ? [NSString stringWithFormat:@" for %d gold", cost] : @""];
    [GenericPopupController displayConfirmationWithDescription:str title:nil okayButton:@"Yes" cancelButton:@"No" target:self selector:@selector(putName)];
    
    [Analytics attemptedNameChange];
  }
}

- (void) putName {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int cost = gl.diamondCostToChangeName;
  if (gs.gold >= cost) {
    [self.loadingView display:self.view];
    [[OutgoingEventController sharedOutgoingEventController] resetName:self.nameChangeTextField.text];
    
    [Analytics nameChange];
  } else {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:cost];
  }
}

- (IBAction)prestigeInfoClicked:(id)sender {
  [FAQMenuController displayView];
  [[FAQMenuController sharedFAQMenuController] loadPrestigeInfo];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
  if ([str length] > [[Globals sharedGlobals] maxNameLength]) {
    return NO;
  }
  return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
  [UIView animateWithDuration:0.3f animations:^{
    self.nameChangeView.superview.center = ccpAdd(self.nameChangeView.superview.center, ccp(0, -75));
  }];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
  [UIView animateWithDuration:0.3f animations:^{
    self.nameChangeView.superview.center = ccpAdd(self.nameChangeView.superview.center, ccp(0, 75));
  }];
}

- (IBAction)closeClicked:(id)sender {
  [self.wallTabView endEditing];
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [ProfileViewController removeView];
  }];
  self.userId = 0;
  
  [self.equipPopup closeClicked:nil];
  
  if (_displayKiipOnClose) {
    _displayKiipOnClose = NO;
    GameState *gs = [GameState sharedGameState];
    NSArray *levelUpRewards = [[[Globals sharedGlobals] kiipRewardConditions] levelUpConditionsList];
    NSSet *levelupDict = [NSSet setWithArray:levelUpRewards];
    
    if ([levelupDict containsObject:[NSNumber numberWithInt:gs.level]]) {
      //      NSString *curAchievement = [NSString stringWithFormat:@"level_up_%d",
      //                                  gs.level];
      //      [KiipDelegate postAchievementNotificationAchievement:curAchievement];
    }
    
    // Show the level up popup here
    Globals *gl = [Globals sharedGlobals];
    if (gs.level >= gl.levelToShowRateUsPopup && gl.levelToShowRateUsPopup > 0) {
      [Globals checkRateUsPopup];
    }
  }
}

- (IBAction)chatClicked:(id)sender {
  [ChatMenuController displayView];
  [[ChatMenuController sharedChatMenuController] loadPrivateChatsForUserId:_fup.userId animated:NO];
}

- (IBAction)attackClicked:(id)sender {
  BOOL success = [[BattleLayer sharedBattleLayer] beginBattleAgainst:_fup];
  if (success) [self closeClicked:nil];
}

- (IBAction)changeButtonClicked:(id)sender {
  EquipView *v = [EquipView new];
  v.tag = 0;
  [self equipViewSelected:v];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [wallTabView endEditing];
}

- (void) didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  if (self.isViewLoaded && !self.view.superview) {
    self.view = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.fup = nil;
    self.userNameLabel = nil;
    self.typeLabel = nil;
    self.levelLabel = nil;
    self.attackLabel = nil;
    self.defenseLabel = nil;
    self.codeLabel = nil;
    self.winsLabel = nil;
    self.lossesLabel = nil;
    self.fleesLabel = nil;
    self.profilePicture = nil;
    self.profileBar = nil;
    self.equippingView = nil;
    self.skillTabView = nil;
    self.wallTabView = nil;
    self.attackStatLabel = nil;
    self.defenseStatLabel = nil;
    self.staminaStatLabel = nil;
    self.energyStatLabel = nil;
    self.attackStatButton = nil;
    self.defenseStatButton = nil;
    self.staminaStatButton = nil;
    self.energyStatButton = nil;
    self.enemyAttackLabel = nil;
    self.enemyMiddleView = nil;
    self.staminaCostLabel = nil;
    self.skillPointsLabel = nil;
    self.selfLeftView = nil;
    self.friendLeftView = nil;
    self.visitButton = nil;
    self.smallAttackButton = nil;
    self.bigAttackButton = nil;
    self.spinner = nil;
    self.mainView = nil;
    self.bgdView = nil;
    self.equipPopup = nil;
    self.specialTabView = nil;
    self.profileTabView = nil;
    self.nameChangeView = nil;
    self.nameChangeTextField = nil;
    self.noEquipButtonView = nil;
    self.noEquipLabel = nil;
    self.noEquipMiddleView = nil;
    self.clanButton = nil;
    self.clanView = nil;
    self.equipBrowseView = nil;
    self.changeButtonLabel = nil;
    self.changeButtonView = nil;
    self.equipTabView = nil;
    [_queuedEquips release];
    _queuedEquips = nil;
  }
}

@end
