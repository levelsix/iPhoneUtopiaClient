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
#import "ChatMenuController.h"
#import "AppDelegate.h"
#import "BazaarMap.h"
#import "HomeMap.h"
#import "GoldShoppeViewController.h"
#import "ClanMenuController.h"
#import "Downloader.h"
#import "ArmoryViewController.h"
#import "GameLayer.h"

#define TagLog(...) //LNLog(__VA_ARGS__)

#define PURGE_EQUIP_KEY @"Purge Equip Images"

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
@synthesize playerHasBoughtInAppPurchase = _playerHasBoughtInAppPurchase;
@synthesize lastEnergyRefill = _lastEnergyRefill;
@synthesize lastStaminaRefill = _lastStaminaRefill;
@synthesize lastShortLicensePurchaseTime = _lastShortLicensePurchaseTime;
@synthesize lastLongLicensePurchaseTime = _lastLongLicensePurchaseTime;
@synthesize numAdColonyVideosWatched = _numAdColonyVideosWatched;
@synthesize numGroupChatsRemaining = _numGroupChatsRemaining;
@synthesize isAdmin = _isAdmin;

@synthesize deviceToken = _deviceToken;

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
@synthesize staticLockBoxEvents = _staticLockBoxEvents;
@synthesize staticGoldSales = _staticGoldSales;

@synthesize carpenterStructs = _carpenterStructs;
@synthesize armoryWeapons = _armoryWeapons;
@synthesize armoryArmor = _armoryArmor;
@synthesize armoryAmulets = _armoryAmulets;

@synthesize myEquips = _myEquips;
@synthesize myStructs = _myStructs;
@synthesize myCities = _myCities;
@synthesize myLockBoxEvents = _myLockBoxEvents;
@synthesize lockBoxEventTimers = _lockBoxEventTimers;

@synthesize availableQuests = _availableQuests;
@synthesize inProgressCompleteQuests = _inProgressCompleteQuests;
@synthesize inProgressIncompleteQuests = _inProgressIncompleteQuests;

@synthesize notifications = _notifications;
@synthesize wallPosts = _wallPosts;
@synthesize globalChatMessages = _globalChatMessages;
@synthesize clanChatMessages = _clanChatMessages;

@synthesize lastLogoutTime = _lastLogoutTime;

@synthesize allies = _allies;

@synthesize unrespondedUpdates = _unrespondedUpdates;

@synthesize lastGoldmineRetrieval = _lastGoldmineRetrieval;

@synthesize clan = _clan;

@synthesize requestedClans = _requestedClans;

@synthesize mktSearchEquips = _mktSearchEquips;

@synthesize userExpansion = _userExpansion;

@synthesize goldSaleTimers = _goldSaleTimers;

@synthesize clanTierLevels = _clanTierLevels;

@synthesize forgeAttempts = _forgeAttempts;

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
    _staticBosses = [[NSMutableDictionary alloc] init];
    _notifications = [[NSMutableArray alloc] init];
    _myEquips = [[NSMutableArray alloc] init];
    _myStructs = [[NSMutableArray alloc] init];
    _myCities = [[NSMutableDictionary alloc] init];
    _wallPosts = [[NSMutableArray alloc] init];
    _globalChatMessages = [[NSMutableArray alloc] init];
    _clanChatMessages = [[NSMutableArray alloc] init];
    _boosterPurchases = [[NSMutableArray alloc] init];
    _staticLockBoxEvents = [[NSMutableArray alloc] init];
    _myLockBoxEvents = [[NSMutableDictionary alloc] init];
    _forgeAttempts = [[NSMutableArray alloc] init];
    _myBosses = [[NSMutableArray alloc] init];
    
    _availableQuests = [[NSMutableDictionary alloc] init];
    _inProgressCompleteQuests = [[NSMutableDictionary alloc] init];
    _inProgressIncompleteQuests = [[NSMutableDictionary alloc] init];
    
    _privateChats = [[NSMutableArray alloc] init];
    
    _unrespondedUpdates = [[NSMutableArray alloc] init];
    
    _requestedClans = [[NSMutableArray alloc] init];
    
    _clanTowerUserBattles = [[NSMutableArray alloc] init];
    
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
//  if (time == 0) {
//    // Special case: if time is 0, let it go through automatically
//    _lastUserUpdate = 0;
//  } else if (time <= _lastUserUpdate) {
//    LNLog(@"Did not update. This Update time = %lld, Last Update time = %lld.", time, _lastUserUpdate);
//    return;
//  } else {
//    _lastUserUpdate = time;
//    NSLog(@"Updated time to %lld.", time);
//  }
  
  // Copy over data from full user proto
  if (_userId != user.userId || ![_name isEqualToString:user.name] || _type != user.userType || (user.hasClan && ![self.clan.data isEqualToData:user.clan.data]) || (!user.hasClan && self.clan)) {
    self.userId = user.userId;
    self.name = user.name;
    self.type = user.userType;
    if (user.hasClan) {
      self.clan = user.clan;
    } else {
      self.clan = nil;
    }
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
  self.weaponEquipped2 = user.weaponTwoEquippedUserEquip.userEquipId;
  self.armorEquipped2 = user.armorTwoEquippedUserEquip.userEquipId;
  self.amuletEquipped2 = user.amuletTwoEquippedUserEquip.userEquipId;
  self.isAdmin = user.isAdmin;
  self.location = CLLocationCoordinate2DMake(user.userLocation.latitude, user.userLocation.longitude);
  self.hasReceivedfbReward = user.hasReceivedfbReward;
  self.prestigeLevel = user.prestigeLevel;
  self.numAdditionalForgeSlots = user.numAdditionalForgeSlots;
  self.numBeginnerSalesPurchased = user.numBeginnerSalesPurchased;
  self.hasActiveShield = user.hasActiveShield;
  
  NSTimeInterval t = user.lastEnergyRefillTime/1000.0;
  self.lastEnergyRefill = [NSDate dateWithTimeIntervalSince1970:t];
  self.lastStaminaRefill = [NSDate dateWithTimeIntervalSince1970:user.lastStaminaRefillTime/1000.0];
  self.lastShortLicensePurchaseTime = [NSDate dateWithTimeIntervalSince1970:user.lastShortLicensePurchaseTime/1000.0];
  self.lastLongLicensePurchaseTime = [NSDate dateWithTimeIntervalSince1970:user.lastLongLicensePurchaseTime/1000.0];
  self.createTime = [NSDate dateWithTimeIntervalSince1970:user.createTime/1000.0];
  self.numAdColonyVideosWatched = user.numAdColonyVideosWatched;
  self.numGroupChatsRemaining = user.numGroupChatsRemaining;
  
  self.lastLogoutTime = [NSDate dateWithTimeIntervalSince1970:user.lastLogoutTime/1000.0];
  
  self.lastGoldmineRetrieval = user.hasLastGoldmineRetrieval ? [NSDate dateWithTimeIntervalSince1970:user.lastGoldmineRetrieval/1000.0] : nil;
  
  for (id<GameStateUpdate> gsu in _unrespondedUpdates) {
    if ([gsu respondsToSelector:@selector(update)]) {
      [gsu update];
    }
  }
  
  [[TopBar sharedTopBar] setUpEnergyTimer];
  
  [[TopBar sharedTopBar] setUpStaminaTimer];
  
  [[TopBar sharedTopBar] shouldDisplayShieldView:[self hasBeginnerShield]];
  
  GameLayer *glay = [GameLayer sharedGameLayer];
  if ([glay.currentMap isKindOfClass:[BazaarMap class]]) {
    [(BazaarMap *)glay.currentMap reloadLocks];
  }
}

- (MinimumUserProto *) minUser {
  MinimumUserProto_Builder *mup = [[[[MinimumUserProto builder] setName:_name] setUserId:_userId] setUserType:_type];
  if (_clan != nil) {
    mup.clan = _clan;
  }
  return mup.build;
}

- (id) getStaticDataFrom:(NSDictionary *)dict withId:(int)itemId {
  AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  if (itemId == 0) {
    [Globals popupMessage:@"Attempted to access static item 0"];
    return nil;
  }
  [dict retain];
  NSNumber *num = [NSNumber numberWithInt:itemId];
  id p = [dict objectForKey:num];
  int numTimes = 1;
  while (!p) {
    numTimes++;
    if (numTimes == 50 || (numTimes %= 100) == 99) {
      ContextLogWarn(LN_CONTEXT_GAMESTATE, @"Lotsa wait time for this. Re-retrieving.");
      
      LNLog(@"Re-retrieving item: %d. Current things:", itemId);
      
      NSString *s = @"(";
      for (NSNumber *num in dict.allKeys) {
        s = [s stringByAppendingFormat:@"%d,", num.intValue];
      }
      
      // Lets try to retrieve the data by forcing a call
      SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
      NSArray *arr = [NSArray arrayWithObject:[NSNumber numberWithInt:itemId]];
      if (dict == _staticStructs) {
        [sc sendRetrieveStaticDataMessageWithStructIds:arr taskIds:nil questIds:nil cityIds:nil equipIds:nil buildStructJobIds:nil defeatTypeJobIds:nil possessEquipJobIds:nil upgradeStructJobIds:nil events:NO clanTierLevels:NO bossIds:nil];
        LNLog(@"Structures");
      } else if (dict == _staticTasks) {
        [sc sendRetrieveStaticDataMessageWithStructIds:nil taskIds:arr questIds:nil cityIds:nil equipIds:nil buildStructJobIds:nil defeatTypeJobIds:nil possessEquipJobIds:nil upgradeStructJobIds:nil events:NO clanTierLevels:NO bossIds:nil];
        LNLog(@"Tasks");
      } else if (dict == _staticQuests) {
        [sc sendRetrieveStaticDataMessageWithStructIds:nil taskIds:nil questIds:arr cityIds:nil equipIds:nil buildStructJobIds:nil defeatTypeJobIds:nil possessEquipJobIds:nil upgradeStructJobIds:nil events:NO clanTierLevels:NO bossIds:nil];
        LNLog(@"Quests");
      } else if (dict == _staticCities) {
        [sc sendRetrieveStaticDataMessageWithStructIds:nil taskIds:nil questIds:nil cityIds:arr equipIds:nil buildStructJobIds:nil defeatTypeJobIds:nil possessEquipJobIds:nil upgradeStructJobIds:nil events:NO clanTierLevels:NO bossIds:nil];
        LNLog(@"Cities");
      } else if (dict == _staticEquips) {
        [sc sendRetrieveStaticDataMessageWithStructIds:nil taskIds:nil questIds:nil cityIds:nil equipIds:arr buildStructJobIds:nil defeatTypeJobIds:nil possessEquipJobIds:nil upgradeStructJobIds:nil events:NO clanTierLevels:NO bossIds:nil];
        LNLog(@"Equips");
      } else if (dict == _staticBuildStructJobs) {
        [sc sendRetrieveStaticDataMessageWithStructIds:nil taskIds:nil questIds:nil cityIds:nil equipIds:nil buildStructJobIds:arr defeatTypeJobIds:nil possessEquipJobIds:nil upgradeStructJobIds:nil events:NO clanTierLevels:NO bossIds:nil];
        LNLog(@"Build Struct Jobs");
      } else if (dict == _staticDefeatTypeJobs) {
        [sc sendRetrieveStaticDataMessageWithStructIds:nil taskIds:nil questIds:nil cityIds:nil equipIds:nil buildStructJobIds:nil defeatTypeJobIds:arr possessEquipJobIds:nil upgradeStructJobIds:nil events:NO clanTierLevels:NO bossIds:nil];
        LNLog(@"Defeat Type Jobs");
      } else if (dict == _staticPossessEquipJobs) {
        [sc sendRetrieveStaticDataMessageWithStructIds:nil taskIds:nil questIds:nil cityIds:nil equipIds:nil buildStructJobIds:nil defeatTypeJobIds:nil possessEquipJobIds:arr upgradeStructJobIds:nil events:NO clanTierLevels:NO bossIds:nil];
        LNLog(@"Possess Equip Jobs");
      } else if (dict == _staticUpgradeStructJobs) {
        [sc sendRetrieveStaticDataMessageWithStructIds:nil taskIds:nil questIds:nil cityIds:nil equipIds:nil buildStructJobIds:nil defeatTypeJobIds:nil possessEquipJobIds:nil upgradeStructJobIds:arr events:NO clanTierLevels:NO bossIds:nil];
        LNLog(@"Upgrade Struct Jobs");
      } else if (dict == _staticBosses) {
        [sc sendRetrieveStaticDataMessageWithStructIds:nil taskIds:nil questIds:nil cityIds:nil equipIds:nil buildStructJobIds:nil defeatTypeJobIds:nil possessEquipJobIds:nil upgradeStructJobIds:nil events:NO clanTierLevels:NO bossIds:arr];
        LNLog(@"Bosses");
      }
      LNLog(@"%@)", s);
    } else if (!ad.isActive || numTimes > 10000) {
      [dict release];
      return nil;
    }
    //    NSAssert(numTimes < 1000000, @"Waiting too long for static data.. Probably not retrieved!", itemId);
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    // Need this in case game state gets deallocated while waiting for static data
    p = [dict objectForKey:num];
  }
  // Retain and autorelease in case data gets purged
  [p retain];
  [dict release];
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

- (int) weaponEquippedId2 {
  return [self myEquipWithUserEquipId:_weaponEquipped2].equipId;
}

- (int) armorEquippedId2 {
  return [self myEquipWithUserEquipId:_armorEquipped2].equipId;
}

- (int) amuletEquippedId2 {
  return [self myEquipWithUserEquipId:_amuletEquipped2].equipId;
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

- (FullTaskProto *) bossWithId:(int)bossId {
  if (bossId == 0) {
    [Globals popupMessage:@"Attempted to access boss 0"];
    return nil;
  }
  return [self getStaticDataFrom:_staticBosses withId:bossId];
}

- (LockBoxEventProto *) lockBoxEventWithId:(int)eventId {
  for (LockBoxEventProto *p in _staticLockBoxEvents) {
    if (p.lockBoxEventId == eventId) {
      return p;
    }
  }
  return nil;
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
  
  int x = -6, y = 5;
  for (UserStruct *us in self.myStructs) {
    if (us.coordinates.x == CENTER_TILE_X && us.coordinates.y == CENTER_TILE_Y) {
      [[OutgoingEventController sharedOutgoingEventController] moveNormStruct:us atX:CENTER_TILE_X+x atY:CENTER_TILE_Y+y];
      
      switch (x) {
        case -6:
          x = -3;
          break;
        case -3:
          x = 2;
          break;
        case 2:
          x = 5;
          break;
        case 5:
          x = -6;
          y -= 3;
          if (y == -1) y -= 2;
          
        default:
          break;
      }
    }
  }
}

- (void) addToMyCities:(NSArray *)cities {
  for (FullUserCityProto *cit in cities) {
    [self.myCities setObject:[UserCity userCityWithProto:cit] forKey:[NSNumber numberWithInt:cit.cityId]];
  }
}

- (void) addToMyLockBoxEvents:(NSArray *)events {
  for (UserLockBoxEventProto *p in events) {
    [self.myLockBoxEvents setObject:p forKey:[NSNumber numberWithInt:p.lockBoxEventId]];
  }
  [self resetLockBoxTimers];
}

- (void) addToMyBosses:(NSArray *)bosses {
  for (FullUserBossProto *f in bosses) {
    UserBoss *del = nil;
    for (UserBoss *a in self.myBosses) {
      if (a.bossId == f.bossId) {
        del = a;
      }
    }
    [self.myBosses removeObject:del];
    
    if ([f isKindOfClass:[FullUserBossProto class]]) {
      [self.myBosses addObject:[UserBoss userBossWithFullUserBossProto:f]];
    } else {
      [self.myBosses addObject:f];
    }
  }
  [self resetBossTimers];
}

- (void) addToAvailableQuests:(NSArray *)quests {
  if (quests.count > 0) {
    for (FullQuestProto *fqp in quests) {
      [self.availableQuests setObject:fqp forKey:[NSNumber numberWithInt:fqp.questId]];
      [[OutgoingEventController sharedOutgoingEventController] acceptQuest:fqp.questId];
    }
    
    if (!self.isTutorial) {
      [[TopBar sharedTopBar] displayNewQuestArrow];
    }
  }
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
  BOOL removedForgeNotification = NO;
  if (un.type == kNotificationForge) {
    UserNotification *n = nil;
    for (UserNotification *t in self.notifications) {
      if (t.type == kNotificationForge && t.blacksmithId == un.blacksmithId) {
        n = t;
      }
    }
    
    if (n) {
      [self.notifications removeObject:n];
      removedForgeNotification = YES;
    }
  }
  
  [self.notifications addObject:un];
  [self.notifications sortUsingComparator:^NSComparisonResult(UserNotification *obj1, UserNotification *obj2) {
    return [obj2.time compare:obj1.time];
  }];
  
  if ([un.time compare:_lastLogoutTime] == NSOrderedDescending) {
    un.hasBeenViewed = NO;
  } else {
    un.hasBeenViewed = YES;
  }
  
  if ([ActivityFeedController isInitialized]) {
    [[[ActivityFeedController sharedActivityFeedController] activityTableView] reloadData];
  }
  
  if (!_isTutorial) {
    GameState *gs = [GameState sharedGameState];
    TopBar *tb = [TopBar sharedTopBar];
    if ([un.time compare:gs.lastLogoutTime] == NSOrderedDescending) {
      // If top bar hasnt started, the activity feed will popup anyways so no need to increment badge.
      if ([tb isStarted]) {
        ForgeMenuController *fmc = [ForgeMenuController isInitialized] ? [ForgeMenuController sharedForgeMenuController] : nil;
        if (fmc.view.superview && (un.type == kNotificationForge || un.type == kNotificationEnhance)) {
          un.hasBeenViewed = YES;
        } else if ((un.type == kNotificationForge && !removedForgeNotification) || un.type != kNotificationForge) {
          [tb.profilePic incrementNotificationBadge];
          [tb addNotificationToDisplayQueue:un];
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
      
      TopBar *tb = [TopBar sharedTopBar];
      if (tb.isStarted && (!pvc.view.superview || pvc.profileBar.state != kMyProfile)) {
        UserNotification *un = [[[UserNotification alloc] initWithWallPost:wallPost] autorelease];
        [tb addNotificationToDisplayQueue:un];
      }
      
    }
  }
}

- (void) addChatMessage:(MinimumUserProto *)sender message:(NSString *)msg scope:(GroupChatScope)scope isAdmin:(BOOL)isAdmin {
  ChatMessage *cm = [[ChatMessage alloc] init];
  cm.sender = sender;
  cm.message = msg;
  cm.date = [NSDate date];
  cm.isAdmin = isAdmin;
  [self addChatMessage:cm scope:scope];
  [cm release];
}

- (void) addChatMessage:(ChatMessage *)cm scope:(GroupChatScope) scope {
  int arrCount = 0;
  
  ChatBottomView *btm = [[TopBar sharedTopBar] chatBottomView];
  if (scope == GroupChatScopeGlobal) {
    [self.globalChatMessages addObject:cm];
    
    if (btm.isGlobal) {
      [btm addChat:cm];
    }
    arrCount = self.globalChatMessages.count;
  } else if (scope == GroupChatScopeClan) {
    [self.clanChatMessages addObject:cm];
    
    if (!btm.isGlobal) {
      [btm addChat:cm];
    }
    arrCount = self.clanChatMessages.count;
  }
  
  
  if ([ChatMenuController isInitialized]) {
    ChatMenuController *cmc = [ChatMenuController sharedChatMenuController];
    if (cmc.view.superview) {
      if ((cmc.state == kChatStateGlobal && scope == GroupChatScopeGlobal) || (cmc.state == kChatStateClan && scope == GroupChatScopeClan)) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:arrCount-1 inSection:0];
        [cmc.chatTable insertRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
        
        // Give 100 pixels of leniency
        if (cmc.chatPopup.hidden && cmc.chatTable.contentOffset.y > cmc.chatTable.contentSize.height-cmc.chatTable.frame.size.height-100) {
          [cmc.chatTable scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
      }
    }
  }
  
  // Check whether we should add to the badge num
  // If both the chat bottom view and the menu are not global
  if (scope == GroupChatScopeClan) {
    BOOL shouldIncrement = YES;
    if (!btm.isGlobal) {
      shouldIncrement = NO;
    }
    
    if (shouldIncrement && [ChatMenuController isInitialized]) {
      ChatMenuController *cmc = [ChatMenuController sharedChatMenuController];
      if (cmc.view.superview && cmc.state == kChatStateClan) {
        shouldIncrement = NO;
      }
    }
    
    if (shouldIncrement && [cm.date compare:self.lastLogoutTime] == NSOrderedDescending) {
      self.clanChatBadgeNum++;
      
      btm.badgeLabel.text = self.clanChatBadgeNum < 100 ? [NSString stringWithFormat:@"%d", self.clanChatBadgeNum] : @"!";
      btm.badgeView.hidden = NO;
      
      if ([ChatMenuController isInitialized]) {
        ChatMenuController *cmc = [ChatMenuController sharedChatMenuController];
        cmc.topBar.clanBadgeLabel.text = self.clanChatBadgeNum < 100 ? [NSString stringWithFormat:@"%d", self.clanChatBadgeNum] : @"!";
        cmc.topBar.clanBadgeView.hidden = NO;
      }
    }
  }
}

- (void) addBoosterPurchase:(RareBoosterPurchaseProto *)bp {
  [self.boosterPurchases insertObject:bp atIndex:0];
  
  if ([ArmoryViewController isInitialized]) {
    ArmoryViewController *avc = [ArmoryViewController sharedArmoryViewController];
    [avc.feedView addedBoosterPurchase];
  }
}

- (void) clanChatViewed {
  ChatBottomView *btm = [[TopBar sharedTopBar] chatBottomView];
  btm.badgeView.hidden = YES;
  
  if ([ChatMenuController isInitialized]) {
    ChatMenuController *cmc = [ChatMenuController sharedChatMenuController];
    cmc.topBar.clanBadgeView.hidden = YES;
  }
  
  self.clanChatBadgeNum = 0;
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

- (NSArray *) myEquipsWithEquipId:(int)equipId {
  NSMutableArray *array = [NSMutableArray array];
  for (UserEquip *ue in self.myEquips) {
    if (ue.equipId == equipId) {
      [array addObject:ue];
    }
  }
  return array;
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

- (void) addToStaticBosses:(NSArray *)arr {
  for (FullBossProto *p in arr) {
    [self.staticBosses setObject:p forKey:[NSNumber numberWithInt:p.bossId]];
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
  }
}

- (void) addToStaticEquips:(NSArray *)arr {
  for (FullEquipProto *p in arr) {
    [self.staticEquips setObject:p forKey:[NSNumber numberWithInt:p.equipId]];
  }
  
  // Purge all static equips if not done before
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
  BOOL purged = [def boolForKey:PURGE_EQUIP_KEY];
  if (!purged) {
    for (FullEquipProto *eq in self.staticEquips.allValues) {
      NSString *s = [Globals imageNameForEquip:eq.equipId];
      NSString *resName = [CCFileUtils getDoubleResolutionImage:s validate:NO];
      [[Downloader sharedDownloader] deleteFile:resName];
    }
    
    [[Downloader sharedDownloader] deleteFile:@"enhancelvl1.png"];
    [[Downloader sharedDownloader] deleteFile:@"enhancelvl2.png"];
    [[Downloader sharedDownloader] deleteFile:@"enhancelvl3.png"];
    [[Downloader sharedDownloader] deleteFile:@"enhancelvl4.png"];
    [[Downloader sharedDownloader] deleteFile:@"enhancelvl5.png"];
    
    LNLog(@"Purged all equip images.");
    [def setBool:YES forKey:PURGE_EQUIP_KEY];
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

- (void) addNewStaticLockBoxEvents:(NSArray *)events {
  self.staticLockBoxEvents = [NSMutableArray array];
  for (LockBoxEventProto *p in events) {
    [_staticLockBoxEvents addObject:p];
    [self.staticEquips setObject:p.prizeEquip forKey:[NSNumber numberWithInt:p.prizeEquip.equipId]];
  }
  [self resetLockBoxTimers];
}

- (void) addNewStaticBossEvents:(NSArray *)events {
  self.staticBossEvents = [NSMutableArray array];
  for (BossEventProto *p in events) {
    [_staticBossEvents addObject:p];
    [self.staticEquips setObject:p.leftEquip forKey:[NSNumber numberWithInt:p.leftEquip.equipId]];
    [self.staticEquips setObject:p.middleEquip forKey:[NSNumber numberWithInt:p.middleEquip.equipId]];
    [self.staticEquips setObject:p.rightEquip forKey:[NSNumber numberWithInt:p.rightEquip.equipId]];
  }
}

- (void) addNewStaticTournaments:(NSArray *)events {
  self.staticTournaments = [NSMutableArray array];
  for (LeaderboardEventProto *p in events) {
    [_staticTournaments addObject:p];
  }
  [self resetTournamentTimers];
}

- (void) addToClanTierLevels:(NSArray *) tiers {
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:tiers.count];
  for (ClanTierLevelProto *tier in tiers) {
    [dict setObject:tier forKey:[NSNumber numberWithInt:tier.tierLevel]];
  }
  self.clanTierLevels = dict;
}

- (int) maxClanTierLevel {
  int max = 1;
  for (NSNumber *n in self.clanTierLevels.allKeys) {
    if (n.intValue > max) {
      max = n.intValue;
    }
  }
  return max;
}

- (ClanTierLevelProto *) clanTierForLevel:(int)level {
  return [self.clanTierLevels objectForKey:[NSNumber numberWithInt:level]];
}

- (FullQuestProto *) questForQuestId:(int)questId {
  NSNumber *num = [NSNumber numberWithInt:questId];
  FullQuestProto *fqp = [_availableQuests objectForKey:num];
  fqp = fqp ? fqp : [_inProgressCompleteQuests objectForKey:num];
  fqp = fqp ? fqp : [_inProgressIncompleteQuests objectForKey:num];
  return fqp;
}

- (BOOL) hasValidLicense {
  Globals *gl = [Globals sharedGlobals];
  
  NSTimeInterval shortLic = [self.lastShortLicensePurchaseTime timeIntervalSinceNow];
  NSTimeInterval time = -((NSTimeInterval)gl.numDaysShortMarketplaceLicenseLastsFor)*24*60*60;
  if (shortLic > time) {
    return YES;
  }
  
  NSTimeInterval longLic = [self.lastLongLicensePurchaseTime timeIntervalSinceNow];
  time = -gl.numDaysLongMarketplaceLicenseLastsFor*24l*60l*60l;
  if (longLic > time) {
    return YES;
  }
  
  return NO;
}

- (void) addUnrespondedUpdate:(id<GameStateUpdate>)up {
  if (_isTutorial) {
    return;
  }
  
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

- (ForgeAttempt *) forgeAttemptForSlot:(int)slotNum {
  for (ForgeAttempt *a in self.forgeAttempts) {
    if (a.slotNumber == slotNum) {
      return a;
    }
  }
  return nil;
}

- (ForgeAttempt *) forgeAttemptForBlacksmithId:(int)blacksmithId {
  for (ForgeAttempt *a in self.forgeAttempts) {
    if (a.blacksmithId == blacksmithId) {
      return a;
    }
  }
  return nil;
}

- (void) addForgeAttempt:(ForgeAttempt *)u {
  ForgeAttempt *toRemove = [self forgeAttemptForSlot:u.slotNumber];
  [self.forgeAttempts removeObject:toRemove];
  [self.forgeAttempts addObject:u];
}

- (void) removeForgeAttempt:(int)blacksmithId {
  ForgeAttempt *toRemove = [self forgeAttemptForBlacksmithId:blacksmithId];
  [self.forgeAttempts removeObject:toRemove];
}

- (void) beginForgeTimers {
  [self stopForgeTimers];
  NSMutableArray *timers = [NSMutableArray array];
  Globals *gl = [Globals sharedGlobals];
  for (ForgeAttempt *fa in self.forgeAttempts) {
    if (!fa.isComplete) {
      float seconds = [gl calculateMinutesForForge:fa.equipId level:fa.level]*60.f;
      NSDate *endTime = [fa.startTime dateByAddingTimeInterval:seconds];
      
      if ([endTime compare:[NSDate date]] == NSOrderedDescending) {
        NSTimer *t = [[NSTimer timerWithTimeInterval:endTime.timeIntervalSinceNow target:self selector:@selector(forgeWaitTimeComplete:) userInfo:fa repeats:NO] retain];
        [[NSRunLoop mainRunLoop] addTimer:t forMode:NSRunLoopCommonModes];
        [timers addObject:t];
      } else {
        [self forgeWaitTimeComplete:fa];
      }
    } else {
      UserNotification *un = [[UserNotification alloc] initWithForgeAttempt:fa];
      [self addNotification:un];
      [un release];
    }
  }
  self.forgeTimers = timers;
}

- (void) forgeWaitTimeComplete:(id)t {
  ForgeAttempt *fa = t;
  if ([t isKindOfClass:[NSTimer class]]) {
    fa = [(NSTimer *)t userInfo];
  }
  [[OutgoingEventController sharedOutgoingEventController] forgeAttemptWaitComplete:fa.blacksmithId];
}

- (void) stopForgeTimers {
  for (NSTimer *t in self.forgeTimers) {
    [t invalidate];
  }
  self.forgeTimers = nil;
}

- (void) beginEnhancementTimer {
  [self stopEnhancementTimer];
  Globals *gl = [Globals sharedGlobals];
  EquipEnhancementProto *ee = self.equipEnhancement;
  int mins = [gl calculateMinutesToEnhance:(UserEquip *)ee.enhancingEquip feeders:ee.feederEquipsList];
  NSDate *end = [NSDate dateWithTimeIntervalSince1970:ee.startTime/1000.+mins*60];
  
  if ([end compare:[NSDate date]] == NSOrderedDescending) {
    _enhanceTimer = [[NSTimer timerWithTimeInterval:end.timeIntervalSinceNow target:self selector:@selector(beginEnhancementTimer) userInfo:nil repeats:NO] retain];
    [[NSRunLoop mainRunLoop] addTimer:_enhanceTimer forMode:NSRunLoopCommonModes];
  } else {
    UserNotification *un = [[UserNotification alloc] initWithEnhancement:self.equipEnhancement];
    [self addNotification:un];
    [un release];
  }
}

- (void) stopEnhancementTimer {
  if (_enhanceTimer) {
    [_enhanceTimer invalidate];
    [_enhanceTimer release];
    _enhanceTimer = nil;
  }
}

- (void) beginGoldmineTimer {
  [self stopGoldmineTimer];
  Globals *gl = [Globals sharedGlobals];
  
  NSTimeInterval timeInterval = -[self.lastGoldmineRetrieval timeIntervalSinceNow];
  int timeToStartCollect = 3600.f*gl.numHoursBeforeGoldmineRetrieval;
  int timeToEndCollect = 3600.f*(gl.numHoursBeforeGoldmineRetrieval+gl.numHoursForGoldminePickup);
  
  if (timeInterval < timeToStartCollect) {
    NSTimeInterval timeInterval = [[self.lastGoldmineRetrieval dateByAddingTimeInterval:timeToStartCollect] timeIntervalSinceNow];
    _goldmineTimer = [[NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(goldmineTimeComplete) userInfo:nil repeats:NO] retain];
    [[NSRunLoop mainRunLoop] addTimer:_goldmineTimer forMode:NSRunLoopCommonModes];
  } else if (timeInterval < timeToEndCollect) {
    NSTimeInterval timeInterval = [[self.lastGoldmineRetrieval dateByAddingTimeInterval:timeToEndCollect] timeIntervalSinceNow];
    _goldmineTimer = [[NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(goldmineTimeComplete) userInfo:nil repeats:NO] retain];
    [[NSRunLoop mainRunLoop] addTimer:_goldmineTimer forMode:NSRunLoopCommonModes];
  }
}

- (void) goldmineTimeComplete {
  UserNotification *un = [[UserNotification alloc] initWithGoldmineRetrieval:self.lastGoldmineRetrieval];
  if (un) {
    [self addNotification:un];
    if ([BazaarMap isInitialized]) {
      BazaarMap *bm = [BazaarMap sharedBazaarMap];
      CritStructBuilding *csb = (CritStructBuilding *)[bm getChildByTag:BazaarStructTypeGoldMine];
      if (un.goldmineCollect) {
        csb.retrievable = YES;
      } else {
        csb.retrievable = NO;
      }
    }
    [un release];
  }
}

- (void) stopGoldmineTimer {
  if (_goldmineTimer) {
    [_goldmineTimer invalidate];
    [_goldmineTimer release];
    _goldmineTimer = nil;
  }
}

- (void) beginExpansionTimer {
  [self stopExpansionTimer];
  Globals *gl = [Globals sharedGlobals];
  UserExpansion *ue = _userExpansion;
  
  if (ue.isExpanding) {
    float seconds = [gl calculateNumMinutesForNewExpansion:ue]*60;
    NSDate *endTime = [ue.lastExpandTime dateByAddingTimeInterval:seconds];
    
    if ([endTime compare:[NSDate date]] == NSOrderedDescending) {
      _expansionTimer = [[NSTimer timerWithTimeInterval:endTime.timeIntervalSinceNow target:self selector:@selector(expansionWaitTimeComplete) userInfo:nil repeats:NO] retain];
      [[NSRunLoop mainRunLoop] addTimer:_expansionTimer forMode:NSRunLoopCommonModes];
    } else {
      [self expansionWaitTimeComplete];
    }
  }
}

- (void) expansionWaitTimeComplete {
  [[OutgoingEventController sharedOutgoingEventController] expansionWaitComplete:NO];
  
  if ([HomeMap isInitialized]) {
    [[HomeMap sharedHomeMap] refresh];
  }
}

- (void) stopExpansionTimer {
  if (_expansionTimer) {
    [_expansionTimer invalidate];
    [_expansionTimer release];
    _expansionTimer = nil;
  }
}

- (void) addToRequestedClans:(NSArray *)arr {
  for (FullUserClanProto *uc in arr) {
    if (uc.status == UserClanStatusRequesting) {
      [self.requestedClans addObject:[NSNumber numberWithInt:uc.clanId]];
    }
  }
}

- (void) updateLockBoxButton {
  Globals *gl = [Globals sharedGlobals];
  LockBoxEventProto *e = [self getCurrentLockBoxEvent];
  UserLockBoxEventProto *ue = [self.myLockBoxEvents objectForKey:[NSNumber numberWithInt:e.lockBoxEventId]];
  
  BOOL shouldDisplayButton = NO;
  BOOL shouldDisplayBadge = NO;
  if (e) {
    shouldDisplayButton = YES;
    
    uint64_t secs = [[NSDate date] timeIntervalSince1970];
    uint64_t pickTime = ue.lastPickTime/1000 + 60*gl.numMinutesToRepickLockBox;
    if (!ue || secs >= pickTime) {
      shouldDisplayBadge = YES;
    }
    
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:e.endDate/1000.0];
    int secs2 = endDate.timeIntervalSinceNow;
    if (secs2 < 0) {
      shouldDisplayBadge = YES;
    }
  }
  
  [[TopBar sharedTopBar] shouldDisplayLockBoxButton:shouldDisplayButton andBadge:shouldDisplayBadge];
}

- (void) resetLockBoxTimers {
  Globals *gl = [Globals sharedGlobals];
  
  [self stopAllLockBoxTimers];
  
  if (_isTutorial) {
    return;
  }
  
  [self updateLockBoxButton];
  
  _lockBoxEventTimers = [[NSMutableArray array] retain];
  for (LockBoxEventProto *e in _staticLockBoxEvents) {
    NSTimer *timer;
    NSTimeInterval timeInterval;
    
    timeInterval = [[NSDate dateWithTimeIntervalSince1970:e.startDate/1000.0] timeIntervalSinceNow];
    if (timeInterval > 0) {
      timer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(updateLockBoxButton) userInfo:nil repeats:NO];
      [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
      [_lockBoxEventTimers addObject:timer];
    }
    
    timeInterval = [[NSDate dateWithTimeIntervalSince1970:e.endDate/1000.0] timeIntervalSinceNow];
    if (timeInterval > 0) {
      timer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(updateLockBoxButton) userInfo:nil repeats:NO];
      [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
      [_lockBoxEventTimers addObject:timer];
    }
    
    timeInterval = [[NSDate dateWithTimeIntervalSince1970:e.endDate/1000.0+gl.numDaysToShowAfterEventEnded*24*60*60] timeIntervalSinceNow];
    if (timeInterval > 0) {
      timer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(updateLockBoxButton) userInfo:nil repeats:NO];
      [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
      [_lockBoxEventTimers addObject:timer];
    }
    
    UserLockBoxEventProto *ue = [self.myLockBoxEvents objectForKey:[NSNumber numberWithInt:e.lockBoxEventId]];
    if (ue) {
      timeInterval = [[NSDate dateWithTimeIntervalSince1970:(ue.lastPickTime/1000.0+60*gl.numMinutesToRepickLockBox)] timeIntervalSinceNow];
      if (timeInterval > 0) {
        timer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(updateLockBoxButton) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        [_lockBoxEventTimers addObject:timer];
      }
    }
  }
}

- (void) stopAllLockBoxTimers {
  for (NSTimer *timer in _lockBoxEventTimers) {
    [timer invalidate];
  }
  [_lockBoxEventTimers removeAllObjects];
  [_lockBoxEventTimers release];
  _lockBoxEventTimers = nil;
}

- (LockBoxEventProto *) getCurrentLockBoxEvent {
  Globals *gl = [Globals sharedGlobals];
  double curTime = [[NSDate date] timeIntervalSince1970]*1000.0;
  for (LockBoxEventProto *p in _staticLockBoxEvents) {
    if (curTime > p.startDate && curTime < p.endDate+gl.numDaysToShowAfterEventEnded*24*60*60*1000) {
      UserLockBoxEventProto *up = [self.myLockBoxEvents objectForKey:[NSNumber numberWithInt:p.lockBoxEventId]];
      BOOL hasItems = NO;
      if (curTime > p.endDate) {
        for (UserLockBoxItemProto *i in up.itemsList) {
          if (i.quantity > 0) {
            hasItems = YES;
          }
        }
      } else {
        hasItems = YES;
      }
      
      if (hasItems && !up.hasBeenRedeemed) {
        return p;
      }
    }
  }
  return nil;
}

- (void) addToNumLockBoxesForEvent:(int)eventId {
  NSNumber *num = [NSNumber numberWithInt:eventId];
  UserLockBoxEventProto *e = [_myLockBoxEvents objectForKey:num];
  UserLockBoxEventProto_Builder *b = nil;
  if (e) {
    b = [UserLockBoxEventProto builderWithPrototype:e];
    b.numLockBoxes++;
  } else {
    b = [UserLockBoxEventProto builderWithPrototype:e];
    b.userId = _userId;
    b.lockBoxEventId = eventId;
    b.numTimesCompleted = 0;
    b.numLockBoxes = 1;
  }
  [_myLockBoxEvents setObject:b.build forKey:num];
}

- (void) resetBossTimers {
  [self stopAllBossTimers];
  
  [self updateBossButton];
  
  _bossTimers = [[NSMutableArray array] retain];
  for (UserBoss *e in _myBosses) {
    NSTimer *timer;
    NSTimeInterval timeInterval;
    
    timeInterval = [[e timeUpDate] timeIntervalSinceNow];
    if (timeInterval > 0) {
      timer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(updateBossButton) userInfo:nil repeats:NO];
      [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
      [_bossTimers addObject:timer];
    }
  }
}

- (UserBoss *) getCurrentBoss {
  UserBoss *last = nil;
  for (UserBoss *p in _myBosses) {
    if ([p isAlive] && (!last || [[last timeUpDate] compare:[p timeUpDate]] == NSOrderedDescending)) {
      last = p;
    }
  }
  return last;
}

- (void) stopAllBossTimers {
  for (NSTimer *timer in _bossTimers) {
    [timer invalidate];
  }
  [_bossTimers removeAllObjects];
  [_bossTimers release];
  _bossTimers = nil;
}

- (void) updateBossButton {
  UserBoss *e = [self getCurrentBoss];
  
  BOOL shouldDisplayButton = e != nil;
  [[TopBar sharedTopBar] shouldDisplayBossButton:shouldDisplayButton];
}

- (void) resetTournamentTimers {
  [self stopAllTournamentTimers];
  
  if (_isTutorial) {
    return;
  }
  
  [self updateTournamentButton];
  
  Globals *gl = [Globals sharedGlobals];
  
  _tournamentTimers = [[NSMutableArray array] retain];
  for (LeaderboardEventProto *e in _staticTournaments) {
    NSTimer *timer;
    NSTimeInterval timeInterval;
    
    timeInterval = [[NSDate dateWithTimeIntervalSince1970:e.startDate/1000.0] timeIntervalSinceNow];
    if (timeInterval > 0) {
      timer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(updateTournamentButton) userInfo:nil repeats:NO];
      [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
      [_tournamentTimers addObject:timer];
    }
    
    timeInterval = [[NSDate dateWithTimeIntervalSince1970:e.endDate/1000.0+gl.tournamentNumHrsToDisplayAfterEnd*3600] timeIntervalSinceNow];
    if (timeInterval > 0) {
      timer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(updateTournamentButton) userInfo:nil repeats:NO];
      [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
      [_tournamentTimers addObject:timer];
    }
  }
}

- (LeaderboardEventProto *) getCurrentTournament {
  Globals *gl = [Globals sharedGlobals];
  double curTime = [[NSDate date] timeIntervalSince1970]*1000.0;
  for (LeaderboardEventProto *p in _staticTournaments) {
    if (curTime > p.startDate && curTime < p.lastShowDate+gl.tournamentNumHrsToDisplayAfterEnd*3600000l) {
      return p;
    }
  }
  return nil;
}

- (void) stopAllTournamentTimers {
  for (NSTimer *timer in _tournamentTimers) {
    [timer invalidate];
  }
  [_tournamentTimers removeAllObjects];
  [_tournamentTimers release];
  _tournamentTimers = nil;
}

- (void) updateTournamentButton {
  LeaderboardEventProto *e = [self getCurrentTournament];
  
  BOOL shouldDisplayButton = e != nil;
  [[TopBar sharedTopBar] shouldDisplayTournamentButton:shouldDisplayButton];
}

- (GoldSaleProto *) getCurrentGoldSale {
  Globals *gl = [Globals sharedGlobals];
  double curTime = [[NSDate date] timeIntervalSince1970]*1000.0;
  for (GoldSaleProto *p in _staticGoldSales) {
    if (p.isBeginnerSale && self.numBeginnerSalesPurchased >= gl.numBeginnerSalesAllowed) {
      continue;
    }
    
    if (curTime > p.startDate && curTime < p.endDate) {
      return p;
    }
  }
  return nil;
}

- (void) resetGoldSaleTimers {
  [self stopAllGoldSaleTimers];
  
  if (_isTutorial) {
    return;
  }
  
  [self updateGoldSaleBadge];
  
  _goldSaleTimers = [[NSMutableArray array] retain];
  for (GoldSaleProto *e in _staticGoldSales) {
    NSTimer *timer;
    NSTimeInterval timeInterval;
    
    timeInterval = [[NSDate dateWithTimeIntervalSince1970:e.startDate/1000.0] timeIntervalSinceNow];
    if (timeInterval > 0) {
      timer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(updateGoldSaleBadge) userInfo:nil repeats:NO];
      [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
      [_goldSaleTimers addObject:timer];
    }
    
    timeInterval = [[NSDate dateWithTimeIntervalSince1970:e.endDate/1000.0] timeIntervalSinceNow];
    if (timeInterval > 0) {
      timer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(updateGoldSaleBadge) userInfo:nil repeats:NO];
      [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
      [_goldSaleTimers addObject:timer];
    }
  }
}

- (void) updateGoldSaleBadge {
  if ([GoldShoppeViewController isInitialized]) {
    [[GoldShoppeViewController sharedGoldShoppeViewController] update];
  }
  
  if ([TopBar isInitialized]) {
    TopBar *tb = [TopBar sharedTopBar];
    if (tb.isStarted) {
      [tb displayGoldSaleBadge];
    }
  }
}

- (void) stopAllGoldSaleTimers {
  for (NSTimer *timer in _goldSaleTimers) {
    [timer invalidate];
  }
  [_goldSaleTimers removeAllObjects];
  [_goldSaleTimers release];
  _goldSaleTimers = nil;
}

- (void) updateClanTowers:(NSArray *)arr {
  NSMutableArray *a = [NSMutableArray arrayWithArray:self.clanTowers];
  
  for (ClanTowerProto *ctp in arr) {
    ClanTowerProto *old = [self clanTowerWithId:ctp.towerId];
    
    if (old) {
      [a replaceObjectAtIndex:[self.clanTowers indexOfObject:old] withObject:ctp];
    } else {
      [a addObject:ctp];
    }
    
    LNLog(@"Updating tower %d: owner=%d, attacker=%d, o_wins=%d, a_wins=%d", ctp.towerId, ctp.towerOwner.clanId, ctp.towerAttacker.clanId, ctp.ownerBattlesWin, ctp.attackerBattlesWin);
  }
  
  self.clanTowers = a;
  
  if ([ClanMenuController isInitialized]) {
    [[ClanMenuController sharedClanMenuController] updateClanTowers];
  }
  
  [[TopBar sharedTopBar] shouldDisplayTowerButton:[self isEngagedInClanTowerWar]];
}

- (ClanTowerProto *) clanTowerWithId:(int)towerId {
  for (ClanTowerProto *ctp in self.clanTowers) {
    if (ctp.towerId == towerId) {
      return ctp;
    }
  }
  return nil;
}

- (void) addClanTowerUserBattle:(ClanTowerUserBattle *)ctub {
  if (ctub) {
    [self.clanTowerUserBattles insertObject:ctub atIndex:0];
    
    if ([ClanMenuController isInitialized]) {
      ClanMenuController *cmc = [ClanMenuController sharedClanMenuController];
      [cmc.clanTowerScoresTab addedUserBattle:ctub];
    }
  }
}

- (void) removeClanTowerUserBattlesForTowerId:(int)towerId {
  NSArray *objs = [self clanTowerUserBattlesForTowerId:towerId];
  [self.clanTowerUserBattles removeObjectsInArray:objs];
  
  if ([ClanMenuController isInitialized]) {
    ClanMenuController *cmc = [ClanMenuController sharedClanMenuController];
    [cmc.clanTowerScoresTab removedUserBattlesForTowerId:towerId];
  }
}

- (NSArray *) clanTowerUserBattlesForTowerId:(int)towerId {
  NSMutableArray *arr = [NSMutableArray array];
  for (ClanTowerUserBattle *ctub in self.clanTowerUserBattles) {
    if (ctub.towerId == towerId) {
      [arr addObject:ctub];
    }
  }
  return arr;
}

- (NSArray *) mktSearchEquipsSimilarToString:(NSString *)string {
  NSMutableArray *arr = [NSMutableArray array];
  for (FullEquipProto *eq in _mktSearchEquips) {
    if ([eq.name rangeOfString:string options:NSCaseInsensitiveSearch].length > 0) {
      [arr addObject:eq];
    }
  }
  [arr sortUsingComparator:^NSComparisonResult(FullEquipProto *obj1, FullEquipProto *obj2) {
    NSRange range1 = [obj1.name rangeOfString:string options:NSCaseInsensitiveSearch];
    NSRange range2 = [obj2.name rangeOfString:string options:NSCaseInsensitiveSearch];
    
    if (range1.location < range2.location) {
      return NSOrderedAscending;
    } else if (range1.location > range2.location) {
      return NSOrderedDescending;
    }
    return NSOrderedSame;
  }];
  return arr;
}

- (BOOL) isEngagedInClanTowerWar {
  if (!self.clan) {
    return NO;
  }
  for (ClanTowerProto *ctp in self.clanTowers) {
    if (ctp.hasTowerAttacker && ctp.hasTowerOwner) {
      if (ctp.towerAttacker.clanId == self.clan.clanId || ctp.towerOwner.clanId == self.clan.clanId) {
        return YES;
      }
    }
  }
  return NO;
}

- (void) addStaticBoosterPacks:(NSArray *)bpps userBoosterPacks:(NSArray *)ubpps {
  self.boosterPacks = bpps;
  self.myBoosterPacks = [NSMutableDictionary dictionary];
  for (UserBoosterPackProto *ubpp in ubpps) {
    [self.myBoosterPacks setObject:ubpp forKey:[NSNumber numberWithInt:ubpp.boosterPackId]];
  }
}

- (UserBoosterPackProto *) myBoosterPackForId:(int)packId {
  return [self.myBoosterPacks objectForKey:[NSNumber numberWithInt:packId]];
}

- (BoosterPackProto *) boosterPackForId:(int)packId {
  for (BoosterPackProto *bpp in self.boosterPacks) {
    if (bpp.boosterPackId == packId) {
      return bpp;
    }
  }
  return nil;
}

- (CityGemProto *) gemForId:(int)gemId {
  for (CityGemProto *gem in self.cityGems) {
    if (gem.gemId == gemId) {
      return gem;
    }
  }
  return nil;
}

- (NSArray *) getUserEquipArray {
  NSMutableArray *arr = [NSMutableArray array];
  const int size = 6;
  int ids[size] = {_weaponEquipped, _armorEquipped, _amuletEquipped, _weaponEquipped2, _armorEquipped2, _amuletEquipped2};
  for (int i = 0; i < size; i++) {
    UserEquip *eq = [self myEquipWithUserEquipId:ids[i]];
    [arr addObject:eq == nil ? [NSNull null] : eq];
  }
  return arr;
}

- (BOOL) hasBeginnerShield {
  return [Globals userHasBeginnerShield:self.createTime.timeIntervalSince1970*1000 hasActiveShield:self.hasActiveShield];
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
  [[SocketCommunication sharedSocketCommunication] sendRetrieveStaticDataMessageWithStructIds:_staticStructs.allKeys taskIds:_staticTasks.allKeys questIds:_staticQuests.allKeys cityIds:_staticCities.allKeys equipIds:_staticEquips.allKeys buildStructJobIds:_staticBuildStructJobs.allKeys defeatTypeJobIds:_staticDefeatTypeJobs.allKeys possessEquipJobIds:_staticPossessEquipJobs.allKeys upgradeStructJobIds:_staticUpgradeStructJobs.allKeys events:YES clanTierLevels:YES bossIds:_staticBosses.allKeys];
  
  self.staticTasks = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticCities = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticEquips = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticQuests = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticStructs = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticDefeatTypeJobs = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticBuildStructJobs = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticPossessEquipJobs = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticUpgradeStructJobs = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticBosses = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticBossEvents = [[[NSMutableArray alloc] init] autorelease];
  self.staticLockBoxEvents = [[[NSMutableArray alloc] init] autorelease];
  self.staticGoldSales = [[[NSMutableArray alloc] init] autorelease];
  self.staticTournaments = [[[NSMutableArray alloc] init] autorelease];
  self.boosterPacks = nil;
  self.myBoosterPacks = nil;
  self.clanTierLevels = nil;
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
  self.staticBosses = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticDefeatTypeJobs = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticBuildStructJobs = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticPossessEquipJobs = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticUpgradeStructJobs = [[[NSMutableDictionary alloc] init] autorelease];
  self.notifications = [[[NSMutableArray alloc] init] autorelease];
  self.myEquips = [[[NSMutableArray alloc] init] autorelease];
  self.myStructs = [[[NSMutableArray alloc] init] autorelease];
  self.myCities = [[[NSMutableDictionary alloc] init] autorelease];
  self.wallPosts = [[[NSMutableArray alloc] init] autorelease];
  self.clanChatMessages = [[[NSMutableArray alloc] init] autorelease];
  self.globalChatMessages = [[[NSMutableArray alloc] init] autorelease];
  self.staticLockBoxEvents = [[[NSMutableArray alloc] init] autorelease];
  self.myLockBoxEvents = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticBossEvents = [[[NSMutableArray alloc] init] autorelease];
  self.staticTournaments = [[[NSMutableArray alloc] init] autorelease];
  self.boosterPurchases = [[[NSMutableArray alloc] init] autorelease];
  self.forgeAttempts = [[[NSMutableArray alloc] init] autorelease];
  self.myBosses = [[[NSMutableArray alloc] init] autorelease];
  
  self.availableQuests = [[[NSMutableDictionary alloc] init] autorelease];
  self.inProgressCompleteQuests = [[[NSMutableDictionary alloc] init] autorelease];
  self.inProgressIncompleteQuests = [[[NSMutableDictionary alloc] init] autorelease];
  
  self.prestigeLevel = 0;
  
  self.carpenterStructs = nil;
  self.armoryAmulets = nil;
  self.armoryArmor = nil;
  self.armoryWeapons = nil;
  self.boosterPacks = nil;
  self.myBoosterPacks = nil;
  self.cityGems = nil;
  
  self.unrespondedUpdates = [[[NSMutableArray alloc] init] autorelease];
  
  self.requestedClans = [[[NSMutableArray alloc] init] autorelease];
  
  self.mktSearchEquips = nil;
  
  self.userExpansion = nil;
  
  self.clanTierLevels = nil;
  self.clanTowers = nil;
  self.clanTowerUserBattles = [NSMutableArray array];
  
  [self stopEnhancementTimer];
  self.equipEnhancement = nil;
  
  self.clan = nil;
  self.userId = 0;
  
  [self stopForgeTimers];
  
  [self stopAllLockBoxTimers];
  [self stopAllGoldSaleTimers];
  [self stopAllBossTimers];
  [self stopAllTournamentTimers];
  
  [self stopExpansionTimer];
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
  self.staticBosses = nil;
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
  self.attackBotList = nil;
  self.attackPlayersList = nil;
  self.notifications = nil;
  self.wallPosts = nil;
  self.globalChatMessages = nil;
  self.clanChatMessages = nil;
  self.lastLogoutTime = nil;
  self.unrespondedUpdates = nil;
  self.deviceToken = nil;
  self.allies = nil;
  self.clan = nil;
  self.requestedClans = nil;
  self.lockBoxEventTimers = nil;
  self.bossTimers = nil;
  self.myLockBoxEvents = nil;
  self.staticLockBoxEvents = nil;
  self.mktSearchEquips = nil;
  self.userExpansion = nil;
  self.clanTowers = nil;
  self.equipEnhancement = nil;
  self.clanTowerUserBattles = nil;
  [self stopAllLockBoxTimers];
  [self stopAllBossTimers];
  [self stopForgeTimers];
  [self stopEnhancementTimer];
  [self stopExpansionTimer];
  [self stopAllGoldSaleTimers];
  [self stopAllTournamentTimers];
  [super dealloc];
}

@end
