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
                                       health:gs.maxHealth
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
  [[SocketCommunication sharedSocketCommunication] sendLogoutMessage];
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
  
  int tag = [[SocketCommunication sharedSocketCommunication] sendTaskActionMessage:taskId curTime:[self getCurrentMilliseconds]];
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
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
-(void)test
{
  
}
- (int) buyEquip:(int)equipId {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:equipId];
  
  if (!fep.isBuyableInArmory) {
    [Globals popupMessage:@"Attempting to buy equip that is not in the armory.."];
  }
  
  if (gs.silver >= fep.coinPrice && gs.gold >= fep.diamondPrice) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendArmoryMessage:ArmoryRequestProto_ArmoryRequestTypeBuy quantity:1 equipId:equipId];
    
    ChangeEquipUpdate *ceu = [ChangeEquipUpdate updateWithTag:tag equipId:equipId change:1];
    SilverUpdate *su = [SilverUpdate updateWithTag:tag change:-fep.coinPrice];
    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:-fep.diamondPrice];
    
    [[Globals sharedGlobals] confirmWearEquip:fep.equipId];
    
    [gs addUnrespondedUpdates:ceu, su, gu, nil];
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
  FullEquipProto *fep = [gs equipWithId:equipId];
  
  if (ue) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendArmoryMessage:ArmoryRequestProto_ArmoryRequestTypeSell quantity:1 equipId:equipId];
    
    ChangeEquipUpdate *ceu = [ChangeEquipUpdate updateWithTag:tag equipId:equipId change:-1];
    SilverUpdate *su = [SilverUpdate updateWithTag:tag change:[gl calculateEquipSilverSellCost:ue]];
    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:[gl calculateEquipGoldSellCost:ue]];
    
    [gs addUnrespondedUpdates:ceu, su, gu, nil];
    
    [Globals popupMessage:[NSString stringWithFormat:@"You have sold 1 %@!", fep.name]];
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
    
    int tag = [[SocketCommunication sharedSocketCommunication] sendEquipEquipmentMessage:equipId];
    [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
    
    if ([ArmoryViewController sharedArmoryViewController].view.superview) {
      [[ArmoryViewController sharedArmoryViewController] refresh];
    }
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
  
  int tag = [[SocketCommunication sharedSocketCommunication] sendGenerateAttackListMessage:numEnemies 
                                                                   latUpperBound:MIN(CGRectGetMaxY(bounds), 90)
                                                                   latLowerBound:MAX(CGRectGetMinY(bounds), -90) 
                                                                   lonUpperBound:MIN(CGRectGetMaxX(bounds), 180) 
                                                                   lonLowerBound:MAX(CGRectGetMinX(bounds), -180)];
  [[GameState sharedGameState] addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) inAppPurchase:(NSString *)receipt goldAmt:(int)gold {
  int tag = [[SocketCommunication sharedSocketCommunication] sendInAppPurchaseMessage:receipt];
  [[GameState sharedGameState] addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:gold]];
}

- (void) retrieveMostRecentMarketplacePosts {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  [[[GameState sharedGameState] marketplaceEquipPosts] removeAllObjects];
  int tag = [sc sendRetrieveCurrentMarketplacePostsMessageBeforePostId:0 fromSender:NO];
  [[MarketplaceViewController sharedMarketplaceViewController] deleteRows:1];
  [[GameState sharedGameState] addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) retrieveMoreMarketplacePosts {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  GameState *gs = [GameState sharedGameState];
  FullMarketplacePostProto *x = gs.marketplaceEquipPosts.lastObject;
  if (!x) {
    return;
  }
  int tag = [sc sendRetrieveCurrentMarketplacePostsMessageBeforePostId:[x marketplacePostId] fromSender:NO];
  [[GameState sharedGameState] addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) retrieveMostRecentMarketplacePostsFromSender {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  [[[GameState sharedGameState] marketplaceEquipPostsFromSender] removeAllObjects];
  int tag = [sc sendRetrieveCurrentMarketplacePostsMessageBeforePostId:0 fromSender:YES];
  [[MarketplaceViewController sharedMarketplaceViewController] deleteRows:1];
  [[GameState sharedGameState] addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) retrieveMoreMarketplacePostsFromSender {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  GameState *gs = [GameState sharedGameState];
  FullMarketplacePostProto *x = gs.marketplaceEquipPostsFromSender.lastObject;
  if (!x) {
    return;
  }
  int tag = [sc sendRetrieveCurrentMarketplacePostsMessageBeforePostId:[x marketplacePostId] fromSender:YES];
  [[GameState sharedGameState] addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
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
    int tag = [[SocketCommunication sharedSocketCommunication] sendEquipPostToMarketplaceMessage:equipId coins:silver diamonds:gold];
    
    ChangeEquipUpdate *ceu = [ChangeEquipUpdate updateWithTag:tag equipId:equipId change:-1];
    [gs addUnrespondedUpdate:ceu];
    [GenericPopupController displayViewWithText:[NSString stringWithFormat:@"You have posted your %@ for %d %@!", fep.name, silver ? silver : gold, silver ? @"silver" : @"gold"] title:@"Congratulations!"];
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
      BOOL isGold = NO;
      int amount = 0;
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
      int tag = [sc sendRetractMarketplacePostMessage:postId];
      [mktPostsFromSender removeObject:proto];
      NSIndexPath *y = [NSIndexPath indexPathForRow:i+1+![[GameState sharedGameState] hasValidLicense] inSection:0];
      NSIndexPath *z = mktPostsFromSender.count+gs.myEquips.count == 0 ? [NSIndexPath indexPathForRow:0 inSection:0]:nil;
      NSArray *a = [NSArray arrayWithObjects:y, z, nil];
      [mvc.postsTableView deleteRowsAtIndexPaths:a withRowAnimation:UITableViewRowAnimationTop];
      
      FullUserUpdate *fuu = isGold ? [GoldUpdate updateWithTag:tag change:-amount] : [SilverUpdate updateWithTag:tag change:-amount];
      ChangeEquipUpdate *ceu = [ChangeEquipUpdate updateWithTag:tag equipId:proto.postedEquip.equipId change:1];
      [gs addUnrespondedUpdates:fuu, ceu, nil];
      
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
          int tag = [sc sendPurchaseFromMarketplaceMessage:postId poster:proto.poster.userId];
          GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:-proto.diamondCost];
          SilverUpdate *su = [SilverUpdate updateWithTag:tag change:-proto.coinCost];
          
          [[Globals sharedGlobals] confirmWearEquip:proto.postedEquip.equipId];
          
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
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (gs.skillPoints >= gl.healthBaseCost) {
    int tag = [sc sendUseSkillPointMessage:UseSkillPointRequestProto_BoostTypeHealth];
    HealthUpdate *hu = [HealthUpdate updateWithTag:tag change:gl.healthBaseGain];
    SkillPointsUpdate *spu = [SkillPointsUpdate updateWithTag:tag change:-gl.healthBaseCost];
    [gs addUnrespondedUpdates:hu, spu, nil];
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
    int tag = [[SocketCommunication sharedSocketCommunication] sendRefillStatWaitTimeComplete:RefillStatWaitCompleteRequestProto_RefillStatWaitCompleteTypeEnergy curTime:now.timeIntervalSince1970*1000];
    
    int maxChange = gs.maxEnergy-gs.currentEnergy;
    int change = tInt/(gl.energyRefillWaitMinutes*60);
    int realChange = MIN(maxChange, change);
    NSDate *nextDate = [gs.lastEnergyRefill dateByAddingTimeInterval:realChange*gl.energyRefillWaitMinutes*60];
    EnergyUpdate *eu = [EnergyUpdate updateWithTag:tag change:realChange];
    LastEnergyRefillUpdate *leru = [LastEnergyRefillUpdate updateWithTag:tag prevDate:gs.lastEnergyRefill nextDate:nextDate];
    [gs addUnrespondedUpdates:eu, leru, nil];
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
    int tag = [[SocketCommunication sharedSocketCommunication] sendRefillStatWaitTimeComplete:RefillStatWaitCompleteRequestProto_RefillStatWaitCompleteTypeStamina curTime:now.timeIntervalSince1970*1000];
    
    int maxChange = gs.maxStamina-gs.currentStamina;
    int change = tInt/(gl.staminaRefillWaitMinutes*60);
    int realChange = MIN(maxChange, change);
    NSDate *nextDate = [gs.lastStaminaRefill dateByAddingTimeInterval:realChange*gl.staminaRefillWaitMinutes*60];
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
      [Globals popupMessage:@"Already constructing a building"];
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
    userStruct.lastRetrieved = [NSDate dateWithTimeIntervalSince1970:ms/1000];
    
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
    userStruct.lastRetrieved = [NSDate dateWithTimeIntervalSince1970:ms/1000];
    
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
    userStruct.lastRetrieved = [NSDate dateWithTimeIntervalSince1970:ms/1000];
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
        int tag = [sc sendUpgradeNormStructureMessage:userStruct.userStructId time:ms];
        userStruct.isComplete = NO;
        userStruct.lastUpgradeTime = [NSDate dateWithTimeIntervalSince1970:ms/1000];\
        
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
        userStruct.lastUpgradeTime = [NSDate dateWithTimeIntervalSince1970:ms/1000];\
        
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
    int tag = [sc sendRetrieveStaticDataMessageWithStructIds:[rStructs allObjects] taskIds:[rTasks allObjects] questIds:nil cityIds:nil equipIds:[rEquips allObjects] buildStructJobIds:[rBuildStructJobs allObjects] defeatTypeJobIds:[rDefeatTypeJobs allObjects] possessEquipJobIds:[rPossessEquipJobs allObjects] upgradeStructJobIds:[rUpgradeStructJobs allObjects]];
    [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
  }
}

- (void) retrieveStaticEquip:(int)equipId {
  GameState *gs = [GameState sharedGameState];
  NSNumber *n = [NSNumber numberWithInt:equipId];
  if (![gs.staticEquips objectForKey:n] && equipId != 0) {
    LNLog(@"Retrieving equip %d.", equipId);
     int tag = [[SocketCommunication sharedSocketCommunication] sendRetrieveStaticDataMessageWithStructIds:nil taskIds:nil questIds:nil cityIds:nil equipIds:[NSArray arrayWithObject:[NSNumber numberWithInt:equipId]] buildStructJobIds:nil defeatTypeJobIds:nil possessEquipJobIds:nil upgradeStructJobIds:nil];
    [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
  }
}

- (void) retrieveStaticEquipsForUser:(FullUserProto *)fup {
  [self retrieveStaticEquip:fup.weaponEquipped];
  [self retrieveStaticEquip:fup.armorEquipped];
  [self retrieveStaticEquip:fup.amuletEquipped];
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
  MapViewController *mvc = [MapViewController sharedMapViewController];
  
  if (!city) {
    [Globals popupMessage:@"Trying to visit nil city"];
    return;
  }
  if ([[GameLayer sharedGameLayer] currentCity] == city.cityId) {
    [mvc close];
    return;
  }
  
  
  if (city.minLevel <= gs.level) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendLoadNeutralCityMessage:city.cityId];
    
    if (![[BattleLayer sharedBattleLayer] isRunning]) {
      [mvc startLoadingWithText:[NSString stringWithFormat:@"Traveling to %@", city.name]];
    }
    
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
    
    [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
  } else {
    [Globals popupMessage:@"Trying to visit city above your level."];
  }
}

- (void) loadNeutralCity:(int)cityId asset:(int)assetId {
  if (cityId == 0) {
    if (assetId == 1) {
      [[GameLayer sharedGameLayer] loadHomeMap];
      [[HomeMap sharedHomeMap] moveToTutorialGirl];
    } else if (assetId == 2) {
      [[GameLayer sharedGameLayer] loadBazaarMap];
      [[BazaarMap sharedBazaarMap] moveToQuestGiver];
    }
  } else {
    if ([[GameLayer sharedGameLayer] currentCity] == cityId) {
      if (assetId != 0) {
        [[[GameLayer sharedGameLayer] missionMap] moveToAssetId:assetId];
      }
    }
    
    [[GameLayer sharedGameLayer] setAssetId: assetId];
    [self loadNeutralCity:cityId];
  }
}

- (void) loadNeutralCity:(int)cityId enemyType:(DefeatTypeJobProto_DefeatTypeJobEnemyType)type {
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
  
  if (gs.experience >= gs.expRequiredForNextLevel) {
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
    
    ChangeEquipUpdate *ceu = nil;
    if (fqp.equipIdGained > 0) {
      ceu = [ChangeEquipUpdate updateWithTag:tag equipId:fqp.equipIdGained change:1];
    }
    
    [gs addUnrespondedUpdates:su, eu, ceu, nil];
    
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
  if (content.length <= 0) {
    [Globals popupMessage:@"Attempting to post on player wall with no content"];
    return nil;
  }
  if (playerId <= 0) {
    [Globals popupMessage:@"Attempting to post on player 0's wall"];
    return nil;
  }
  
  int tag = [[SocketCommunication sharedSocketCommunication] sendPostOnPlayerWallMessage:playerId withContent:content];
  
  GameState *gs = [GameState sharedGameState];
  PlayerWallPostProto_Builder *bldr = [PlayerWallPostProto builder];
  bldr.playerWallPostId = 0;
  bldr.poster = [[[[[MinimumUserProto builder] setUserId:gs.userId] setUserType:gs.type] setName:gs.name] build];
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
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
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

- (void) adColonyReward:(int)gold {
  GameState *gs = [GameState sharedGameState];

  uint64_t time = [self getCurrentMilliseconds];
  NSString *preparedText = [NSString stringWithFormat:@"%d%@%d%llu",
                            gs.userId,
                            gs.referralCode, 
                            gold,
                            time];
  id<OASignatureProviding> signer = [[OAHMAC_SHA1SignatureProvider alloc] init];
  NSString *digest = [signer signClearText:preparedText
                                withSecret:LVL6_SHARED_SECRET];

  NSLog(@"%@ %@", preparedText, digest);
  
  int tag = [[SocketCommunication sharedSocketCommunication] 
             sendEarnFreeDiamondsAdColonyMessageClientTime:time
             digest:digest
             gold:gold];
  [Globals popupMessage:[NSString stringWithFormat:@"Congratulations! You just earned %d Gold", 
                         gold]];
  [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:gold]];
  
  [Analytics watchedAdColony];
}

@end
