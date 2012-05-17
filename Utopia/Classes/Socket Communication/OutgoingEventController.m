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
#import "TopBar.h"
#import "GameLayer.h"
#import "MissionMap.h"
#import "MapViewController.h"
#import "TutorialConstants.h"

@implementation OutgoingEventController

SYNTHESIZE_SINGLETON_FOR_CLASS(OutgoingEventController);

- (uint64_t) getCurrentMilliseconds {
  return (uint64_t)([[NSDate date] timeIntervalSince1970]*1000);
}

- (void) createUser {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  
  [sc sendUserCreateMessageWithName:gs.name 
                               type:gs.type
                                lat:gs.location.latitude 
                                lon:gs.location.longitude
                       referralCode:tc.referralCode
                        deviceToken:nil
                             attack:gs.attack
                            defense:gs.defense 
                             health:gs.maxHealth
                             energy:gs.maxEnergy
                            stamina:gs.maxStamina
               timeOfStructPurchase:tc.structTimeOfPurchase.timeIntervalSince1970*1000
                  timeOfStructBuild:tc.structTimeOfBuildComplete.timeIntervalSince1970*1000
                            structX:tc.structCoords.x
                            structY:tc.structCoords.y
                       usedDiamonds:tc.structUsedDiamonds];
}

- (void) vaultDeposit:(int)amount {
  if (amount <= 0) {
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  if (amount <= gs.silver) {
    [[SocketCommunication sharedSocketCommunication] sendVaultMessage:amount requestType:VaultRequestProto_VaultRequestTypeDeposit];
    gs.silver -= amount;
    gs.vaultBalance += (int)floorf(amount * (1.f-[[Globals sharedGlobals] cutOfVaultDepositTaken]));
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
    UserEquip *ue = [gs myEquipWithId:equipReq.equipId];
    if (!ue || ue.quantity < equipReq.quantity) {
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
  
  [[SocketCommunication sharedSocketCommunication] sendTaskActionMessage:taskId curTime:[self getCurrentMilliseconds]];
  return YES;
}

- (void) battle:(FullUserProto *)defender result:(BattleResult)result city:(int)city equips:(NSArray *)equips {
  GameState *gs = [GameState sharedGameState];
  
  if (gs.currentStamina > 0) {
    gs.currentStamina--;
    
    MinimumUserProto *mup = [[[[[MinimumUserProto builder] setName:defender.name] setUserId:defender.userId] setUserType:defender.userType] build];
    
    [[SocketCommunication sharedSocketCommunication] sendBattleMessage:mup result:result curTime:[self getCurrentMilliseconds] city:city equips:equips];
    
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

- (int) buyEquip:(int)equipId {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:equipId];
  
  if (!fep.isBuyableInArmory) {
    [Globals popupMessage:@"Attempting to buy equip that is not in the armory.."];
  }
  
  if (gs.silver >= fep.coinPrice && gs.gold >= fep.diamondPrice) {
    [[SocketCommunication sharedSocketCommunication] sendArmoryMessage:ArmoryRequestProto_ArmoryRequestTypeBuy quantity:1 equipId:equipId];
    [gs changeQuantityForEquip:equipId by:1];
    
    gs.silver -= fep.coinPrice;
    gs.gold -= fep.diamondPrice;
  } else {
    [Globals popupMessage:@"Not enough money to buy this equipment"];
  }
  
  UserEquip *ue = [gs myEquipWithId:equipId];
  return ue.quantity;
}

- (int) sellEquip:(int)equipId {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserEquip *ue = [gs myEquipWithId:equipId];
  
  if (ue) {
    [[SocketCommunication sharedSocketCommunication] sendArmoryMessage:ArmoryRequestProto_ArmoryRequestTypeSell quantity:1 equipId:equipId];
    
    gs.silver += [gl calculateEquipSilverSellCost:ue];
    gs.gold += [gl calculateEquipGoldSellCost:ue];
    
    [gs changeQuantityForEquip:equipId by:-1];
  } else {
    [Globals popupMessage:@"You do not own this equipment"];
  }
  
  return [gs myEquipWithId:equipId].quantity;
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
  LNLog(@"%d enemies in rect: %@", numEnemies, [NSValue valueWithCGRect:bounds]);
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

- (void) retrieveMostRecentMarketplacePosts {
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

- (void) retrieveMostRecentMarketplacePostsFromSender {
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

- (void) equipPostToMarketplace:(int)equipId price:(int)price {
  GameState *gs = [GameState sharedGameState];
  
  if (price <= 0) {
    [Globals popupMessage:@"You need to enter a price!"];
    return;
  } else if (!gs.hasValidLicense) {
    [Globals popupMessage:@"You need a license to make a post"];
  }
  
  UserEquip *eq = [gs myEquipWithId:equipId];
  
  if (eq) {
    FullEquipProto *fep = [gs equipWithId:equipId];
    BOOL sellsForGold = [Globals sellsForGoldInMarketplace:fep];
    int silver = sellsForGold ? 0 : price;
    int gold = sellsForGold ? price : 0;
    [[SocketCommunication sharedSocketCommunication] sendEquipPostToMarketplaceMessage:equipId coins:silver diamonds:gold];
    [gs changeQuantityForEquip:equipId by:-1];
  } else {
    [Globals popupMessage:@"Unable to find this equip!"];
  }
}

- (void) retractMarketplacePost:(int)postId {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  MarketplaceViewController *mvc = [MarketplaceViewController sharedMarketplaceViewController];
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *mktPostsFromSender = [mvc postsForState];
  for (int i = 0; i < mktPostsFromSender.count; i++) {
    FullMarketplacePostProto *proto = [mktPostsFromSender objectAtIndex:i];
    if ([proto marketplacePostId] == postId) {
      if (proto.diamondCost > 0) {
        int amount = (int) ceilf(proto.diamondCost*gl.retractPercentCut);
        if (gs.gold >= amount) {
          gs.gold -= amount;
        } else {
          [Globals popupMessage:@"Not enough gold to retract"];
          return;
        }
      } else {
        int amount = (int) ceilf(proto.coinCost*gl.retractPercentCut);
        if (gs.silver >= amount) {
          gs.silver -= amount;
        } else {
          [Globals popupMessage:@"Not enough silver to retract"];
          return;
        }
      }
      [sc sendRetractMarketplacePostMessage:postId];
      [mktPostsFromSender removeObject:proto];
      NSIndexPath *y = [NSIndexPath indexPathForRow:i+1+![[GameState sharedGameState] hasValidLicense] inSection:0];
      NSIndexPath *z = mktPostsFromSender.count+gs.myEquips.count == 0 ? [NSIndexPath indexPathForRow:0 inSection:0]:nil;
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
  GameState *gs = [GameState sharedGameState];
  
  NSMutableArray *mktPosts = [mvc postsForState];
  for (int i = 0; i < mktPosts.count; i++) {
    FullMarketplacePostProto *proto = [mktPosts objectAtIndex:i];
    if ([proto marketplacePostId] == postId) {
      if (gs.userId != proto.poster.userId) {
        if (gs.gold >= proto.diamondCost && gs.silver >= proto.coinCost) {
          [sc sendPurchaseFromMarketplaceMessage:postId poster:proto.poster.userId];
          gs.gold -= proto.diamondCost;
          gs.silver -= proto.coinCost;
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
    [sc sendRedeemMarketplaceEarningsMessage];
    gs.gold += gs.marketplaceGoldEarnings;
    gs.silver += gs.marketplaceSilverEarnings;
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
    NSDate *date = [NSDate date];
    [sc sendPurchaseMarketplaceLicenseMessage:[date timeIntervalSince1970]*1000 type:PurchaseMarketplaceLicenseRequestProto_LicenseTypeShort];
    gs.lastShortLicensePurchaseTime = date;
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
    NSDate *date = [NSDate date];
    [sc sendPurchaseMarketplaceLicenseMessage:[date timeIntervalSince1970]*1000 type:PurchaseMarketplaceLicenseRequestProto_LicenseTypeLong];
    gs.lastLongLicensePurchaseTime = date;
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

- (void) refillEnergyWaitComplete {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  NSDate *now = [NSDate date];
  NSTimeInterval tInt = [now timeIntervalSinceDate:gs.lastEnergyRefill];
  
  if (gs.currentEnergy >= gs.maxEnergy) {
    [Globals popupMessage:@"Trying to increase energy when at max.."];
  } else if (tInt >= 0.f) {
    [[SocketCommunication sharedSocketCommunication] sendRefillStatWaitTimeComplete:RefillStatWaitCompleteRequestProto_RefillStatWaitCompleteTypeEnergy curTime:now.timeIntervalSince1970*1000];
    
    int maxChange = gs.maxEnergy-gs.currentEnergy;
    int change = tInt/(gl.energyRefillWaitMinutes*60);
    int realChange = MIN(maxChange, change);
    gs.currentEnergy += realChange;
    gs.lastEnergyRefill = [gs.lastEnergyRefill dateByAddingTimeInterval:realChange*gl.energyRefillWaitMinutes*60];
  } else {
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
    [[SocketCommunication sharedSocketCommunication] sendRefillStatWaitTimeComplete:RefillStatWaitCompleteRequestProto_RefillStatWaitCompleteTypeStamina curTime:now.timeIntervalSince1970*1000];
    
    int maxChange = gs.maxStamina-gs.currentStamina;
    int change = tInt/(gl.staminaRefillWaitMinutes*60);
    int realChange = MIN(maxChange, change);
    gs.currentStamina += realChange;
    gs.lastStaminaRefill = [gs.lastStaminaRefill dateByAddingTimeInterval:realChange*gl.staminaRefillWaitMinutes*60];
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
    [sc sendRefillStatWithDiamondsMessage:RefillStatWithDiamondsRequestProto_StatTypeEnergy];
    gs.currentEnergy = gs.maxEnergy;
    gs.gold -= gl.energyRefillCost;
    
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
    [sc sendRefillStatWithDiamondsMessage:RefillStatWithDiamondsRequestProto_StatTypeStamina];
    gs.currentStamina = gs.maxStamina;
    gs.gold -= gl.staminaRefillCost;
    
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
      [Globals popupMessage:@"Already constructing a building"];
      return us;
    }
  }
  
  if (gs.silver >= fsp.coinPrice && gs.gold >= fsp.diamondPrice) {
    [[SocketCommunication sharedSocketCommunication] sendPurchaseNormStructureMessage:structId x:x y:y time:[self getCurrentMilliseconds]];
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
    [[[GameState sharedGameState] myStructs] addObject:us];
    [us release];
    
    // Update game state
    gs.silver -= fsp.coinPrice;
    gs.gold -= fsp.diamondPrice;
    
    [Analytics normStructPurchase:structId];
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
    
    [Analytics normStructSell:userStruct.structId level:userStruct.level];
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
  Globals *gl = [Globals sharedGlobals];
  
  if (userStruct.userStructId == 0) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (userStruct.userId != gs.userId) {
    [Globals popupMessage:@"This is not your building!"];
  } else if (gs.gold < [gl calculateDiamondCostForInstaBuild:userStruct]) {
    [Globals popupMessage:@"Not enough diamonds to speed up build"];
  } else if (!userStruct.isComplete && !userStruct.lastUpgradeTime) {
    int64_t ms = [self getCurrentMilliseconds];
    [sc sendFinishNormStructBuildWithDiamondsMessage:userStruct.userStructId time:ms type:FinishNormStructWaittimeWithDiamondsRequestProto_NormStructWaitTimeTypeFinishConstruction];
    userStruct.isComplete = YES;
    userStruct.lastRetrieved = [NSDate dateWithTimeIntervalSince1970:ms/1000];
    
    // Update game state
    FullStructureProto *fsp = [gs structWithId:userStruct.structId];
    gs.gold -= fsp.instaBuildDiamondCost;
    
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
    [sc sendFinishNormStructBuildWithDiamondsMessage:userStruct.userStructId time:[self getCurrentMilliseconds] type:FinishNormStructWaittimeWithDiamondsRequestProto_NormStructWaitTimeTypeFinishUpgrade];
    userStruct.isComplete = YES;
    userStruct.lastRetrieved = [NSDate dateWithTimeIntervalSince1970:ms/1000];
    userStruct.level++;
    
    // Update game state
    FullStructureProto *fsp = [gs structWithId:userStruct.structId];
    gs.gold -= fsp.instaUpgradeDiamondCostBase;
    
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
  FullStructureProto *fsp = [gs structWithId:userStruct.structId];
  
  // Check that no other building is being upgraded
  for (UserStruct *us in gs.myStructs) {
    if (us.state == kUpgrading) {
      [Globals popupMessage:@"Already upgrading a building"];
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
        [sc sendUpgradeNormStructureMessage:userStruct.userStructId time:ms];
        userStruct.isComplete = NO;
        userStruct.lastUpgradeTime = [NSDate dateWithTimeIntervalSince1970:ms/1000];\
        
        // Update game state
        gs.gold -= cost;
        
        [Analytics normStructInstaUpgrade:userStruct.structId level:userStruct.level+1];
      }
    } else {
      if (cost > gs.silver) {
        [Globals popupMessage:@"Trying to upgrade without enough silver"];
      } else {
        int64_t ms = [self getCurrentMilliseconds];
        [sc sendUpgradeNormStructureMessage:userStruct.userStructId time:ms];
        userStruct.isComplete = NO;
        userStruct.lastUpgradeTime = [NSDate dateWithTimeIntervalSince1970:ms/1000];\
        
        // Update game state
        gs.silver -= cost;
        
        [Analytics normStructInstaUpgrade:userStruct.structId level:userStruct.level+1];
      }
    }
    
  } else {
    [Globals popupMessage:@"This building is not upgradable"];
  }
}

- (UserCritStruct *) placeCritStruct:(CritStructType)type x:(int)x y:(int)y {
  GameState *gs = [GameState sharedGameState];
  
  for (UserCritStruct *ucs in gs.myCritStructs) {
    if (ucs.type == type) {
      [Globals popupMessage:@"Already have this critical structure"];
      return ucs;
    }
  }
  
  UserCritStruct *ucs = [[UserCritStruct alloc] initWithType:type];
  if (gs.level >= ucs.minLevel) {
    [[SocketCommunication sharedSocketCommunication] sendCritStructPlace:type x:x y:y];
    ucs.location = CGRectMake(x, y, ucs.size.width, ucs.size.height);
    ucs.orientation = StructOrientationPosition1;
    [gs.myCritStructs addObject:ucs];
    [ucs release];
    
    [Analytics placedCritStruct:ucs.name];
    return ucs;
  } else {
    [Globals popupMessage:@"Not high enough level to build this critical struct"];
  }
  [ucs release];
  return nil;
}

- (void) moveCritStruct:(UserCritStruct *)cs x:(int)x y:(int)y {
  if (!CGPointEqualToPoint(cs.location.origin, CGPointMake(x, y))) {
    [[SocketCommunication sharedSocketCommunication] sendCritStructMove:cs.type x:x y:y];
    cs.location = CGRectMake(x, y, cs.size.width, cs.size.height);
  }
}

- (void) rotateCritStruct:(UserCritStruct *)cs orientation:(StructOrientation)orientation {
  if (cs.orientation != orientation) {
    [[SocketCommunication sharedSocketCommunication] sendCritStructRotate:cs.type orientation:orientation];
    cs.orientation = orientation;
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
  for (FullQuestProto *fqp in [gs.availableQuests allValues]) {
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
  for (FullQuestProto *fqp in [gs.inProgressQuests allValues]) {
    for (NSNumber *num in fqp.taskReqsList) {
      if (![sTasks objectForKey:num]) {
        [rTasks addObject:num];
        shouldSend = YES;
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
    NSNumber *w = [NSNumber numberWithInt:fup.weaponEquipped];
    if (fup.weaponEquipped && ![sEquips objectForKey:w]) {
      [rEquips addObject:w];
      shouldSend = YES;
    }
    
    NSNumber *ar = [NSNumber numberWithInt:fup.armorEquipped];
    if (fup.armorEquipped && ![sEquips objectForKey:ar]) {
      [rEquips addObject:ar];
      shouldSend = YES;
    }
    
    NSNumber *am = [NSNumber numberWithInt:fup.amuletEquipped];
    if (fup.amuletEquipped && ![sEquips objectForKey:am]) {
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
  
  if (shouldSend) {
    [sc sendRetrieveStaticDataMessageWithStructIds:[rStructs allObjects] taskIds:[rTasks allObjects] questIds:nil cityIds:nil equipIds:[rEquips allObjects] buildStructJobIds:[rBuildStructJobs allObjects] defeatTypeJobIds:[rDefeatTypeJobs allObjects] possessEquipJobIds:[rPossessEquipJobs allObjects] upgradeStructJobIds:[rUpgradeStructJobs allObjects]];
  }
}

- (void) retrieveStaticEquip:(int)equipId {
  GameState *gs = [GameState sharedGameState];
  NSNumber *n = [NSNumber numberWithInt:equipId];
  if (![gs.staticEquips objectForKey:n] && equipId != 0) {
    [[SocketCommunication sharedSocketCommunication] sendRetrieveStaticDataMessageWithStructIds:nil taskIds:nil questIds:nil cityIds:nil equipIds:[NSArray arrayWithObject:[NSNumber numberWithInt:equipId]] buildStructJobIds:nil defeatTypeJobIds:nil possessEquipJobIds:nil upgradeStructJobIds:nil];
  }
}

- (void) retrieveStructStore {
  [[SocketCommunication sharedSocketCommunication] sendRetrieveStaticDataFromShopMessage:RetrieveStaticDataForShopRequestProto_RetrieveForShopTypeAllStructures];
}

- (void) retrieveEquipStore {
  // Used primarily for profile and battle
  [[SocketCommunication sharedSocketCommunication] sendRetrieveStaticDataFromShopMessage:RetrieveStaticDataForShopRequestProto_RetrieveForShopTypeEquipmentForArmory];
}

- (void) loadPlayerCity:(int)userId {
  MinimumUserProto *mup = [[[MinimumUserProto builder] setUserId:userId] build];
  
  [[SocketCommunication sharedSocketCommunication] sendLoadPlayerCityMessage:mup];
}

- (void) loadNeutralCity:(int)cityId {
  GameState *gs = [GameState sharedGameState];
  FullCityProto *city = [gs cityWithId:cityId];
  MapViewController *mvc = [MapViewController sharedMapViewController];
  
  if (!city) {
    [Globals popupMessage:@"Trying to visit nil city"];
    return;
  }
  if ([[GameLayer sharedGameLayer] currentCity] == city.cityId) {
    [mvc fadeOut];
    return;
  }
  
  
  if (city.minLevel <= gs.level) {
    [[SocketCommunication sharedSocketCommunication] sendLoadNeutralCityMessage:city.cityId];
    
    [mvc startLoadingWithText:[NSString stringWithFormat:@"Travelling to %@", city.name]];
    
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

- (void) loadNeutralCity:(int)cityId asset:(int)assetId {
  GameState *gs = [GameState sharedGameState];
  FullCityProto *city = [gs cityWithId:cityId];
  
  if ([[GameLayer sharedGameLayer] currentCity] == city.cityId) {
    if (assetId != 0) {
      [[[GameLayer sharedGameLayer] missionMap] moveToAssetId:assetId];
    }
  }
  
  [[GameLayer sharedGameLayer] setAssetId: assetId];
  [self loadNeutralCity:cityId];
}

- (void) loadNeutralCity:(int)cityId enemyType:(UserType)type {
  GameState *gs = [GameState sharedGameState];
  FullCityProto *city = [gs cityWithId:cityId];
  
  if ([[GameLayer sharedGameLayer] currentCity] == city.cityId) {
      [[[GameLayer sharedGameLayer] missionMap] moveToEnemyType:type];
  }
  
  [[GameLayer sharedGameLayer] setEnemyType:type];
  [self loadNeutralCity:cityId];
}

- (void) changeUserLocationWithCoordinate:(CLLocationCoordinate2D)coord {
  CGFloat lat = coord.latitude;
  CGFloat lon = coord.longitude;
  if (!(lat > 90 || lat < -90 || lon > 180 || lon < -180)) {
    [[SocketCommunication sharedSocketCommunication] sendChangeUserLocationMessageWithLatitude:lat longitude:lon];
    [[GameState sharedGameState] setLocation:coord];
  } else {
    [Globals popupMessage:@"Trying to change user location with coordinates out of bounds."];
  }
}

- (void) levelUp {
  GameState *gs = [GameState sharedGameState];
  
  if (gs.experience >= gs.expRequiredForNextLevel) {
    [[SocketCommunication sharedSocketCommunication] sendLevelUpMessage];
    gs.level++;
    gs.currentEnergy = gs.maxEnergy;
    gs.currentStamina = gs.maxStamina;
    gs.expRequiredForCurrentLevel = gs.expRequiredForNextLevel;
    gs.expRequiredForNextLevel = 100000000;
    
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
    [[SocketCommunication sharedSocketCommunication] sendQuestAcceptMessage:questId];
    
    [gs.availableQuests removeObjectForKey:questIdNum];
    [gs.inProgressQuests setObject:fqp forKey:questIdNum];
    
    [[[GameLayer sharedGameLayer] missionMap] questAccepted:fqp];
    
    [Analytics questAccept:questId];
  } else {
    [Globals popupMessage:@"Attempting to accept unavailable quest"];
  }
}

- (void) redeemQuest:(int)questId {
  GameState *gs = [GameState sharedGameState];
  NSNumber *questIdNum = [NSNumber numberWithInt:questId];
  FullQuestProto *fqp = [gs.inProgressQuests objectForKey:questIdNum];
  
  if (fqp) {
    [[SocketCommunication sharedSocketCommunication] sendQuestRedeemMessage:questId];
    
    [gs.inProgressQuests removeObjectForKey:questIdNum];
    gs.silver += fqp.coinsGained;
    gs.experience += fqp.expGained;
    
    if (fqp.equipIdGained > 0) {
      [gs changeQuantityForEquip:fqp.equipIdGained by:1];
    }
    
    [Analytics questRedeem:questId];
  } else {
    [Globals popupMessage:@"Attempting to redeem quest that is not in progress"];
  }
}

- (void) retrieveQuestLog {
  [[SocketCommunication sharedSocketCommunication] sendUserQuestDetailsMessage:0];
}

- (void) retrieveQuestDetails:(int)questId {
  if (questId == 0) {
    [Globals popupMessage:@"Attempting to retrieve information about quest 0"];
    return;
  }
  NSNumber *num = [NSNumber numberWithInt:questId];
  if ([[[[GameState sharedGameState] inProgressQuests] allKeys] containsObject:num]) {
    [[SocketCommunication sharedSocketCommunication] sendUserQuestDetailsMessage:questId];
  } else {
    [Globals popupMessage:@"Attempting to retrieve information about un-accepted quest"];
  }
}

- (void) retrieveEquipsForUser:(int)userId {
  if (userId == 0) {
    [Globals popupMessage:@"Attempting to retrieve equips for user 0"];
    return;
  }
  [[SocketCommunication sharedSocketCommunication] sendRetrieveUserEquipForUserMessage:userId];
}

- (void) retrieveUsersForUserIds:(NSArray *)userIds {
  [[SocketCommunication sharedSocketCommunication] sendRetrieveUsersForUserIds:userIds];
}

- (void) retrieveMostRecentWallPostsForPlayer:(int)playerId {
  [[SocketCommunication sharedSocketCommunication] sendRetrievePlayerWallPostsMessage:playerId beforePostId:0];
}

- (void) retrieveWallPostsForPlayer:(int)playerId beforePostId:(int)postId {
  [[SocketCommunication sharedSocketCommunication] sendRetrievePlayerWallPostsMessage:playerId beforePostId:postId];
}

- (PlayerWallPostProto *) postToPlayerWall:(int)playerId withContent:(NSString *)content {
  if (content.length <= 0) {
    [Globals popupMessage:@"Attempting to post on player wall with no content"];
    return nil;
  }
  if (playerId <= 0) {
    [Globals popupMessage:@"Attempting to post on player 0's wall"];
    return nil;
  }
  
  [[SocketCommunication sharedSocketCommunication] sendPostOnPlayerWallMessage:playerId withContent:content];
  
  GameState *gs = [GameState sharedGameState];
  PlayerWallPostProto_Builder *bldr = [PlayerWallPostProto builder];
  bldr.playerWallPostId = 0;
  bldr.poster = [[[[[MinimumUserProto builder] setUserId:gs.userId] setUserType:gs.type] setName:gs.name] build];
  bldr.wallOwnerId = playerId;
  bldr.content = content;
  bldr.timeOfPost = [[NSDate date] timeIntervalSince1970]*1000;
  
  return [bldr build];
}

@end
