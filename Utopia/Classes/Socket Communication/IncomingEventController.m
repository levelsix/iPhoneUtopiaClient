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
#import "MarketplaceViewController.h"

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
    case EventProtocolResponseSMoveNormStructureEvent:
      responseClass = [MoveNormStructureResponseProto class];
      break;
    case EventProtocolResponseSUpgradeNormStructureEvent:
      responseClass = [UpgradeNormStructureResponseProto class];
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
    
    for (FullMarketplacePostProto *p in [proto marketplacePostsList]) {
      if (p.postType == MarketplacePostTypeEquipPost) {
        [eq addObject:p];
      } else {
        [cur addObject:p];
      }
    }
    int c = mvc.state == kCurrencyBuyingState || mvc.state == kCurrencySellingState ? x+1 : y+1;
    [mvc reloadRowsFrom:c];
  }
  [mvc performSelector:@selector(stopLoading) withObject:nil afterDelay:0.4];
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

- (void) handleMoveNormStructureResponseProto: (MoveNormStructureResponseProto *) proto {
  NSLog(@"Move norm struct response received.");
}

- (void) handleUpgradeNormStructureResponseProto: (UpgradeNormStructureResponseProto *) proto {
  NSLog(@"Upgrade norm structure response received.");
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
}

@end
