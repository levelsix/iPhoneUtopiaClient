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
#import "CityRankupViewController.h"
#import "GoldShoppeViewController.h"
#import "ActivityFeedController.h"
#import "GenericPopupController.h"
#import "DialogMenuController.h"
#import "ProfileViewController.h"

@implementation IncomingEventController

SYNTHESIZE_SINGLETON_FOR_CLASS(IncomingEventController);

- (Class) getClassForType: (EventProtocolResponse) type {
  // This is very hacky but I suppose necessary.. :/
  Class responseClass;
  switch (type) {
    case EventProtocolResponseSUserCreateEvent:
      responseClass = [UserCreateResponseProto class];
      break;
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
    case EventProtocolResponseSPurchaseMarketplaceLicenseEvent:
      responseClass = [PurchaseMarketplaceLicenseResponseProto class];
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
    case EventProtocolResponseSCritStructureActionEvent:
      responseClass = [CriticalStructureActionResponseProto class];
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
    case EventProtocolResponseSRetrieveUserEquipForUser:
      responseClass = [RetrieveUserEquipForUserResponseProto class];
      break;
    case EventProtocolResponseSRetrieveUsersForUserIdsEvent:
      responseClass = [RetrieveUsersForUserIdsResponseProto class];
      break;
    case EventProtocolResponseSReferralCodeUsedEvent:
      responseClass = [ReferralCodeUsedResponseProto class];
      break;
    case EventProtocolResponseSRetrievePlayerWallPosts:
      responseClass = [RetrievePlayerWallPostsResponseProto class];
      break;
    case EventProtocolResponseSPostOnPlayerWall:
      responseClass = [PostOnPlayerWallResponseProto class];
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

- (void) handleUserCreateResponseProto:(UserCreateResponseProto *) proto {
  LNLog(@"Received user create with status %d", proto.status);
  
  [[DialogMenuController sharedDialogMenuController] receivedUserCreateResponse:proto];
  if (proto.status == UserCreateResponseProto_UserCreateStatusSuccess) {
    [[GameState sharedGameState] updateUser:proto.sender];
    [[OutgoingEventController sharedOutgoingEventController] startup];
  }
}

- (void) handleChatResponseProto:(ChatResponseProto *) proto {
  LNLog(@"%@", [proto message]);
}

- (void) handleVaultResponseProto:(VaultResponseProto *) proto {
  LNLog(@"Vault response received with status %d", proto.status);
  
  if (proto.status == VaultResponseProto_VaultStatusSuccess) {
    [[GameState sharedGameState] setVaultBalance:proto.vaultAmount];
    [[GameState sharedGameState] setSilver:proto.coinAmount];
  } else {
    [Globals popupMessage:@"Server failed to perform vault action."];
  }
}

- (void) handleBattleResponseProto:(BattleResponseProto *) proto {
  LNLog(@"Battle response received with status %d.", proto.status);
  
  if (proto.status == BattleResponseProto_BattleStatusSuccess) {
    GameState *gs = [GameState sharedGameState];
    
    if (proto.attacker.userId == gs.userId) {
      gs.experience += proto.expGained;
      
      if (proto.battleResult == BattleResultAttackerWin) {
        gs.silver += proto.coinsGained;
      } else {
        gs.silver -= proto.coinsGained;
      }
      
      if (proto.hasEquipGained) {
        [[gs staticEquips] setObject:proto.equipGained forKey:[NSNumber numberWithInt:proto.equipGained.equipId]];
        [gs changeQuantityForEquip:proto.equipGained.equipId by:1];
      }
      [[BattleLayer sharedBattleLayer] setBrp:proto];
    } else {
      if (proto.battleResult == BattleResultAttackerWin) {
        gs.silver -= proto.coinsGained;
      } else {
        gs.silver += proto.coinsGained;
      }
      
      if (proto.hasEquipGained) {
        [[gs staticEquips] setObject:proto.equipGained forKey:[NSNumber numberWithInt:proto.equipGained.equipId]];
        [gs changeQuantityForEquip:proto.equipGained.equipId by:-1];
      }
      
      UserNotification *un = [[UserNotification alloc] initWithBattleResponse:proto];
      [gs addNotification:un];
      [un release];
      
      [Analytics receivedNotification];
    }
  } else {
    [Globals popupMessage:@"Server failed to record battle"];
  }
}

- (void) handleArmoryResponseProto:(ArmoryResponseProto *) proto {
  LNLog(@"Armory response received with status %d", proto.status);
  
  if (proto.status != ArmoryResponseProto_ArmoryStatusSuccess) {
    [Globals popupMessage:@"Server failed to perform armory action."];
  }
}

- (void) handleStartupResponseProto:(StartupResponseProto *) proto {
  LNLog(@"Startup response received with status %d.", proto.startupStatus);
  
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  
  if (proto.updateStatus == StartupResponseProto_UpdateStatusMajorUpdate) {
    [GenericPopupController displayMajorUpdatePopup:proto.appStoreUrl];
    return;
  } else if (proto.updateStatus == StartupResponseProto_UpdateStatusMinorUpdate) {
    [Globals popupMessage:@"There is an update available. Head over to the app store to download it now!"];
  }
  
  [gl updateConstants:proto.startupConstants];
  if (proto.startupStatus == StartupResponseProto_StartupStatusUserInDb) {
    // Update user before creating map
    [gs updateUser:proto.sender];
    [[GameViewController sharedGameViewController] setIsTutorial:NO];
    
    OutgoingEventController *oec = [OutgoingEventController sharedOutgoingEventController];
    
    [gs.myEquips removeAllObjects];
    [gs addToMyEquips:proto.userEquipsList];
    [gs.myCities removeAllObjects];
    [gs addToMyCities:proto.userCityInfosList];
    [gs.staticCities removeAllObjects];
    [gs addToStaticCities:proto.allCitiesList];
    [gs.staticEquips removeAllObjects];
    [gs addToStaticEquips:proto.equipsList];
    [gs.availableQuests removeAllObjects];
    [gs addToAvailableQuests:proto.availableQuestsList];
    [gs.inProgressQuests removeAllObjects];
//    [gs addToInProgressQuests:proto.in];
    [oec loadPlayerCity:gs.userId];
    [oec retrieveAllStaticData];
    
    gs.expRequiredForCurrentLevel = proto.experienceRequiredForCurrentLevel;
    gs.expRequiredForNextLevel = proto.experienceRequiredForNextLevel;
    
    UserNotification *un;
    for (StartupResponseProto_AttackedNotificationProto *p in proto.attackNotificationsList) {
      un = [[UserNotification alloc] initBattleNotificationAtStartup:p];
      [gs addNotification:un];
      [un release];
    }
    for (StartupResponseProto_MarketplacePostPurchasedNotificationProto *p in proto.marketplacePurchaseNotificationsList) {
      un = [[UserNotification alloc] initMarketplaceNotificationAtStartup:p];
      [gs addNotification:un];
      [un release];
    }
    for (StartupResponseProto_ReferralNotificationProto *p in proto.referralNotificationsList) {
      un = [[UserNotification alloc] initReferralNotificationAtStartup:p];
      [gs addNotification:un];
      [un release];
    }
    
    for (PlayerWallPostProto *wallPost in proto.playerWallPostNotificationsList) {
      [gs addWallPost:wallPost];
    }
    
    if (gs.isTutorial) {
      [[DialogMenuController sharedDialogMenuController] stopLoading];
    }
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
    gs.connected = YES;
    gs.expRequiredForCurrentLevel = 0;
    gs.expRequiredForNextLevel = tc.expRequiredForLevelTwo;
  }
}

- (void) handleLevelUpResponseProto:(LevelUpResponseProto *) proto {
  LNLog(@"Level up response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == LevelUpResponseProto_LevelUpStatusSuccess) {
    gs.expRequiredForNextLevel = proto.experienceRequiredForNewNextLevel;
    [gs addToStaticEquips:proto.newlyEquippableEpicsAndLegendariesList];
    [gs addToStaticCities:proto.citiesNewlyAvailableToUserList];
    [gs addToStaticStructs:proto.newlyAvailableStructsList];
    
    for (FullCityProto *fcp in proto.citiesNewlyAvailableToUserList) {
      UserCity *uc = [[UserCity alloc] init];
      uc.cityId = fcp.cityId;
      uc.curRank = 1;
      uc.numTasksComplete = 0;
      [gs.myCities setObject:uc forKey:[NSNumber numberWithInt:fcp.cityId]];
      [uc release];
    }
    
    // This will be released after the level up controller closes
    LevelUpViewController *vc = [[LevelUpViewController alloc] initWithLevelUpResponse:proto];
    [[[[CCDirector sharedDirector] openGLView] superview] addSubview:vc.view];
    
    [Analytics levelUp:proto.newLevel];
  } else {
    [Globals popupMessage:@"Server failed to handle level up"];
  }
}

- (void) handleInAppPurchaseResponseProto:(InAppPurchaseResponseProto *) proto {
  LNLog(@"In App Purchase response received with status %d.", proto.status);
  
  [[GoldShoppeViewController sharedGoldShoppeViewController] stopLoading];
  if (proto.status != InAppPurchaseResponseProto_InAppPurchaseStatusSuccess) {
    [Globals popupMessage:@"Sorry! Server failed to process in app purchase! Please send us an email at support@lvl6.com"];
  }
}

- (void) handleTaskActionResponseProto:(TaskActionResponseProto *) proto {
  LNLog(@"Task action received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  GameLayer *gLay = [GameLayer sharedGameLayer];
  [[gLay missionMap] receivedTaskResponse:proto];
  
  if (proto.status == TaskActionResponseProto_TaskActionStatusSuccess) {
    gs.silver +=  proto.coinsGained;
    
    if (proto.hasLootEquipId && proto.lootEquipId > 0) {
      [gs changeQuantityForEquip:proto.lootEquipId by:1];
    }
    
    if (proto.cityRankedUp) {
      int cityId = 1;
      UserCity *city = [gs myCityWithId:cityId];
      city.curRank++;
      city.numTasksComplete = 0;
      
      gs.silver += proto.coinBonusIfCityRankup;
      gs.experience += proto.expBonusIfCityRankup;
            
      // This will be released after the level up controller closes
      CityRankupViewController *vc = [[CityRankupViewController alloc] initWithRank:city.curRank coins:proto.coinBonusIfCityRankup exp:proto.expBonusIfCityRankup];
      [[[[CCDirector sharedDirector] openGLView] superview] addSubview:vc.view];
      
      if (gLay.currentCity == cityId) {
        NSArray *sprites = [[gLay missionMap] mapSprites];
        for (MapSprite *spr in sprites) {
          if ([spr isKindOfClass:[MissionBuilding class]]) {
            MissionBuilding *mb = (MissionBuilding *)spr;
            mb.numTimesActed = 0;
          }
        }
      }
    }
  } else {
    [Globals popupMessage:@"Server failed to complete task"];
  }
}

- (void) handleUpdateClientUserResponseProto:(UpdateClientUserResponseProto *) proto {
  LNLog(@"Update client user response received.");
  
  [[GameState sharedGameState] updateUser:proto.sender];
}

- (void)handleRetrieveCurrentMarketplacePostsResponseProto:(RetrieveCurrentMarketplacePostsResponseProto *)proto {
  LNLog(@"Retrieve mkt response received with %d posts%@ and status %d.", proto.marketplacePostsList.count, proto.fromSender ? @" from sender" : @"", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  MarketplaceViewController *mvc = [MarketplaceViewController sharedMarketplaceViewController];
  if (proto.status == RetrieveCurrentMarketplacePostsResponseProto_RetrieveCurrentMarketplacePostsStatusSuccess) {
    if ([proto.marketplacePostsList count] > 0) {
      NSMutableArray *eq;
      NSMutableArray *staticEquips = [NSMutableArray arrayWithCapacity:proto.marketplacePostsList.count];
      
      if (proto.fromSender) {
        eq = [gs marketplaceEquipPostsFromSender];
      } else {
        eq = [gs marketplaceEquipPosts];
      }
      
      if (proto.beforeThisPostId == 0) {
        [eq removeAllObjects];
      }
      
      int oldCount = [eq count];
      
      for (FullMarketplacePostProto *fmpp in proto.marketplacePostsList) {
        [eq addObject:fmpp];
        [staticEquips addObject:fmpp.postedEquip];
      }
      [gs addToStaticEquips:staticEquips];
      
      [mvc insertRowsFrom:oldCount+![[GameState sharedGameState] hasValidLicense]+1];
    }
  } else {
    [Globals popupMessage:@"Server failed to retrieve current marketplace posts."];
  }
  [mvc doneRefreshing];
  [mvc performSelector:@selector(stopLoading) withObject:nil afterDelay:0.6];
}

- (void) handlePostToMarketplaceResponseProto:(PostToMarketplaceResponseProto *) proto {
  LNLog(@"Post to mkt response received with status %d", [proto status]);
  
  if (proto.status == PostToMarketplaceResponseProto_PostToMarketplaceStatusSuccess) {
    [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentMarketplacePostsFromSender];
  } else {
    [Globals popupMessage:@"Server failed to post item."];
  }
}

- (void) handlePurchaseFromMarketplaceResponseProto:(PurchaseFromMarketplaceResponseProto *) proto {
  LNLog(@"Purchase from mkt response received with status %d", proto.status);
  
  MarketplaceViewController *mvc = [MarketplaceViewController sharedMarketplaceViewController];
  if (proto.status == PurchaseFromMarketplaceResponseProto_PurchaseFromMarketplaceStatusSuccess) {
    GameState *gs = [GameState sharedGameState];
    if (proto.posterId == gs.userId) {
      // This is a notification
      UserNotification *un = [[UserNotification alloc] initWithMarketplaceResponse:proto];
      [gs addNotification:un];
      [un release];
      
      [Analytics receivedNotification];
    } else {
      NSMutableArray *mktPosts = [mvc postsForState];
      
      for (int i = 0; i < mktPosts.count; i++) {
        FullMarketplacePostProto *p = [mktPosts objectAtIndex:i];
        if (p.marketplacePostId == proto.marketplacePost.marketplacePostId) {
          [mktPosts removeObject:p];
          NSIndexPath *y = [NSIndexPath indexPathForRow:i+1 inSection:0];
          NSIndexPath *z = mktPosts.count == 0? [NSIndexPath indexPathForRow:0 inSection:0]:nil;
          NSArray *a = [NSArray arrayWithObjects:y, z, nil];
          [mvc.postsTableView deleteRowsAtIndexPaths:a withRowAnimation:UITableViewRowAnimationTop];
          
          [gs changeQuantityForEquip:p.postedEquip.equipId by:1];
          break;
        }
      }
    }
  } else {
    [Globals popupMessage:@"Server failed to purchase from marketplace."];
  }
  [mvc removeLoadingView];
}

- (void) handleRetractMarketplacePostResponseProto:(RetractMarketplacePostResponseProto *) proto {
  LNLog(@"Retract marketplace response received with status %d", proto.status);
  
  if (proto.status != RetractMarketplacePostResponseProto_RetractMarketplacePostStatusSuccess) {
    [Globals popupMessage:@"Server failed to retract marketplace post."];
  }
}

- (void) handleRedeemMarketplaceEarningsRequestProto:(RedeemMarketplaceEarningsResponseProto *) proto {
  LNLog(@"Redeem response received with status %d", proto.status);
  
  if (proto.status != RedeemMarketplaceEarningsResponseProto_RedeemMarketplaceEarningsStatusSuccess) {
    [Globals popupMessage:@"Server failed to redeem marketplace earnings."];
  }
}

- (void) handlePurchaseMarketplaceLicenseResponseProto:(PurchaseMarketplaceLicenseResponseProto *) proto {
  LNLog(@"Purchase marketplace license received with status %d", proto.status);
  
  if (proto.status != PurchaseMarketplaceLicenseResponseProto_PurchaseMarketplaceLicenseStatusSuccess) {
    [Globals popupMessage:@"Server failed to purchase marketplace license"];
  }
}

- (void) handleGenerateAttackListResponseProto:(GenerateAttackListResponseProto *) proto {
  LNLog(@"Generate attack list response received with status %d and %d enemies.", proto.status, proto.enemiesList.count);
  
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

- (void) handleUseSkillPointResponseProto:(UseSkillPointResponseProto *) proto {
  LNLog(@"Use skill point response received with status %d.", proto.status);
  
  if (proto.status != UseSkillPointResponseProto_UseSkillPointStatusSuccess) {
    [Globals popupMessage:@"Server failed to add skill point."];
  }
}

- (void) handleRefillStatWaitCompleteResponseProto:(RefillStatWaitCompleteResponseProto *) proto {
  LNLog(@"Refill stat wait complete response received with status %d.", proto.status);
  
  if (proto.status != RefillStatWaitCompleteResponseProto_RefillStatWaitCompleteStatusSuccess) {
    // Silence this
    [Globals popupMessage:@"Server failed to refill stat."];
  }
}

- (void) handleRefillStatWithDiamondsResponseProto:(RefillStatWithDiamondsResponseProto *) proto {
  LNLog(@"Refill stat with diamonds response with status %d.", proto.status);
  
  if (proto.status != RefillStatWithDiamondsResponseProto_RefillStatStatusSuccess) {
    [Globals popupMessage:@"Server failed to refill stat with diamonds."];
  }
}

- (void) handlePurchaseNormStructureResponseProto:(PurchaseNormStructureResponseProto *) proto {
  LNLog(@"Purchase norm struct response received with status: %d.", proto.status);
  
  if (proto.status == PurchaseNormStructureResponseProto_PurchaseNormStructureStatusSuccess) {
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
        LNLog(@"Received success in purchase with no userStructId");
      }
    } else {
      [Globals popupMessage:[NSString stringWithFormat:@"Something went wrong in the purchase. Error Status: %d", proto.status]];
      [[[GameState sharedGameState] myStructs] removeObject:us];
      [[HomeMap sharedHomeMap] refresh];
    }
  } else {
    [Globals popupMessage:@"Server failed to purchase building."];
  }
}

- (void) handleMoveOrRotateNormStructureResponseProto:(MoveOrRotateNormStructureResponseProto *) proto {
  LNLog(@"Move norm struct response received with status: %d.", proto.status);
  
  if (proto.status != MoveOrRotateNormStructureResponseProto_MoveOrRotateNormStructureStatusSuccess) {
    [Globals popupMessage:@"Server failed to change building location or orientation."];
  }
}

- (void) handleUpgradeNormStructureResponseProto:(UpgradeNormStructureResponseProto *) proto {
  LNLog(@"Upgrade norm structure response received with status %d.", proto.status);
  
  if (proto.status != UpgradeNormStructureResponseProto_UpgradeNormStructureStatusSuccess) {
    [Globals popupMessage:@"Server failed to upgrade building."];
  }
}

- (void) handleNormStructWaitCompleteResponseProto:(NormStructWaitCompleteResponseProto *) proto {
  LNLog(@"Norm struct builds complete response received with status %d.", proto.status);
  
  if (proto.status != NormStructWaitCompleteResponseProto_NormStructWaitCompleteStatusSuccess) {
    [Globals popupMessage:@"Server failed to complete normal structure wait time."];
  }
}

- (void) handleFinishNormStructWaittimeWithDiamondsResponseProto:(FinishNormStructWaittimeWithDiamondsResponseProto *) proto {
  LNLog(@"Finish norm struct with diamonds response received with status %d.", proto.status);
  
  if (proto.status != FinishNormStructWaittimeWithDiamondsResponseProto_FinishNormStructWaittimeStatusSuccess) {
    [Globals popupMessage:@"Server failed to speed up normal structure wait time."];
  }
}

- (void) handleRetrieveCurrencyFromNormStructureResponseProto:(RetrieveCurrencyFromNormStructureResponseProto *) proto {
  LNLog(@"Retrieve currency response received with status: %d.", proto.status);
  
  if (proto.status != RetrieveCurrencyFromNormStructureResponseProto_RetrieveCurrencyFromNormStructureStatusSuccess) {
    [Globals popupMessage:@"Server failed to retrieve from normal structure."];
  }
}

- (void) handleSellNormStructureResponseProto:(SellNormStructureResponseProto *) proto {
  LNLog(@"Sell norm struct response received with status %d.", proto.status);
  
  if (proto.status != SellNormStructureResponseProto_SellNormStructureStatusSuccess) {
    [Globals popupMessage:@"Server failed to sell normal structure."];
  }
}

- (void) handleCriticalStructureActionResponseProto:(CriticalStructureActionResponseProto *) proto {
  LNLog(@"Crit struct action response received with status %d", proto.status);
  
  if (proto.status != CriticalStructureActionResponseProto_CritStructActionStatusSuccess) {
    [Globals popupMessage:@"Server failed to perform critical struct action"];
  }
}

- (void) handleLoadPlayerCityResponseProto:(LoadPlayerCityResponseProto *) proto {
  LNLog(@"Load player city response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  
  if (proto.status == LoadPlayerCityResponseProto_LoadPlayerCityStatusSuccess) {
    [gs.myStructs removeAllObjects];
    [gs addToMyStructs:proto.ownerNormStructsList];
    
    NSMutableArray *arr = [NSMutableArray array];
    [gs.myCritStructs removeAllObjects];
    if (proto.hasArmory) [arr addObject:proto.armory];
    if (proto.hasMarketplace) [arr addObject:proto.marketplace];
    if (proto.hasAviary) [arr addObject:proto.aviary];
    if (proto.hasCarpenter) [arr addObject:proto.carpenter];
    if (proto.hasVault) [arr addObject:proto.vault];
    [gs addToMyCritStructs:arr];
    
    [[OutgoingEventController sharedOutgoingEventController] retrieveAllStaticData];
    
    while (![[GameViewController sharedGameViewController] canLoad]) {
      [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
    dispatch_queue_t queue = dispatch_queue_create(nil, nil);
    dispatch_async(queue, ^{
      [[HomeMap sharedHomeMap] performSelectorInBackground:@selector(backgroundRefresh) withObject:nil];
      gs.connected = YES;
      [[GameViewController sharedGameViewController] allowOpeningOfDoor];
    });
  } else if (proto.status == LoadPlayerCityResponseProto_LoadPlayerCityStatusNoSuchPlayer) {
    [Globals popupMessage:@"Trying to reach a nonexistent player's city."];
  } else {
    [Globals popupMessage:@"Server failed to load player city."];
  }
}

- (void) handleLoadNeutralCityResponseProto:(LoadNeutralCityResponseProto *)proto {
  LNLog(@"Load neutral city response received with status %d.", proto.status);
  
  if (proto.status == LoadNeutralCityResponseProto_LoadNeutralCityStatusSuccess) {
    [[GameLayer sharedGameLayer] performSelectorInBackground:@selector(loadMissionMapWithProto:) withObject:proto];
    [[OutgoingEventController sharedOutgoingEventController] retrieveAllStaticData];
  } else if (proto.status == LoadNeutralCityResponseProto_LoadNeutralCityStatusNotAccessibleToUser) {
    [Globals popupMessage:@"Trying to reach inaccessible city.."];
  } else {
    [Globals popupMessage:@"Server failed to send back static data."];
  }
}

- (void) handleRetrieveStaticDataResponseProto:(RetrieveStaticDataResponseProto *) proto {
  LNLog(@"Retrieve static data response received with status %d", proto.status);
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

- (void) handleRetrieveStaticDataForShopResponseProto:(RetrieveStaticDataForShopResponseProto *)proto {
  LNLog(@"Retrieve static data for shop response received with status %d, %d structs, %d equips.", proto.status, proto.structsList.count, proto.equipsList.count);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == RetrieveStaticDataForShopResponseProto_RetrieveStaticDataForShopStatusSuccess) {
    if (proto.structsList.count > 0) {
      [gs setCarpenterStructs:proto.structsList];
      
      [gs addToStaticStructs:proto.structsList];
      
      CarpenterMenuController *cmc = [CarpenterMenuController sharedCarpenterMenuController];
      [cmc reloadCarpenterStructs];
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
      [avc refresh];
    }
  } else {
    [Globals popupMessage:@"Server failed to send back store data.."];
  }
}

- (void) handleEquipEquipmentResponseProto:(EquipEquipmentResponseProto *)proto {
  LNLog(@"Equip equipment response received with status %d.", proto.status);
  
  if (proto.status != EquipEquipmentResponseProto_EquipEquipmentStatusSuccess) {
    [Globals popupMessage:@"Server failed to equip equipment."];
  }
}

- (void) handleChangeUserLocationResponseProto:(ChangeUserLocationResponseProto *)proto {
  LNLog(@"Change user location response received with status %d.", proto.status);
  
  if (proto.status != ChangeUserLocationResponseProto_ChangeUserLocationStatusSuccess) {
    [Globals popupMessage:@"Server failed to update user location."];
  }
}

- (void) handleQuestAcceptResponseProto:(QuestAcceptResponseProto *)proto {
  LNLog(@"Quest accept response received with status %d", proto.status);
  
  if (proto.status != QuestAcceptResponseProto_QuestAcceptStatusSuccess) {
    [Globals popupMessage:@"Server failed to accept quest"];
  } else {
    if ([[GameLayer sharedGameLayer] currentCity] == proto.cityIdOfAcceptedQuest) {
      [[[GameLayer sharedGameLayer] missionMap] receivedQuestAcceptResponse:proto];
    }
  }
}

- (void) handleQuestRedeemResponseProto:(QuestRedeemResponseProto *)proto {
  LNLog(@"Quest redeem response received with status %d", proto.status);
  
  if (proto.status == QuestRedeemResponseProto_QuestRedeemStatusSuccess) {
    [[GameState sharedGameState] addToAvailableQuests:proto.newlyAvailableQuestsList];
    [[OutgoingEventController sharedOutgoingEventController] retrieveAllStaticData];
    
    [[[GameLayer sharedGameLayer] missionMap] reloadQuestGivers];
  } else {
    [Globals popupMessage:@"Server failed to redeem quest"];
  }
}

- (void) handleUserQuestDetailsResponseProto:(UserQuestDetailsResponseProto *)proto {
  LNLog(@"Quest log details response received with status %d", proto.status);
  if (proto.status == UserQuestDetailsResponseProto_UserQuestDetailsStatusSuccess) {
    [[QuestLogController sharedQuestLogController] loadQuestData:proto.inProgressUserQuestDataList];
    [[OutgoingEventController sharedOutgoingEventController] retrieveAllStaticData];
  } else {
    [Globals popupMessage:@"Server failed to send quest log details"];
  }
}

- (void) handleQuestCompleteResponseProto:(QuestCompleteResponseProto *)proto {
  LNLog(@"Received quest complete response for quest %d.", proto.questId);
  
  GameState *gs = [GameState sharedGameState];
  FullQuestProto *fqp = [[gs inProgressQuests] objectForKey:[NSNumber numberWithInt:proto.questId]];
  
  if (fqp) {
    QuestCompleteView *qcv = [[QuestLogController sharedQuestLogController] createQuestCompleteView];
    qcv.questNameLabel.text = fqp.name;
    
    FullCityProto *fcp = [gs cityWithId:fqp.cityId];
    qcv.visitDescLabel.text = [NSString stringWithFormat:@"Visit %@ in %@ to receive your reward!", proto.neutralCityElement.name, fcp.name];
    
    [[[[CCDirector sharedDirector] openGLView] superview] addSubview:qcv];
    [Globals bounceView:qcv.mainView fadeInBgdView:qcv.bgdView];
    
    [Analytics questComplete:proto.questId];
  } else {
    [Globals popupMessage:@"Server sent quest complete for invalid quest"];
  }
}

- (void) handleRetrieveUserEquipForUserResponseProto:(RetrieveUserEquipForUserResponseProto *)proto {
  LNLog(@"Retrieve user equip response received.");
  
  OutgoingEventController *oec = [OutgoingEventController sharedOutgoingEventController];
  for (FullUserEquipProto *fuep in proto.userEquipsList) {
    [oec retrieveStaticEquip:fuep.equipId];
  }
  
  [[BattleLayer sharedBattleLayer] receivedUserEquips:proto];
}

- (void) handleRetrieveUsersForUserIdsResponseProto:(RetrieveUsersForUserIdsResponseProto *)proto {
  LNLog(@"Retrieve user ids for user received.");
  
  OutgoingEventController *oec = [OutgoingEventController sharedOutgoingEventController];
  for (FullUserProto *fup in proto.requestedUsersList) {
    [oec retrieveStaticEquip:fup.weaponEquipped];
    [oec retrieveStaticEquip:fup.armorEquipped];
    [oec retrieveStaticEquip:fup.amuletEquipped];
  }
  
  [[ActivityFeedController sharedActivityFeedController] receivedUsers:proto];
  [[ProfileViewController sharedProfileViewController] receivedFullUserProtos:proto.requestedUsersList];
}

- (void) handleReferralCodeUsedResponseProto:(ReferralCodeUsedResponseProto *)proto {
  LNLog(@"Referral code used received.");
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  gs.gold += gl.diamondRewardForReferrer;
  UserNotification *un = [[UserNotification alloc] initWithReferralResponse:proto];
  [gs addNotification:un];
  [un release];
  
  [Analytics receivedNotification];
}

- (void) handleRetrievePlayerWallPostsResponseProto:(RetrievePlayerWallPostsResponseProto *)proto {
  LNLog(@"Retrieve player wall response received with status %d.", proto.status);
  
  if (proto.status == RetrievePlayerWallPostsResponseProto_RetrievePlayerWallPostsStatusSuccess) {
    [[ProfileViewController sharedProfileViewController] receivedWallPosts:proto];
  } else {
    [Globals popupMessage:@"Server failed to send back wall posts."];
  }
}

- (void) handlePostOnPlayerWallResponseProto:(PostOnPlayerWallResponseProto *)proto {
  LNLog(@"Post on player wall response received with status %d.", proto.status);
  
  if (proto.status == PostOnPlayerWallResponseProto_PostOnPlayerWallStatusSuccess) {
    
  } else {
    [Globals popupMessage:@"Server failed to send post on wall."];
  }
}

@end
