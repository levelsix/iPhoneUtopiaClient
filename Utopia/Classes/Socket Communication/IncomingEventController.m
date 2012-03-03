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
#import "MapViewController.h"
#import "ArmoryViewController.h"
#import "CarpenterMenuController.h"

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
    case EventProtocolResponseSArmoryEvent:
      responseClass = [ArmoryResponseProto class];
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
    case EventProtocolResponseSRetrieveStaticDataForShopEvent:
      responseClass = [RetrieveStaticDataForShopResponseProto class];
      break;
    case EventProtocolResponseSEquipEquipmentEvent:
      responseClass = [EquipEquipmentResponseProto class];
      break;
    default:
      responseClass = nil;
      break;
  }
  return responseClass;
}

- (void) receivedResponseForMessage:(int)tag {
  // Clear the static data we have held
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

- (void) handleArmoryResponseProto: (ArmoryResponseProto *) proto {
  NSLog(@"Armory response received with status %d", proto.status);
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
  [gs addToMyStructs:proto.userStructuresList];
  [gs addToStaticCities:proto.citiesAvailableToUserList];
  [gs addToStaticEquips:proto.equipsList];
  [gs addToStaticStructs:proto.structsList];
  [oec retrieveAllStaticData];
  
  HomeMap *map = [HomeMap sharedHomeMap];
  [map performSelectorOnMainThread:@selector(refresh) withObject:nil waitUntilDone:YES];
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
    NSMutableArray *eq;
    
    if (proto.fromSender) {
      eq = [[GameState sharedGameState] marketplaceEquipPostsFromSender];
    } else {
      eq = [[GameState sharedGameState] marketplaceEquipPosts];
    }
    
    if (proto.beforeThisPostId == 0) {
      [eq removeAllObjects];
    }
    
    int oldCount = [eq count];
    
    for (FullMarketplacePostProto *fmpp in proto.marketplacePostsList) {
      [eq addObject:fmpp];
    }
    
    [mvc insertRowsFrom:oldCount+1];
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
  NSLog(@"Generate attack list response received with status %d and %d enemies.", proto.status, proto.enemiesList.count);
  
  if (proto.status == GenerateAttackListResponseProto_GenerateAttackListStatusSuccess) {
    GameState *gs = [GameState sharedGameState];
    for (FullUserProto *fup in proto.enemiesList) {
      BOOL shouldBeAdded = YES;
      for (FullUserProto *checkFup in gs.attackList) {
        if (checkFup.userId == fup.userId) {
          shouldBeAdded = NO;
        }
      }
      
      if (shouldBeAdded) {
        [gs.attackList addObject:fup];
      }
    }
    [[MapViewController sharedMapViewController] addNewPins];
  } else {
    [Globals popupMessage:@"An error occurred while generating the attack list"];
  }
}

- (void) handleUseSkillPointResponseProto: (UseSkillPointResponseProto *) proto {
  NSLog(@"Use skill point response received with status %d.", proto.status);
}

- (void) handleRefillStatWithDiamondsResponseProto: (RefillStatWithDiamondsResponseProto *) proto {
  NSLog(@"Refill stat with diamonds response with status %d.", proto.status);
}

- (void) handlePurchaseNormStructureResponseProto: (PurchaseNormStructureResponseProto *) proto {
  NSLog(@"Purchase norm struct response received with status: %d.", proto.status);
  
  // Get the userstruct without a userStructId
  UserStruct *us = nil;
  for (UserStruct *u in [[GameState sharedGameState] myStructs]) {
    if (u.userStructId == 0) {
      us = u;
      break;
    }
  }
  
  if (proto.status == PurchaseCityExpansionResponseProto_PurchaseCityExpansionStatusSuccess) {
    if (proto.hasUserStructId) {
      us.userStructId = proto.userStructId;
    } else {
      // This should never happen
      NSLog(@"Received success in purchase with no userStructId");
    }
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Something went wrong in the purchase. Error Status: %d", proto.status]];
    [[[GameState sharedGameState] myStructs] removeObject:us];
    [[HomeMap sharedHomeMap] refresh];
  }
}

- (void) handleMoveOrRotateNormStructureResponseProto: (MoveOrRotateNormStructureResponseProto *) proto {
  NSLog(@"Move norm struct response received with status: %d.", proto.status);
}

- (void) handleUpgradeNormStructureResponseProto: (UpgradeNormStructureResponseProto *) proto {
  NSLog(@"Upgrade norm structure response received with status %d.", proto.status);
}

- (void) handleNormStructWaitCompleteResponseProto: (NormStructWaitCompleteResponseProto *) proto {
  NSLog(@"Norm struct builds complete response received");
}

- (void) handleFinishNormStructWaittimeWithDiamondsResponseProto: (FinishNormStructWaittimeWithDiamondsResponseProto *) proto {
  NSLog(@"Finish norm struct with diamonds response received with status %d.", proto.status);
}

- (void) handleRetrieveCurrencyFromNormStructureResponseProto: (RetrieveCurrencyFromNormStructureResponseProto *) proto {
  NSLog(@"Retrieve currency response received with status: %d.", proto.status);
}

- (void) handleSellNormStructureResponseProto: (SellNormStructureResponseProto *) proto {
  NSLog(@"Sell norm struct response received with status %d.", proto.status);
}

- (void) handleLoadPlayerCityResponseProto: (LoadPlayerCityResponseProto *) proto {
  NSLog(@"Load player city response received with status %d.", proto.status);
  [[GameState sharedGameState] addToMyStructs:proto.ownerNormStructsList];
  [[OutgoingEventController sharedOutgoingEventController] retrieveAllStaticData];
  [[HomeMap sharedHomeMap] refresh];
}

- (void) handleRetrieveStaticDataResponseProto: (RetrieveStaticDataResponseProto *) proto {
  NSLog(@"Retrieve static data response received with status %d.", proto.status);
  GameState *gs = [GameState sharedGameState];
  
  if (proto.status == RetrieveStaticDataResponseProto_RetrieveStaticDataStatusSuccess) {
    [gs addToStaticBuildStructJobs:proto.buildStructJobsList];
    [gs addToStaticCities:proto.citiesList];
    [gs addToStaticDefeatTypeJobs:proto.defeatTypeJobsList];
    [gs addToStaticEquips:proto.equipsList];
    [gs addToStaticPossessEquipJobs:proto.possessEquipJobsList];
    [gs addToStaticQuests:proto.questsList];
    [gs addToStaticStructs:proto.structsList];
    [gs addToStaticTasks:proto.tasksList];
    [gs addToStaticUpgradeStructJobs:proto.upgradeStructJobsList];
  }
}

- (void) handleRetrieveStaticDataForShopResponseProto: (RetrieveStaticDataForShopResponseProto *)proto {
  NSLog(@"Retrieve static data for shop response received with status %d, %d structs, %d equips.", proto.status, proto.structsList.count, proto.equipsList.count);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == RetrieveStaticDataForShopResponseProto_RetrieveStaticDataForShopStatusSuccess) {
    if (proto.structsList.count > 0) {
      [gs setCarpenterStructs:proto.structsList];
      
      [gs addToStaticStructs:proto.structsList];
      
      CarpenterMenuController *cmc = [CarpenterMenuController sharedCarpenterMenuController];
      [cmc.carpTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }
    
    if (proto.equipsList.count > 0) {
      // Need to sort armory equips
      NSMutableArray *weapons = [NSMutableArray array];
      NSMutableArray *armor = [NSMutableArray array];
      NSMutableArray *amulets = [NSMutableArray array];
      for (FullEquipProto *fep in proto.equipsList) {
        NSMutableArray *toAdd;
        if (fep.equipType == FullEquipProto_EquipTypeWeapon) {
          toAdd = weapons;
        } else if (fep.equipType == FullEquipProto_EquipTypeArmor) {
          toAdd = armor;
        } else if (fep.equipType == FullEquipProto_EquipTypeAmulet) {
          toAdd = amulets;
        } else {
          [Globals popupMessage:@"Found an equip with invalid type"];
        }
        
        // Make sure to enter them in order
        int i = toAdd.count-1;
        while (i >= 0) {
          FullEquipProto *cur = [toAdd objectAtIndex:i];
          if (cur.equipId < fep.equipId) {
            break;
          }
          i--;
        }
        [toAdd insertObject:fep atIndex:i+1];
      }
      gs.armoryWeapons = weapons;
      gs.armoryArmor = armor;
      gs.armoryAmulets = amulets;

      [gs addToStaticEquips:proto.equipsList];
      
      ArmoryViewController *avc = [ArmoryViewController sharedArmoryViewController];
      [avc performSelectorOnMainThread:@selector(refresh) withObject:nil waitUntilDone:YES];
    }
  } else {
    [Globals popupMessage:@"Unable to reach store.."];
  }
}

- (void) handleEquipEquipmentResponseProto: (EquipEquipmentResponseProto *)proto {
  NSLog(@"Equip equipment response received with status %d.", proto.status);
  
  if (proto.status != EquipEquipmentResponseProto_EquipEquipmentStatusSuccess) {
    [Globals popupMessage:@"Unable to equip equipment."];
  }
}

@end
