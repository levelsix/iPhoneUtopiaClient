//
//  EventController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/3/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "IncomingEventController.h"
#import "Protocols.pb.h"
#import "LNSynthesizeSingleton.h"
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
#import "VaultMenuController.h"

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
    case EventProtocolResponseSEnableApnsEvent:
      responseClass = [EnableAPNSResponseProto class];
      break;
    case EventProtocolResponseSEarnFreeDiamonds:
      responseClass = [EarnFreeDiamondsResponseProto class];
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

- (void) handleUserCreateResponseProto:(UserCreateResponseProto *)proto tag:(int)tag  {
  LNLog(@"Received user create with status %d", proto.status);
  
  [[DialogMenuController sharedDialogMenuController] receivedUserCreateResponse:proto];
  GameState *gs = [GameState sharedGameState];
  if (proto.status == UserCreateResponseProto_UserCreateStatusSuccess) {
    [gs updateUser:proto.sender];
    [[OutgoingEventController sharedOutgoingEventController] startup];
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleChatResponseProto:(ChatResponseProto *)proto tag:(int)tag {
  LNLog(@"%@", [proto message]);
}

- (void) handleVaultResponseProto:(VaultResponseProto *)proto tag:(int)tag {
  LNLog(@"Vault response received with status %d", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == VaultResponseProto_VaultStatusSuccess) {
    [gs setVaultBalance:proto.vaultAmount];
    [gs setSilver:proto.coinAmount];
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to perform vault action."];
    [gs removeAndUndoAllUpdatesForTag:tag];
    [[VaultMenuController sharedVaultMenuController] updateBalance];
  }
}

- (void) handleBattleResponseProto:(BattleResponseProto *)proto tag:(int)tag {
  LNLog(@"Battle response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == BattleResponseProto_BattleStatusSuccess) {
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
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to record battle"];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleArmoryResponseProto:(ArmoryResponseProto *)proto tag:(int)tag {
  LNLog(@"Armory response received with status %d", proto.status);
  
  GameState *gs =[GameState sharedGameState];
  if (proto.status != ArmoryResponseProto_ArmoryStatusSuccess) {
    [Globals popupMessage:@"Server failed to perform armory action."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [gs removeNonFullUserUpdatesForTag:tag];
  }
}

- (void) handleStartupResponseProto:(StartupResponseProto *)proto tag:(int)tag {
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
    [gs.inProgressCompleteQuests removeAllObjects];
    [gs addToInProgressCompleteQuests:proto.inProgressCompleteQuestsList];
    [gs.inProgressIncompleteQuests removeAllObjects];
    [gs addToInProgressIncompleteQuests:proto.inProgressIncompleteQuestsList];
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
    
    [gs setConnected:YES];
    gs.connected = YES;
    gs.expRequiredForCurrentLevel = 0;
    gs.expRequiredForNextLevel = tc.expRequiredForLevelTwo;
  }
  
  [gs removeNonFullUserUpdatesForTag:tag];
}

- (void) handleLevelUpResponseProto:(LevelUpResponseProto *)proto tag:(int)tag {
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
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to handle level up"];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleInAppPurchaseResponseProto:(InAppPurchaseResponseProto *)proto tag:(int)tag {
  LNLog(@"In App Purchase response received with status %d.", proto.status);
  
  [[GoldShoppeViewController sharedGoldShoppeViewController] stopLoading];
  GameState *gs = [GameState sharedGameState];
  if (proto.status != InAppPurchaseResponseProto_InAppPurchaseStatusSuccess) {
    [Globals popupMessage:@"Sorry! Server failed to process in app purchase! Please send us an email at support@lvl6.com"];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [gs removeNonFullUserUpdatesForTag:tag];
  }
}

- (void) handleTaskActionResponseProto:(TaskActionResponseProto *)proto tag:(int)tag {
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
      int cityId = proto.cityId;
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
            mb.numTimesActedForTask = 0;
          }
        }
      }
    }
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to complete task"];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleUpdateClientUserResponseProto:(UpdateClientUserResponseProto *)proto tag:(int)tag {
  LNLog(@"Update client user response received.");
  
  GameState *gs = [GameState sharedGameState];
  [gs removeFullUserUpdatesForTag:tag];
  [gs updateUser:proto.sender];
}

- (void)handleRetrieveCurrentMarketplacePostsResponseProto:(RetrieveCurrentMarketplacePostsResponseProto *)proto tag:(int)tag {
  LNLog(@"Retrieve mkt response received with %d posts%@ and status %d.", proto.marketplacePostsList.count, proto.fromSender ? @" from sender" : @"", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  MarketplaceViewController *mvc = [MarketplaceViewController sharedMarketplaceViewController];
  if (proto.status == RetrieveCurrentMarketplacePostsResponseProto_RetrieveCurrentMarketplacePostsStatusSuccess) {
    if ([proto.marketplacePostsList count] > 0) {
      if (mvc.view.superview) {
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
    }
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to retrieve current marketplace posts."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
  [mvc doneRefreshing];
  [mvc performSelector:@selector(stopLoading) withObject:nil afterDelay:0.6];
}

- (void) handlePostToMarketplaceResponseProto:(PostToMarketplaceResponseProto *)proto tag:(int)tag {
  LNLog(@"Post to mkt response received with status %d", [proto status]);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == PostToMarketplaceResponseProto_PostToMarketplaceStatusSuccess) {
    MarketplaceViewController *mvc = [MarketplaceViewController sharedMarketplaceViewController];
    if (mvc.view.superview) {
      [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentMarketplacePostsFromSender];
    }
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to post item."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handlePurchaseFromMarketplaceResponseProto:(PurchaseFromMarketplaceResponseProto *)proto tag:(int)tag {
  LNLog(@"Purchase from mkt response received with status %d", proto.status);
  
  MarketplaceViewController *mvc = [MarketplaceViewController sharedMarketplaceViewController];
  GameState *gs = [GameState sharedGameState];
  if (proto.status == PurchaseFromMarketplaceResponseProto_PurchaseFromMarketplaceStatusSuccess) {
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
          if (mvc.view.superview) {
            [mktPosts removeObject:p];
            NSIndexPath *y = [NSIndexPath indexPathForRow:i+1 inSection:0];
            NSIndexPath *z = mktPosts.count == 0 ? [NSIndexPath indexPathForRow:0 inSection:0] : nil;
            NSArray *a = [NSArray arrayWithObjects:y, z, nil];
            [mvc.postsTableView deleteRowsAtIndexPaths:a withRowAnimation:UITableViewRowAnimationTop];
          }
          
          [gs changeQuantityForEquip:p.postedEquip.equipId by:1];
          break;
        }
      }
    }
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to purchase from marketplace."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
  [mvc removeLoadingView];
}

- (void) handleRetractMarketplacePostResponseProto:(RetractMarketplacePostResponseProto *)proto tag:(int)tag {
  LNLog(@"Retract marketplace response received with status %d", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status != RetractMarketplacePostResponseProto_RetractMarketplacePostStatusSuccess) {
    [Globals popupMessage:@"Server failed to retract marketplace post."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [gs removeNonFullUserUpdatesForTag:tag];
  }
}

- (void) handleRedeemMarketplaceEarningsRequestProto:(RedeemMarketplaceEarningsResponseProto *)proto tag:(int)tag {
  LNLog(@"Redeem response received with status %d", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status != RedeemMarketplaceEarningsResponseProto_RedeemMarketplaceEarningsStatusSuccess) {
    [Globals popupMessage:@"Server failed to redeem marketplace earnings."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [gs removeNonFullUserUpdatesForTag:tag];
  }
}

- (void) handlePurchaseMarketplaceLicenseResponseProto:(PurchaseMarketplaceLicenseResponseProto *)proto tag:(int)tag {
  LNLog(@"Purchase marketplace license received with status %d", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status != PurchaseMarketplaceLicenseResponseProto_PurchaseMarketplaceLicenseStatusSuccess) {
    [Globals popupMessage:@"Server failed to purchase marketplace license"];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [gs removeNonFullUserUpdatesForTag:tag];
  }
}

- (void) handleGenerateAttackListResponseProto:(GenerateAttackListResponseProto *)proto tag:(int)tag {
  LNLog(@"Generate attack list response received with status %d and %d enemies.", proto.status, proto.enemiesList.count);
  
    GameState *gs = [GameState sharedGameState];
  if (proto.status == GenerateAttackListResponseProto_GenerateAttackListStatusSuccess) {
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
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"An error occurred while generating the attack list"];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleUseSkillPointResponseProto:(UseSkillPointResponseProto *)proto tag:(int)tag {
  LNLog(@"Use skill point response received with status %d.", proto.status);
  
  if (proto.status != UseSkillPointResponseProto_UseSkillPointStatusSuccess) {
    [Globals popupMessage:@"Server failed to add skill point."];
  }
}

- (void) handleRefillStatWaitCompleteResponseProto:(RefillStatWaitCompleteResponseProto *)proto tag:(int)tag {
  LNLog(@"Refill stat wait complete response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status != RefillStatWaitCompleteResponseProto_RefillStatWaitCompleteStatusSuccess) {
    [Globals popupMessage:@"Server failed to refill stat."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [gs removeNonFullUserUpdatesForTag:tag];
  }
}

- (void) handleRefillStatWithDiamondsResponseProto:(RefillStatWithDiamondsResponseProto *)proto tag:(int)tag {
  LNLog(@"Refill stat with diamonds response with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status != RefillStatWithDiamondsResponseProto_RefillStatStatusSuccess) {
    [Globals popupMessage:@"Server failed to refill stat with diamonds."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [gs removeNonFullUserUpdatesForTag:tag];
  }
}

- (void) handlePurchaseNormStructureResponseProto:(PurchaseNormStructureResponseProto *)proto tag:(int)tag {
  LNLog(@"Purchase norm struct response received with status: %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
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
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to purchase building."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleMoveOrRotateNormStructureResponseProto:(MoveOrRotateNormStructureResponseProto *)proto tag:(int)tag {
  LNLog(@"Move norm struct response received with status: %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status != MoveOrRotateNormStructureResponseProto_MoveOrRotateNormStructureStatusSuccess) {
    [Globals popupMessage:@"Server failed to change building location or orientation."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [gs removeNonFullUserUpdatesForTag:tag];
  }
}

- (void) handleUpgradeNormStructureResponseProto:(UpgradeNormStructureResponseProto *)proto tag:(int)tag {
  LNLog(@"Upgrade norm structure response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status != UpgradeNormStructureResponseProto_UpgradeNormStructureStatusSuccess) {
    [Globals popupMessage:@"Server failed to upgrade building."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [gs removeNonFullUserUpdatesForTag:tag];
  }
}

- (void) handleNormStructWaitCompleteResponseProto:(NormStructWaitCompleteResponseProto *)proto tag:(int)tag {
  LNLog(@"Norm struct builds complete response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status != NormStructWaitCompleteResponseProto_NormStructWaitCompleteStatusSuccess) {
    [Globals popupMessage:@"Server failed to complete normal structure wait time."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [gs removeNonFullUserUpdatesForTag:tag];
  }
}

- (void) handleFinishNormStructWaittimeWithDiamondsResponseProto:(FinishNormStructWaittimeWithDiamondsResponseProto *)proto tag:(int)tag {
  LNLog(@"Finish norm struct with diamonds response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status != FinishNormStructWaittimeWithDiamondsResponseProto_FinishNormStructWaittimeStatusSuccess) {
    [Globals popupMessage:@"Server failed to speed up normal structure wait time."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [gs removeNonFullUserUpdatesForTag:tag];
  }
}

- (void) handleRetrieveCurrencyFromNormStructureResponseProto:(RetrieveCurrencyFromNormStructureResponseProto *)proto tag:(int)tag {
  LNLog(@"Retrieve currency response received with status: %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status != RetrieveCurrencyFromNormStructureResponseProto_RetrieveCurrencyFromNormStructureStatusSuccess) {
    [Globals popupMessage:@"Server failed to retrieve from normal structure."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [gs removeNonFullUserUpdatesForTag:tag];
  }
}

- (void) handleSellNormStructureResponseProto:(SellNormStructureResponseProto *)proto tag:(int)tag {
  LNLog(@"Sell norm struct response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status != SellNormStructureResponseProto_SellNormStructureStatusSuccess) {
    [Globals popupMessage:@"Server failed to sell normal structure."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [gs removeNonFullUserUpdatesForTag:tag];
  }
}

- (void) handleCriticalStructureActionResponseProto:(CriticalStructureActionResponseProto *)proto tag:(int)tag {
  LNLog(@"Crit struct action response received with status %d", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status != CriticalStructureActionResponseProto_CritStructActionStatusSuccess) {
    [Globals popupMessage:@"Server failed to perform critical struct action"];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [gs removeNonFullUserUpdatesForTag:tag];
  }
}

- (void) handleLoadPlayerCityResponseProto:(LoadPlayerCityResponseProto *)proto tag:(int)tag {
  LNLog(@"Load player city response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  
  if (proto.status == LoadPlayerCityResponseProto_LoadPlayerCityStatusSuccess) {
    [gs.myStructs removeAllObjects];
    [gs addToMyStructs:proto.ownerNormStructsList];
    
    [[OutgoingEventController sharedOutgoingEventController] retrieveAllStaticData];
    
    while (![[GameViewController sharedGameViewController] canLoad]) {
      [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
    dispatch_queue_t queue = dispatch_queue_create(nil, nil);
    dispatch_async(queue, ^{
      [[HomeMap sharedHomeMap] backgroundRefresh];
      gs.connected = YES;
      [[GameViewController sharedGameViewController] allowOpeningOfDoor];
    });
    dispatch_release(queue);
    [gs removeNonFullUserUpdatesForTag:tag];
  } else if (proto.status == LoadPlayerCityResponseProto_LoadPlayerCityStatusNoSuchPlayer) {
    [Globals popupMessage:@"Trying to reach a nonexistent player's city."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to load player city."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleLoadNeutralCityResponseProto:(LoadNeutralCityResponseProto *)proto tag:(int)tag {
  LNLog(@"Load neutral city response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == LoadNeutralCityResponseProto_LoadNeutralCityStatusSuccess) {
    [[GameLayer sharedGameLayer] performSelectorInBackground:@selector(loadMissionMapWithProto:) withObject:proto];
    [[OutgoingEventController sharedOutgoingEventController] retrieveAllStaticData];
    [gs removeNonFullUserUpdatesForTag:tag];
  } else if (proto.status == LoadNeutralCityResponseProto_LoadNeutralCityStatusNotAccessibleToUser) {
    [Globals popupMessage:@"Trying to reach inaccessible city.."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to send back static data."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleRetrieveStaticDataResponseProto:(RetrieveStaticDataResponseProto *)proto tag:(int)tag {
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
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to send back static data."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleRetrieveStaticDataForShopResponseProto:(RetrieveStaticDataForShopResponseProto *)proto tag:(int)tag {
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
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to send back store data.."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleEquipEquipmentResponseProto:(EquipEquipmentResponseProto *)proto tag:(int)tag {
  LNLog(@"Equip equipment response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status != EquipEquipmentResponseProto_EquipEquipmentStatusSuccess) {
    [Globals popupMessage:@"Server failed to equip equipment."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [gs removeNonFullUserUpdatesForTag:tag];
  }
}

- (void) handleChangeUserLocationResponseProto:(ChangeUserLocationResponseProto *)proto tag:(int)tag {
  LNLog(@"Change user location response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status != ChangeUserLocationResponseProto_ChangeUserLocationStatusSuccess) {
    [Globals popupMessage:@"Server failed to update user location."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [gs removeNonFullUserUpdatesForTag:tag];
  }
}

- (void) handleQuestAcceptResponseProto:(QuestAcceptResponseProto *)proto tag:(int)tag {
  LNLog(@"Quest accept response received with status %d", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status != QuestAcceptResponseProto_QuestAcceptStatusSuccess) {
    [Globals popupMessage:@"Server failed to accept quest"];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [gs removeNonFullUserUpdatesForTag:tag];
  }
}

- (void) handleQuestRedeemResponseProto:(QuestRedeemResponseProto *)proto tag:(int)tag {
  LNLog(@"Quest redeem response received with status %d", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == QuestRedeemResponseProto_QuestRedeemStatusSuccess) {
    [[GameState sharedGameState] addToAvailableQuests:proto.newlyAvailableQuestsList];
    [[OutgoingEventController sharedOutgoingEventController] retrieveAllStaticData];
    
    // Reload quest givers for all maps cuz we have new quests
    [[[GameLayer sharedGameLayer] missionMap] reloadQuestGivers];
    [[BazaarMap sharedBazaarMap] reloadQuestGivers];
    [[HomeMap sharedHomeMap] reloadQuestGivers];
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to redeem quest"];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleUserQuestDetailsResponseProto:(UserQuestDetailsResponseProto *)proto tag:(int)tag {
  LNLog(@"Quest log details response received with status %d", proto.status);
  GameState *gs = [GameState sharedGameState];
  if (proto.status == UserQuestDetailsResponseProto_UserQuestDetailsStatusSuccess) {
    [[QuestLogController sharedQuestLogController] loadQuestData:proto.inProgressUserQuestDataList];
    [[OutgoingEventController sharedOutgoingEventController] retrieveAllStaticData];
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to send quest log details"];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleQuestCompleteResponseProto:(QuestCompleteResponseProto *)proto tag:(int)tag {
  LNLog(@"Received quest complete response for quest %d.", proto.questId);
  
  GameState *gs = [GameState sharedGameState];
  NSNumber *questNum = [NSNumber numberWithInt:proto.questId];
  FullQuestProto *fqp = [gs.inProgressIncompleteQuests objectForKey:questNum];
  
  if (fqp) {
    [[QuestLogController sharedQuestLogController] loadQuestCompleteScreen:fqp];
    
    [gs.inProgressIncompleteQuests removeObjectForKey:questNum];
    [gs.inProgressCompleteQuests setObject:fqp forKey:questNum];
    
    GameMap *map = [Globals mapForQuest:fqp];
    [map reloadQuestGivers];
    
    [Analytics questComplete:proto.questId];
  } else {
    [Globals popupMessage:@"Server sent quest complete for invalid quest"];
  }
}

- (void) handleRetrieveUserEquipForUserResponseProto:(RetrieveUserEquipForUserResponseProto *)proto tag:(int)tag {
  LNLog(@"Retrieve user equip response received.");
  
  OutgoingEventController *oec = [OutgoingEventController sharedOutgoingEventController];
  for (FullUserEquipProto *fuep in proto.userEquipsList) {
    [oec retrieveStaticEquip:fuep.equipId];
  }
  
  [[BattleLayer sharedBattleLayer] receivedUserEquips:proto];
  [[ProfileViewController sharedProfileViewController] receivedEquips:proto];
  
  GameState *gs = [GameState sharedGameState];
  [gs removeNonFullUserUpdatesForTag:tag];
}

- (void) handleRetrieveUsersForUserIdsResponseProto:(RetrieveUsersForUserIdsResponseProto *)proto tag:(int)tag {
  LNLog(@"Retrieve user ids for user received.");
  
  OutgoingEventController *oec = [OutgoingEventController sharedOutgoingEventController];
  for (FullUserProto *fup in proto.requestedUsersList) {
    [oec retrieveStaticEquip:fup.weaponEquipped];
    [oec retrieveStaticEquip:fup.armorEquipped];
    [oec retrieveStaticEquip:fup.amuletEquipped];
  }
  
  [[ActivityFeedController sharedActivityFeedController] receivedUsers:proto];
  [[ProfileViewController sharedProfileViewController] receivedFullUserProtos:proto.requestedUsersList];
  
  GameState *gs = [GameState sharedGameState];
  [gs removeNonFullUserUpdatesForTag:tag];
}

- (void) handleReferralCodeUsedResponseProto:(ReferralCodeUsedResponseProto *)proto tag:(int)tag {
  LNLog(@"Referral code used received.");
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  gs.gold += gl.diamondRewardForReferrer;
  UserNotification *un = [[UserNotification alloc] initWithReferralResponse:proto];
  [gs addNotification:un];
  [un release];
  
  [Analytics receivedNotification];
}

- (void) handleRetrievePlayerWallPostsResponseProto:(RetrievePlayerWallPostsResponseProto *)proto tag:(int)tag {
  LNLog(@"Retrieve player wall response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == RetrievePlayerWallPostsResponseProto_RetrievePlayerWallPostsStatusSuccess) {
    [[ProfileViewController sharedProfileViewController] receivedWallPosts:proto];
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to send back wall posts."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handlePostOnPlayerWallResponseProto:(PostOnPlayerWallResponseProto *)proto tag:(int)tag {
  LNLog(@"Post on player wall response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == PostOnPlayerWallResponseProto_PostOnPlayerWallStatusSuccess) {
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to send post on wall."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleEnableAPNSResponseProto:(EnableAPNSResponseProto *)proto tag:(int)tag {
  LNLog(@"Enable apns response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == EnableAPNSResponseProto_EnableAPNSStatusSuccess) {
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleEarnFreeDiamondsResponseProto:(EarnFreeDiamondsResponseProto *)proto tag:(int)tag {
  LNLog(@"Earn free diamonds response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == EarnFreeDiamondsResponseProto_EarnFreeDiamondsStatusSuccess) {
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to validate free gold."];
    [gs removeFullUserUpdatesForTag:tag];
  }
}

@end
