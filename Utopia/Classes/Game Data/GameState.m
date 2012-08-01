//
//  GameState.m
//  Utopia
//
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "GameState.h"
#import "LNSynthesizeSingleton.h"
#import "SocketCommunication.h"
#import "Globals.h"
#import "OutgoingEventController.h"
#import "TopBar.h"
#import "ActivityFeedController.h"
#import "ProfileViewController.h"
#import "ForgeMenuController.h"

#define TagLog(...) ContextLogInfo(LN_CONTEXT_TAGS, __VA_ARGS__)

@implementation GameState

@synthesize isTutorial = _isTutorial;
@synthesize connected = _connected;
@synthesize userId = _userId;
@synthesize name = _name;
@synthesize type = _type;
@synthesize level = _level;
@synthesize defense = _defense;
@synthesize attack = _attack;
@synthesize currentEnergy = _currentEnergy;
@synthesize maxEnergy = _maxEnergy;
@synthesize currentStamina = _currentStamina;
@synthesize maxStamina = _maxStamina;
@synthesize gold = _gold;
@synthesize silver = _silver;
@synthesize vaultBalance = _vaultBalance;
@synthesize referralCode = _referralCode;
@synthesize battlesWon = _battlesWon;
@synthesize battlesLost = _battlesLost;
@synthesize flees = _flees;
@synthesize location = _location;
@synthesize numReferrals = _numReferrals;
@synthesize experience = _experience;
@synthesize tasksCompleted = _tasksCompleted;
@synthesize skillPoints = _skillPoints;
@synthesize marketplaceSilverEarnings = _marketplaceSilverEarnings;
@synthesize marketplaceGoldEarnings = _marketplaceGoldEarnings;
@synthesize numPostsInMarketplace = _numPostsInMarketplace;
@synthesize numMarketplaceSalesUnredeemed = _numMarketplaceSalesUnredeemed;
@synthesize weaponEquipped = _weaponEquipped;
@synthesize armorEquipped = _armorEquipped;
@synthesize amuletEquipped = _amuletEquipped;
@synthesize playerHasBoughtInAppPurchase = _playerHasBoughtInAppPurchase;
@synthesize lastEnergyRefill = _lastEnergyRefill;
@synthesize lastStaminaRefill = _lastStaminaRefill;
@synthesize lastShortLicensePurchaseTime = _lastShortLicensePurchaseTime;
@synthesize lastLongLicensePurchaseTime = _lastLongLicensePurchaseTime;

@synthesize deviceToken = _deviceToken;

@synthesize maxCity = _maxCity;
@synthesize expRequiredForCurrentLevel = _expRequiredForCurrentLevel;
@synthesize expRequiredForNextLevel = _expRequiredForNextLevel;

@synthesize marketplaceEquipPosts = _marketplaceEquipPosts;
@synthesize marketplaceEquipPostsFromSender = _marketplaceEquipPostsFromSender;

@synthesize staticTasks = _staticTasks;
@synthesize staticCities = _staticCities;
@synthesize staticEquips = _staticEquips;
@synthesize staticQuests = _staticQuests;
@synthesize staticStructs = _staticStructs;
@synthesize staticDefeatTypeJobs = _staticDefeatTypeJobs;
@synthesize staticBuildStructJobs = _staticBuildStructJobs;
@synthesize staticPossessEquipJobs = _staticPossessEquipJobs;
@synthesize staticUpgradeStructJobs = _staticUpgradeStructJobs;

@synthesize carpenterStructs = _carpenterStructs;
@synthesize armoryWeapons = _armoryWeapons;
@synthesize armoryArmor = _armoryArmor;
@synthesize armoryAmulets = _armoryAmulets;

@synthesize myEquips = _myEquips;
@synthesize myStructs = _myStructs;
@synthesize myCities = _myCities;

@synthesize availableQuests = _availableQuests;
@synthesize inProgressCompleteQuests = _inProgressCompleteQuests;
@synthesize inProgressIncompleteQuests = _inProgressIncompleteQuests;

@synthesize attackList = _attackList;
@synthesize notifications = _notifications;
@synthesize wallPosts = _wallPosts;

@synthesize lastLogoutTime = _lastLogoutTime;

@synthesize allies = _allies;

@synthesize unrespondedUpdates = _unrespondedUpdates;

@synthesize forgeAttempt = _forgeAttempt;

SYNTHESIZE_SINGLETON_FOR_CLASS(GameState);

- (id) init {
  if ((self = [super init])) {
    _connected = NO;
    _marketplaceEquipPosts = [[NSMutableArray alloc] init];
    _marketplaceEquipPostsFromSender = [[NSMutableArray alloc] init];
    _staticTasks = [[NSMutableDictionary alloc] init];
    _staticCities = [[NSMutableDictionary alloc] init];
    _staticEquips = [[NSMutableDictionary alloc] init];
    _staticQuests = [[NSMutableDictionary alloc] init];
    _staticStructs = [[NSMutableDictionary alloc] init];
    _staticDefeatTypeJobs = [[NSMutableDictionary alloc] init];
    _staticBuildStructJobs = [[NSMutableDictionary alloc] init];
    _staticPossessEquipJobs = [[NSMutableDictionary alloc] init];
    _staticUpgradeStructJobs = [[NSMutableDictionary alloc] init];
    _attackList = [[NSMutableArray alloc] init];
    _notifications = [[NSMutableArray alloc] init];
    _myEquips = [[NSMutableArray alloc] init];
    _myStructs = [[NSMutableArray alloc] init];
    _myCities = [[NSMutableDictionary alloc] init];
    _wallPosts = [[NSMutableArray alloc] init];
    
    _availableQuests = [[NSMutableDictionary alloc] init];
    _inProgressCompleteQuests = [[NSMutableDictionary alloc] init];
    _inProgressIncompleteQuests = [[NSMutableDictionary alloc] init];
    
    _unrespondedUpdates = [[NSMutableArray alloc] init];
    
    _silver = 10000;
    _gold = 50;
    _vaultBalance = 2500;
    _currentEnergy = 1;
    _maxEnergy = 3;
    _currentStamina = 1;
    _maxStamina = 3;
    _level = 12;
    _experience = 30;
    _expRequiredForNextLevel = 40;
  }
  return self;
}

- (void) updateUser:(FullUserProto *)user timestamp:(uint64_t)time {
  if (time == 0) {
    // Special case: if time is 0, let it go through automatically
    _lastUserUpdate = 0;
  } else if (time <= _lastUserUpdate) {
    return;
  } else {
    _lastUserUpdate = time;
  }
  
  // Copy over data from full user proto
  if (_userId != user.userId || ![_name isEqualToString:user.name] || _type != user.userType) {
    self.userId = user.userId;
    self.name = user.name;
    self.type = user.userType;
    [[SocketCommunication sharedSocketCommunication] rebuildSender];
  }
  self.level = user.level;
  self.defense = user.defense;
  self.attack = user.attack;
  self.currentEnergy = user.energy;
  self.maxEnergy = user.energyMax;
  self.currentStamina = user.stamina;
  self.maxStamina = user.staminaMax;
  self.skillPoints = user.skillPoints;
  self.gold = user.diamonds;
  self.silver = user.coins;
  self.vaultBalance = user.vaultBalance;
  self.experience = user.experience;
  self.tasksCompleted = user.tasksCompleted;
  self.battlesWon = user.battlesWon;
  self.battlesLost = user.battlesLost;
  self.flees = user.flees;
  self.referralCode = user.referralCode;
  self.numReferrals = user.numReferrals;
  self.marketplaceGoldEarnings = user.marketplaceDiamondsEarnings;
  self.marketplaceSilverEarnings = user.marketplaceCoinsEarnings;
  self.numPostsInMarketplace = user.numPostsInMarketplace;
  self.numMarketplaceSalesUnredeemed = user.numMarketplaceSalesUnredeemed;
  self.weaponEquipped = user.weaponEquippedUserEquip.userEquipId;
  self.armorEquipped = user.armorEquippedUserEquip.userEquipId;
  self.amuletEquipped = user.amuletEquippedUserEquip.userEquipId;
  self.location = CLLocationCoordinate2DMake(user.userLocation.latitude, user.userLocation.longitude);
  
  NSTimeInterval t = user.lastEnergyRefillTime/1000.0;
  self.lastEnergyRefill = [NSDate dateWithTimeIntervalSince1970:t];
  self.lastStaminaRefill = [NSDate dateWithTimeIntervalSince1970:user.lastStaminaRefillTime/1000.0];
  self.lastShortLicensePurchaseTime = [NSDate dateWithTimeIntervalSince1970:user.lastShortLicensePurchaseTime/1000.0];
  self.lastLongLicensePurchaseTime = [NSDate dateWithTimeIntervalSince1970:user.lastLongLicensePurchaseTime/1000.0];
  
  self.lastLogoutTime = [NSDate dateWithTimeIntervalSince1970:user.lastLogoutTime/1000.0];
  
  [[TopBar sharedTopBar] setUpEnergyTimer];
  [[TopBar sharedTopBar] setUpStaminaTimer];
  
  for (id<GameStateUpdate> gsu in _unrespondedUpdates) {
    if ([gsu respondsToSelector:@selector(update)]) {
      [gsu update];
    }
  }
}

- (id) getStaticDataFrom:(NSDictionary *)dict withId:(int)itemId {
  if (itemId == 0) {
    [Globals popupMessage:@"Attempted to access static item 0"];
    return nil;
  }
  NSNumber *num = [NSNumber numberWithInt:itemId];
  id p = [dict objectForKey:num];
  int numTimes = 0;
  while (!p) {
    numTimes++;
    if (numTimes == 1000) {
      ContextLogWarn(LN_CONTEXT_GAMESTATE, @"Lotsa wait time for this");
    }
    //    NSAssert(numTimes < 1000000, @"Waiting too long for static data.. Probably not retrieved!", itemId);
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    // Need this in case game state gets deallocated while waiting for static data
    p = [dict objectForKey:num];
  }
  // Retain and autorelease in case data gets purged
  [p retain];
  return [p autorelease];
}

- (int) weaponEquippedId {
  return [self myEquipWithUserEquipId:_weaponEquipped].equipId;
}

- (int) armorEquippedId {
  return [self myEquipWithUserEquipId:_armorEquipped].equipId;
}

- (int) amuletEquippedId {
  return [self myEquipWithUserEquipId:_amuletEquipped].equipId;
}

- (FullEquipProto *) equipWithId:(int)equipId {
  if (equipId == 0) {
    [Globals popupMessage:@"Attempted to access equip 0"];
    return nil;
  }
  return [self getStaticDataFrom:_staticEquips withId:equipId];
}

- (FullStructureProto *) structWithId:(int)structId {
  if (structId == 0) {
    [Globals popupMessage:@"Attempted to access struct 0"];
    return nil;
  }
  return [self getStaticDataFrom:_staticStructs withId:structId];
}

- (FullCityProto *) cityWithId:(int)cityId {
  if (cityId == 0) {
    [Globals popupMessage:@"Attempted to access city 0"];
    return nil;
  }
  return [self getStaticDataFrom:_staticCities withId:cityId];
}

- (FullTaskProto *) taskWithId:(int)taskId {
  if (taskId == 0) {
    [Globals popupMessage:@"Attempted to access task 0"];
    return nil;
  }
  return [self getStaticDataFrom:_staticTasks withId:taskId];
}

- (void) addToMyEquips:(NSArray *)equips {
  for (FullUserEquipProto *eq in equips) {
    [self.myEquips addObject:[UserEquip userEquipWithProto:eq]];
  }
}

- (void) addToMyStructs:(NSArray *)structs {
  for (FullUserStructureProto *st in structs) {
    [self.myStructs addObject:[UserStruct userStructWithProto:st]];
  }
}

- (void) addToMyCities:(NSArray *)cities {
  for (FullUserCityProto *cit in cities) {
    [self.myCities setObject:[UserCity userCityWithProto:cit] forKey:[NSNumber numberWithInt:cit.cityId]];
  }
}

- (void) addToAvailableQuests:(NSArray *)quests {
  for (FullQuestProto *fqp in quests) {
    [self.availableQuests setObject:fqp forKey:[NSNumber numberWithInt:fqp.questId]];
  }
  
  [[TopBar sharedTopBar] displayNewQuestArrow];
}

- (void) addToInProgressCompleteQuests:(NSArray *)quests {
  for (FullQuestProto *fqp in quests) {
    [self.inProgressCompleteQuests setObject:fqp forKey:[NSNumber numberWithInt:fqp.questId]];
  }
}

- (void) addToInProgressIncompleteQuests:(NSArray *)quests {
  for (FullQuestProto *fqp in quests) {
    [self.inProgressIncompleteQuests setObject:fqp forKey:[NSNumber numberWithInt:fqp.questId]];
  }
}

- (void) addNotification:(UserNotification *)un {
  [self.notifications addObject:un];
  [self.notifications sortUsingComparator:^NSComparisonResult(UserNotification *obj1, UserNotification *obj2) {
    return [obj2.time compare:obj1.time];
  }];
  
  if ([un.time compare:_lastLogoutTime] == NSOrderedDescending) {
    un.hasBeenViewed = NO;
  } else {
    un.hasBeenViewed = YES;
  }
  
  [[[ActivityFeedController sharedActivityFeedController] activityTableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
  
  if (!_isTutorial) {
    GameState *gs = [GameState sharedGameState];
    if ([un.time compare:gs.lastLogoutTime] == NSOrderedDescending) {
      // If top bar hasnt started, the activity feed will popup anyways so no need to increment badge.
      if ([[TopBar sharedTopBar] isStarted]) {
        ForgeMenuController *fmc = [ForgeMenuController sharedForgeMenuController];
        if (fmc.view.superview && un.type == kNotificationForge) {
          un.hasBeenViewed = YES;
        } else {
          [[[TopBar sharedTopBar] profilePic] incrementNotificationBadge];
        }
      }
    }
  }
}

- (void) addWallPost:(PlayerWallPostProto *)wallPost {
  [self.wallPosts addObject:wallPost];
  [self.wallPosts sortUsingComparator:^NSComparisonResult(PlayerWallPostProto *obj1, PlayerWallPostProto *obj2) {
    if (obj1.timeOfPost < obj2.timeOfPost) {
      return NSOrderedDescending;
    } else if (obj1.timeOfPost == obj2.timeOfPost) {
      return NSOrderedSame;
    } else {
      return NSOrderedAscending;
    }
  }];
  
  if (!_isTutorial) {
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:wallPost.timeOfPost/1000.0];
    if ([time compare:_lastLogoutTime] == NSOrderedDescending) {
      [[[TopBar sharedTopBar] profilePic] incrementProfileBadge];
      
      ProfileViewController *pvc = [ProfileViewController sharedProfileViewController];
      [pvc.wallTabView displayNewWallPost];
    }
  }
}

- (UserEquip *) myEquipWithId:(int)equipId level:(int)level {
  for (UserEquip *ue in self.myEquips) {
    if (ue.equipId == equipId && ue.level == level) {
      return ue;
    }
  }
  return nil;
}

- (NSArray *) myEquipsWithId:(int)equipId level:(int)level {
  NSMutableArray *array = [NSMutableArray array];
  for (UserEquip *ue in self.myEquips) {
    if (ue.equipId == equipId && ue.level == level) {
      [array addObject:ue];
    }
  }
  return array;
}

- (UserEquip *) myEquipWithUserEquipId:(int)userEquipId {
  for (UserEquip *ue in self.myEquips) {
      if (userEquipId == ue.userEquipId) {
        return ue;
      }
  }
  return nil;
}

- (int) quantityOfEquip:(int)equipId {
  int quantity = 0;
  for (UserEquip *ue in _myEquips) {
    if (ue.equipId == equipId) {
      quantity += 1;
    }
  }
  return quantity;
}

- (int) quantityOfEquip:(int)equipId level:(int)level {
  int quantity = 0;
  for (UserEquip *ue in _myEquips) {
    if (ue.equipId == equipId && ue.level == level) {
      quantity += ue.equipId;
    }
  }
  return quantity;
}

- (UserStruct *) myStructWithId:(int)structId {
  for (UserStruct *us in self.myStructs) {
    if (us.structId == structId) {
      return us;
    }
  }
  return nil;
}

- (UserCity *) myCityWithId:(int)cityId {
  return [self.myCities objectForKey:[NSNumber numberWithInt:cityId]];
}

- (void) addToStaticStructs:(NSArray *)arr {
  for (FullStructureProto *p in arr) {
    [self.staticStructs setObject:p forKey:[NSNumber numberWithInt:p.structId]];
  }
}

- (void) addToStaticTasks:(NSArray *)arr {
  for (FullTaskProto *p in arr) {
    [self.staticTasks setObject:p forKey:[NSNumber numberWithInt:p.taskId]];
  }
}

- (void) addToStaticQuests:(NSArray *)arr {
  for (FullQuestProto *p in arr) {
    [self.staticQuests setObject:p forKey:[NSNumber numberWithInt:p.questId]];
  }
}

- (void) addToStaticCities:(NSArray *)arr {
  for (FullCityProto *p in arr) {
    [self.staticCities setObject:p forKey:[NSNumber numberWithInt:p.cityId]];
    if (p.cityId > _maxCity) {
      _maxCity = p.cityId;
    }
  }
}

- (void) addToStaticEquips:(NSArray *)arr {
  for (FullEquipProto *p in arr) {
    [self.staticEquips setObject:p forKey:[NSNumber numberWithInt:p.equipId]];
  }
}

- (void) addToStaticBuildStructJobs:(NSArray *)arr {
  for (BuildStructJobProto *p in arr) {
    [self.staticBuildStructJobs setObject:p forKey:[NSNumber numberWithInt:p.buildStructJobId]];
  }
}

- (void) addToStaticDefeatTypeJobs:(NSArray *)arr {
  for (DefeatTypeJobProto *p in arr) {
    [self.staticDefeatTypeJobs setObject:p forKey:[NSNumber numberWithInt:p.defeatTypeJobId]];
  }
}

- (void) addToStaticPossessEquipJobs:(NSArray *)arr {
  for (PossessEquipJobProto *p in arr) {
    [self.staticPossessEquipJobs setObject:p forKey:[NSNumber numberWithInt:p.possessEquipJobId]];
  }
}

- (void) addToStaticUpgradeStructJobs:(NSArray *)arr {
  for (UpgradeStructJobProto *p in arr) {
    [self.staticUpgradeStructJobs setObject:p forKey:[NSNumber numberWithInt:p.upgradeStructJobId]];
  }
}

- (FullQuestProto *) questForQuestId:(int)questId {
  NSNumber *num = [NSNumber numberWithInt:questId];
  FullQuestProto *fqp = [_availableQuests objectForKey:num];
  fqp = fqp ? fqp : [_inProgressCompleteQuests objectForKey:num];
  fqp = fqp ? fqp : [_inProgressIncompleteQuests objectForKey:num];
  return fqp;
}

- (BOOL) hasValidLicense {
  return YES;
  //  Globals *gl = [Globals sharedGlobals];
  //  
  //  NSTimeInterval shortLic = [self.lastShortLicensePurchaseTime timeIntervalSinceNow];
  //  NSTimeInterval time = -((NSTimeInterval)gl.numDaysShortMarketplaceLicenseLastsFor)*24*60*60;
  //  if (shortLic > time) {
  //    return YES;
  //  }
  //  
  //  NSTimeInterval longLic = [self.lastLongLicensePurchaseTime timeIntervalSinceNow];
  //  time = -gl.numDaysLongMarketplaceLicenseLastsFor*24l*60l*60l;
  //  if (longLic > time) {
  //    return YES;
  //  }
  //  
  //  return NO;
}

- (void) addUnrespondedUpdate:(id<GameStateUpdate>)up {
  [_unrespondedUpdates addObject:up];
  
  if ([up respondsToSelector:@selector(update)]) {
    [up update];
  }
  
  TagLog(@"Added %@ for tag %d", NSStringFromClass([up class]), up.tag);
}

- (void) addUnrespondedUpdates:(id<GameStateUpdate>)field1, ...
{
	va_list params;
	va_start(params,field1);
	
  for (id<GameStateUpdate> arg = field1; arg != nil; arg = va_arg(params, id<GameStateUpdate>))
  {
    [self addUnrespondedUpdate:arg];
  }
  va_end(params);
}

- (void) removeAndUndoAllUpdatesForTag:(int)tag {
  NSMutableArray *updates = [NSMutableArray array];
  for (id<GameStateUpdate> update in _unrespondedUpdates) {
    if (update.tag == tag) {
      if ([update respondsToSelector:@selector(undo)]) {
        [update undo];
      }
      [updates addObject:update];
    }
  }
  
  for (id<GameStateUpdate> update in updates) {
    [_unrespondedUpdates removeObject:update];
    TagLog(@"Removed and undid %@ for tag %d", NSStringFromClass([update class]), update.tag);
  }
}

- (void) removeFullUserUpdatesForTag:(int)tag {
  NSMutableArray *updates = [NSMutableArray array];
  for (id<GameStateUpdate> update in _unrespondedUpdates) {
    if (update.tag == tag && [update isKindOfClass:[FullUserUpdate class]]) {
      [updates addObject:update];
    }
  }
  
  for (id<GameStateUpdate> update in updates) {
    [_unrespondedUpdates removeObject:update];
    TagLog(@"Removed full user %@ for tag %d", NSStringFromClass([update class]), update.tag);
  }
}

- (void) removeNonFullUserUpdatesForTag:(int)tag {
  NSMutableArray *updates = [NSMutableArray array];
  for (id<GameStateUpdate> update in _unrespondedUpdates) {
    if (update.tag == tag && ![update isKindOfClass:[FullUserUpdate class]]) {
      [updates addObject:update];
    }
  }
  
  for (id<GameStateUpdate> update in updates) {
    [_unrespondedUpdates removeObject:update];
    TagLog(@"Removed non full user %@ for tag %d", NSStringFromClass([update class]), update.tag);
  }
}

- (void) beginForgeTimer {
  [self stopForgeTimer];
  Globals *gl = [Globals sharedGlobals];
  ForgeAttempt *fa = self.forgeAttempt;
  
  if (!fa.isComplete) {
    float seconds = [gl calculateMinutesForForge:fa.equipId level:fa.level]*60.f;
    NSDate *endTime = [fa.startTime dateByAddingTimeInterval:seconds];
    
    if ([endTime compare:[NSDate date]] == NSOrderedDescending) {
      _forgeTimer = [[NSTimer timerWithTimeInterval:  endTime.timeIntervalSinceNow target:self selector:@selector(forgeWaitTimeComplete) userInfo:nil repeats:NO] retain];
      [[NSRunLoop mainRunLoop] addTimer:_forgeTimer forMode:NSRunLoopCommonModes];
    } else {
      [self forgeWaitTimeComplete];
    }
  } else {
    UserNotification *un = [[UserNotification alloc] initWithForgeAttempt:self.forgeAttempt];
    [self addNotification:un];
    [un release];
  }
}

- (void) forgeWaitTimeComplete {
  [[OutgoingEventController sharedOutgoingEventController] forgeAttemptWaitComplete];
}

- (void) stopForgeTimer {
  if (_forgeTimer) {
    [_forgeTimer invalidate];
    [_forgeTimer release];
    _forgeTimer = nil;
  }
}

- (void) purgeStaticData {
  [_staticQuests removeAllObjects];
  [_staticBuildStructJobs removeAllObjects];
  [_staticDefeatTypeJobs removeAllObjects];
  [_staticPossessEquipJobs removeAllObjects];
  [_staticUpgradeStructJobs removeAllObjects];
  
  // Reretrieve necessary data
  [[OutgoingEventController sharedOutgoingEventController] retrieveAllStaticData];
}

- (void) reretrieveStaticData {
  [[SocketCommunication sharedSocketCommunication] sendRetrieveStaticDataMessageWithStructIds:_staticStructs.allKeys taskIds:_staticTasks.allKeys questIds:_staticQuests.allKeys cityIds:_staticCities.allKeys equipIds:_staticEquips.allKeys buildStructJobIds:_staticBuildStructJobs.allKeys defeatTypeJobIds:_staticDefeatTypeJobs.allKeys possessEquipJobIds:_staticPossessEquipJobs.allKeys upgradeStructJobIds:_staticUpgradeStructJobs.allKeys];
  
  [_staticStructs removeAllObjects];
  [_staticEquips removeAllObjects];
  [_staticTasks removeAllObjects];
  [_staticCities removeAllObjects];
  [_staticQuests removeAllObjects];
  [_staticBuildStructJobs removeAllObjects];
  [_staticDefeatTypeJobs removeAllObjects];
  [_staticPossessEquipJobs removeAllObjects];
  [_staticUpgradeStructJobs removeAllObjects];
}

- (void) clearAllData {
  _connected = NO;
  self.marketplaceEquipPosts = [[[NSMutableArray alloc] init] autorelease];
  self.marketplaceEquipPostsFromSender = [[[NSMutableArray alloc] init] autorelease];
  self.staticTasks = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticCities = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticEquips = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticQuests = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticStructs = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticDefeatTypeJobs = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticBuildStructJobs = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticPossessEquipJobs = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticUpgradeStructJobs = [[[NSMutableDictionary alloc] init] autorelease];
  self.attackList = [[[NSMutableArray alloc] init] autorelease];
  self.notifications = [[[NSMutableArray alloc] init] autorelease];
  self.myEquips = [[[NSMutableArray alloc] init] autorelease];
  self.myStructs = [[[NSMutableArray alloc] init] autorelease];
  self.myCities = [[[NSMutableDictionary alloc] init] autorelease];
  self.wallPosts = [[[NSMutableArray alloc] init] autorelease];
  
  self.availableQuests = [[[NSMutableDictionary alloc] init] autorelease];
  self.inProgressCompleteQuests = [[[NSMutableDictionary alloc] init] autorelease];
  self.inProgressIncompleteQuests = [[[NSMutableDictionary alloc] init] autorelease];
  
  [self stopForgeTimer];
  self.forgeAttempt = nil;
}

- (void) dealloc {
  self.name = nil;
  self.referralCode = nil;
  self.carpenterStructs = nil;
  self.armoryWeapons = nil;
  self.armoryArmor = nil;
  self.armoryAmulets = nil;
  self.lastEnergyRefill = nil;
  self.lastStaminaRefill = nil;
  self.marketplaceEquipPosts = nil;
  self.marketplaceEquipPostsFromSender = nil;
  self.lastShortLicensePurchaseTime = nil;
  self.lastLongLicensePurchaseTime = nil;
  self.staticTasks = nil;
  self.staticCities = nil;
  self.staticEquips = nil;
  self.staticQuests = nil;
  self.staticStructs = nil;
  self.staticDefeatTypeJobs = nil;
  self.staticBuildStructJobs = nil;
  self.staticPossessEquipJobs = nil;
  self.staticUpgradeStructJobs = nil;
  self.myCities = nil;
  self.myEquips = nil;
  self.myStructs = nil;
  self.availableQuests = nil;
  self.inProgressCompleteQuests = nil;
  self.inProgressIncompleteQuests = nil;
  self.attackList = nil;
  self.notifications = nil;
  self.wallPosts = nil;
  self.lastLogoutTime = nil;
  self.unrespondedUpdates = nil;
  self.deviceToken = nil;
  self.allies = nil;
  self.forgeAttempt = nil;
  [super dealloc];
}

@end
