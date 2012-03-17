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
#import "GameLayer.h"
#import "QuestLogController.h"
#import "BattleLayer.h"
#import "LevelUpViewController.h"
#import "MissionMap.h"
#import "TutorialConstants.h"
#import "GameViewController.h"

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
    case EventProtocolResponseSRefillStatWaitCompleteEvent:
      responseClass = [RefillStatWaitCompleteResponseProto class];
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
    case EventProtocolResponseSLoadNeutralCityEvent:
      responseClass = [LoadNeutralCityResponseProto class];
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
    case EventProtocolResponseSChangeUserLocationEvent:
      responseClass = [ChangeUserLocationResponseProto class];
      break;
    case EventProtocolResponseSQuestAcceptEvent:
      responseClass = [QuestAcceptResponseProto class];
      break;
    case EventProtocolResponseSQuestRedeemEvent:
      responseClass = [QuestRedeemResponseProto class];
      break;
    case EventProtocolResponseSUserQuestDetailsEvent:
      responseClass = [UserQuestDetailsResponseProto class];
      break;
    case EventProtocolResponseSQuestCompleteEvent:
      responseClass = [QuestCompleteResponseProto class];
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
  NSLog(@"Battle response received with status %d.", proto.status);
  
  if (proto.status == BattleResponseProto_BattleStatusSuccess) {
    GameState *gs = [GameState sharedGameState];
    
    gs.experience += proto.expGained;
    gs.silver += proto.coinsGained;
    
    int equipId = proto.equipGained.equipId;
    UserEquip *ue = [gs myEquipWithId:equipId];
    if (ue) {
      ue.quantity++;
    } else {
      UserEquip *ue = [[UserEquip alloc] init];
      ue.equipId = equipId;
      ue.quantity = 1;
      ue.userId = gs.userId;
      [[gs myEquips] addObject:ue];
      [ue release];
    }
    
    if (proto.hasEquipGained) {
      [[gs staticEquips] setObject:proto.equipGained forKey:[NSNumber numberWithInt:proto.equipGained.equipId]];
    }
    [[BattleLayer sharedBattleLayer] setBrp:proto];
  } else {
    [Globals popupMessage:@"Server failed to record battle"];
  }
}

- (void) handleArmoryResponseProto: (ArmoryResponseProto *) proto {
  NSLog(@"Armory response received with status %d", proto.status);
}

- (void) handleStartupResponseProto: (StartupResponseProto *) proto {
  NSLog(@"Startup response received with status %d.", proto.startupStatus);
  
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  
  [gl updateConstants:proto.startupConstants];
  if (proto.startupStatus == StartupResponseProto_StartupStatusUserInDb) {
    [[GameViewController sharedGameViewController] setIsTutorial:NO];
    
    OutgoingEventController *oec = [OutgoingEventController sharedOutgoingEventController];
    
    [gs updateUser:proto.sender];
    [gs addToMyEquips:proto.userEquipsList];
    [gs addToMyCities:proto.userCityInfosList];
    [gs addToStaticCities:proto.citiesAvailableToUserList];
    [gs addToStaticEquips:proto.equipsList];
    [gs addToAvailableQuests:proto.availableQuestsList];
    [gs addToInProgressQuests:proto.inProgressQuestsList];
    [oec loadPlayerCity:gs.userId];
    [oec retrieveAllStaticData];
    
    gs.expRequiredForCurrentLevel = proto.experienceRequiredForCurrentLevel;
    gs.expRequiredForNextLevel = proto.experienceRequiredForNextLevel;
  } else {
    // Need to create new player
    StartupResponseProto_TutorialConstants *tc = proto.tutorialConstants;
    [[TutorialConstants sharedTutorialConstants] loadTutorialConstants:tc];
    [gs addToStaticStructs:tc.carpenterStructsList];
    NSArray *arr = [NSArray arrayWithObjects:tc.warriorInitWeapon, tc.warriorInitArmor, tc.archerInitWeapon, tc.archerInitArmor, tc.mageInitWeapon, tc.mageInitArmor, tc.tutorialQuest.firstDefeatTypeJobBattleLootAmulet, nil];
    [gs addToStaticEquips:arr];
    
    [[GameViewController sharedGameViewController] setIsTutorial:YES];
    
    GameState *gs = [GameState sharedGameState];
    [gs setConnected:YES];
    gs.expRequiredForCurrentLevel = 0;
    gs.expRequiredForNextLevel = tc.expRequiredForLevelTwo;
  }
}

- (void) handleLevelUpResponseProto: (LevelUpResponseProto *) proto {
  NSLog(@"Level up response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == LevelUpResponseProto_LevelUpStatusSuccess) {
    gs.expRequiredForNextLevel = proto.experienceRequiredForNewNextLevel;
    [gs addToStaticEquips:proto.newlyEquippableEpicsAndLegendariesList];
    [gs addToStaticCities:proto.citiesNewlyAvailableToUserList];
    [gs addToStaticStructs:proto.newlyAvailableStructsList];
    
    // This will be released after the level up controller closes
    LevelUpViewController *vc = [[LevelUpViewController alloc] initWithLevelUpResponse:proto];
    [[[[CCDirector sharedDirector] openGLView] superview] addSubview:vc.view];
  }
}

- (void) handleInAppPurchaseResponseProto: (InAppPurchaseResponseProto *) proto {
  NSLog(@"In App Purchase response received with status %d.", proto.status);
}

- (void) handleTaskActionResponseProto: (TaskActionResponseProto *) proto {
  NSLog(@"Task action received with status %d.", proto.status);
}

- (void) handleUpdateClientUserResponseProto: (UpdateClientUserResponseProto *) proto {
  NSLog(@"Update client user response received.");
  
  [[GameState sharedGameState] updateUser:proto.sender];
}

- (void)handleRetrieveCurrentMarketplacePostsResponseProto:(RetrieveCurrentMarketplacePostsResponseProto *)proto {
  NSLog(@"Retrieve mkt response received with %d posts%@.", proto.marketplacePostsList.count, proto.fromSender ? @" from sender" : @"");
  
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
  NSLog(@"Post to mkt response received with status %d", [proto status]);
}

- (void) handlePurchaseFromMarketplaceResponseProto: (PurchaseFromMarketplaceResponseProto *) proto {
  NSLog(@"Purchase from mkt response received with status %d", proto.status);
}

- (void) handleRetractMarketplacePostResponseProto: (RetractMarketplacePostResponseProto *) proto {
  NSLog(@"Retract marketplace response received with status %d", proto.status);
}

- (void) handleRedeemMarketplaceEarningsRequestProto: (RedeemMarketplaceEarningsResponseProto *) proto {
  NSLog(@"Redeem response received with statuss %d", proto.status);
}

- (void) handleGenerateAttackListResponseProto: (GenerateAttackListResponseProto *) proto {
  NSLog(@"Generate attack list response received with status %d and %d enemies.", proto.status, proto.enemiesList.count);
  
  if (proto.status == GenerateAttackListResponseProto_GenerateAttackListStatusSuccess) {
    GameState *gs = [GameState sharedGameState];
    for (FullUserProto *fup in proto.enemiesList) {
      BOOL shouldBeAdded = YES;
      // Make sure this is not a repeat
      for (FullUserProto *checkFup in gs.attackList) {
        if (checkFup.userId == fup.userId) {
          shouldBeAdded = NO;
        }
      }
      
      if (shouldBeAdded) {
        [gs.attackList addObject:fup];
      }
    }
    [[OutgoingEventController sharedOutgoingEventController] retrieveAllStaticData];
    [[MapViewController sharedMapViewController] addNewPins];
  } else {
    [Globals popupMessage:@"An error occurred while generating the attack list"];
  }
}

- (void) handleUseSkillPointResponseProto: (UseSkillPointResponseProto *) proto {
  NSLog(@"Use skill point response received with status %d.", proto.status);
}

- (void) handleRefillStatWaitCompleteResponseProto: (RefillStatWaitCompleteResponseProto *) proto {
  NSLog(@"Refill stat wait complete response received with status %d.", proto.status);
  
  
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
  NSLog(@"Norm struct builds complete response received with status %d.", proto.status);
  
  if (proto.status != NormStructWaitCompleteResponseProto_NormStructWaitCompleteStatusSuccess) {
    [Globals popupMessage:@"Server failed to complete normal structure wait time."];
  }
}

- (void) handleFinishNormStructWaittimeWithDiamondsResponseProto: (FinishNormStructWaittimeWithDiamondsResponseProto *) proto {
  NSLog(@"Finish norm struct with diamonds response received with status %d.", proto.status);
  
  if (proto.status != FinishNormStructWaittimeWithDiamondsResponseProto_FinishNormStructWaittimeStatusSuccess) {
    [Globals popupMessage:@"Server failed to speed up normal structure wait time."];
  }
}

- (void) handleRetrieveCurrencyFromNormStructureResponseProto: (RetrieveCurrencyFromNormStructureResponseProto *) proto {
  NSLog(@"Retrieve currency response received with status: %d.", proto.status);
  
  if (proto.status != RetrieveStaticDataResponseProto_RetrieveStaticDataStatusSuccess) {
    [Globals popupMessage:@"Server failed to retrieve from normal structure."];
  }
}

- (void) handleSellNormStructureResponseProto: (SellNormStructureResponseProto *) proto {
  NSLog(@"Sell norm struct response received with status %d.", proto.status);
  
  if (proto.status != SellNormStructureResponseProto_SellNormStructureStatusSuccess) {
    [Globals popupMessage:@"Server failed to sell normal structure."];
  }
}

- (void) handleLoadPlayerCityResponseProto: (LoadPlayerCityResponseProto *) proto {
  NSLog(@"Load player city response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  
  if (proto.status == LoadPlayerCityResponseProto_LoadPlayerCityStatusSuccess) {
    [gs addToMyStructs:proto.ownerNormStructsList];
    
    NSMutableArray *arr = [NSMutableArray array];
    if (proto.hasArmory) [arr addObject:proto.armory];
    if (proto.hasMarketplace) [arr addObject:proto.marketplace];
    if (proto.hasAviary) [arr addObject:proto.aviary];
    if (proto.hasCarpenter) [arr addObject:proto.carpenter];
    if (proto.hasVault) [arr addObject:proto.vault];
    [gs addToMyCritStructs:arr];
    
    [[OutgoingEventController sharedOutgoingEventController] retrieveAllStaticData];
    [[HomeMap sharedHomeMap] refresh];
  } else if (proto.status == LoadPlayerCityResponseProto_LoadPlayerCityStatusNoSuchPlayer) {
    [Globals popupMessage:@"Trying to reach a nonexistent player's city."];
  } else {
    [Globals popupMessage:@"Server failed to load player city."];
  }
}

- (void) handleLoadNeutralCityResponseProto: (LoadNeutralCityResponseProto *)proto {
  NSLog(@"Load neutral city response received with status %d.", proto.status);
  
  //  GameState *gs = [GameState sharedGameState];
  
  if (proto.status == LoadNeutralCityResponseProto_LoadNeutralCityStatusSuccess) {
    [[GameLayer sharedGameLayer] loadMissionMapWithProto:proto];
    [[OutgoingEventController sharedOutgoingEventController] retrieveAllStaticData];
  } else if (proto.status == LoadNeutralCityResponseProto_LoadNeutralCityStatusNotAccessibleToUser) {
    [Globals popupMessage:@"Trying to reach inaccessible city.."];
  } else {
    [Globals popupMessage:@"Server failed to send back static data."];
  }
}

- (void) handleRetrieveStaticDataResponseProto: (RetrieveStaticDataResponseProto *) proto {
  NSLog(@"Retrieve static data response received with status %d", proto.status);
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
    
    [[OutgoingEventController sharedOutgoingEventController] retrieveAllStaticData];
  } else {
    [Globals popupMessage:@"Server failed to send back static data."];
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
        NSMutableArray *toAdd = nil;
        if (fep.equipType == FullEquipProto_EquipTypeWeapon) {
          toAdd = weapons;
        } else if (fep.equipType == FullEquipProto_EquipTypeArmor) {
          toAdd = armor;
        } else if (fep.equipType == FullEquipProto_EquipTypeAmulet) {
          toAdd = amulets;
        } else {
          [Globals popupMessage:@"Found an equip with invalid type."];
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
    [Globals popupMessage:@"Server failed to send back store data.."];
  }
}

- (void) handleEquipEquipmentResponseProto: (EquipEquipmentResponseProto *)proto {
  NSLog(@"Equip equipment response received with status %d.", proto.status);
  
  if (proto.status != EquipEquipmentResponseProto_EquipEquipmentStatusSuccess) {
    [Globals popupMessage:@"Server failed to equip equipment."];
  }
}

- (void) handleChangeUserLocationResponseProto: (ChangeUserLocationResponseProto *)proto {
  NSLog(@"Change user location response received with status %d.", proto.status);
  
  if (proto.status != ChangeUserLocationResponseProto_ChangeUserLocationStatusSuccess) {
    [Globals popupMessage:@"Server failed to update user location."];
  }
}

- (void) handleQuestAcceptResponseProto: (QuestAcceptResponseProto *)proto {
  NSLog(@"Quest accept response received with status %d", proto.status);
  
  if (proto.status != QuestAcceptResponseProto_QuestAcceptStatusSuccess) {
    [Globals popupMessage:@"Server failed to accept quest"];
  } else {
    [[[GameLayer sharedGameLayer] missionMap] reloadQuestGivers];
  }
}

- (void) handleQuestRedeemResponseProto: (QuestRedeemResponseProto *)proto {
  NSLog(@"Quest redeem response received with status %d", proto.status);
  
  if (proto.status == QuestRedeemResponseProto_QuestRedeemStatusSuccess) {
    [[GameState sharedGameState] addToAvailableQuests:proto.newlyAvailableQuestsList];
    
    [[[GameLayer sharedGameLayer] missionMap] reloadQuestGivers];
  } else {
    [Globals popupMessage:@"Server failed to redeem quest"];
  }
}

- (void) handleUserQuestDetailsResponseProto: (UserQuestDetailsResponseProto *)proto {
  NSLog(@"Quest log details response received with status %d", proto.status);
  if (proto.status == UserQuestDetailsResponseProto_UserQuestDetailsStatusSuccess) {
    [[QuestLogController sharedQuestLogController] loadQuestData:proto.inProgressUserQuestDataList];
    [[OutgoingEventController sharedOutgoingEventController] retrieveAllStaticData];
  } else {
    [Globals popupMessage:@"Server failed to send quest log details"];
  }
}

- (void) handleQuestCompleteResponseProto: (QuestCompleteResponseProto *)proto {
  NSLog(@"Received quest complete response for quest %d.", proto.questId);
  
  GameState *gs = [GameState sharedGameState];
  FullQuestProto *fqp = [[gs inProgressQuests] objectForKey:[NSNumber numberWithInt:proto.questId]];
  
  if (fqp) {
    QuestCompleteView *qcv = [[QuestLogController sharedQuestLogController] createQuestCompleteView];
    qcv.questNameLabel.text = fqp.name;
    
    FullCityProto *fcp = [gs cityWithId:fqp.cityId];
    qcv.visitDescLabel.text = [NSString stringWithFormat:@"Visit %@ in %@ to receive your reward!", proto.neutralCityElement.name, fcp.name];
    
    [[[[CCDirector sharedDirector] openGLView] superview] addSubview:qcv];
  } else {
    [Globals popupMessage:@"Server sent quest complete for invalid quest"];
  }
}

@end
