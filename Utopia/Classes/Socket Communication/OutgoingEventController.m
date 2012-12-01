//
//  OutgoingEventController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/29/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "OutgoingEventController.h"
#import "LNSynthesizeSingleton.h"
#import "GameState.h"
#import "SocketCommunication.h"
#import "Globals.h"
#import "MarketplaceViewController.h"
#import "TopBar.h"
#import "GameLayer.h"
#import "MissionMap.h"
#import "HomeMap.h"
#import "MapViewController.h"
#import "TutorialConstants.h"
#import "GenericPopupController.h"
#import "SoundEngine.h"
#import "BattleLayer.h"
#import "OtherUpdates.h"
#import "OAHMAC_SHA1SignatureProvider.h"
#import "GameViewController.h"
#import "ArmoryViewController.h"
#import "EquipDeltaView.h"
#import "ForgeMenuController.h"
#import "GoldShoppeViewController.h"

#define  LVL6_SHARED_SECRET @"mister8conrad3chan9is1a2very4great5man"

@implementation OutgoingEventController

SYNTHESIZE_SINGLETON_FOR_CLASS(OutgoingEventController);

- (uint64_t) getCurrentMilliseconds {
  return (uint64_t)([[NSDate date] timeIntervalSince1970]*1000);
}

- (void) createUser {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  
  int tag = [sc sendUserCreateMessageWithName:gs.name
                                         type:gs.type
                                          lat:gs.location.latitude
                                          lon:gs.location.longitude
                                 referralCode:tc.referralCode
                                  deviceToken:gs.deviceToken
                                       attack:gs.attack
                                      defense:gs.defense
                                       energy:gs.maxEnergy
                                      stamina:gs.maxStamina
                         timeOfStructPurchase:tc.structTimeOfPurchase.timeIntervalSince1970*1000
                            timeOfStructBuild:tc.structTimeOfBuildComplete.timeIntervalSince1970*1000
                                      structX:tc.structCoords.x
                                      structY:tc.structCoords.y
                                 usedDiamonds:tc.structUsedDiamonds];
  
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) startup {
  int tag = [[SocketCommunication sharedSocketCommunication] sendStartupMessage:[self getCurrentMilliseconds]];
  [[GameState sharedGameState] addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) logout {
  GameState *gs = [GameState sharedGameState];
  if (gs.connected && gs.userId > 0) {
    [[SocketCommunication sharedSocketCommunication] sendLogoutMessage];
  }
}

- (void) reconnect {
  int tag = [[SocketCommunication sharedSocketCommunication] sendReconnectMessage];
  [[GameState sharedGameState] addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) vaultDeposit:(int)amount {
  if (amount <= 0) {
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  if (amount <= gs.silver) {
    int tag = [sc sendVaultMessage:amount requestType:VaultRequestProto_VaultRequestTypeDeposit];
    int vaultChange = (int)floorf(amount * (1.f-[[Globals sharedGlobals] cutOfVaultDepositTaken]));
    SilverUpdate *su = [SilverUpdate updateWithTag:tag change:-amount];
    VaultUpdate *vu = [VaultUpdate updateWithTag:tag change:vaultChange];
    [gs addUnrespondedUpdates:su, vu, nil];
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Unable to deposit %d coins. Currently only have %d silver.", amount, gs.silver]];
  }
}

- (void) vaultWithdrawal:(int)amount {
  if (amount <= 0) {
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  if (amount <= gs.vaultBalance) {
    int tag = [sc sendVaultMessage:amount requestType:VaultRequestProto_VaultRequestTypeWithdraw];
    SilverUpdate *su = [SilverUpdate updateWithTag:tag change:amount];
    VaultUpdate *vu = [VaultUpdate updateWithTag:tag change:-amount];
    [gs addUnrespondedUpdates:su, vu, nil];
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Unable to withdraw %d coins. Currently only have %d coins in vault.", amount, gs.vaultBalance]];
  }
}

- (BOOL) taskAction:(int)taskId curTimesActed:(int)numTimesActed {
  // Return num times acted
  GameState *gs = [GameState sharedGameState];
  FullTaskProto *ftp = [gs taskWithId:taskId];
  UserCity *fcp = [gs myCityWithId:ftp.cityId];
  
  if (!fcp) {
    [Globals popupMessage:@"Attempting to do task in a locked city"];
    return NO;
  }
  
  for (FullTaskProto_FullTaskEquipReqProto *equipReq in ftp.equipReqsList) {
    NSArray *myEquips = [gs myEquipsWithEquipId:equipReq.equipId];
    int i = 0;
    for (UserEquip *ue in myEquips) {
      i += pow(2, ue.level-1);
      
      if (i >= equipReq.quantity) {
        break;
      }
    }
    if (i < equipReq.quantity) {
      [Globals popupMessage:@"Attempting to do task without required equipment"];
      return NO;
    }
  }
  
  if (gs.currentEnergy < ftp.energyCost) {
    [Globals popupMessage:@"Attempting to do task without enough energy"];
  }
  
  if (numTimesActed+1 == ftp.numRequiredForCompletion) {
    fcp.numTasksComplete++;
  }
  
  int tag = [[SocketCommunication sharedSocketCommunication] sendTaskActionMessage:taskId curTime:[self getCurrentMilliseconds]];
  [gs addUnrespondedUpdate:[EnergyUpdate updateWithTag:tag change:-ftp.energyCost]];
  return YES;
}

- (void) battle:(FullUserProto *)defender result:(BattleResult)result city:(int)city equips:(NSArray *)equips {
  GameState *gs = [GameState sharedGameState];
  
  if (gs.currentStamina > 0) {
    MinimumUserProto *mup = [[[[[MinimumUserProto builder] setName:defender.name] setUserId:defender.userId] setUserType:defender.userType] build];
    
    int tag = [[SocketCommunication sharedSocketCommunication] sendBattleMessage:mup result:result curTime:[self getCurrentMilliseconds] city:city equips:equips];
    [gs addUnrespondedUpdate:[StaminaUpdate updateWithTag:tag change:-1]];
    
    switch (result) {
      case BattleResultAttackerWin:
        gs.battlesWon++;
        break;
        
      case BattleResultAttackerFlee:
        gs.flees++;
        break;
        
      case BattleResultDefenderWin:
        gs.battlesLost++;
        break;
        
      default:
        break;
    }
  } else {
    [Globals popupMessage:@"Trying to complete battle without any stamina."];
  }
}

- (void) buyEquip:(int)equipId {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:equipId];
  
  if (!fep.isBuyableInArmory) {
    [Globals popupMessage:@"Attempting to buy equip that is not in the armory.."];
  } else if (gs.silver >= fep.coinPrice && gs.gold >= fep.diamondPrice) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendArmoryMessage:ArmoryRequestProto_ArmoryRequestTypeBuy quantity:1 equipId:equipId];
    
    SilverUpdate *su = [SilverUpdate updateWithTag:tag change:-fep.coinPrice];
    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:-fep.diamondPrice];
    
    [gs addUnrespondedUpdates:su, gu, nil];
  } else {
    [Globals popupMessage:@"Not enough money to buy this equipment"];
  }
}

//- (int) sellEquip:(int)equipId {
//  GameState *gs = [GameState sharedGameState];
//  Globals *gl = [Globals sharedGlobals];
//  UserEquip *ue = [gs myEquipWithId:equipId];
//
//  if (ue) {
//    int tag = [[SocketCommunication sharedSocketCommunication] sendArmoryMessage:ArmoryRequestProto_ArmoryRequestTypeSell quantity:1 equipId:equipId];
//
//    SilverUpdate *su = [SilverUpdate updateWithTag:tag change:[gl calculateEquipSilverSellCost:ue]];
//    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:[gl calculateEquipGoldSellCost:ue]];
//    ChangeEquipUpdate *ceu = [ChangeEquipUpdate updateWithTag:tag equipId:equipId change:-1];
//
//    [gs addUnrespondedUpdates:ceu, su, gu, nil];
//
//  } else {
//    [Globals popupMessage:@"You do not own this equipment"];
//  }
//
//  return [gs myEquipWithId:equipId].quantity;
//}

- (BOOL) wearEquip:(int)userEquipId {
  GameState *gs = [GameState sharedGameState];
  UserEquip *ue = [gs myEquipWithUserEquipId:userEquipId];
  
  if (ue) {
    FullEquipProto *fep = [[GameState sharedGameState] equipWithId:ue.equipId];
    
    if (![Globals canEquip:fep]) {
      return NO;
    }
    
    if (fep.equipType == FullEquipProto_EquipTypeWeapon) {
      if (gs.weaponEquipped == userEquipId) {
        return NO;
      }
      gs.weaponEquipped = userEquipId;
    } else if (fep.equipType == FullEquipProto_EquipTypeArmor) {
      if (gs.armorEquipped == userEquipId) {
        return NO;
      }
      gs.armorEquipped = userEquipId;
    } else if (fep.equipType == FullEquipProto_EquipTypeAmulet) {
      if (gs.amuletEquipped == userEquipId) {
        return NO;
      }
      gs.amuletEquipped = userEquipId;
    }
    
    int tag = [[SocketCommunication sharedSocketCommunication] sendEquipEquipmentMessage:userEquipId];
    [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
    
    if ([ArmoryViewController sharedArmoryViewController].view.superview) {
      [[ArmoryViewController sharedArmoryViewController] refresh];
    }
    
    if ([MarketplaceViewController sharedMarketplaceViewController].view.superview) {
      [[MarketplaceViewController sharedMarketplaceViewController].bottomBar updateLabels];
    }
  } else {
    [Globals popupMessage:@"You do not own this equip"];
    return NO;
  }
  
  return YES;
}

- (void) generateAttackList:(int)numEnemies bounds:(CGRect)bounds {
  ContextLogInfo( LN_CONTEXT_COMMUNICATION, @"%d enemies in rect: %@", numEnemies, [NSValue valueWithCGRect:bounds]);
  if (bounds.size.width <= 0 || bounds.size.height <= 0) {
    [Globals popupMessage:@"Invalid bounds to generate attack list"];
    return;
  }
  
  if (numEnemies <= 0) {
    [Globals popupMessage:@"Invalid number of enemies to retrieve"];
    return;
  }
  
  int tag = [[SocketCommunication sharedSocketCommunication]
             sendGenerateAttackListMessage:numEnemies
             latUpperBound:MIN(CGRectGetMaxY(bounds), 90)
             latLowerBound:MAX(CGRectGetMinY(bounds), -90)
             lonUpperBound:MIN(CGRectGetMaxX(bounds), 180)
             lonLowerBound:MAX(CGRectGetMinX(bounds), -180)];
  [[GameState sharedGameState] addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) generateAttackList:(int)numEnemies {
  if (numEnemies <= 0) {
    [Globals popupMessage:@"Invalid number of enemies to retrieve"];
    return;
  }
  
  int tag = [[SocketCommunication sharedSocketCommunication] sendGenerateAttackListMessage:numEnemies];
  [[GameState sharedGameState] addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) inAppPurchase:(NSString *)receipt goldAmt:(int)gold product:(SKProduct *)product {
  GameState *gs = [GameState sharedGameState];
  if (gs.connected) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendInAppPurchaseMessage:receipt product:product];
    [[GameState sharedGameState] addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:gold]];
  }
  
  NSString *key = IAP_DEFAULTS_KEY;
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *arr = [defaults arrayForKey:key];
  NSMutableArray *mut = arr ? [[arr mutableCopy] autorelease] : [NSMutableArray array];
  [mut addObject:receipt];
  [defaults setObject:mut forKey:IAP_DEFAULTS_KEY];
  [defaults synchronize];
}

- (void) retrieveMarketplacePosts:(int)searchEquipId {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  Globals *gl = [Globals sharedGlobals];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  int filterBarButton = [defaults integerForKey:FILTER_BAR_USER_DEFAULTS_KEY];
  int rarityBarButton = [defaults integerForKey:RARITY_BAR_USER_DEFAULTS_KEY];
  BOOL myClassOnly = [defaults boolForKey:SWITCH_BUTTON_USER_DEFAULTS_KEY];
  int equipMin = [defaults integerForKey:EQUIP_LEVEL_MIN_USER_DEFAULTS_KEY];
  int equipMax = [defaults integerForKey:EQUIP_LEVEL_MAX_USER_DEFAULTS_KEY];
  int forgeMin = [defaults integerForKey:FORGE_LEVEL_MIN_USER_DEFAULTS_KEY];
  int forgeMax = [defaults integerForKey:FORGE_LEVEL_MAX_USER_DEFAULTS_KEY];
  int sortOrder = [defaults integerForKey:SORT_ORDER_USER_DEFAULTS_KEY];
  BOOL commonEquips = YES;
  BOOL uncommonEquips = YES;
  BOOL rareEquips = YES;
  BOOL epicEquips = YES;
  BOOL legendaryEquips = YES;
  
  RetrieveCurrentMarketplacePostsRequestProto_RetrieveCurrentMarketplacePostsFilter filter = RetrieveCurrentMarketplacePostsRequestProto_RetrieveCurrentMarketplacePostsFilterAll;
  switch (filterBarButton) {
    case 1:
      filter = RetrieveCurrentMarketplacePostsRequestProto_RetrieveCurrentMarketplacePostsFilterWeapons;
      break;
    case 2:
      filter = RetrieveCurrentMarketplacePostsRequestProto_RetrieveCurrentMarketplacePostsFilterArmor;
      break;
    case 3:
      filter = RetrieveCurrentMarketplacePostsRequestProto_RetrieveCurrentMarketplacePostsFilterAmulets;
      break;
    default:
      break;
  }
  
  
  if (rarityBarButton & 1) {
    if (!(rarityBarButton & (1 << 1))) legendaryEquips = NO;
    if (!(rarityBarButton & (1 << 2))) epicEquips = NO;
    if (!(rarityBarButton & (1 << 3))) rareEquips = NO;
    if (!(rarityBarButton & (1 << 4))) uncommonEquips = NO;
    if (!(rarityBarButton & (1 << 5))) commonEquips = NO;
  }
  
  if (equipMin == 0) equipMin = 1;
  if (equipMax == 0) equipMax = gl.maxLevelForUser/5*5+4;
  
  if (forgeMin == 0) forgeMin = 1;
  if (forgeMax == 0) forgeMax = gl.forgeMaxEquipLevel;
  
  int curNumEntries = [[GameState sharedGameState] marketplaceEquipPosts].count;
  int tag = [sc sendRetrieveCurrentMarketplacePostsMessageWithCurNumEntries:curNumEntries filter:filter commonEquips:commonEquips uncommonEquips:uncommonEquips rareEquips:rareEquips epicEquips:epicEquips legendaryEquips:legendaryEquips myClassOnly:myClassOnly minEquipLevel:equipMin maxEquipLevel:equipMax minForgeLevel:forgeMin maxForgeLevel:forgeMax sortOrder:sortOrder specificEquipId:searchEquipId];
  [[GameState sharedGameState] addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) retrieveMostRecentMarketplacePosts:(int)searchEquipId {
  [[[GameState sharedGameState] marketplaceEquipPosts] removeAllObjects];
  [[MarketplaceViewController sharedMarketplaceViewController] deleteRows:1];
  [self retrieveMarketplacePosts:searchEquipId];
}

- (void) retrieveMoreMarketplacePosts:(int)searchEquipId {
  [self retrieveMarketplacePosts:searchEquipId];
}

- (void) retrieveMostRecentMarketplacePostsFromSender {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  [[[GameState sharedGameState] marketplaceEquipPostsFromSender] removeAllObjects];
  int tag = [sc sendRetrieveCurrentMarketplacePostsMessageFromSenderWithCurNumEntries:0];
  [[MarketplaceViewController sharedMarketplaceViewController] deleteRows:2];
  [[GameState sharedGameState] addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) retrieveMoreMarketplacePostsFromSender {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  GameState *gs = [GameState sharedGameState];
  int tag = [sc sendRetrieveCurrentMarketplacePostsMessageFromSenderWithCurNumEntries:gs.marketplaceEquipPostsFromSender.count];
  [[GameState sharedGameState] addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) equipPostToMarketplace:(int)userEquipId price:(int)price {
  GameState *gs = [GameState sharedGameState];
  
  if (price <= 0) {
    [Globals popupMessage:@"You need to enter a price!"];
    return;
  }
  
  UserEquip *eq = [gs myEquipWithUserEquipId:userEquipId];
  
  if (eq) {
    FullEquipProto *fep = [gs equipWithId:eq.equipId];
    BOOL sellsForGold = [Globals sellsForGoldInMarketplace:fep];
    int silver = sellsForGold ? 0 : price;
    int gold = sellsForGold ? price : 0;
    int tag = [[SocketCommunication sharedSocketCommunication] sendEquipPostToMarketplaceMessage:userEquipId coins:silver diamonds:gold];
    
    ChangeEquipUpdate *ceu = [ChangeEquipUpdate updateWithTag:tag userEquip:eq remove:YES];
    [gs addUnrespondedUpdate:ceu];
    [GenericPopupController displayNotificationViewWithText:[NSString stringWithFormat:@"You have posted your %@ for %d %@!", fep.name, silver ? silver : gold, silver ? @"silver" : @"gold"] title:@"Congratulations!"];
  } else {
    [Globals popupMessage:@"Unable to find this equip!"];
  }
}

- (void) retractMarketplacePost:(int)postId {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  MarketplaceViewController *mvc = [MarketplaceViewController sharedMarketplaceViewController];
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *mktPostsFromSender = mvc.arrayForCurrentState;
  for (int i = 0; i < mktPostsFromSender.count; i++) {
    FullMarketplacePostProto *proto = [mktPostsFromSender objectAtIndex:i];
    if (proto.marketplacePostId == postId) {
      BOOL isGold = NO;
      int amount = 0;
      if (![gl canRetractMarketplacePostForFree:proto]) {
        if (proto.diamondCost > 0) {
          isGold = YES;
          amount = (int) ceilf(proto.diamondCost*gl.retractPercentCut);
          if (gs.gold < amount)  {
            [Globals popupMessage:@"Not enough gold to retract"];
            return;
          }
        } else {
          isGold = NO;
          amount = (int) ceilf(proto.coinCost*gl.retractPercentCut);
          if (gs.silver < amount) {
            [Globals popupMessage:@"Not enough silver to retract"];
            return;
          }
        }
      }
      int tag = [sc sendRetractMarketplacePostMessage:postId curTime:[self getCurrentMilliseconds]];
      
      [proto retain];
      [mktPostsFromSender removeObject:proto];
      // Might be in either list depending on current state
      [gs.marketplaceEquipPostsFromSender removeObject:proto];
      [gs.marketplaceEquipPosts removeObject:proto];
      [proto release];
      
      BOOL showsLicenseRow = YES;
      NSIndexPath *y = [NSIndexPath indexPathForRow:i+1+showsLicenseRow inSection:0];
      NSIndexPath *z = nil;
      if (mvc.state == kEquipBuyingState && mktPostsFromSender.count == 0) {
        z = [NSIndexPath indexPathForRow:0 inSection:0];
      } else if (mvc.state == kEquipSellingState && mktPostsFromSender.count+gs.myEquips.count == 0) {
        z = [NSIndexPath indexPathForRow:0 inSection:0];
      }
      NSArray *a = [NSArray arrayWithObjects:y, z, nil];
      [mvc.postsTableView deleteRowsAtIndexPaths:a withRowAnimation:UITableViewRowAnimationFade];
      
      FullUserUpdate *fuu = isGold ? [GoldUpdate updateWithTag:tag change:-amount] : [SilverUpdate updateWithTag:tag change:-amount];
      [gs addUnrespondedUpdate:fuu];
      
      return;
    }
  }
  
  [Globals popupMessage:@"Cannot verify that this item belongs to user.."];
}

- (void) purchaseFromMarketplace:(int)postId {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  GameState *gs = [GameState sharedGameState];
  
  NSMutableArray *mktPosts = gs.marketplaceEquipPosts;
  for (int i = 0; i < mktPosts.count; i++) {
    FullMarketplacePostProto *mktPost = [mktPosts objectAtIndex:i];
    if ([mktPost marketplacePostId] == postId) {
      if (gs.userId != mktPost.poster.userId) {
        if (gs.gold >= mktPost.diamondCost && gs.silver >= mktPost.coinCost) {
          int tag = [sc sendPurchaseFromMarketplaceMessage:postId poster:mktPost.poster.userId];
          GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:-mktPost.diamondCost];
          SilverUpdate *su = [SilverUpdate updateWithTag:tag change:-mktPost.coinCost];
          
          [gs addUnrespondedUpdates:gu, su, nil];
        } else {
          [Globals popupMessage:@"Not enough coins to purchase"];
        }
        return;
      }
    }
  }
  
  [Globals popupMessage:@"Cannot find this item.."];
}

- (void) redeemMarketplaceEarnings {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  GameState *gs = [GameState sharedGameState];
  
  if (gs.marketplaceGoldEarnings || gs.marketplaceSilverEarnings) {
    int tag = [sc sendRedeemMarketplaceEarningsMessage];
    
    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:gs.marketplaceGoldEarnings];
    SilverUpdate *su = [SilverUpdate updateWithTag:tag change:gs.marketplaceSilverEarnings];
    [gs addUnrespondedUpdates:gu, su, nil];
    
    gs.marketplaceGoldEarnings = 0;
    gs.marketplaceSilverEarnings = 0;
  } else {
    [Globals popupMessage:@"Nothing to earn!"];
  }
}

- (void) purchaseShortMarketplaceLicense {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (gs.hasValidLicense) {
    [Globals popupMessage:@"Trying to buy short license when you already own one"];
  } else if (gs.gold < gl.diamondCostOfShortMarketplaceLicense) {
    [Globals popupMessage:@"Trying to buy short license without enough gold"];
  } else {
    uint64_t curTime = [self getCurrentMilliseconds];
    int tag = [sc sendPurchaseMarketplaceLicenseMessage:curTime type:PurchaseMarketplaceLicenseRequestProto_LicenseTypeShort];
    gs.lastShortLicensePurchaseTime = [NSDate dateWithTimeIntervalSince1970:curTime/1000.];
    
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-gl.diamondCostOfShortMarketplaceLicense]];
  }
}

- (void) purchaseLongMarketplaceLicense {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (gs.hasValidLicense) {
    [Globals popupMessage:@"Trying to buy long license when you already own one"];
  } else if (gs.gold < gl.diamondCostOfLongMarketplaceLicense) {
    [Globals popupMessage:@"Trying to buy long license without enough gold"];
  } else {
    uint64_t curTime = [self getCurrentMilliseconds];
    int tag = [sc sendPurchaseMarketplaceLicenseMessage:curTime type:PurchaseMarketplaceLicenseRequestProto_LicenseTypeLong];
    gs.lastShortLicensePurchaseTime = [NSDate dateWithTimeIntervalSince1970:curTime/1000.];
    
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-gl.diamondCostOfLongMarketplaceLicense]];
  }
}

- (void) addAttackSkillPoint {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (gs.skillPoints >= gl.attackBaseCost) {
    int tag = [sc sendUseSkillPointMessage:UseSkillPointRequestProto_BoostTypeAttack];
    AttackUpdate *au = [AttackUpdate updateWithTag:tag change:gl.attackBaseGain];
    SkillPointsUpdate *spu = [SkillPointsUpdate updateWithTag:tag change:-gl.attackBaseCost];
    [gs addUnrespondedUpdates:au, spu, nil];
  } else {
    [Globals popupMessage:@"No skill points available to add"];
  }
}

- (void) addDefenseSkillPoint {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (gs.skillPoints >= gl.defenseBaseCost) {
    int tag = [sc sendUseSkillPointMessage:UseSkillPointRequestProto_BoostTypeDefense];
    DefenseUpdate *au = [DefenseUpdate updateWithTag:tag change:gl.defenseBaseGain];
    SkillPointsUpdate *spu = [SkillPointsUpdate updateWithTag:tag change:-gl.defenseBaseCost];
    [gs addUnrespondedUpdates:au, spu, nil];
  } else {
    [Globals popupMessage:@"No skill points available to add"];
  }
}

- (void) addEnergySkillPoint {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (gs.skillPoints >= gl.energyBaseCost) {
    int tag = [sc sendUseSkillPointMessage:UseSkillPointRequestProto_BoostTypeEnergy];
    
    // Make sure max happens before cur, because cur can only be as high as max
    MaxEnergyUpdate *meu = [MaxEnergyUpdate updateWithTag:tag change:gl.energyBaseGain];
    EnergyUpdate *eu = [EnergyUpdate updateWithTag:tag change:gl.energyBaseGain];
    SkillPointsUpdate *spu = [SkillPointsUpdate updateWithTag:tag change:-gl.energyBaseCost];
    [gs addUnrespondedUpdates:meu, eu, spu, nil];
  } else {
    [Globals popupMessage:@"No skill points available to add"];
  }
}

- (void) addStaminaSkillPoint {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (gs.skillPoints >= gl.staminaBaseCost) {
    int tag = [sc sendUseSkillPointMessage:UseSkillPointRequestProto_BoostTypeStamina];
    
    // Make sure max happens before cur, because cur can only be as high as max
    MaxStaminaUpdate *msu = [MaxStaminaUpdate updateWithTag:tag change:gl.staminaBaseGain];
    StaminaUpdate *su = [StaminaUpdate updateWithTag:tag change:gl.staminaBaseGain];
    SkillPointsUpdate *spu = [SkillPointsUpdate updateWithTag:tag change:-gl.staminaBaseCost];
    [gs addUnrespondedUpdates:msu, su, spu, nil];
  } else {
    [Globals popupMessage:@"No skill points available to add"];
  }
}

- (void) addHealthSkillPoint {
  //  GameState *gs = [GameState sharedGameState];
  //  Globals *gl = [Globals sharedGlobals];
  //  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  //  if (gs.skillPoints >= gl.healthBaseCost) {
  //    int tag = [sc sendUseSkillPointMessage:UseSkillPointRequestProto_BoostTypeHealth];
  //    HealthUpdate *hu = [HealthUpdate updateWithTag:tag change:gl.healthBaseGain];
  //    SkillPointsUpdate *spu = [SkillPointsUpdate updateWithTag:tag change:-gl.healthBaseCost];
  //    [gs addUnrespondedUpdates:hu, spu, nil];
  //  } else {
  //    [Globals popupMessage:@"No skill points available to add"];
  //  }
}

- (void) refillEnergyWaitComplete {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  NSDate *now = [NSDate date];
  NSTimeInterval tInt = [now timeIntervalSinceDate:gs.lastEnergyRefill];
  
  if (gs.currentEnergy >= gs.maxEnergy) {
    [Globals popupMessage:@"Trying to increase energy when at max.."];
  } else if (tInt >= gl.energyRefillWaitMinutes*60.f) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendRefillStatWaitTimeComplete:RefillStatWaitCompleteRequestProto_RefillStatWaitCompleteTypeEnergy curTime:now.timeIntervalSince1970*1000];
    
    int maxChange = gs.maxEnergy-gs.currentEnergy;
    int change = tInt/(gl.energyRefillWaitMinutes*60);
    int realChange = MIN(maxChange, change);
    NSDate *nextDate = [gs.lastEnergyRefill dateByAddingTimeInterval:realChange*gl.energyRefillWaitMinutes*60.f];
    NSLog(@"Sending refill energy. Last time: %@, Next time: %@", gs.lastEnergyRefill, nextDate);
    EnergyUpdate *eu = [EnergyUpdate updateWithTag:tag change:realChange];
    LastEnergyRefillUpdate *leru = [LastEnergyRefillUpdate updateWithTag:tag prevDate:gs.lastEnergyRefill nextDate:nextDate];
    [gs addUnrespondedUpdates:eu, leru, nil];
  } else {
    LNLog(@"Refilling energy before time. Seconds since last refill: %f", tInt);
    [Globals popupMessage:@"Trying to refill energy before time.."];
  }
}

- (void) refillStaminaWaitComplete {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  NSDate *now = [NSDate date];
  NSTimeInterval tInt = [now timeIntervalSinceDate:gs.lastStaminaRefill];
  
  if (gs.currentStamina >= gs.maxStamina) {
    [Globals popupMessage:@"Trying to increase stamina when at max.."];
  } else if (tInt >= 0.f) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendRefillStatWaitTimeComplete:RefillStatWaitCompleteRequestProto_RefillStatWaitCompleteTypeStamina curTime:now.timeIntervalSince1970*1000];
    
    int maxChange = gs.maxStamina-gs.currentStamina;
    int change = tInt/(gl.staminaRefillWaitMinutes*60);
    int realChange = MIN(maxChange, change);
    NSDate *nextDate = [gs.lastStaminaRefill dateByAddingTimeInterval:realChange*gl.staminaRefillWaitMinutes*60+1.f];
    StaminaUpdate *su = [StaminaUpdate updateWithTag:tag change:realChange];
    LastStaminaRefillUpdate *lsru = [LastStaminaRefillUpdate updateWithTag:tag prevDate:gs.lastStaminaRefill nextDate:nextDate];
    [gs addUnrespondedUpdates:su, lsru, nil];
  } else {
    [Globals popupMessage:@"Trying to refill stamina before time.."];
  }
}

- (void) refillEnergyWithDiamonds {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (gs.currentEnergy >= gs.maxEnergy) {
    [Globals popupMessage:@"Attempting to refill energy with already full energy"];
  } else if (gs.gold >= gl.energyRefillCost) {
    int tag = [sc sendRefillStatWithDiamondsMessage:RefillStatWithDiamondsRequestProto_StatTypeEnergy];
    EnergyUpdate *eu = [EnergyUpdate updateWithTag:tag change:gs.maxEnergy-gs.currentEnergy];
    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:-gl.energyRefillCost];
    [gs addUnrespondedUpdates:eu, gu, nil];
    
    [[TopBar sharedTopBar] setUpEnergyTimer];
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Not enough gold to refill energy. Need: %d, Have: %d.", gl.energyRefillCost, gs.gold]];
  }
}

- (void) refillStaminaWithDiamonds {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (gs.currentStamina >= gs.maxStamina) {
    [Globals popupMessage:@"Attempting to refill stamina with already full stamina"];
  } else if (gs.gold >= gl.staminaRefillCost) {
    int tag = [sc sendRefillStatWithDiamondsMessage:RefillStatWithDiamondsRequestProto_StatTypeStamina];
    StaminaUpdate *su = [StaminaUpdate updateWithTag:tag change:gs.maxStamina-gs.currentStamina];
    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:-gl.staminaRefillCost];
    [gs addUnrespondedUpdates:su, gu, nil];
    
    [[TopBar sharedTopBar] setUpStaminaTimer];
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Not enough gold to refill stamina. Need: %d, Have: %d.", gl.staminaRefillCost, gs.gold]];
  }
}

- (UserStruct *) purchaseNormStruct:(int)structId atX:(int)x atY:(int)y {
  GameState *gs = [GameState sharedGameState];
  FullStructureProto *fsp = [gs structWithId:structId];
  UserStruct *us = nil;
  
  // Check that no other building is being built
  for (UserStruct *u in gs.myStructs) {
    if (u.state == kBuilding) {
      [Globals popupMessage:@"You can only construct one building at a time!"];
      return us;
    }
  }
  
  if (gs.silver >= fsp.coinPrice && gs.gold >= fsp.diamondPrice) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendPurchaseNormStructureMessage:structId x:x y:y time:[self getCurrentMilliseconds]];
    us = [[UserStruct alloc] init];
    
    // UserStructId will come in the response
    us.userId = [[GameState sharedGameState] userId];
    us.structId = structId;
    us.level = 1;
    us.isComplete = NO;
    us.coordinates = CGPointMake(x, y);
    us.orientation = 0;
    us.purchaseTime = [NSDate date];
    us.lastRetrieved = nil;
    
    AddStructUpdate *asu = [AddStructUpdate updateWithTag:tag userStruct:us];
    SilverUpdate *su = [SilverUpdate updateWithTag:tag change:-fsp.coinPrice];
    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:-fsp.diamondPrice];
    [gs addUnrespondedUpdates:asu, su, gu, nil];
    
    [us release];
    
    [Analytics normStructPurchase:structId];
  } else {
    [Globals popupMessage:@"Not enough money to purchase this building"];
  }
  return us;
}

- (void) moveNormStruct:(UserStruct *)userStruct atX:(int)x atY:(int)y {
  CGPoint newCoord = CGPointMake(x, y);
  if (!CGPointEqualToPoint(userStruct.coordinates, newCoord)) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendMoveNormStructureMessage:userStruct.userStructId x:x y:y];
    userStruct.coordinates = CGPointMake(x, y);
    
    [[GameState sharedGameState] addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
  }
}

- (void) rotateNormStruct:(UserStruct *)userStruct to:(StructOrientation)orientation {
  if (userStruct.orientation != orientation) {
    [[SocketCommunication sharedSocketCommunication] sendRotateNormStructureMessage:userStruct.userStructId orientation:orientation];
    userStruct.orientation = orientation;
  }
}

- (void) sellNormStruct:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  Globals *gl = [Globals sharedGlobals];
  
  if (userStruct.userStructId == 0) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (userStruct.userId != gs.userId) {
    [Globals popupMessage:@"This is not your building!"];
  } else {
    int tag = [sc sendSellNormStructureMessage:userStruct.userStructId];
    
    SellStructUpdate *ssu = [SellStructUpdate updateWithTag:tag userStruct:userStruct];
    SilverUpdate *su = [SilverUpdate updateWithTag:tag change:[gl calculateStructSilverSellCost:userStruct]];
    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:[gl calculateStructGoldSellCost:userStruct]];
    
    [gs addUnrespondedUpdates:ssu, su, gu, nil];
    
    [Analytics normStructSell:userStruct.structId level:userStruct.level];
  }
}

- (void) retrieveFromNormStructure:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  Globals *gl = [Globals sharedGlobals];
  
  if (userStruct.userStructId == 0) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (userStruct.userId != gs.userId) {
    [Globals popupMessage:@"This is not your building!"];
  } else if (userStruct.isComplete && userStruct.lastRetrieved) {
    int64_t ms = [self getCurrentMilliseconds];
    int tag = [sc sendRetrieveCurrencyFromNormStructureMessage:userStruct.userStructId time:ms];
    userStruct.lastRetrieved = [NSDate dateWithTimeIntervalSince1970:ms/1000.0];
    
    // Update game state
    [gs addUnrespondedUpdate:[SilverUpdate updateWithTag:tag change:[gl calculateIncomeForUserStruct:userStruct]]];
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Building %d is not ready to be retrieved", userStruct.userStructId]];
  }
}

- (void) instaBuild:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  Globals *gl = [Globals sharedGlobals];
  
  if (userStruct.userStructId == 0) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (userStruct.userId != gs.userId) {
    [Globals popupMessage:@"This is not your building!"];
  } else if (gs.gold < [gl calculateDiamondCostForInstaBuild:userStruct]) {
    [Globals popupMessage:@"Not enough diamonds to speed up build"];
  } else if (!userStruct.isComplete && !userStruct.lastUpgradeTime) {
    int64_t ms = [self getCurrentMilliseconds];
    int tag = [sc sendFinishNormStructBuildWithDiamondsMessage:userStruct.userStructId time:ms type:FinishNormStructWaittimeWithDiamondsRequestProto_NormStructWaitTimeTypeFinishConstruction];
    userStruct.isComplete = YES;
    userStruct.lastRetrieved = [NSDate dateWithTimeIntervalSince1970:ms/1000.0];
    
    // Update game state
    FullStructureProto *fsp = [gs structWithId:userStruct.structId];
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-fsp.instaBuildDiamondCost]];
    
    [Analytics normStructInstaBuild:userStruct.structId];
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Building %d is not constructing", userStruct.userStructId]];
  }
}

- (void) instaUpgrade:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  Globals *gl = [Globals sharedGlobals];
  
  if (userStruct.userStructId == 0) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (userStruct.userId != gs.userId) {
    [Globals popupMessage:@"This is not your building!"];
  } else if (gs.gold < [gl calculateDiamondCostForInstaUpgrade:userStruct]) {
    [Globals popupMessage:@"Not enough diamonds to speed up upgrade"];
  } else if (!userStruct.isComplete && userStruct.lastUpgradeTime) {
    int64_t ms = [self getCurrentMilliseconds];
    int tag = [sc sendFinishNormStructBuildWithDiamondsMessage:userStruct.userStructId time:[self getCurrentMilliseconds] type:FinishNormStructWaittimeWithDiamondsRequestProto_NormStructWaitTimeTypeFinishUpgrade];
    userStruct.isComplete = YES;
    userStruct.lastRetrieved = [NSDate dateWithTimeIntervalSince1970:ms/1000.0];
    userStruct.level++;
    
    // Update game state
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-[gl calculateDiamondCostForInstaUpgrade:userStruct]]];
    
    [Analytics normStructInstaUpgrade:userStruct.structId level:userStruct.level];
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Building %d is not upgrading", userStruct.userStructId]];
  }
}

- (void) normStructWaitComplete:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:userStruct.structId];
  
  if (userStruct.userStructId == 0) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (userStruct.userId != gs.userId) {
    [Globals popupMessage:@"This is not your building!"];
  } else if (!userStruct.isComplete) {
    NSDate *date;
    if (userStruct.state == kBuilding) {
      date = [NSDate dateWithTimeInterval:fsp.minutesToBuild*60 sinceDate:userStruct.purchaseTime];
    } else if (userStruct.state == kUpgrading) {
      date = [NSDate dateWithTimeInterval:[gl calculateMinutesToUpgrade:userStruct]*60 sinceDate:userStruct.lastUpgradeTime];
    } else {
      [Globals popupMessage:@"Something went wrong, building should still be waiting"];
      return;
    }
    
    if ([date compare:[NSDate date]] == NSOrderedDescending) {
      [Globals popupMessage:@"Something went wrong, building should still be waiting"];
      return;
    }
    userStruct.lastRetrieved = date;
    userStruct.isComplete = YES;
    
    int64_t ms = [self getCurrentMilliseconds];
    int tag = [sc sendNormStructBuildsCompleteMessage:[NSArray arrayWithObject:[NSNumber numberWithInt:userStruct.userStructId]] time:ms];
    
    if (userStruct.lastUpgradeTime) {
      // Building was upgraded, not constructed
      userStruct.level++;
    }
    
    [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Building %d is not upgrading or constructing", userStruct.userStructId]];
  }
}

- (void) upgradeNormStruct:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  FullStructureProto *fsp = [gs structWithId:userStruct.structId];
  
  // Check that no other building is being upgraded
  for (UserStruct *us in gs.myStructs) {
    if (us.state == kUpgrading) {
      [Globals popupMessage:@"You can only upgrade one building at a time!"];
      return;
    }
  }
  
  if (userStruct.userStructId == 0) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (userStruct.userId != gs.userId) {
    [Globals popupMessage:@"This is not your building!"];
  } else if (userStruct.isComplete) {
    int cost = [[Globals sharedGlobals] calculateUpgradeCost:userStruct];
    BOOL isGoldBuilding = fsp.diamondPrice > 0;
    if (isGoldBuilding) {
      if (cost > gs.gold) {
        [Globals popupMessage:@"Trying to upgrade without enough gold"];
      } else {
        int64_t ms = [self getCurrentMilliseconds];
        int tag = [sc sendUpgradeNormStructureMessage:userStruct.userStructId time:ms];
        userStruct.isComplete = NO;
        userStruct.lastUpgradeTime = [NSDate dateWithTimeIntervalSince1970:ms/1000.0];\
        
        // Update game state
        [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-cost]];
        
        [Analytics normStructInstaUpgrade:userStruct.structId level:userStruct.level+1];
      }
    } else {
      if (cost > gs.silver) {
        [Globals popupMessage:@"Trying to upgrade without enough silver"];
      } else {
        int64_t ms = [self getCurrentMilliseconds];
        int tag = [sc sendUpgradeNormStructureMessage:userStruct.userStructId time:ms];
        userStruct.isComplete = NO;
        userStruct.lastUpgradeTime = [NSDate dateWithTimeIntervalSince1970:ms/1000.0];\
        
        // Update game state
        [gs addUnrespondedUpdate:[SilverUpdate updateWithTag:tag change:-cost]];
        
        [Analytics normStructInstaUpgrade:userStruct.structId level:userStruct.level+1];
      }
    }
    
  } else {
    [Globals popupMessage:@"This building is not upgradable"];
  }
}

- (void) retrieveAllStaticData {
  // First go through equips
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  BOOL shouldSend = NO;
  
  NSArray *equips = [gs myEquips];
  NSDictionary *sEquips = [gs staticEquips];
  NSMutableSet *rEquips = [NSMutableSet set];
  for (FullUserEquipProto *eq in equips) {
    NSNumber *equipId = [NSNumber numberWithInt:eq.equipId];
    if (![sEquips objectForKey:equipId]) {
      [rEquips addObject:equipId];
      shouldSend = YES;
    }
  }
  
  NSArray *structs = [gs myStructs];
  NSDictionary *sStructs = [gs staticStructs];
  NSMutableSet *rStructs = [NSMutableSet set];
  for (FullStructureProto *str in structs) {
    NSNumber *structId = [NSNumber numberWithInt:str.structId];
    if (![sStructs objectForKey:structId]) {
      [rStructs addObject:structId];
      shouldSend = YES;
    }
  }
  
  NSArray *tasks = [[gs staticTasks] allValues];
  for (FullTaskProto *ftp in tasks) {
    for (FullTaskProto_FullTaskEquipReqProto *eq in ftp.equipReqsList) {
      NSNumber *equipId = [NSNumber numberWithInt:eq.equipId];
      if (![sEquips objectForKey:equipId]) {
        [rEquips addObject:equipId];
        shouldSend = YES;
      }
    }
    for (NSNumber *equipId in ftp.potentialLootEquipIdsList) {
      if (![sEquips objectForKey:equipId]) {
        [rEquips addObject:equipId];
        shouldSend = YES;
      }
    }
  }
  
  NSMutableSet *rTasks = [NSMutableSet set];
  NSDictionary *sTasks = [gs staticTasks];
  NSMutableSet *rBuildStructJobs = [NSMutableSet set];
  NSDictionary *sBuildStructJobs = [gs staticBuildStructJobs];
  NSMutableSet *rDefeatTypeJobs = [NSMutableSet set];
  NSDictionary *sDefeatTypeJobs = [gs staticDefeatTypeJobs];
  NSMutableSet *rPossessEquipJobs = [NSMutableSet set];
  NSDictionary *sPossessEquipJobs = [gs staticPossessEquipJobs];
  NSMutableSet *rUpgradeStructJobs = [NSMutableSet set];
  NSDictionary *sUpgradeStructJobs = [gs staticUpgradeStructJobs];
  
  NSArray *questDictionaries = [NSArray arrayWithObjects:gs.availableQuests, gs.inProgressCompleteQuests, gs.inProgressIncompleteQuests, nil];
  for (NSDictionary *dict in questDictionaries) {
    for (FullQuestProto *fqp in [dict allValues]) {
      for (NSNumber *num in fqp.taskReqsList) {
        if (![sTasks objectForKey:num]) {
          [rTasks addObject:num];
        }
      }
      for (NSNumber *num in fqp.buildStructJobsReqsList) {
        if (![sBuildStructJobs objectForKey:num]) {
          [rBuildStructJobs addObject:num];
          shouldSend = YES;
        }
      }
      for (NSNumber *num in fqp.upgradeStructJobsReqsList) {
        if (![sUpgradeStructJobs objectForKey:num]) {
          [rUpgradeStructJobs addObject:num];
          shouldSend = YES;
        }
      }
      for (NSNumber *num in fqp.defeatTypeReqsList) {
        if (![sDefeatTypeJobs objectForKey:num]) {
          [rDefeatTypeJobs addObject:num];
          shouldSend = YES;
        }
      }
      for (NSNumber *num in fqp.possessEquipJobReqsList) {
        if (![sPossessEquipJobs objectForKey:num]) {
          [rPossessEquipJobs addObject:num];
          shouldSend = YES;
        }
      }
      
      NSNumber *n = [NSNumber numberWithInt:fqp.equipIdGained];
      if (fqp.equipIdGained && ![sEquips objectForKey:n]) {
        [rEquips addObject:n];
        shouldSend = YES;
      }
    }
  }
  
  for (PossessEquipJobProto *p in [gs.staticPossessEquipJobs allValues]) {
    NSNumber *n = [NSNumber numberWithInt:p.equipId];
    if (![sEquips objectForKey:n]) {
      [rEquips addObject:n];
      shouldSend = YES;
    }
  }
  
  for (UpgradeStructJobProto *p in [gs.staticUpgradeStructJobs allValues]) {
    NSNumber *n = [NSNumber numberWithInt:p.structId];
    if (![sStructs objectForKey:n]) {
      [rStructs addObject:n];
      shouldSend = YES;
    }
  }
  
  for (BuildStructJobProto *p in [gs.staticBuildStructJobs allValues]) {
    NSNumber *n = [NSNumber numberWithInt:p.structId];
    if (![sStructs objectForKey:n]) {
      [rStructs addObject:n];
      shouldSend = YES;
    }
  }
  
  for (FullUserProto *fup in gs.attackList) {
    int eq = fup.weaponEquippedUserEquip.equipId;
    NSNumber *w = [NSNumber numberWithInt:eq];
    if (eq && ![sEquips objectForKey:w]) {
      [rEquips addObject:w];
      shouldSend = YES;
    }
    
    eq = fup.armorEquippedUserEquip.equipId;
    NSNumber *ar = [NSNumber numberWithInt:eq];
    if (eq && ![sEquips objectForKey:ar]) {
      [rEquips addObject:ar];
      shouldSend = YES;
    }
    
    eq = fup.amuletEquippedUserEquip .equipId;
    NSNumber *am = [NSNumber numberWithInt:eq];
    if (eq && ![sEquips objectForKey:am]) {
      [rEquips addObject:am];
      shouldSend = YES;
    }
  }
  
  for (FullUserProto *fup in gs.attackMapList) {
    int eq = fup.weaponEquippedUserEquip.equipId;
    NSNumber *w = [NSNumber numberWithInt:eq];
    if (eq && ![sEquips objectForKey:w]) {
      [rEquips addObject:w];
      shouldSend = YES;
    }
    
    eq = fup.armorEquippedUserEquip.equipId;
    NSNumber *ar = [NSNumber numberWithInt:eq];
    if (eq && ![sEquips objectForKey:ar]) {
      [rEquips addObject:ar];
      shouldSend = YES;
    }
    
    eq = fup.amuletEquippedUserEquip .equipId;
    NSNumber *am = [NSNumber numberWithInt:eq];
    if (eq && ![sEquips objectForKey:am]) {
      [rEquips addObject:am];
      shouldSend = YES;
    }
  }
  
  for (UserNotification *un in gs.notifications) {
    if (un.stolenEquipId != 0) {
      NSNumber *n = [NSNumber numberWithInt:un.stolenEquipId];
      if (![sEquips objectForKey:n]) {
        [rEquips addObject:n];
        shouldSend = YES;
      }
    }
    
    if (un.marketPost.postedEquip.equipId) {
      NSNumber *n = [NSNumber numberWithInt:un.marketPost.postedEquip.equipId];
      if (![sEquips objectForKey:n]) {
        [rEquips addObject:n];
        shouldSend = YES;
      }
    }
  }
  
  if (gs.forgeAttempt) {
    NSNumber *n = [NSNumber numberWithInt:gs.forgeAttempt.equipId];
    if (![sEquips objectForKey:n]) {
      [rEquips addObject:n];
      shouldSend = YES;
    }
  }
  
  if (shouldSend) {
    int tag = [sc sendRetrieveStaticDataMessageWithStructIds:nil /*[rStructs allObjects]*/ taskIds:[rTasks allObjects] questIds:nil cityIds:nil equipIds:nil /*[rEquips allObjects]*/ buildStructJobIds:[rBuildStructJobs allObjects] defeatTypeJobIds:[rDefeatTypeJobs allObjects] possessEquipJobIds:[rPossessEquipJobs allObjects] upgradeStructJobIds:[rUpgradeStructJobs allObjects] lockBoxEvents:YES clanTierLevels:NO bossIds:nil];
    [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
  }
}

- (void) retrieveStaticEquip:(int)equipId {
  GameState *gs = [GameState sharedGameState];
  NSNumber *n = [NSNumber numberWithInt:equipId];
  if (![gs.staticEquips objectForKey:n] && equipId != 0) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendRetrieveStaticDataMessageWithStructIds:nil taskIds:nil questIds:nil cityIds:nil equipIds:[NSArray arrayWithObject:[NSNumber numberWithInt:equipId]] buildStructJobIds:nil defeatTypeJobIds:nil possessEquipJobIds:nil upgradeStructJobIds:nil lockBoxEvents:NO clanTierLevels:NO bossIds:nil];
    [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
  }
}

- (void) retrieveStaticEquips:(NSArray *)equipIds {
  GameState *gs = [GameState sharedGameState];
  
  NSMutableArray *arr = [NSMutableArray arrayWithCapacity:equipIds.count];
  for (NSNumber *n in arr) {
    if (![gs.staticEquips objectForKey:n] && n != 0) {
      [arr addObject:equipIds];
    }
  }
  
  int tag = [[SocketCommunication sharedSocketCommunication] sendRetrieveStaticDataMessageWithStructIds:nil taskIds:nil questIds:nil cityIds:nil equipIds:arr buildStructJobIds:nil defeatTypeJobIds:nil possessEquipJobIds:nil upgradeStructJobIds:nil lockBoxEvents:NO clanTierLevels:NO bossIds:nil];
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) retrieveStaticEquipsForUser:(FullUserProto *)fup {
  [self retrieveStaticEquips:[NSArray arrayWithObjects:
                              [NSNumber numberWithInt:fup.weaponEquippedUserEquip.equipId],
                              [NSNumber numberWithInt:fup.armorEquippedUserEquip.equipId],
                              [NSNumber numberWithInt:fup.amuletEquippedUserEquip.equipId],
                              nil]];
}

- (void) retrieveStaticEquipsForUsers:(NSArray *)users {
  NSMutableSet *ids = [NSMutableSet set];
  for (FullUserProto *fup in users) {
    [ids addObject:[NSNumber numberWithInt:fup.weaponEquippedUserEquip.equipId]];
    [ids addObject:[NSNumber numberWithInt:fup.armorEquippedUserEquip.equipId]];
    [ids addObject:[NSNumber numberWithInt:fup.amuletEquippedUserEquip.equipId]];
  }
  [self retrieveStaticEquips:[ids allObjects]];
}

- (void) retrieveStructStore {
  GameState *gs = [GameState sharedGameState];
  int tag = [[SocketCommunication sharedSocketCommunication] sendRetrieveStaticDataFromShopMessage:RetrieveStaticDataForShopRequestProto_RetrieveForShopTypeAllStructures];
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) retrieveEquipStore {
  // Used primarily for profile and battle
  GameState *gs = [GameState sharedGameState];
  int tag = [[SocketCommunication sharedSocketCommunication] sendRetrieveStaticDataFromShopMessage:RetrieveStaticDataForShopRequestProto_RetrieveForShopTypeEquipmentForArmory];
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) loadPlayerCity:(int)userId {
  GameState *gs = [GameState sharedGameState];
  
  int tag = [[SocketCommunication sharedSocketCommunication] sendLoadPlayerCityMessage:userId];
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) loadNeutralCity:(int)cityId {
  GameState *gs = [GameState sharedGameState];
  FullCityProto *city = [gs cityWithId:cityId];
  MapViewController *mvc = [MapViewController isInitialized] ? [MapViewController sharedMapViewController] : nil;
  
  if (!city) {
    [Globals popupMessage:@"You are not high enough level to access this city!"];
    return;
  }
  if ([[GameLayer sharedGameLayer] currentCity] == city.cityId) {
    [mvc close];
    return;
  }
  
  if (city.minLevel <= gs.level) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendLoadNeutralCityMessage:city.cityId];
    
    if (![BattleLayer isInitialized] || ![[BattleLayer sharedBattleLayer] isRunning]) {
      GameLayer *glay = [GameLayer sharedGameLayer];
      [glay.currentMap pickUpAllDrops];
      [glay.loadingView displayWithText:[NSString stringWithFormat:@"Traveling to %@", city.name]];
    }
    
    // Load any tasks we don't have as well
    NSDictionary *sTasks = [gs staticTasks];
    NSMutableSet *rTasks = [NSMutableSet set];
    for (NSNumber *taskId in city.taskIdsList) {
      if (![sTasks objectForKey:taskId]) {
        [rTasks addObject:taskId];
      }
    }
    NSDictionary *sBosses = [gs staticBosses];
    NSMutableSet *rBosses = [NSMutableSet set];
    for (NSNumber *bossId in city.bossIdsList) {
      if (![sBosses objectForKey:bossId]) {
        [rBosses addObject:bossId];
      }
    }
    
    if (rTasks.count > 0 || rBosses.count > 0) {
      [[SocketCommunication sharedSocketCommunication] sendRetrieveStaticDataMessageWithStructIds:nil taskIds:[rTasks allObjects] questIds:nil cityIds:nil equipIds:nil buildStructJobIds:nil defeatTypeJobIds:nil possessEquipJobIds:nil upgradeStructJobIds:nil lockBoxEvents:NO clanTierLevels:NO bossIds:[rBosses allObjects]];
    }
    
    [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
  } else {
    [Globals popupMessage:@"Trying to visit city above your level."];
  }
}

- (void) loadNeutralCity:(int)cityId asset:(int)assetId {
  if (cityId == 0) {
    if (assetId == 1) {
      [[GameLayer sharedGameLayer] loadHomeMap];
      [[HomeMap sharedHomeMap] moveToTutorialGirlAnimated:YES];
    } else if (assetId == 2) {
      [[GameLayer sharedGameLayer] loadBazaarMap];
      [[BazaarMap sharedBazaarMap] moveToQuestGiverAnimated:YES];
    }
  } else {
    if ([[GameLayer sharedGameLayer] currentCity] == cityId) {
      if (assetId != 0) {
        [[[GameLayer sharedGameLayer] missionMap] moveToAssetId:assetId animated:YES];
      }
    } else {
      [[GameLayer sharedGameLayer] setAssetId: assetId];
      [self loadNeutralCity:cityId];
    }
  }
}

- (void) loadNeutralCity:(int)cityId enemyType:(DefeatTypeJobProto_DefeatTypeJobEnemyType)type {
  GameState *gs = [GameState sharedGameState];
  FullCityProto *city = [gs cityWithId:cityId];
  
  if ([[GameLayer sharedGameLayer] currentCity] == city.cityId) {
    [[[GameLayer sharedGameLayer] missionMap] moveToEnemyType:type animated:YES];
  } else {
    [[GameLayer sharedGameLayer] setEnemyType:type];
    [self loadNeutralCity:cityId];
  }
}

- (void) changeUserLocationWithCoordinate:(CLLocationCoordinate2D)coord {
  CGFloat lat = coord.latitude;
  CGFloat lon = coord.longitude;
  GameState *gs = [GameState sharedGameState];
  if (!(lat > 90 || lat < -90 || lon > 180 || lon < -180)) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendChangeUserLocationMessageWithLatitude:lat longitude:lon];
    [gs setLocation:coord];
    [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
  } else {
    [Globals popupMessage:@"Trying to change user location with coordinates out of bounds."];
  }
}

- (void) levelUp {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (gs.level >= gl.maxLevelForUser) {
    [Globals popupMessage:@"Trying to level up when already at maximum level."];
  } else if (gs.experience >= gs.expRequiredForNextLevel) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendLevelUpMessage];
    
    LevelUpdate *lu = [LevelUpdate updateWithTag:tag change:1];
    EnergyUpdate *eu = [EnergyUpdate updateWithTag:tag change:gs.maxEnergy-gs.currentEnergy];
    StaminaUpdate *su = [StaminaUpdate updateWithTag:tag change:gs.maxStamina-gs.currentStamina];
    ExpForNextLevelUpdate *efnlu = [ExpForNextLevelUpdate updateWithTag:tag prevLevel:gs.expRequiredForCurrentLevel curLevel:gs.expRequiredForNextLevel nextLevel:10000000];
    [gs addUnrespondedUpdates:lu, eu, su, efnlu, nil];
    
    [[TopBar sharedTopBar] setUpEnergyTimer];
    [[TopBar sharedTopBar] setUpStaminaTimer];
  } else {
    [Globals popupMessage:@"Trying to level up without enough experience"];
  }
}

- (void) acceptQuest:(int)questId {
  GameState *gs = [GameState sharedGameState];
  NSNumber *questIdNum = [NSNumber numberWithInt:questId];
  FullQuestProto *fqp = [gs.availableQuests objectForKey:questIdNum];
  
  if (fqp) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendQuestAcceptMessage:questId];
    [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
    
    [gs.availableQuests removeObjectForKey:questIdNum];
    [gs.inProgressIncompleteQuests setObject:fqp forKey:questIdNum];
    
    GameMap *map = [Globals mapForQuest:fqp];
    [map questAccepted:fqp];
    
    [[TopBar sharedTopBar] setQuestBadgeAnimated:NO];
    
    [Analytics questAccept:questId];
  } else {
    [Globals popupMessage:@"Attempting to accept unavailable quest"];
  }
}

- (void) redeemQuest:(int)questId {
  GameState *gs = [GameState sharedGameState];
  NSNumber *questIdNum = [NSNumber numberWithInt:questId];
  FullQuestProto *fqp = [gs.inProgressCompleteQuests objectForKey:questIdNum];
  
  if (fqp) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendQuestRedeemMessage:questId];
    
    [gs.inProgressCompleteQuests removeObjectForKey:questIdNum];
    SilverUpdate *su = [SilverUpdate updateWithTag:tag change:fqp.coinsGained];
    ExperienceUpdate *eu = [ExperienceUpdate updateWithTag:tag change:fqp.expGained];
    
    [gs addUnrespondedUpdates:su, eu, nil];
    
    GameMap *map = [Globals mapForQuest:fqp];
    [map questRedeemed:fqp];
    
    [Analytics questRedeem:questId];
  } else {
    [Globals popupMessage:@"Attempting to redeem quest that is not in progress"];
  }
}

- (void) retrieveQuestLog {
  GameState *gs = [GameState sharedGameState];
  int tag = [[SocketCommunication sharedSocketCommunication] sendUserQuestDetailsMessage:0];
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) retrieveQuestDetails:(int)questId {
  if (questId == 0) {
    [Globals popupMessage:@"Attempting to retrieve information about quest 0"];
    return;
  }
  NSNumber *num = [NSNumber numberWithInt:questId];
  GameState *gs = [GameState sharedGameState];
  if ([gs.inProgressCompleteQuests.allKeys containsObject:num] || [gs.inProgressIncompleteQuests.allKeys containsObject:num]) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendUserQuestDetailsMessage:questId];
    [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
  } else {
    [Globals popupMessage:@"Attempting to retrieve information about un-accepted quest"];
  }
}

- (void) retrieveEquipsForUser:(int)userId {
  if (userId == 0) {
    [Globals popupMessage:@"Attempting to retrieve equips for user 0"];
    return;
  }
  GameState *gs = [GameState sharedGameState];
  int tag = [[SocketCommunication sharedSocketCommunication] sendRetrieveUserEquipForUserMessage:userId];
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) retrieveUsersForUserIds:(NSArray *)userIds {
  GameState *gs = [GameState sharedGameState];
  int tag = [[SocketCommunication sharedSocketCommunication] sendRetrieveUsersForUserIds:[[NSSet setWithArray:userIds] allObjects]];
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) retrieveMostRecentWallPostsForPlayer:(int)playerId {
  GameState *gs = [GameState sharedGameState];
  int tag = [[SocketCommunication sharedSocketCommunication] sendRetrievePlayerWallPostsMessage:playerId beforePostId:0];
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) retrieveWallPostsForPlayer:(int)playerId beforePostId:(int)postId {
  GameState *gs = [GameState sharedGameState];
  int tag = [[SocketCommunication sharedSocketCommunication] sendRetrievePlayerWallPostsMessage:playerId beforePostId:postId];
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (PlayerWallPostProto *) postToPlayerWall:(int)playerId withContent:(NSString *)content {
  Globals *gl = [Globals sharedGlobals];
  if (content.length <= 0 || content.length > gl.maxCharLengthForWallPost) {
    [Globals popupMessage:@"Attempting to post on player wall with incorrect content length."];
    return nil;
  }
  if (playerId <= 0) {
    [Globals popupMessage:@"Attempting to post on player 0's wall."];
    return nil;
  }
  
  int tag = [[SocketCommunication sharedSocketCommunication] sendPostOnPlayerWallMessage:playerId withContent:content];
  
  GameState *gs = [GameState sharedGameState];
  PlayerWallPostProto_Builder *bldr = [PlayerWallPostProto builder];
  bldr.playerWallPostId = 0;
  bldr.poster = gs.minUser;
  bldr.wallOwnerId = playerId;
  bldr.content = content;
  bldr.timeOfPost = [[NSDate date] timeIntervalSince1970]*1000;
  
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
  
  return [bldr build];
}

- (void) enableApns:(NSData *)deviceToken {
  GameState *gs = [GameState sharedGameState];
  
  NSString *str = nil;
  if (deviceToken) {
    str = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
  }
  
  gs.deviceToken = str;
  
  while (gs.userId == 0) {
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.f]];
    
    if (gs.isTutorial) {
      return;
    }
  }
  
  int tag = [[SocketCommunication sharedSocketCommunication] sendAPNSMessage:str];
  
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) kiipReward:(int)gold receipt:(NSString *)string {
  GameState *gs = [GameState sharedGameState];
  int tag = [[SocketCommunication sharedSocketCommunication] sendEarnFreeDiamondsKiipMessageClientTime:[self getCurrentMilliseconds] receipt:string];
  [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:gold]];
}

- (void) adColonyRewardWithAmount:(int)amount type:(EarnFreeDiamondsRequestProto_AdColonyRewardType)type {
  GameState *gs = [GameState sharedGameState];
  
  uint64_t time = [self getCurrentMilliseconds];
  NSString *preparedText = [NSString stringWithFormat:@"%d%@%d%d%llu",
                            gs.userId,
                            gs.referralCode,
                            amount,
                            type,
                            time];
  id<OASignatureProviding> signer = [[OAHMAC_SHA1SignatureProvider alloc] init];
  NSString *digest = [signer signClearText:preparedText
                                withSecret:LVL6_SHARED_SECRET];
  [signer release];
  
  int tag = [[SocketCommunication sharedSocketCommunication]
             sendEarnFreeDiamondsAdColonyMessageClientTime:time
             digest:digest
             amount:amount
             type:type];
  
  NSString *typeStr = @"";
  if (type == EarnFreeDiamondsRequestProto_AdColonyRewardTypeCoins) {
    typeStr = @"Silver";
    [gs addUnrespondedUpdate:[SilverUpdate updateWithTag:tag change:amount]];
  } else if (type == EarnFreeDiamondsRequestProto_AdColonyRewardTypeDiamonds) {
    typeStr = @"Gold";
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:amount]];
  }
  [Globals popupMessage:[NSString stringWithFormat:@"Congratulations! You just earned %d %@!", amount, typeStr]];
  gs.numAdColonyVideosWatched++;
  
  // Call this to update the cur gold label UI
  [[GoldShoppeViewController sharedGoldShoppeViewController] update];
  
  [Analytics watchedAdColony];
}

- (BOOL) submitEquipsToBlacksmithWithUserEquipId:(int)equipOne userEquipId:(int)equipTwo guaranteed:(BOOL)guaranteed {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (gs.forgeAttempt) {
    [Globals popupMessage:@"Attempting to forge equip when forging is already taking place."];
    return NO;
  }
  
  if (equipOne != equipTwo) {
    UserEquip *ue1 = [gs myEquipWithUserEquipId:equipOne];
    UserEquip *ue2 = [gs myEquipWithUserEquipId:equipTwo];
    
    if (ue1.level > 9) {
      [Globals popupMessage:@"Attempting to forge two equips that are already at max level."];
    } else if (ue1.equipId == ue2.equipId && ue1.level == ue2.level) {
      int goldCost = 0;
      if (guaranteed) {
        goldCost = [gl calculateGoldCostToGuaranteeForgingSuccess:ue1.equipId level:ue1.level];
        if (goldCost > gs.gold) {
          [Globals popupMessage:@"Attempting to guarantee forge success without enough gold."];
          return NO;
        }
      }
      
      int tag = [sc sendSubmitEquipsToBlacksmithMessageWithUserEquipId:equipOne userEquipId:equipTwo guaranteed:guaranteed clientTime:[self getCurrentMilliseconds]];
      
      ChangeEquipUpdate *ceu1 = [ChangeEquipUpdate updateWithTag:tag userEquip:ue1 remove:YES];
      ChangeEquipUpdate *ceu2 = [ChangeEquipUpdate updateWithTag:tag userEquip:ue2 remove:YES];
      GoldUpdate *gu = guaranteed ? [GoldUpdate updateWithTag:tag change:-goldCost] : nil;
      [gs addUnrespondedUpdates:ceu1, ceu2, gu, nil];
      
      return YES;
    } else {
      [Globals popupMessage:@"Attempting to forge two different equips or equips of different level."];
    }
  } else {
    [Globals popupMessage:@"Attempting to forge two equips with the same id."];
  }
  
  return NO;
}

- (void) forgeAttemptWaitComplete {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int blacksmithId = gs.forgeAttempt.blacksmithId;
  NSDate *now = [NSDate date];
  float timeInterval = [now timeIntervalSinceDate:gs.forgeAttempt.startTime]/60.f;
  int minutes = [gl calculateMinutesForForge:gs.forgeAttempt.equipId level:gs.forgeAttempt.level];
  
  if (gs.forgeAttempt.isComplete) {
    [Globals popupMessage:@"Attempting to complete forge when it is already complete."];
  } else if (timeInterval > minutes) {
    gs.forgeAttempt.isComplete = YES;
    [gs stopForgeTimer];
    
    ForgeMenuController *fmc = [ForgeMenuController sharedForgeMenuController];
    
    if (gs.forgeAttempt.level == fmc.curItem.level && gs.forgeAttempt.equipId == fmc.curItem.equipId) {
      [fmc reloadCurrentItem];
    }
    
    int tag = [sc sendForgeAttemptWaitCompleteMessageWithBlacksmithId:blacksmithId clientTime:[self getCurrentMilliseconds]];
    NoUpdate *nu = [NoUpdate updateWithTag:tag];
    [gs addUnrespondedUpdate:nu];
  } else {
    [Globals popupMessage:@"Attempting to complete forge before it is ready."];
  }
}

- (void) finishForgeAttemptWaittimeWithDiamonds {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int goldCost = [gl calculateGoldCostToSpeedUpForging:gs.forgeAttempt.equipId level:gs.forgeAttempt.level];
  
  if (gs.forgeAttempt.isComplete) {
    [Globals popupMessage:@"Attempting to complete forge with diamonds when it is already complete."];
  } else if (goldCost <= gs.gold) {
    gs.forgeAttempt.isComplete = YES;
    gs.forgeAttempt.speedupTime = [NSDate date];
    [gs stopForgeTimer];
    
    int tag = [sc sendFinishForgeAttemptWaittimeWithDiamondsWithBlacksmithId:gs.forgeAttempt.blacksmithId clientTime:[self getCurrentMilliseconds]];
    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:-goldCost];
    [gs addUnrespondedUpdate:gu];
  } else {
    [Globals popupMessage:@"Attempting to complete forge without enough diamonds."];
  }
}

- (void) collectForgeEquips {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  GameState *gs = [GameState sharedGameState];
  
  if (gs.forgeAttempt.isComplete) {
    int tag = [sc sendCollectForgeEquipsWithBlacksmithId:gs.forgeAttempt.blacksmithId];
    NoUpdate *nu = [NoUpdate updateWithTag:tag];
    [gs addUnrespondedUpdate:nu];
  } else {
    [Globals popupMessage:@"Attempting to collect forge equips before it is complete."];
  }
}

- (void) resetStats {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  
  int cost = gl.diamondCostToResetSkillPoints;
  if (gs.gold >= cost) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendCharacterModWithType:CharacterModTypeResetSkillPoints newType:0 newName:nil];
    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:-cost];
    [gs addUnrespondedUpdate:gu];
  } else {
    [Globals popupMessage:@"Attempting to reset stats without enough gold"];
  }
}

- (void) resetName:(NSString *)name {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  
  int cost = gl.diamondCostToChangeName;
  if (gs.gold >= cost) {
    int tag =  [[SocketCommunication sharedSocketCommunication] sendCharacterModWithType:CharacterModTypeChangeName newType:0 newName:name];;
    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:-cost];
    [gs addUnrespondedUpdate:gu];
    
    gs.name = name;
  } else {
    [Globals popupMessage:@"Attempting to reset name without enough gold"];
  }
}

- (void) changeUserType:(UserType)type {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  
  int cost = gl.diamondCostToChangeCharacterType;
  if (gs.clan && ![Globals userType:type isAlliesWith:gs.type]) {
    [Globals popupMessage:@"Attempting to switch sides while in a clan."];
  } else if (gs.type == type) {
    [Globals popupMessage:@"Attempting to switch to same side."];
  } else if (gs.gold >= cost) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendCharacterModWithType:CharacterModTypeChangeCharacterType newType:type newName:nil];;
    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:-cost];
    [gs addUnrespondedUpdate:gu];
    
    gs.type = type;
    
    [GameLayer purgeSingleton];
    [[TopBar sharedTopBar] invalidateTimers];
    [TopBar purgeSingleton];
    [[HomeMap sharedHomeMap] invalidateAllTimers];
    [HomeMap purgeSingleton];
    [BazaarMap purgeSingleton];
    [[[CCDirector sharedDirector] runningScene] removeAllChildrenWithCleanup:YES];
  } else {
    [Globals popupMessage:@"Attempting to change user type without enough gold"];
  }
}

- (void) resetGame {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  
  int cost = gl.diamondCostToResetCharacter;
  if (gs.clan) {
    [Globals popupMessage:@"Attempting to reset game while in a clan."];
  } else if (gs.gold >= cost) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendCharacterModWithType:CharacterModTypeNewPlayer newType:0 newName:nil];
    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:-cost];
    [gs addUnrespondedUpdate:gu];
  } else {
    [Globals popupMessage:@"Attempting to reset character without enough gold"];
  }
}

- (void) retrieveLeaderboardForType:(LeaderboardType)type {
  [[SocketCommunication sharedSocketCommunication] sendRetrieveLeaderboardMessage:type afterRank:0];
}

- (void) retrieveLeaderboardForType:(LeaderboardType)type afterRank:(int)afterRank {
  [[SocketCommunication sharedSocketCommunication] sendRetrieveLeaderboardMessage:type afterRank:afterRank];
}

- (void) sendGroupChat:(GroupChatScope)scope message:(NSString *)msg {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (msg.length > gl.maxLengthOfChatString) {
    [Globals popupMessage:@"Attempting to send msg that exceeds appropriate length"];
  } else {
    //  if ((scope == GroupChatScopeGlobal && gs.numGroupChatsRemaining > 0) || (scope != GroupChatScopeGlobal)) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendGroupChatMessage:scope message:msg clientTime:[self getCurrentMilliseconds]];
    
    if (scope == GroupChatScopeGlobal) {
      [gs addUnrespondedUpdate:[ChatUpdate updateWithTag:tag change:-1]];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
      [gs addChatMessage:gs.minUser message:msg scope:scope isAdmin:gs.isAdmin];
    });
    //  } else {
    //    [Globals popupMessage:@"Attempting to send chat without any speakers"];
    //  }
  }
}

- (void) purchaseGroupChats {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (gs.gold >= gl.diamondPriceForGroupChatPurchasePackage) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendPurchaseGroupChatMessage];
    ChatUpdate *cu = [ChatUpdate updateWithTag:tag change:gl.numChatsGivenPerGroupChatPurchasePackage];
    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:-gl.diamondPriceForGroupChatPurchasePackage];
    [gs addUnrespondedUpdates:cu, gu, nil];
  } else {
    [Globals popupMessage:@"Attempting to purchase chat without enough gold."];
  }
}

- (int) createClan:(NSString *)clanName tag:(NSString *)clanTag {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  
  if (clanName.length <= 0 || clanName.length > gl.maxCharLengthForClanName) {
    [Globals popupMessage:@"Attempting to create clan with inappropriate clan name length."];
  } else if (clanTag.length <= 0 || clanTag.length > gl.maxCharLengthForClanTag) {
    [Globals popupMessage:@"Attempting to create clan with inappropriate clan tag length."];
  } else if (gs.gold < gl.diamondPriceToCreateClan) {
    [Globals popupMessage:@"Attempting to create clan without enough gold."];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendCreateClanMessage:clanName tag:clanTag];
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-gl.diamondPriceToCreateClan]];
    return tag;
  }
  return 0;
}

- (int) leaveClan {
  GameState *gs = [GameState sharedGameState];
  
  // Make sure clan controller checks member size and clan leader
  if (gs.clan) {
    return [[SocketCommunication sharedSocketCommunication] sendLeaveClanMessage];
  } else {
    [Globals popupMessage:@"Attempting to leave clan without being in clan."];
  }
  return 0;
}

- (int) requestJoinClan:(int)clanId {
  GameState *gs = [GameState sharedGameState];
  
  if (gs.clan) {
    [Globals popupMessage:@"Attempting to request to join clan while in a clan."];
  } else if ([gs.requestedClans containsObject:[NSNumber numberWithInt:clanId]]) {
    [Globals popupMessage:@"Attempting to send multiple requests to join clan."];
  } else {
    return [[SocketCommunication sharedSocketCommunication] sendRequestJoinClanMessage:clanId];
  }
  return 0;
}

- (int) retractRequestToJoinClan:(int)clanId {
  GameState *gs = [GameState sharedGameState];
  
  if (gs.clan) {
    [Globals popupMessage:@"Attempting to retract clan request while in a clan."];
  } else if (![gs.requestedClans containsObject:[NSNumber numberWithInt:clanId]]) {
    [Globals popupMessage:@"Attempting to retract invalid clan request."];
  } else {
    return [[SocketCommunication sharedSocketCommunication] sendRetractRequestJoinClanMessage:clanId];
  }
  return 0;
}

- (int) approveOrRejectRequestToJoinClan:(int)requesterId accept:(BOOL)accept {
  GameState *gs = [GameState sharedGameState];
  
  if (!gs.clan || gs.clan.ownerId != gs.userId) {
    [Globals popupMessage:@"Attempting to respond to clan request while not clan leader."];
  } else {
    return [[SocketCommunication sharedSocketCommunication] sendApproveOrRejectRequestToJoinClan:requesterId accept:accept];
  }
  return 0;
}

- (int) transferClanOwnership:(int)newClanOwnerId {
  GameState *gs = [GameState sharedGameState];
  
  if (!gs.clan || gs.clan.ownerId != gs.userId) {
    [Globals popupMessage:@"Attempting to transfer clan ownership while not clan leader."];
  } else {
    return [[SocketCommunication sharedSocketCommunication] sendTransferClanOwnership:newClanOwnerId];
  }
  return 0;
}

- (int) changeClanDescription:(NSString *)description {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (!gs.clan || gs.clan.ownerId != gs.userId) {
    [Globals popupMessage:@"Attempting to change clan description while not clan leader."];
  } else if (description.length <= 0 || description.length > gl.maxCharLengthForClanDescription) {
    [Globals popupMessage:@"Attempting to change clan description with inappropriate length"];
  } else {
    return [[SocketCommunication sharedSocketCommunication] sendChangeClanDescription:description];
  }
  return 0;
}

- (int) bootPlayerFromClan:(int)playerId {
  GameState *gs = [GameState sharedGameState];
  
  if (!gs.clan || gs.clan.ownerId != gs.userId) {
    [Globals popupMessage:@"Attempting to boot player while not clan leader."];
  } else {
    return [[SocketCommunication sharedSocketCommunication] sendBootPlayerFromClan:playerId];
  }
  return 0;
}

- (void) retrieveClanInfo:(NSString *)clanName clanId:(int)clanId grabType:(RetrieveClanInfoRequestProto_ClanInfoGrabType)grabType isForBrowsingList:(BOOL)isForBrowsingList  beforeClanId:(int)beforeClanId {
  int tag = [[SocketCommunication sharedSocketCommunication] sendRetrieveClanInfoMessage:clanName clanId:clanId grabType:grabType isForBrowsingList:isForBrowsingList beforeClanId:beforeClanId];
  
  GameState *gs = [GameState sharedGameState];
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (ClanBulletinPostProto *) postOnClanBulletin:(NSString *)content {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  if (content.length <= 0 || content.length > gl.maxCharLengthForWallPost) {
    [Globals popupMessage:@"Attempting to post on clan wall with no content."];
    return nil;
  }
  if (!gs.clan) {
    [Globals popupMessage:@"Attempting to post on clan wall while not in a clan."];
    return nil;
  }
  if (gs.userId != gs.clan.ownerId) {
    [Globals popupMessage:@"You must be the leader to post on the clan board."];
    return nil;
  }
  
  int tag = [[SocketCommunication sharedSocketCommunication] sendPostOnClanBulletinMessage:content];
  
  ClanBulletinPostProto_Builder *bldr = [ClanBulletinPostProto builder];
  bldr.clanBulletinPostId = 0;
  bldr.poster = gs.minUser;
  bldr.content = content;
  bldr.timeOfPost = [[NSDate date] timeIntervalSince1970]*1000;
  
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
  
  return [bldr build];
}

- (void) retrieveClanBulletinPosts:(int)beforeThisPostId {
  GameState *gs = [GameState sharedGameState];
  int tag = [[SocketCommunication sharedSocketCommunication] sendRetrieveClanBulletinPostsMessage:beforeThisPostId];
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) upgradeClanTierLevel {
  GameState *gs = [GameState sharedGameState];
  ClanTierLevelProto *p = [gs clanTierForLevel:gs.clan.currentTierLevel];
  int cost = p.upgradeCost;
  
  if (gs.clan.ownerId != gs.userId) {
    [Globals popupMessage:@"Attempting to upgrade clan tier level while not leader."];
  } else if (gs.gold < cost) {
    [Globals popupMessage:@"Attempting to upgrade clan tier level without enough gold."];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendUpgradeClanTierLevelMessage];
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-cost]];
  }
}

- (void) beginGoldmineTimer {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  BOOL reset = NO;
  if (gs.lastGoldmineRetrieval) {
    if (gs.gold < gl.goldCostForGoldmineRestart) {
      [Globals popupMessage:@"Attempting to restart goldmine without enough gold"];
    }
    reset = YES;
  }
  
  uint64_t clientTime = [self getCurrentMilliseconds];
  int tag = [[SocketCommunication sharedSocketCommunication] sendBeginGoldmineTimerMessage:clientTime reset:reset];
  
  if (reset) {
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-gl.goldCostForGoldmineRestart]];
  }
  
  NSDate *nextDate = reset ? nil : [NSDate dateWithTimeIntervalSince1970:clientTime/1000.0];
  [gs addUnrespondedUpdate:[GoldmineTimeUpdate updateWithTag:tag prevDate:gs.lastGoldmineRetrieval nextDate:nextDate]];
  
  [gs beginGoldmineTimer];
}

- (void) collectFromGoldmine {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (!gs.lastGoldmineRetrieval) {
    [Globals popupMessage:@"Attempting to collect from goldmine when it is not started"];
    return;
  }
  
  NSTimeInterval timeInterval = -[gs.lastGoldmineRetrieval timeIntervalSinceNow];
  float timeToEnd = 3600.f*(gl.numHoursBeforeGoldmineRetrieval+gl.numHoursForGoldminePickup);
  
  if (timeInterval > timeToEnd) {
    [Globals popupMessage:@"Attempting to collect from goldmine after missing pickup time"];
  } else if (timeInterval > 3600*(gl.numHoursBeforeGoldmineRetrieval+gl.numHoursForGoldminePickup)) {
    [Globals popupMessage:@"Attempting to collect from goldmine after missing pickup time"];
  } else {
    
    uint64_t clientTime = [self getCurrentMilliseconds];
    int tag = [[SocketCommunication sharedSocketCommunication] sendCollectFromGoldmineMessage:clientTime];
    
    [gs addUnrespondedUpdates:[GoldUpdate updateWithTag:tag change:gl.goldAmountFromGoldminePickup], [GoldmineTimeUpdate updateWithTag:tag prevDate:gs.lastGoldmineRetrieval nextDate:[gs.lastGoldmineRetrieval dateByAddingTimeInterval:timeToEnd]], nil];
    
    [gs beginGoldmineTimer];
  }
}

- (void) pickLockBox:(int)eventId method:(PickLockBoxRequestProto_PickLockBoxMethod)method {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  LockBoxEventProto *lbe = [gs getCurrentLockBoxEvent];
  UserLockBoxEventProto *ulbe = [gs.myLockBoxEvents objectForKey:[NSNumber numberWithInt:lbe.lockBoxEventId]];
  
  int goldCost = method == PickLockBoxRequestProto_PickLockBoxMethodGold ? gl.goldCostToPickLockBox : 0;
  int silverCost = method == PickLockBoxRequestProto_PickLockBoxMethodSilver ? gl.silverCostToPickLockBox : 0;
  uint64_t ms = [self getCurrentMilliseconds];
  uint64_t pickTime = ulbe.lastPickTime + 60000*gl.numMinutesToRepickLockBox;
  if (ms < pickTime){
    goldCost += gl.goldCostToResetPickLockBox;
  }
  if (gs.gold < goldCost || gs.silver < silverCost) {
    [Globals popupMessage:@"Attempting to pick lock box without enough currency"];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendPickLockBoxMessage:eventId method:method clientTime:[self getCurrentMilliseconds]];
    
    [gs addUnrespondedUpdates:[GoldUpdate updateWithTag:tag change:-goldCost], [SilverUpdate updateWithTag:tag change:-silverCost], nil];
  }
}

- (void) purchaseCityExpansion:(ExpansionDirection)direction {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserExpansion *ue = gs.userExpansion;
  
  int silverCost = [gl calculateSilverCostForNewExpansion:ue];
  if (gs.silver < silverCost) {
    [Globals popupMessage:@"Attempting to expand without enough silver"];
  } else if (ue.isExpanding) {
    [Globals popupMessage:@"Attempting to expand while already expanding"];
  } else {
    uint64_t ms = [self getCurrentMilliseconds];
    int tag = [[SocketCommunication sharedSocketCommunication] sendPurchaseCityExpansionMessage:direction timeOfPurchase:ms];
    [gs addUnrespondedUpdate:[SilverUpdate updateWithTag:tag change:-silverCost]];
    
    if (!ue) {
      ue = [[UserExpansion alloc] init];
      ue.userId = gs.userId;
    }
    
    ue.isExpanding = YES;
    ue.lastExpandDirection = direction;
    ue.lastExpandTime = [NSDate dateWithTimeIntervalSince1970:ms/1000.0];
    gs.userExpansion = ue;
    
    [gs beginExpansionTimer];
  }
}

- (void) expansionWaitComplete:(BOOL)speedUp {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserExpansion *ue = gs.userExpansion;
  
  int goldCost = speedUp ? [gl calculateGoldCostToSpeedUpExpansion:ue] : 0;
  if (gs.gold < goldCost) {
    [Globals popupMessage:@"Attempting to speedup without enough gold"];
  } else if (!ue.isExpanding) {
    [Globals popupMessage:@"Attempting to complete expansion while not expanding"];
  } else if (!speedUp && [[NSDate date] compare:[ue.lastExpandTime dateByAddingTimeInterval:[gl calculateNumMinutesForNewExpansion:ue]*60]] == NSOrderedAscending) {
    [Globals popupMessage:@"Attempting to complete expansion before it is ready"];
  } else {
    uint64_t ms = [self getCurrentMilliseconds];
    int tag = [[SocketCommunication sharedSocketCommunication] sendExpansionWaitCompleteMessage:speedUp curTime:ms];
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-goldCost]];
    
    ue.isExpanding = NO;
    
    switch (ue.lastExpandDirection) {
      case ExpansionDirectionFarLeft:
        ue.farLeftExpansions++;
        break;
      case ExpansionDirectionFarRight:
        ue.farRightExpansions++;
        break;
      case ExpansionDirectionNearLeft:
        ue.nearLeftExpansions++;
        break;
      case ExpansionDirectionNearRight:
        ue.nearRightExpansions++;
        break;
      default:
        break;
    }
    
    [gs stopExpansionTimer];
  }
}

-(void) retrieveThreeCardMonte {
  GameState *gs = [GameState sharedGameState];
  int tag = [[SocketCommunication sharedSocketCommunication] sendRetrieveThreeCardMonteMessage];
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

-(void) playThreeCardMonte:(int)cardID {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  
  if (gs.gold < gl.diamondCostToPlayThreeCardMonte) {
    [Globals popupMessage:@"Attempting to play three card monte without enough gold."];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendPlayThreeCardMonteMessage:cardID];
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-gl.diamondCostToPlayThreeCardMonte]];
  }
}

- (void) bossAction:(UserBoss *)ub {
  GameState *gs = [GameState sharedGameState];
  FullBossProto *fbp = [gs bossWithId:ub.bossId];
  UserCity *fcp = [gs myCityWithId:fbp.cityId];
  
  if (!fcp) {
    [Globals popupMessage:@"Attempting to do boss in a locked city"];
    return;
  }
  
  if (gs.currentStamina < fbp.staminaCost) {
    [Globals popupMessage:@"Attempting to attack boss without enough stamina"];
  }
  
  int tag = [[SocketCommunication sharedSocketCommunication] sendBossActionMessage:ub.bossId curTime:[self getCurrentMilliseconds]];
  [gs addUnrespondedUpdate:[StaminaUpdate updateWithTag:tag change:-fbp.staminaCost]];
}

@end
