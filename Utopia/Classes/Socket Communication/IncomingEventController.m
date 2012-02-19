//
//  EventController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/3/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "IncomingEventController.h"
#import "Protocols.pb.h"
#import "SynthesizeSingleton.h"
#import "GameState.h"
#import "Globals.h"
#import "MarketplaceViewController.h"
#import "OutgoingEventController.h"
#import "HomeMap.h"

@implementation IncomingEventController

SYNTHESIZE_SINGLETON_FOR_CLASS(IncomingEventController);

- (Class) getClassForType: (EventProtocolResponse) type {
  // This is very hacky but I suppose necessary.. :/
  Class responseClass;
  switch (type) {
    case EventProtocolResponseSChatEvent:
      responseClass = [ChatResponseProto class];
      break;
    case EventProtocolResponseSVaultEvent:
      responseClass = [VaultResponseProto class];
      break;
    case EventProtocolResponseSBattleEvent:
      responseClass = [BattleResponseProto class];
      break;
    case EventProtocolResponseSRetrieveTasksForCityEvent:
      responseClass = [RetrieveTasksForCityResponseProto class];
      break;
    case EventProtocolResponseSStartupEvent:
      responseClass = [StartupResponseProto class];
      break;
    case EventProtocolResponseSLevelUpEvent:
      responseClass = [LevelUpResponseProto class];
      break;
    case EventProtocolResponseSTaskActionEvent:
      responseClass = [TaskActionResponseProto class];
      break;
    case EventProtocolResponseSInAppPurchaseEvent:
      responseClass = [InAppPurchaseResponseProto class];
      break;
    case EventProtocolResponseSUpdateClientUserEvent:
      responseClass = [UpdateClientUserResponseProto class];
      break;
    case EventProtocolResponseSRetrieveCurrentMarketplacePostsEvent:
      responseClass = [RetrieveCurrentMarketplacePostsResponseProto class];
      break;
    case EventProtocolResponseSPostToMarketplaceEvent:
      responseClass = [PostToMarketplaceResponseProto class];
      break;
    case EventProtocolResponseSPurchaseFromMarketplaceEvent:
      responseClass = [PurchaseFromMarketplaceResponseProto class];
      break;
    case EventProtocolResponseSRetractPostFromMarketplaceEvent:
      responseClass = [RetractMarketplacePostResponseProto class];
      break;
    case EventProtocolResponseSRedeemMarketplaceEarningsEvent:
      responseClass = [RedeemMarketplaceEarningsResponseProto class];
      break;
    case EventProtocolResponseSGenerateAttackListEvent:
      responseClass = [GenerateAttackListResponseProto class];
      break;
    case EventProtocolResponseSUseSkillPointEvent:
      responseClass = [UseSkillPointResponseProto class];
      break;
    case EventProtocolResponseSRefillStatWithDiamondsEvent:
      responseClass = [RefillStatWithDiamondsResponseProto class];
      break;
    case EventProtocolResponseSPurchaseNormStructureEvent:
      responseClass = [PurchaseNormStructureResponseProto class];
      break;
    case EventProtocolResponseSMoveOrRotateNormStructureEvent:
      responseClass = [MoveOrRotateNormStructureResponseProto class];
      break;
    case EventProtocolResponseSUpgradeNormStructureEvent:
      responseClass = [UpgradeNormStructureResponseProto class];
      break;
    case EventProtocolResponseSNormStructWaitCompleteEvent:
      responseClass = [NormStructWaitCompleteResponseProto class];
      break;
    case EventProtocolResponseSFinishNormStructWaittimeWithDiamondsEvent:
      responseClass = [FinishNormStructWaittimeWithDiamondsResponseProto class];
      break;
    case EventProtocolResponseSRetrieveCurrencyFromNormStructureEvent:
      responseClass = [RetrieveCurrencyFromNormStructureResponseProto class];
      break;
    case EventProtocolResponseSSellNormStructureEvent:
      responseClass = [SellNormStructureResponseProto class];
      break;
    case EventProtocolResponseSLoadPlayerCityEvent:
      responseClass = [LoadPlayerCityResponseProto class];
      break;
    case EventProtocolResponseSRetrieveStaticDataEvent:
      responseClass = [RetrieveStaticDataResponseProto class];
      break;
    default:
      responseClass = nil;
      break;
  }
  return responseClass;
}

- (void) handleChatResponseProto: (ChatResponseProto *) proto {
  NSLog(@"%@", [proto message]);
}

- (void) handleVaultResponseProto: (VaultResponseProto *) proto {
  [[GameState sharedGameState] setVaultBalance:proto.vaultAmount];
  [[GameState sharedGameState] setSilver:proto.coinAmount];
  NSLog(@"Vault: %d, Coins: %d", proto.vaultAmount, proto.coinAmount);
}

- (void) handleBattleResponseProto: (BattleResponseProto *) proto {
  NSLog(@"Battle response received");
}

- (void) handleRetrieveTasksForCityResponseProto: (RetrieveTasksForCityResponseProto *) proto {
  NSLog(@"Tasks message received ");
}

- (void) handleStartupResponseProto: (StartupResponseProto *) proto {
  NSLog(@"Startup response received");
  
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  OutgoingEventController *oec = [OutgoingEventController sharedOutgoingEventController];
  
  [gl updateConstants:proto.startupConstants];
  [gs updateUser:proto.sender];
  [gs addToMyEquips:proto.userEquipsList];
//  [gs setMyStructs:[NSMutableArray arrayWithArray:proto.userStructuresList]];
  [oec retrieveAllStaticData];
}

- (void) handleLevelUpResponseProto: (LevelUpResponseProto *) proto {
  NSLog(@"Level up response received");
}

- (void) handleInAppPurchaseResponseProto: (InAppPurchaseResponseProto *) proto {
  NSLog(@"In App Purchase response received");
}

- (void) handleTaskActionResponseProto: (TaskActionResponseProto *) proto {
  NSLog(@"Task action received ");
}

- (void) handleUpdateClientUserResponseProto: (UpdateClientUserResponseProto *) proto {
  NSLog(@"Update client user response received");
  
  [[GameState sharedGameState] updateUser:proto.sender];
}

- (void)handleRetrieveCurrentMarketplacePostsResponseProto:(RetrieveCurrentMarketplacePostsResponseProto *)proto {
  NSLog(@"Retrieve mkt response received");
  
  MarketplaceViewController *mvc = [MarketplaceViewController sharedMarketplaceViewController];
  if ([proto.marketplacePostsList count] > 0) {
    NSMutableArray *cur;
    NSMutableArray *eq;
    
    if (proto.fromSender) {
      cur = [[GameState sharedGameState] marketplaceCurrencyPostsFromSender];
      eq = [[GameState sharedGameState] marketplaceEquipPostsFromSender];
    } else {
      cur = [[GameState sharedGameState] marketplaceCurrencyPosts];
      eq = [[GameState sharedGameState] marketplaceEquipPosts];
    }
    
    if (proto.beforeThisPostId == 0) {
      [cur removeAllObjects];
      [eq removeAllObjects];
    }
    
    int x = [cur count];
    int y = [eq count];
    int c, d;
    if (mvc.state == kCurrencyBuyingState || mvc.state == kCurrencySellingState) { 
      c = x+1;
      d = cur.count-x;
    } else {
      c = y+1;
      d = eq.count-y;
    }
    [mvc insertRowsFrom:c];
  }
  [mvc performSelector:@selector(stopLoading) withObject:nil afterDelay:0.6];
}

- (void) handlePostToMarketplaceResponseProto: (PostToMarketplaceResponseProto *) proto {
  NSLog(@"Post to mkt response received, %d", [proto status]);
}

- (void) handlePurchaseFromMarketplaceResponseProto: (PurchaseFromMarketplaceResponseProto *) proto {
  NSLog(@"Purchase from mkt response received");
}

- (void) handleRetractMarketplacePostResponseProto: (RetractMarketplacePostResponseProto *) proto {
  NSLog(@"Retract marketplace response received with status: %d", proto.status);
}

- (void) handleRedeemMarketplaceEarningsRequestProto: (RedeemMarketplaceEarningsResponseProto *) proto {
  NSLog(@"Redeem response received with status: %d", proto.status);
}

- (void) handleGenerateAttackListResponseProto: (GenerateAttackListResponseProto *) proto {
  NSLog(@"Generate attack list response received.");
}

- (void) handleUseSkillPointResponseProto: (UseSkillPointResponseProto *) proto {
  NSLog(@"Use skill point response received.");
}

- (void) handleRefillStatWithDiamondsResponseProto: (RefillStatWithDiamondsResponseProto *) proto {
  NSLog(@"refill stat with diamonds response.");
}

- (void) handlePurchaseNormStructureResponseProto: (PurchaseNormStructureResponseProto *) proto {
  NSLog(@"Purchase norm struct response received.");
}

- (void) handleMoveOrRotateNormStructureResponseProto: (MoveOrRotateNormStructureResponseProto *) proto {
  NSLog(@"Move norm struct response received with status: %d.", proto.status);
}

- (void) handleUpgradeNormStructureResponseProto: (UpgradeNormStructureResponseProto *) proto {
  NSLog(@"Upgrade norm structure response received.");
}

- (void) handleNormStructWaitCompleteResponseProto: (NormStructWaitCompleteResponseProto *) proto {
  NSLog(@"Norm struct builds complete response received");
}

- (void) handleFinishNormStructWaittimeWithDiamondsResponseProto: (FinishNormStructWaittimeWithDiamondsResponseProto *) proto {
  NSLog(@"Finish norm struct with diamonds response received.");
}

- (void) handleRetrieveCurrencyFromNormStructureResponseProto: (RetrieveCurrencyFromNormStructureResponseProto *) proto {
  NSLog(@"Retrieve currency response received.");
}

- (void) handleSellNormStructureResponseProto: (SellNormStructureResponseProto *) proto {
  NSLog(@"Sell norm struct response received.");
}

- (void) handleLoadPlayerCityResponseProto: (LoadPlayerCityResponseProto *) proto {
  NSLog(@"Load player city response received.");
  [[GameState sharedGameState] addToMyStructs:proto.ownerNormStructsList];
  [[OutgoingEventController sharedOutgoingEventController] retrieveAllStaticData];
  [[HomeMap sharedHomeMap] refresh];
}

- (void) handleRetrieveStaticDataResponseProto: (RetrieveStaticDataResponseProto *) proto {
  NSLog(@"Retrieve static data response received.");
  GameState *gs = [GameState sharedGameState];
  
  if (proto.status == RetrieveStaticDataResponseProto_RetrieveStaticDataStatusSuccess) {
    NSMutableDictionary *mutDict = gs.staticStructs;
    for (FullStructureProto *st in proto.structsList) {
      [mutDict setObject:st forKey:[NSNumber numberWithInt:st.structId]];
    }
    
    mutDict = gs.staticTasks;
    for (FullTaskProto *task in proto.tasksList) {
      [mutDict setObject:task forKey:[NSNumber numberWithInt:task.taskId]];
    }
    
    mutDict = gs.staticEquips;
    for (FullEquipProto *equip in proto.equipsList) {
      [mutDict setObject:equip forKey:[NSNumber numberWithInt:equip.equipId]];
    }
    
    mutDict = gs.staticCities;
    for (FullCityProto *city in proto.citiesList) {
      [mutDict setObject:city forKey:[NSNumber numberWithInt:city.cityId]];
    }
    
    mutDict = gs.staticQuests;
    for (FullQuestProto *quest in proto.questsList) {
      [mutDict setObject:quest forKey:[NSNumber numberWithInt:quest.questId]];
    }
    
    mutDict = gs.staticBuildStructJobs;
    for (BuildStructJobProto *job in proto.buildStructJobsList) {
      [mutDict setObject:job forKey:[NSNumber numberWithInt:job.buildStructJobId]];
    }
    
    mutDict = gs.staticDefeatTypeJobs;
    for (DefeatTypeJobProto *job in proto.defeatTypeJobsList) {
      [mutDict setObject:job forKey:[NSNumber numberWithInt:job.defeatTypeJobId]];
    }
    
    mutDict = gs.staticEquips;
    for (FullEquipProto *eq in proto.possessEquipJobsList) {
      [mutDict setObject:eq forKey:[NSNumber numberWithInt:eq.equipId]];
    }
    
    mutDict = gs.staticUpgradeStructJobProto;
    for (UpgradeStructJobProto *job in proto.upgradeStructJobsList) {
      [mutDict setObject:job forKey:[NSNumber numberWithInt:job.upgradeStructJobId]];
    }
  }
}

@end
