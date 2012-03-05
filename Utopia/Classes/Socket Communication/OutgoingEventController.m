  //
//  OutgoingEventController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/29/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "OutgoingEventController.h"
#import "SynthesizeSingleton.h"
#import "GameState.h"
#import "SocketCommunication.h"
#import "Globals.h"
#import "MarketplaceViewController.h"

@implementation OutgoingEventController

SYNTHESIZE_SINGLETON_FOR_CLASS(OutgoingEventController);

- (uint64_t) getCurrentMilliseconds {
  return (uint64_t)([[NSDate date] timeIntervalSince1970]*1000);
}

- (void) vaultDeposit:(int)amount {
  if (amount <= 0) {
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  if (amount <= gs.silver) {
    [[SocketCommunication sharedSocketCommunication] sendVaultMessage:amount requestType:VaultRequestProto_VaultRequestTypeDeposit];
    gs.silver -= amount;
    gs.vaultBalance += (int)floorf(amount * (1.f-[[Globals sharedGlobals] depositPercentCut]));
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Unable to deposit %d coins. Currently only have %d silver.", amount, gs.silver]];
  }
}

- (void) vaultWithdrawal:(int)amount {
  if (amount <= 0) {
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  if (amount <= gs.vaultBalance) {
    [[SocketCommunication sharedSocketCommunication] sendVaultMessage:amount requestType:VaultRequestProto_VaultRequestTypeWithdraw];
    gs.silver += amount;
    gs.vaultBalance -= amount;
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Unable to withdraw %d coins. Currently only have %d coins in vault.", amount, gs.vaultBalance]];
  }
}

- (BOOL) taskAction:(int)taskId {
  // Return num times acted
  GameState *gs = [GameState sharedGameState];
  FullTaskProto *ftp = [gs taskWithId:taskId];
  
  if (ftp.cityId > gs.maxCityAccessible) {
    [Globals popupMessage:@"Attempting to do task in a locked city"];
    return NO;
  }
  
  for (FullTaskProto_FullTaskEquipReqProto *equipReq in ftp.equipReqsList) {
    UserEquip *ue = [gs myEquipWithId:equipReq.equipId];
    if (!ue || ue.quantity < equipReq.quantity) {
      [Globals popupMessage:@"Attempting to do task without required equipment"];
      return NO;
    }
  }
  
  if (gs.currentEnergy < ftp.energyCost) {
    [Globals popupMessage:@"Attempting to do task without enough energy"];
  }
  
  [[SocketCommunication sharedSocketCommunication] sendTaskActionMessage:taskId curTime:[self getCurrentMilliseconds]];
  return YES;
}

- (void) battle:(int)defender {
  [[SocketCommunication sharedSocketCommunication] sendBattleMessage:defender];
}

- (int) buyEquip:(int)equipId {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:equipId];
  UserEquip *ue = nil;
  
  for (UserEquip *u in gs.myEquips) {
    if (u.equipId == equipId) {
      ue = u;
    }
  }
  
  if (gs.silver >= fep.coinPrice && gs.gold >= fep.diamondPrice) {
    [[SocketCommunication sharedSocketCommunication] sendArmoryMessage:ArmoryRequestProto_ArmoryRequestTypeBuy quantity:1 equipId:equipId];
    
    if (ue) {
      ue.quantity++;
    } else {
      ue = [[UserEquip alloc] init];
      
      ue.equipId = equipId;
      ue.userId = gs.userId;
      ue.quantity = 1;
      ue.isStolen = NO;
      [gs.myEquips addObject:ue];
    }
    
    gs.silver -= fep.coinPrice;
    gs.gold -= fep.diamondPrice;
  } else {
    [Globals popupMessage:@"Not enough money to buy this equipment"];
  }
  
  return ue.quantity;
}

- (int) sellEquip:(int)equipId {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserEquip *ue = nil;
  
  for (UserEquip *u in gs.myEquips) {
    if (u.equipId == equipId) {
      ue = u;
    }
  }
  
  if (ue) {
    [[SocketCommunication sharedSocketCommunication] sendArmoryMessage:ArmoryRequestProto_ArmoryRequestTypeSell quantity:1 equipId:equipId];
    ue.quantity--;
    
    gs.silver += [gl calculateEquipSilverSellCost:ue];
    gs.gold += [gl calculateEquipGoldSellCost:ue];
    
    if (ue.quantity == 0) {
      if (ue.equipId == gs.weaponEquipped) {
        gs.weaponEquipped = 0;
      } else if (ue.equipId == gs.armorEquipped) {
        gs.armorEquipped = 0;
      } else if (ue.equipId == gs.amuletEquipped) {
        gs.amuletEquipped = 0;
      }
      
      [gs.myEquips removeObject:ue];
      return 0;
    }
  } else {
    [Globals popupMessage:@"You do not own this equipment"];
  }
  
  return ue.quantity;
}

- (BOOL) wearEquip:(int)equipId {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [[GameState sharedGameState] equipWithId:equipId];
  UserEquip *ue = nil;
  
  for (UserEquip *u in gs.myEquips) {
    if (u.equipId == equipId) {
      ue = u;
    }
  }
  
  if (ue) {
    if (![Globals canEquip:fep]) {
      return NO;
    }
    
    if (fep.equipType == FullEquipProto_EquipTypeWeapon) {
      if (gs.weaponEquipped == equipId) {
        return NO;
      }
      gs.weaponEquipped = equipId;
    } else if (fep.equipType == FullEquipProto_EquipTypeArmor) {
      if (gs.armorEquipped == equipId) {
        return NO;
      }
      gs.armorEquipped = equipId;
    } else if (fep.equipType == FullEquipProto_EquipTypeAmulet) {
      if (gs.amuletEquipped == equipId) {
        return NO;
      }
      gs.amuletEquipped = equipId;
    }
    
    [[SocketCommunication sharedSocketCommunication] sendEquipEquipmentMessage:equipId];
  } else {
    [Globals popupMessage:@"You do not own this equip"];
    return NO;
  }
  
  return YES;
}

- (void) generateAttackList:(int)numEnemies bounds:(CGRect)bounds {
  NSLog(@"%d enemies in rect: %@", numEnemies, [NSValue valueWithCGRect:bounds]);
  if (bounds.size.width <= 0 || bounds.size.height <= 0) {
    [Globals popupMessage:@"Invalid bounds to generate attack list"];
    return;
  }
  
  if (numEnemies <= 0) {
    [Globals popupMessage:@"Invalid number of enemies to retrieve"];
    return;
  }
  
  [[SocketCommunication sharedSocketCommunication] sendGenerateAttackListMessage:numEnemies 
                                                                   latUpperBound:MIN(CGRectGetMaxY(bounds), 90)
                                                                   latLowerBound:MAX(CGRectGetMinY(bounds), -90) 
                                                                   lonUpperBound:MIN(CGRectGetMaxX(bounds), 180) 
                                                                   lonLowerBound:MAX(CGRectGetMinX(bounds), -180)];
}

- (void) startup {
  [[SocketCommunication sharedSocketCommunication] sendStartupMessage:[self getCurrentMilliseconds]];
}

- (void) inAppPurchase:(NSString *)receipt {
  [[SocketCommunication sharedSocketCommunication] sendInAppPurchaseMessage:receipt];
}

- (void) retrieveMostRecentPosts {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  [[[GameState sharedGameState] marketplaceEquipPosts] removeAllObjects];
  [sc sendRetrieveCurrentMarketplacePostsMessageBeforePostId:0 fromSender:NO];
  [[MarketplaceViewController sharedMarketplaceViewController] deleteRows:1];
}

- (void) retrieveMoreMarketplacePosts {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  GameState *gs = [GameState sharedGameState];
  FullMarketplacePostProto *x = gs.marketplaceEquipPosts.lastObject;
  if (!x) {
    return;
  }
  [sc sendRetrieveCurrentMarketplacePostsMessageBeforePostId:[x marketplacePostId] fromSender:NO];
}

- (void) retrieveMostRecentPostsFromSender {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  [[[GameState sharedGameState] marketplaceEquipPostsFromSender] removeAllObjects];
  [sc sendRetrieveCurrentMarketplacePostsMessageBeforePostId:0 fromSender:YES];
  [[MarketplaceViewController sharedMarketplaceViewController] deleteRows:1];
}

- (void) retrieveMoreMarketplacePostsFromSender {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  GameState *gs = [GameState sharedGameState];
  FullMarketplacePostProto *x = gs.marketplaceEquipPostsFromSender.lastObject;
  if (!x) {
    return;
  }
  [sc sendRetrieveCurrentMarketplacePostsMessageBeforePostId:[x marketplacePostId] fromSender:YES];
}

- (void) equipPostToMarketplace:(int)equipId silver:(int)silver gold:(int)gold {
  GameState *gs = [GameState sharedGameState];
  
  if (silver <= 0 && gold <= 0) {
    [Globals popupMessage:@"You need to enter a price!"];
    return;
  }
  
  for (FullUserEquipProto *eq in [gs myEquips]) {
    if (eq.equipId == equipId) {
      [[SocketCommunication sharedSocketCommunication] sendEquipPostToMarketplaceMessage:equipId coins:silver diamonds:gold];
      return;
    }
  }
  
  [Globals popupMessage:@"Unable to find this equip!"];
}

- (void) retractMarketplacePost:(int)postId {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  MarketplaceViewController *mvc = [MarketplaceViewController sharedMarketplaceViewController];
  
  NSMutableArray *mktPostsFromSender = [mvc postsForState];
  for (int i = 0; i < mktPostsFromSender.count; i++) {
    FullMarketplacePostProto *proto = [mktPostsFromSender objectAtIndex:i];
    if ([proto marketplacePostId] == postId) {
      [sc sendRetractMarketplacePostMessage:postId];
      [mktPostsFromSender removeObject:proto];
      NSIndexPath *y = [NSIndexPath indexPathForRow:i+1 inSection:0];
      NSIndexPath *z = mktPostsFromSender.count == 0? [NSIndexPath indexPathForRow:0 inSection:0]:nil;
      NSArray *a = [NSArray arrayWithObjects:y, z, nil];
      [mvc.postsTableView deleteRowsAtIndexPaths:a withRowAnimation:UITableViewRowAnimationTop];
      return;
    }
  }
  
  [Globals popupMessage:@"Cannot verify that this item belongs to user.."];
}

- (void) purchaseFromMarketplace:(int)postId {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  MarketplaceViewController *mvc = [MarketplaceViewController sharedMarketplaceViewController];
  
  NSMutableArray *mktPosts = [mvc postsForState];
  for (int i = 0; i < mktPosts.count; i++) {
    FullMarketplacePostProto *proto = [mktPosts objectAtIndex:i];
    if ([proto marketplacePostId] == postId) {
      [sc sendPurchaseFromMarketplaceMessage:postId poster:[proto posterId]];
      [mktPosts removeObject:proto];
      NSIndexPath *y = [NSIndexPath indexPathForRow:i+1 inSection:0];
      NSIndexPath *z = mktPosts.count == 0? [NSIndexPath indexPathForRow:0 inSection:0]:nil;
      NSArray *a = [NSArray arrayWithObjects:y, z, nil];
      [mvc.postsTableView deleteRowsAtIndexPaths:a withRowAnimation:UITableViewRowAnimationTop];
      return;
    }
  }
  
  [Globals popupMessage:@"Cannot find this item.."];
}

- (void) redeemMarketplaceEarnings {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  GameState *gs = [GameState sharedGameState];
  
  if (gs.marketplaceGoldEarnings || gs.marketplaceSilverEarnings) {
    [sc sendRedeemMarketplaceEarningsMessage];
    gs.gold += gs.marketplaceGoldEarnings;
    gs.silver += gs.marketplaceSilverEarnings;
    gs.marketplaceGoldEarnings = 0;
    gs.marketplaceSilverEarnings = 0;
  } else {
    [Globals popupMessage:@"Nothing to earn!"];
  }
}

- (void) addAttackSkillPoint {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (gs.skillPoints > 0) {
    [sc sendUseSkillPointMessage:UseSkillPointRequestProto_BoostTypeAttack];
    gs.attack += gl.attackBaseGain;
    gs.skillPoints -= gl.attackBaseCost;
  } else {
    [Globals popupMessage:@"No skill points available to add"];
  }
}

- (void) addDefenseSkillPoint {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (gs.skillPoints > 0) {
    [sc sendUseSkillPointMessage:UseSkillPointRequestProto_BoostTypeDefense];
    gs.defense += gl.defenseBaseGain;
    gs.skillPoints -= gl.defenseBaseCost;
  } else {
    [Globals popupMessage:@"No skill points available to add"];
  }
}

- (void) addEnergySkillPoint {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (gs.skillPoints > 0) {
    [sc sendUseSkillPointMessage:UseSkillPointRequestProto_BoostTypeEnergy];
    gs.maxEnergy += gl.energyBaseGain;
    gs.currentEnergy += gl.energyBaseGain;
    gs.skillPoints -= gl.energyBaseCost;
  } else {
    [Globals popupMessage:@"No skill points available to add"];
  }
}

- (void) addStaminaSkillPoint {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (gs.skillPoints > 0) {
    [sc sendUseSkillPointMessage:UseSkillPointRequestProto_BoostTypeStamina];
    gs.maxStamina += gl.staminaBaseGain;
    gs.currentStamina += gl.staminaBaseGain;
    gs.skillPoints -= gl.staminaBaseCost;
  } else {
    [Globals popupMessage:@"No skill points available to add"];
  }
}

- (void) addHealthSkillPoint {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (gs.skillPoints > 0) {
    [sc sendUseSkillPointMessage:UseSkillPointRequestProto_BoostTypeHealth];
    gs.maxHealth += gl.healthBaseGain;
    gs.skillPoints -= gl.healthBaseCost;
  } else {
    [Globals popupMessage:@"No skill points available to add"];
  }
}

- (void) refillEnergy {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (gs.gold >= gl.energyRefillCost) {
    [sc sendRefillStatWithDiamondsMessage:RefillStatWithDiamondsRequestProto_StatTypeEnergy curTime:[self getCurrentMilliseconds]];
    gs.currentEnergy = gs.maxEnergy;
    gs.gold -= gl.energyRefillCost;
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Not enough gold to refill energy. Need: %d, Have: %d.", gl.energyRefillCost, gs.gold]];
  }
}

- (void) refillStamina {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (gs.gold >= gl.staminaRefillCost) {
    [sc sendRefillStatWithDiamondsMessage:RefillStatWithDiamondsRequestProto_StatTypeStamina curTime:[self getCurrentMilliseconds]];
    gs.currentStamina = gs.maxStamina;
    gs.gold -= gl.staminaRefillCost;
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Not enough diamonds to refill stamina. Need: %d, Have: %d.", gl.staminaRefillCost, gs.gold]];
  }
}

- (UserStruct *) purchaseNormStruct:(int)structId atX:(int)x atY:(int)y {
  GameState *gs = [GameState sharedGameState];
  FullStructureProto *fsp = [gs structWithId:structId];
  UserStruct *us = nil;
  
  // Check that no other building is being upgraded
  for (UserStruct *u in gs.myStructs) {
    if (u.state == kBuilding) {
      [Globals popupMessage:@"Already constructing a building"];
      return us;
    }
  }
  
  if (gs.silver >= fsp.coinPrice && gs.gold >= fsp.diamondPrice) {
    [[SocketCommunication sharedSocketCommunication] sendPurchaseNormStructureMessage:structId x:x y:y time:[self getCurrentMilliseconds]];
    us = [[[UserStruct alloc] init] autorelease];
    
    // UserStructId will come in the response
    us.userId = [[GameState sharedGameState] userId];
    us.structId = structId;
    us.level = 1;
    us.isComplete = NO;
    us.coordinates = CGPointMake(x, y);
    us.orientation = 0;
    us.purchaseTime = [NSDate date];
    us.lastRetrieved = nil;
    [[[GameState sharedGameState] myStructs] addObject:us];
    
    // Update game state
    gs.silver -= fsp.coinPrice;
    gs.gold -= fsp.diamondPrice;
  } else {
    [Globals popupMessage:@"Not enough money to purchase this building"];
  }
  return us;
}

- (void) moveNormStruct:(UserStruct *)userStruct atX:(int)x atY:(int)y {
  CGPoint newCoord = CGPointMake(x, y);
  if (!CGPointEqualToPoint(userStruct.coordinates, newCoord)) {
    [[SocketCommunication sharedSocketCommunication] sendMoveNormStructureMessage:userStruct.userStructId x:x y:y];
    userStruct.coordinates = CGPointMake(x, y);
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
  
  if (userStruct.userStructId == 0) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (userStruct.userId != gs.userId) {
    [Globals popupMessage:@"This is not your building!"];
  } else if (userStruct.isComplete) {
    [sc sendSellNormStructureMessage:userStruct.userStructId];
    [[gs myStructs] removeObject:userStruct];
    
    // Update game state
    gs.silver += [[Globals sharedGlobals] calculateStructSilverSellCost:userStruct];
    gs.gold += [[Globals sharedGlobals] calculateStructGoldSellCost:userStruct];
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Building %d is completing", userStruct.userStructId]];
  }
}

- (void) retrieveFromNormStructure:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (userStruct.userStructId == 0) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (userStruct.userId != gs.userId) {
    [Globals popupMessage:@"This is not your building!"];
  } else if (userStruct.isComplete && userStruct.lastRetrieved) {
    int64_t ms = [self getCurrentMilliseconds];
    [sc sendRetrieveCurrencyFromNormStructureMessage:userStruct.userStructId time:ms];
    userStruct.lastRetrieved = [NSDate dateWithTimeIntervalSince1970:ms/1000];
    
    // Update game state
    gs.silver += [[Globals sharedGlobals] calculateIncomeForUserStruct:userStruct];
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Building %d is not ready to be retrieved", userStruct.userStructId]];
  }
}

- (void) instaBuild:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (userStruct.userStructId == 0) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (userStruct.userId != gs.userId) {
    [Globals popupMessage:@"This is not your building!"];
  } else if (!userStruct.isComplete && !userStruct.lastUpgradeTime) {
    int64_t ms = [self getCurrentMilliseconds];
    [sc sendFinishNormStructBuildWithDiamondsMessage:userStruct.userStructId time:ms type:FinishNormStructWaittimeWithDiamondsRequestProto_NormStructWaitTimeTypeFinishConstruction];
    userStruct.isComplete = YES;
    userStruct.lastRetrieved = [NSDate dateWithTimeIntervalSince1970:ms/1000];
    
    // Update game state
    FullStructureProto *fsp = [gs structWithId:userStruct.structId];
    gs.gold -= fsp.instaBuildDiamondCostBase;
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Building %d is not constructing", userStruct.userStructId]];
  }
}

- (void) instaUpgrade:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (userStruct.userStructId == 0) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (userStruct.userId != gs.userId) {
    [Globals popupMessage:@"This is not your building!"];
  } else if (!userStruct.isComplete && userStruct.lastUpgradeTime) {
    int64_t ms = [self getCurrentMilliseconds];
    [sc sendFinishNormStructBuildWithDiamondsMessage:userStruct.userStructId time:[self getCurrentMilliseconds] type:FinishNormStructWaittimeWithDiamondsRequestProto_NormStructWaitTimeTypeFinishUpgrade];
    userStruct.isComplete = YES;
    userStruct.lastRetrieved = [NSDate dateWithTimeIntervalSince1970:ms/1000];
    userStruct.level++;
    
    // Update game state
    FullStructureProto *fsp = [gs structWithId:userStruct.structId];
    gs.gold -= fsp.instaUpgradeDiamondCostBase;
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
    [sc sendNormStructBuildsCompleteMessage:[NSArray arrayWithObject:[NSNumber numberWithInt:userStruct.userStructId]] time:ms];
    
    if (userStruct.lastUpgradeTime) {
      // Building was upgraded, not constructed
      userStruct.level++;
    }
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Building %d is not upgrading or constructing", userStruct.userStructId]];
  }
}

- (void) upgradeNormStruct:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  // Check that no other building is being upgraded
  for (UserStruct *us in gs.myStructs) {
    if (us.state == kUpgrading) {
      [[[UIAlertView alloc] initWithTitle:@"Hold On!" message:@"Already upgrading a building"  delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
      return;
    }
  }
  
  if (userStruct.userStructId == 0) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (userStruct.userId != gs.userId) {
    [Globals popupMessage:@"This is not your building!"];
  } else if (userStruct.isComplete) {
    int64_t ms = [self getCurrentMilliseconds];
    [sc sendUpgradeNormStructureMessage:userStruct.userStructId time:ms];
    userStruct.isComplete = NO;
    userStruct.lastUpgradeTime = [NSDate dateWithTimeIntervalSince1970:ms/1000];
    
    // Update game state
    gs.gold -= [[Globals sharedGlobals] calculateUpgradeCost:userStruct];
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
  
  NSArray *tasks = [[gs staticTasks] allKeys];
  for (FullTaskProto_FullTaskEquipReqProto *eq in tasks) {
    NSNumber *equipId = [NSNumber numberWithInt:eq.equipId];
    if (![sEquips objectForKey:equipId]) {
      [rEquips addObject:equipId];
      shouldSend = YES;
    }
  }
  
  if (shouldSend) {
    [sc sendRetrieveStaticDataMessageWithStructIds:[rStructs allObjects] taskIds:nil questIds:nil cityIds:nil equipIds:[rEquips allObjects] buildStructJobIds:nil defeatTypeJobIds:nil possessEquipJobIds:nil upgradeStructJobIds:nil];
  }
}

- (void) retrieveStructStore {
  [[SocketCommunication sharedSocketCommunication] sendRetrieveStaticDataFromShopMessage:RetrieveStaticDataForShopRequestProto_RetrieveForShopTypeAllStructures];
}

- (void) retrieveEquipStore {
  [[SocketCommunication sharedSocketCommunication] sendRetrieveStaticDataFromShopMessage:RetrieveStaticDataForShopRequestProto_RetrieveForShopTypeEquipmentForArmory];
}

- (void) loadPlayerCity:(int)userId {
  MinimumUserProto *mup = [[[MinimumUserProto builder] setUserId:userId] build];
  
  [[SocketCommunication sharedSocketCommunication] sendLoadPlayerCityMessage:mup];
}

- (void) loadNeutralCity:(FullCityProto *)city {
  GameState *gs = [GameState sharedGameState];
  
  if (!city) {
    [Globals popupMessage:@"Trying to visit nil city"];
    return;
  }
  
  if (city.minLevel <= gs.level) {
    [[SocketCommunication sharedSocketCommunication] sendLoadNeutralCityMessage:city.cityId];
    
    // Load any tasks we don't have as well
    NSDictionary *sTasks = [gs staticTasks];
    NSMutableSet *rTasks = [NSMutableSet set];
    for (NSNumber *taskId in city.taskIdsList) {
      if (![sTasks objectForKey:taskId]) {
        [rTasks addObject:taskId];
      }
    }
    
    if (rTasks.count > 0) {
      [[SocketCommunication sharedSocketCommunication] sendRetrieveStaticDataMessageWithStructIds:nil taskIds:[rTasks allObjects] questIds:nil cityIds:nil equipIds:nil buildStructJobIds:nil defeatTypeJobIds:nil possessEquipJobIds:nil upgradeStructJobIds:nil];
    }
  } else {
    [Globals popupMessage:@"Trying to visit city above your level."];
  }
}

@end
