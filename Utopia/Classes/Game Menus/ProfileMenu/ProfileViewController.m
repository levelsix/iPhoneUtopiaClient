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

#define EQUIPPING_DURATION 0.5f

@implementation ProfileViewController

@synthesize state = _state, curScope = _curScope;
@synthesize clanButton;
@synthesize userNameLabel, typeLabel, levelLabel, attackLabel, defenseLabel, codeLabel;
@synthesize winsLabel, lossesLabel, fleesLabel;
@synthesize profilePicture, profileBar;
@synthesize equipsTableView;
@synthesize equippingView, skillTabView, wallTabView;
@synthesize attackStatLabel, defenseStatLabel, staminaStatLabel, energyStatLabel;
@synthesize attackStatButton, defenseStatButton, staminaStatButton, energyStatButton;
@synthesize enemyAttackLabel, enemyMiddleView;
@synthesize staminaCostLabel, skillPointsLabel;
@synthesize selfLeftView, enemyLeftView, friendLeftView;
@synthesize visitButton, smallAttackButton, bigAttackButton;
@synthesize spinner;
@synthesize mainView, bgdView, loadingView;
@synthesize fup = _fup;
@synthesize userId;
@synthesize equipPopup;
@synthesize specialTabView, profileTabView;
@synthesize nameChangeView, nameChangeTextField, equipHeaderLabel;
@synthesize equipsTableDelegate;
@synthesize noEquipLabel, noEquipMiddleView, noEquipButtonView;
@synthesize clanView, equipTabView;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(ProfileViewController);

- (void) viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  equippingView = [[UIImageView alloc] init];
  equippingView.contentMode = UIViewContentModeScaleAspectFit;
  [equipTabView addSubview:equippingView];
  equippingView.hidden = YES;
  
  skillTabView.frame = profileTabView.frame;
  [self.mainView insertSubview:skillTabView aboveSubview:profileTabView];
  
  specialTabView.frame = profileTabView.frame;
  [self.mainView insertSubview:specialTabView aboveSubview:profileTabView];
  
  wallTabView.frame = profileTabView.frame;
  [self.mainView insertSubview:wallTabView aboveSubview:profileTabView];
  
  equipTabView.frame = profileTabView.frame;
  [self.mainView insertSubview:equipTabView aboveSubview:profileTabView];
  
  enemyMiddleView.frame = equipsTableView.frame;
  [equipTabView addSubview:enemyMiddleView];
  
  noEquipMiddleView.frame = equipsTableView.frame;
  [equipTabView addSubview:noEquipMiddleView];
  
  enemyLeftView.frame = selfLeftView.frame;
  [selfLeftView.superview addSubview:enemyLeftView];
  
  friendLeftView.frame = enemyLeftView.frame;
  [selfLeftView.superview addSubview:friendLeftView];
  
  // Start state at 0 so that when it gets loaded it won't be ignored
  _state = 0;
  self.state = kProfileState;
  _curScope = kEquipScopeWeapons;
  
  EquipTableViewDelegate *del = [[EquipTableViewDelegate alloc] init];
  self.equipsTableView.delegate = del;
  self.equipsTableView.dataSource = del;
  self.equipsTableDelegate = del;
  [del release];
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

- (void) setCurScope:(EquipScope)curScope {
  _curScope = curScope;
  [self updateScrollViewForCurrentScope];
  
  if (_curScope == kEquipScopeWeapons) {
    self.equipHeaderLabel.text = @"ALL WEAPONS";
  } else if (_curScope == kEquipScopeArmor) {
    self.equipHeaderLabel.text = @"ALL ARMOR";
  } else if (_curScope == kEquipScopeAmulets) {
    self.equipHeaderLabel.text = @"ALL AMULETS";
  }
}

- (void) doEquip:(UserEquip *)equip {
  FullEquipProto *fep = [[GameState sharedGameState] equipWithId:equip.equipId];
  EquipView *e = nil;
  for (EquipView *ev in equipsTableView.visibleCells) {
    if (ev.equip == equip) {
      e = ev;
    }
  }
  
  [[OutgoingEventController sharedOutgoingEventController] wearEquip:equip.userEquipId];
  if (e) {
    [self doEquippingAnimation:e forType:fep.equipType];
    
    GameState *gs = [GameState sharedGameState];
    [self.equipsTableDelegate setCurWeapon:gs.weaponEquipped curArmor:gs.armorEquipped curAmulet:gs.amuletEquipped];
    
    [self.equipsTableView reloadData];
    
    [self displayMyCurrentStats];
  }
}

- (void) doEquippingAnimation:(EquipView *)ev forType:(FullEquipProto_EquipType)type {
  Globals *gl = [Globals sharedGlobals];
  
  equippingView.frame = [equipTabView convertRect:ev.equipIcon.frame fromView:ev.equipIcon.superview];
  equippingView.image = ev.equipIcon.image;
  equippingView.hidden = NO;
  [equippingView.layer removeAllAnimations];
  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:EQUIPPING_DURATION];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(finishedEquippingAnimation)];
  
//  equippingView.frame = [equipTabView convertRect:cev.equipIcon.frame fromView:cev.equipIcon.superview];
//  
  [UIView commitAnimations];
//  cev.levelIcon.level = ev.equip.level;
//  cev.enhanceIcon.level = [gl calculateEnhancementLevel:ev.equip.enhancementPercentage];
}

- (void) finishedEquippingAnimation {
//  equippingView.hidden = YES;
//  curWeaponView.equipIcon.alpha = 1.f;
//  curArmorView.equipIcon.alpha = 1.f;
//  curAmuletView.equipIcon.alpha = 1.f;
}

- (void) equipViewSelected:(EquipView *)ev {
  GameState *gs = [GameState sharedGameState];
  UserEquip *fuep = ev.equip;
  if (profileBar.state == kMyProfile && fuep.userId == gs.userId) {
    // The fuep is actually a UserEquip.. see @selector(loadMyProfile)
    [equipPopup updateForUserEquip:(UserEquip *)fuep];
    [self.view addSubview:equipPopup];
    [Globals bounceView:equipPopup.mainView fadeInBgdView:equipPopup.bgdView];
    equipPopup.frame = self.view.bounds;
  } else {
    [EquipMenuController displayViewForEquip:fuep.equipId level:fuep.level enhancePercent:fuep.enhancementPercentage];
  }
}

- (void) currentEquipViewSelected:(EquipView *)cev {
  EquipScope scope = 0;
  
  if (cev == curWeaponView) {
    scope = kEquipScopeWeapons;
    curWeaponView.selected = YES;
    curArmorView.selected = NO;
    curAmuletView.selected = NO;
  } else if (cev == curArmorView) {
    scope = kEquipScopeArmor;
    curWeaponView.selected = NO;
    curArmorView.selected = YES;
    curAmuletView.selected = NO;
  } else if (cev == curAmuletView) {
    scope = kEquipScopeAmulets;
    curWeaponView.selected = NO;
    curArmorView.selected = NO;
    curAmuletView.selected = YES;
  } else {
    [Globals popupMessage:@"Error attaining scope value"];
  }
  
  self.curScope = scope;
  
  [self.equipsTableView setContentOffset:CGPointMake(0, -self.equipsTableView.contentInset.top) animated:YES];
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

- (void) updateScrollViewForCurrentScope {
  [self.equipsTableDelegate loadEquipsForScope:self.curScope];
  [self.equipsTableView reloadData];
  
  int numRows = [self.equipsTableView numberOfRowsInSection:0];
  if (numRows == 0) {
    GameState *gs = [GameState sharedGameState];
    
    NSString *equipType = nil;
    if (self.curScope == kEquipScopeWeapons) {
      equipType = @"Weapons";
    } else if (self.curScope == kEquipScopeArmor) {
      equipType = @"Armor";
    } else if (self.curScope == kEquipScopeAmulets) {
      equipType = @"Amulets";
    }
    
    if (self.userId == gs.userId) {
      self.noEquipMiddleView.hidden = NO;
      self.noEquipButtonView.hidden = NO;
      
      self.noEquipLabel.text = [NSString stringWithFormat:@"You do not have any %@ to equip.", equipType];
    } else if (_fup && !_waitingForEquips) {
      BOOL isEnemy = ![Globals userType:gs.type isAlliesWith:_fup.userType];
      if (!isEnemy) {
        self.noEquipMiddleView.hidden = NO;
        self.noEquipButtonView.hidden = YES;
        self.noEquipLabel.text = [NSString stringWithFormat:@"%@ does not have any %@.", _fup.name, equipType];
      } else {
        self.noEquipMiddleView.hidden = YES;
      }
    } else {
      self.noEquipMiddleView.hidden = YES;
    }
  } else {
    self.noEquipMiddleView.hidden = YES;
  }
}

- (IBAction)goToArmoryClicked:(id)sender {
  [ArmoryViewController displayView];
}

- (void) loadEquips:(NSArray *)equips curWeapon:(int)weapon curArmor:(int)armor curAmulet:(int)amulet {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  BOOL weaponFound = NO, armorFound = NO, amuletFound = NO;
  
  [curWeaponView knownEquip];
  [curArmorView knownEquip];
  [curAmuletView knownEquip];
  
  // Sort equips by equippable and then non-equippable.
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
  
  NSMutableArray *sortedEquips = [[self sortEquips:equippables].mutableCopy autorelease];
  [sortedEquips addObjectsFromArray:[self sortEquips:unequippables]];
  
  int i;
  
  for (i = 0; i < sortedEquips.count; i++) {
    UserEquip *ue = [sortedEquips objectAtIndex:i];
    FullEquipProto *fep = [gs equipWithId:ue.equipId];
    
    // check if this item is equipped
    if (ue.userEquipId == weapon && fep.equipType == FullEquipProto_EquipTypeWeapon) {
      curWeaponView.levelIcon.level = ue.level;
      curWeaponView.enhanceIcon.level = [gl calculateEnhancementLevel:ue.enhancementPercentage];
      [Globals loadImageForEquip:fep.equipId toView:curWeaponView.equipIcon maskedView:nil];
      curWeaponView.equipIcon.hidden = NO;
      weaponFound = YES;
      [sortedEquips removeObjectAtIndex:i];
      [sortedEquips insertObject:ue atIndex:0];
    } else if (ue.userEquipId == armor && fep.equipType == FullEquipProto_EquipTypeArmor) {
      curArmorView.levelIcon.level = ue.level;
      curArmorView.enhanceIcon.level = [gl calculateEnhancementLevel:ue.enhancementPercentage];
      [Globals loadImageForEquip:fep.equipId toView:curArmorView.equipIcon maskedView:nil];
      curArmorView.equipIcon.hidden = NO;
      armorFound = YES;
      [sortedEquips removeObjectAtIndex:i];
      [sortedEquips insertObject:ue atIndex:0];
    } else if (ue.userEquipId == amulet && fep.equipType == FullEquipProto_EquipTypeAmulet) {
      curAmuletView.levelIcon.level = ue.level;
      curAmuletView.enhanceIcon.level = [gl calculateEnhancementLevel:ue.enhancementPercentage];
      [Globals loadImageForEquip:fep.equipId toView:curAmuletView.equipIcon maskedView:nil];
      curAmuletView.equipIcon.hidden = NO;
      amuletFound = YES;
      [sortedEquips removeObjectAtIndex:i];
      [sortedEquips insertObject:ue atIndex:0];
    }
  }
  
  [self.equipsTableDelegate loadEquips:sortedEquips curWeapon:weapon curArmor:armor curAmulet:amulet];
  
  // Reload the cur scope
  self.curScope = self.curScope;
  
  if (!weaponFound) {
    if (weapon > 0) {
      [Globals popupMessage:@"Unable to find equipped weapon for this player"];
    }
    [curWeaponView unknownEquip];
  }
  if (!armorFound) {
    if (armor > 0) {
      [Globals popupMessage:@"Unable to find equipped armor for this player"];
    }
    [curArmorView unknownEquip];
  }
  if (!amuletFound) {
    if (amulet > 0) {
      [Globals popupMessage:@"Unable to find equipped amulet for this player"];
    }
    [curAmuletView unknownEquip];
  }
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
  
  equipsTableView.hidden = isEnemy;
  enemyMiddleView.hidden = !isEnemy;
  
  enemyLeftView.hidden = !isEnemy;
  friendLeftView.hidden = isEnemy;
  selfLeftView.hidden = YES;
  
  [self loadEquips:nil curWeapon:0 curArmor:0 curAmulet:0];
  
  enemyAttackLabel.text = [NSString stringWithFormat:@"Attack %@ to see Equipment", fup.name];
  
  self.profileBar.state = kOtherPlayerProfile;
  [self.profileBar setProfileState:self.state];
  
  visitButton.enabled = enabled;
  smallAttackButton.enabled = enabled;
  bigAttackButton.enabled = enabled;
  
  curWeaponView.selected = YES;
  curArmorView.selected = NO;
  curAmuletView.selected = NO;
  self.curScope = kEquipScopeWeapons;
  
  if (self.state == kSkillsState || self.state == kSpecialState) {
    self.state = kProfileState;
  }
  
  if (!isEnemy && !_waitingForEquips) {
    _waitingForEquips = YES;
    [[OutgoingEventController sharedOutgoingEventController] retrieveEquipsForUser:fup.userId];
    [spinner startAnimating];
    self.spinner.hidden = NO;
  } else {
    [spinner stopAnimating];
    self.spinner.hidden = YES;
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
  
  equipsTableView.hidden = NO;
  enemyMiddleView.hidden = YES;
  Globals *globals = [Globals sharedGlobals];
  attack  = [globals calculateAttackForAttackStat:_fup.attack
                                           weapon:_fup.hasWeaponEquippedUserEquip ? (UserEquip *)_fup.weaponEquippedUserEquip : nil
                                            armor:_fup.hasArmorEquippedUserEquip ? (UserEquip *)_fup.armorEquippedUserEquip : nil
                                           amulet:_fup.hasAmuletEquippedUserEquip ? (UserEquip *)_fup.amuletEquippedUserEquip : nil];
  
  defense = [globals calculateDefenseForDefenseStat:_fup.defense
                                             weapon:_fup.hasWeaponEquippedUserEquip ? (UserEquip *)_fup.weaponEquippedUserEquip : nil
                                              armor:_fup.hasArmorEquippedUserEquip ? (UserEquip *)_fup.armorEquippedUserEquip : nil
                                             amulet:_fup.hasAmuletEquippedUserEquip ? (UserEquip *)_fup.amuletEquippedUserEquip : nil];
  attackLabel.text = [NSString stringWithFormat:@"%d", attack];
  defenseLabel.text = [NSString stringWithFormat:@"%d", defense];
  
  if (fup.isFake) {
    equips = [self createFakeEquipsForFakePlayer:fup];
  } else if (equips) {
    equips = [self userEquipArrayFromFullUserEquipProtos:equips];
  }
  
  if (equips) {
    [self loadEquips:equips curWeapon:fup.weaponEquippedUserEquip.userEquipId curArmor:fup.armorEquippedUserEquip.userEquipId curAmulet:fup.amuletEquippedUserEquip.userEquipId];
  } else {
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
          
          [self loadEquips:nil curWeapon:0 curArmor:0 curAmulet:0];
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
    [self loadEquips:[self userEquipArrayFromFullUserEquipProtos:equips] curWeapon:_fup.weaponEquippedUserEquip.userEquipId curArmor:_fup.armorEquippedUserEquip.userEquipId curAmulet:_fup.amuletEquippedUserEquip.userEquipId];
    
    self.spinner.hidden = YES;
    [self.spinner stopAnimating];
    
    Globals *gl = [Globals sharedGlobals];
    UserEquip *weapon = _fup.hasWeaponEquippedUserEquip ? (UserEquip *)_fup.weaponEquippedUserEquip : nil;
    UserEquip *armor = _fup.hasArmorEquippedUserEquip ? (UserEquip *)_fup.armorEquippedUserEquip : nil;
    UserEquip *amulet = _fup.hasAmuletEquippedUserEquip ? (UserEquip *)_fup.amuletEquippedUserEquip : nil;
    attackLabel.text = [NSString stringWithFormat:@"%d", (int)[gl calculateAttackForAttackStat:_fup.attack weapon:weapon armor:armor amulet:amulet]];
    defenseLabel.text = [NSString stringWithFormat:@"%d", (int)[gl calculateDefenseForDefenseStat:_fup.defense weapon:weapon armor:armor amulet:amulet]];
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
  enemyLeftView.hidden = YES;
  friendLeftView.hidden = YES;
  
  wallTabView.wallPosts = nil;
  
  [self loadEquips:nil curWeapon:0 curArmor:0 curAmulet:0];
  
  // Make equip spinner spin
  self.enemyMiddleView.hidden = YES;
  self.spinner.hidden = NO;
  [self.spinner startAnimating];
  
  [ProfileViewController displayView];
}

- (void) displayMyCurrentStats {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserEquip *weaponEquipped = [gs myEquipWithUserEquipId:gs.weaponEquipped];
  UserEquip *armorEquipped = [gs myEquipWithUserEquipId:gs.armorEquipped];
  UserEquip *amuletEquipped = [gs myEquipWithUserEquipId:gs.amuletEquipped];
  attackLabel.text = [NSString stringWithFormat:@"%d", (int)[gl calculateAttackForAttackStat:gs.attack weapon:weaponEquipped armor:armorEquipped amulet:amuletEquipped]];
  defenseLabel.text = [NSString stringWithFormat:@"%d", (int)[gl calculateDefenseForDefenseStat:gs.defense weapon:weaponEquipped armor:armorEquipped amulet:amuletEquipped]];
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
  
  [self displayMyCurrentStats];
  
  [self loadEquips:gs.myEquips curWeapon:gs.weaponEquipped curArmor:gs.armorEquipped curAmulet:gs.amuletEquipped];
  
  if (self.profileBar.state != kMyProfile) {
    self.profileBar.state = kMyProfile;
    self.state = kProfileState;
    
    curWeaponView.selected = YES;
    curArmorView.selected = NO;
    curAmuletView.selected = NO;
    self.curScope = kEquipScopeWeapons;
  }
  [self loadSkills];
  
  equipsTableView.hidden = NO;
  enemyMiddleView.hidden = YES;
  
  self.spinner.hidden = YES;
  [self.spinner stopAnimating];
  
  enemyLeftView.hidden = YES;
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
  if (gs.level < gl.minLevelConstants.clanHouseMinLevel) {
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
  [self displayMyCurrentStats];
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

- (IBAction)visitClicked:(id)sender {
  [Globals popupMessage:@"Sorry, visiting another player's city is coming soon!"];
  [Analytics clickedVisitCity];
}

- (IBAction)attackClicked:(id)sender {
  BOOL success = [[BattleLayer sharedBattleLayer] beginBattleAgainst:_fup];
  if (success) [self closeClicked:nil];
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
    self.curArmorView = nil;
    self.curAmuletView = nil;
    self.curWeaponView = nil;
    self.profilePicture = nil;
    self.profileBar = nil;
    self.equipsTableView = nil;
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
    self.enemyLeftView = nil;
    self.friendLeftView = nil;
    self.visitButton = nil;
    self.smallAttackButton = nil;
    self.bigAttackButton = nil;
    self.equipsTableDelegate = nil;
    self.spinner = nil;
    self.mainView = nil;
    self.bgdView = nil;
    self.equipPopup = nil;
    self.specialTabView = nil;
    self.profileTabView = nil;
    self.nameChangeView = nil;
    self.nameChangeTextField = nil;
    self.equipHeaderLabel = nil;
    self.noEquipButtonView = nil;
    self.noEquipLabel = nil;
    self.noEquipMiddleView = nil;
    self.clanButton = nil;
    self.clanView = nil;
    [_queuedEquips release];
    _queuedEquips = nil;
  }
}

@end
