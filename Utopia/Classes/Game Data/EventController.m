//
//  EventController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/3/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "EventController.h"
#import "Protocols.pb.h"
#import "SynthesizeSingleton.h"
#import "GameState.h"

@implementation EventController

SYNTHESIZE_SINGLETON_FOR_CLASS(EventController);

- (Class) getClassForType: (EventProtocolResponse) type {
  // This is very hacky.. :/
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
    case EventProtocolResponseSClericHealEvent:
      responseClass = [ClericHealResponseProto class];
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
  [[GameState sharedGameState] setCoins:proto.coinAmount];
  NSLog(@"Vault: %d, Coins: %d", proto.vaultAmount, proto.coinAmount);
}

- (void) handleBattleResponseProto: (BattleResponseProto *) proto {
  NSLog(@"Battle: %d, Winner: %d, Coins Gained: %d", proto.status, proto.winnerUserId, proto.coinsGained);
}

- (void) handleClericHealResponseProto: (ClericHealResponseProto *) proto {
  NSLog(@"Cleric: %d, Cost: %d", proto.status, proto.cost);
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
  for (FullMarketplacePostProto *p in [proto marketplacePostsList]) {
    NSLog(@"%d: %@", [p id], [NSDate dateWithTimeIntervalSince1970:[p timeOfPost]/1000.0]);
  }
}

- (void) handlePostToMarketplaceResponseProto: (PostToMarketplaceResponseProto *) proto {
  NSLog(@"Post to mkt response received");
}

- (void) handlePurchaseFromMarketplaceResponseProto: (PurchaseFromMarketplaceResponseProto *) proto {
  NSLog(@"Purchase from mkt response received");
}

- (void) handleRetractMarketplacePostResponseProto: (RetractMarketplacePostResponseProto *) proto {
  NSLog(@"Retract marketplace response received");
}

@end
