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
    NSLog(@"Unable to deposit %d coins. Currently only have %d silver.", amount, gs.silver);
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
    NSLog(@"Unable to withdraw %d coins. Currently only have %d coins in vault.", amount, gs.vaultBalance);
  }
}

- (void) tasksForCity:(int)cityId {
  [[SocketCommunication sharedSocketCommunication] sendTasksForCityMessage:cityId];
}

- (void) taskAction:(int)taskId {
  // TODO: Check to make sure of enough energy and equips
  [[SocketCommunication sharedSocketCommunication] sendTaskActionMessage:taskId];
}

- (void) battle:(int)defender {
  [[SocketCommunication sharedSocketCommunication] sendBattleMessage:defender];
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
  [[[GameState sharedGameState] marketplaceCurrencyPosts] removeAllObjects];
  [sc sendRetrieveCurrentMarketplacePostsMessageBeforePostId:0 fromSender:NO];
  [[MarketplaceViewController sharedMarketplaceViewController] deleteRows:1];
}

- (void) retrieveMoreMarketplacePosts {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  GameState *gs = [GameState sharedGameState];
  FullMarketplacePostProto *x = gs.marketplaceEquipPosts.lastObject;
  FullMarketplacePostProto *y = gs.marketplaceCurrencyPosts.lastObject;
  int postId;
  if (!x && !y) {
    return;
  } else if (!x) {
    postId = [y marketplacePostId];
  } else if (!y) {
    postId = [x marketplacePostId];
  } else {
    postId = MIN([x marketplacePostId], [y marketplacePostId]);
  }
  [sc sendRetrieveCurrentMarketplacePostsMessageBeforePostId:postId fromSender:NO];
}

- (void) retrieveMostRecentPostsFromSender {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  [[[GameState sharedGameState] marketplaceEquipPostsFromSender] removeAllObjects];
  [[[GameState sharedGameState] marketplaceCurrencyPostsFromSender] removeAllObjects];
  [sc sendRetrieveCurrentMarketplacePostsMessageBeforePostId:0 fromSender:YES];
  [[MarketplaceViewController sharedMarketplaceViewController] deleteRows:1];
}

- (void) retrieveMoreMarketplacePostsFromSender {
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  GameState *gs = [GameState sharedGameState];
  FullMarketplacePostProto *x = gs.marketplaceEquipPostsFromSender.lastObject;
  FullMarketplacePostProto *y = gs.marketplaceCurrencyPostsFromSender.lastObject;
  int postId;
  if (!x && !y) {
    return;
  } else if (!x) {
    postId = [y marketplacePostId];
  } else if (!y) {
    postId = [x marketplacePostId];
  } else {
    postId = MIN([x marketplacePostId], [y marketplacePostId]);
  }
  [sc sendRetrieveCurrentMarketplacePostsMessageBeforePostId:postId fromSender:YES];
}

- (void) equipPostToMarketplace:(int)equipId wood:(int)wood silver:(int)silver gold:(int)gold {
  // TODO: need to check equips
  GameState *gs = [GameState sharedGameState];
  
  for (FullUserEquipProto *eq in [gs myEquips]) {
    if (eq.equipId == equipId) {
      [[SocketCommunication sharedSocketCommunication] sendEquipPostToMarketplaceMessage:equipId wood:wood coins:silver diamonds:gold];
    }
  }
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
  
  NSLog(@"Cannot verify that this item belongs to user..");
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
  
  NSLog(@"Cannot find this item..");
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
    NSLog(@"Nothing to earn!");
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
    NSLog(@"No skill points available to add");
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
    NSLog(@"No skill points available to add");
  }
}

- (void) addEnergySkillPoint {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (gs.skillPoints > 0) {
    [sc sendUseSkillPointMessage:UseSkillPointRequestProto_BoostTypeEnergy];
    gs.maxEnergy += gl.energyBaseGain;
    gs.skillPoints -= gl.energyBaseCost;
  } else {
    NSLog(@"No skill points available to add");
  }
}

- (void) addStaminaSkillPoint {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (gs.skillPoints > 0) {
    [sc sendUseSkillPointMessage:UseSkillPointRequestProto_BoostTypeStamina];
    gs.maxStamina += gl.staminaBaseGain;
    gs.skillPoints -= gl.staminaBaseCost;
  } else {
    NSLog(@"No skill points available to add");
  }
}

- (void) addHealthSkillPoint {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (gs.skillPoints > 0) {
    [sc sendUseSkillPointMessage:UseSkillPointRequestProto_BoostTypeHealth];
    gs.maxEnergy += gl.healthBaseGain;
    gs.skillPoints -= gl.healthBaseCost;
  } else {
    NSLog(@"No skill points available to add");
  }
}

- (void) refillEnergy {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (gs.gold >= gl.energyRefillCost) {
    [sc sendRefillStatWithDiamondsMessage:RefillStatWithDiamondsRequestProto_StatTypeEnergy];
    gs.currentEnergy = gs.maxEnergy;
    gs.gold -= gl.energyRefillCost;
  } else {
    NSLog(@"Not enough diamonds to refill energy. Need: %d, Have: %d.", gl.energyRefillCost, gs.gold);
  }
}

- (void) refillStamina {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (gs.gold >= gl.staminaRefillCost) {
    [sc sendRefillStatWithDiamondsMessage:RefillStatWithDiamondsRequestProto_StatTypeStamina];
    gs.currentStamina = gs.maxStamina;
    gs.gold -= gl.staminaRefillCost;
  } else {
    NSLog(@"Not enough diamonds to refill stamina. Need: %d, Have: %d.", gl.staminaRefillCost, gs.gold);
  }
}

- (void) purchaseNormStruct:(int)structId atX:(int)x atY:(int)y {
  [[SocketCommunication sharedSocketCommunication] sendPurchaseNormStructureMessage:structId x:x y:y time:[self getCurrentMilliseconds]];
}

- (void) moveNormStruct:(UserStruct *)userStruct atX:(int)x atY:(int)y {
  CGPoint newCoord = CGPointMake(x, y);
  if (!CGPointEqualToPoint(userStruct.coordinates, newCoord)) {
    [[SocketCommunication sharedSocketCommunication] sendMoveNormStructureMessage:userStruct.userStructId x:x y:y];
  } else {
    NSLog(@"Building is in same place..");
  }
}

- (void) sellNormStruct:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (userStruct.userId != gs.userId) {
    NSLog(@"This is not your building!");
  }
  if (userStruct.isComplete) {
    [sc sendSellNormStructureMessage:userStruct.userStructId];
    [[gs myStructs] removeObject:userStruct];
  } else {
    NSLog(@"Building %d is completing", userStruct.userStructId);
  }
}

- (void) instaBuild:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (userStruct.userId != gs.userId) {
    NSLog(@"This is not your building!");
  }
  if (!userStruct.isComplete && !userStruct.lastUpgradeTime) {
    int64_t ms = [self getCurrentMilliseconds];
    [sc sendFinishNormStructBuildWithDiamondsMessage:userStruct.userStructId time:ms type:FinishNormStructWaittimeWithDiamondsRequestProto_NormStructWaitTimeTypeFinishConstruction];
    userStruct.isComplete = YES;
    userStruct.lastRetrieved = [NSDate dateWithTimeIntervalSince1970:ms/1000];
  } else {
    NSLog(@"Building %d is not constructing", userStruct.userStructId);
  }
}

- (void) instaUpgrade:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (userStruct.userId != gs.userId) {
    NSLog(@"This is not your building!");
  }
  if (!userStruct.isComplete && userStruct.lastUpgradeTime) {
    int64_t ms = [self getCurrentMilliseconds];
    [sc sendFinishNormStructBuildWithDiamondsMessage:userStruct.userStructId time:[self getCurrentMilliseconds] type:FinishNormStructWaittimeWithDiamondsRequestProto_NormStructWaitTimeTypeFinishUpgrade];
    userStruct.isComplete = YES;
    userStruct.lastRetrieved = [NSDate dateWithTimeIntervalSince1970:ms/1000];
    userStruct.level++;
  } else {
    NSLog(@"Building %d is not upgrading", userStruct.userStructId);
  }
}

- (void) normStructWaitComplete:(UserStruct *)userStruct { 
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (userStruct.userId != gs.userId) {
    NSLog(@"This is not your building!");
  }
  if (!userStruct.isComplete) {
    int64_t ms = [self getCurrentMilliseconds];
    [sc sendNormStructBuildsCompleteMessage:[NSArray arrayWithObject:[NSNumber numberWithInt:userStruct.userStructId]] time:ms];
    userStruct.isComplete = YES;
    userStruct.lastRetrieved = [NSDate dateWithTimeInterval:[gl calculateMinutesToUpgrade:userStruct]*60 sinceDate:userStruct.lastUpgradeTime];
    
    if (userStruct.lastUpgradeTime) {
      // Building was upgraded, not constructed
      userStruct.level++;
    }
  } else {
    NSLog(@"Building %d is not upgrading or constructing", userStruct.userStructId);
  }
}

- (void) upgradeNormStruct:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  // Check that no other building is being upgraded
  for (UserStruct *us in gs.myStructs) {
    if (us.state == kUpgrading) {
      NSLog(@"Already upgrading a building..");
      return;
    }
  }
  
  if (userStruct.userId != gs.userId) {
    NSLog(@"This is not your building!");
  }
  if (userStruct.isComplete) {
    int64_t ms = [self getCurrentMilliseconds];
    [sc sendUpgradeNormStructureMessage:userStruct.userStructId time:ms];
    userStruct.isComplete = NO;
    userStruct.lastUpgradeTime = [NSDate dateWithTimeIntervalSince1970:ms/1000];
  } else {
    NSLog(@"This building is not upgradable");
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
  
  if (shouldSend) {
    [sc sendRetrieveStaticDataMessageWithStructIds:[rStructs allObjects] taskIds:nil questIds:nil cityIds:nil equipIds:[rEquips allObjects] buildStructJobIds:nil defeatTypeJobIds:nil possessEquipJobIds:nil upgradeStructJobIds:nil];
  }
}

- (void) loadPlayerCity:(int)userId {
  MinimumUserProto *mup = [[[MinimumUserProto builder] setUserId:userId] build];
  
  [[SocketCommunication sharedSocketCommunication] sendLoadPlayerCityMessage:mup];
}

@end
