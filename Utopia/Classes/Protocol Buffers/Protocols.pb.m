// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "Protocols.pb.h"

@implementation ProtocolsRoot
static PBExtensionRegistry* extensionRegistry = nil;
+ (PBExtensionRegistry*) extensionRegistry {
  return extensionRegistry;
}

+ (void) initialize {
  if (self == [ProtocolsRoot class]) {
    PBMutableExtensionRegistry* registry = [PBMutableExtensionRegistry registry];
    [self registerAllExtensions:registry];
    [EventRoot registerAllExtensions:registry];
    extensionRegistry = [registry retain];
  }
}
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry {
}
@end

BOOL EventProtocolRequestIsValidValue(EventProtocolRequest value) {
  switch (value) {
    case EventProtocolRequestCChatEvent:
    case EventProtocolRequestCBattleEvent:
    case EventProtocolRequestCVaultEvent:
    case EventProtocolRequestCTaskActionEvent:
    case EventProtocolRequestCRetrieveUserEquipForUser:
    case EventProtocolRequestCStartupEvent:
    case EventProtocolRequestCRetrieveStaticDataForShopEvent:
    case EventProtocolRequestCArmoryEvent:
    case EventProtocolRequestCInAppPurchaseEvent:
    case EventProtocolRequestCRetrieveCurrentMarketplacePostsEvent:
    case EventProtocolRequestCPostToMarketplaceEvent:
    case EventProtocolRequestCRetractPostFromMarketplaceEvent:
    case EventProtocolRequestCPurchaseFromMarketplaceEvent:
    case EventProtocolRequestCUseSkillPointEvent:
    case EventProtocolRequestCGenerateAttackListEvent:
    case EventProtocolRequestCPurchaseNormStructureEvent:
    case EventProtocolRequestCMoveOrRotateNormStructureEvent:
    case EventProtocolRequestCSellNormStructureEvent:
    case EventProtocolRequestCUpgradeNormStructureEvent:
    case EventProtocolRequestCRetrieveCurrencyFromNormStructureEvent:
    case EventProtocolRequestCRefillStatWithDiamondsEvent:
    case EventProtocolRequestCFinishNormStructWaittimeWithDiamondsEvent:
    case EventProtocolRequestCNormStructWaitCompleteEvent:
    case EventProtocolRequestCRedeemMarketplaceEarningsEvent:
    case EventProtocolRequestCCritStructureActionEvent:
    case EventProtocolRequestCLoadPlayerCityEvent:
    case EventProtocolRequestCRetrieveStaticDataEvent:
    case EventProtocolRequestCQuestAcceptEvent:
    case EventProtocolRequestCUserQuestDetailsEvent:
    case EventProtocolRequestCQuestRedeemEvent:
    case EventProtocolRequestCPurchaseCityExpansionEvent:
    case EventProtocolRequestCExpansionWaitCompleteEvent:
    case EventProtocolRequestCRefillStatWaitCompleteEvent:
    case EventProtocolRequestCLevelUpEvent:
    case EventProtocolRequestCEnableApnsEvent:
    case EventProtocolRequestCPurchaseMarketplaceLicenseEvent:
    case EventProtocolRequestCUserCreateEvent:
    case EventProtocolRequestCEquipEquipmentEvent:
    case EventProtocolRequestCChangeUserLocationEvent:
    case EventProtocolRequestCLoadNeutralCityEvent:
    case EventProtocolRequestCRetrieveUsersForUserIdsEvent:
    case EventProtocolRequestCPostOnPlayerWallEvent:
    case EventProtocolRequestCRetrievePlayerWallPostsEvent:
    case EventProtocolRequestCEarnFreeDiamondsEvent:
    case EventProtocolRequestCReconnectEvent:
    case EventProtocolRequestCSubmitEquipsToBlacksmith:
    case EventProtocolRequestCForgeAttemptWaitComplete:
    case EventProtocolRequestCFinishForgeAttemptWaittimeWithDiamonds:
    case EventProtocolRequestCCollectForgeEquips:
    case EventProtocolRequestCCharacterModEvent:
    case EventProtocolRequestCRetrieveLeaderboardEvent:
    case EventProtocolRequestCSendGroupChatEvent:
    case EventProtocolRequestCPurchaseGroupChatEvent:
    case EventProtocolRequestCCreateClanEvent:
    case EventProtocolRequestCLeaveClanEvent:
    case EventProtocolRequestCRequestJoinClanEvent:
    case EventProtocolRequestCRetractRequestJoinClanEvent:
    case EventProtocolRequestCApproveOrRejectRequestToJoinClanEvent:
    case EventProtocolRequestCTransferClanOwnership:
    case EventProtocolRequestCRetrieveClanInfoEvent:
    case EventProtocolRequestCChangeClanDescriptionEvent:
    case EventProtocolRequestCPostOnClanBulletinEvent:
    case EventProtocolRequestCRetrieveClanBulletinPostsEvent:
    case EventProtocolRequestCBootPlayerFromClanEvent:
    case EventProtocolRequestCRetrieveThreeCardMonteEvent:
    case EventProtocolRequestCPlayThreeCardMonteEvent:
    case EventProtocolRequestCBeginGoldmineTimerEvent:
    case EventProtocolRequestCCollectFromGoldmineEvent:
    case EventProtocolRequestCPickLockBoxEvent:
    case EventProtocolRequestCBossActionEvent:
    case EventProtocolRequestCBeginClanTowerWar:
    case EventProtocolRequestCUpgradeClanTierEvent:
    case EventProtocolRequestCConcedeClanTowerWar:
    case EventProtocolRequestCRetrieveLeaderboardRankingsEvent:
    case EventProtocolRequestCSubmitEquipEnhancementEvent:
    case EventProtocolRequestCCollectEquipEnhancementEvent:
    case EventProtocolRequestCRetrieveClanTowerScoresEvent:
    case EventProtocolRequestCRetrieveBoosterPackEvent:
    case EventProtocolRequestCPurchaseBoosterPackEvent:
    case EventProtocolRequestCResetBoosterPackEvent:
    case EventProtocolRequestCChangeClanJoinTypeEvent:
    case EventProtocolRequestCPurchaseForgeSlotEvent:
    case EventProtocolRequestCLogoutEvent:
    case EventProtocolRequestAAdminUpdate:
      return YES;
    default:
      return NO;
  }
}
BOOL EventProtocolResponseIsValidValue(EventProtocolResponse value) {
  switch (value) {
    case EventProtocolResponseSChatEvent:
    case EventProtocolResponseSBattleEvent:
    case EventProtocolResponseSVaultEvent:
    case EventProtocolResponseSTaskActionEvent:
    case EventProtocolResponseSRetrieveUserEquipForUser:
    case EventProtocolResponseSStartupEvent:
    case EventProtocolResponseSRetrieveStaticDataForShopEvent:
    case EventProtocolResponseSArmoryEvent:
    case EventProtocolResponseSInAppPurchaseEvent:
    case EventProtocolResponseSRetrieveCurrentMarketplacePostsEvent:
    case EventProtocolResponseSPostToMarketplaceEvent:
    case EventProtocolResponseSRetractPostFromMarketplaceEvent:
    case EventProtocolResponseSPurchaseFromMarketplaceEvent:
    case EventProtocolResponseSUseSkillPointEvent:
    case EventProtocolResponseSGenerateAttackListEvent:
    case EventProtocolResponseSPurchaseNormStructureEvent:
    case EventProtocolResponseSMoveOrRotateNormStructureEvent:
    case EventProtocolResponseSSellNormStructureEvent:
    case EventProtocolResponseSUpgradeNormStructureEvent:
    case EventProtocolResponseSRetrieveCurrencyFromNormStructureEvent:
    case EventProtocolResponseSRefillStatWithDiamondsEvent:
    case EventProtocolResponseSFinishNormStructWaittimeWithDiamondsEvent:
    case EventProtocolResponseSNormStructWaitCompleteEvent:
    case EventProtocolResponseSRedeemMarketplaceEarningsEvent:
    case EventProtocolResponseSCritStructureActionEvent:
    case EventProtocolResponseSLoadPlayerCityEvent:
    case EventProtocolResponseSRetrieveStaticDataEvent:
    case EventProtocolResponseSQuestAcceptEvent:
    case EventProtocolResponseSUserQuestDetailsEvent:
    case EventProtocolResponseSQuestRedeemEvent:
    case EventProtocolResponseSPurchaseCityExpansionEvent:
    case EventProtocolResponseSExpansionWaitCompleteEvent:
    case EventProtocolResponseSRefillStatWaitCompleteEvent:
    case EventProtocolResponseSLevelUpEvent:
    case EventProtocolResponseSEnableApnsEvent:
    case EventProtocolResponseSPurchaseMarketplaceLicenseEvent:
    case EventProtocolResponseSUserCreateEvent:
    case EventProtocolResponseSEquipEquipmentEvent:
    case EventProtocolResponseSChangeUserLocationEvent:
    case EventProtocolResponseSLoadNeutralCityEvent:
    case EventProtocolResponseSRetrieveUsersForUserIdsEvent:
    case EventProtocolResponseSPostOnPlayerWallEvent:
    case EventProtocolResponseSRetrievePlayerWallPostsEvent:
    case EventProtocolResponseSEarnFreeDiamondsEvent:
    case EventProtocolResponseSReconnectEvent:
    case EventProtocolResponseSSubmitEquipsToBlacksmith:
    case EventProtocolResponseSForgeAttemptWaitComplete:
    case EventProtocolResponseSFinishForgeAttemptWaittimeWithDiamonds:
    case EventProtocolResponseSCollectForgeEquips:
    case EventProtocolResponseSCharacterModEvent:
    case EventProtocolResponseSRetrieveLeaderboardEvent:
    case EventProtocolResponseSSendGroupChatEvent:
    case EventProtocolResponseSPurchaseGroupChatEvent:
    case EventProtocolResponseSCreateClanEvent:
    case EventProtocolResponseSLeaveClanEvent:
    case EventProtocolResponseSRequestJoinClanEvent:
    case EventProtocolResponseSRetractRequestJoinClanEvent:
    case EventProtocolResponseSApproveOrRejectRequestToJoinClanEvent:
    case EventProtocolResponseSTransferClanOwnership:
    case EventProtocolResponseSRetrieveClanInfoEvent:
    case EventProtocolResponseSChangeClanDescriptionEvent:
    case EventProtocolResponseSPostOnClanBulletinEvent:
    case EventProtocolResponseSRetrieveClanBulletinPostsEvent:
    case EventProtocolResponseSBootPlayerFromClanEvent:
    case EventProtocolResponseSRetrieveThreeCardMonteEvent:
    case EventProtocolResponseSPlayThreeCardMonteEvent:
    case EventProtocolResponseSBeginGoldmineTimerEvent:
    case EventProtocolResponseSCollectFromGoldmineEvent:
    case EventProtocolResponseSPickLockBoxEvent:
    case EventProtocolResponseSBossActionEvent:
    case EventProtocolResponseSBeginClanTowerWar:
    case EventProtocolResponseSUpgradeClanTierEvent:
    case EventProtocolResponseSConcedeClanTowerWarEvent:
    case EventProtocolResponseSChangedClanTowerEvent:
    case EventProtocolResponseSRetrieveLeaderboardRankingsEvent:
    case EventProtocolResponseSSubmitEquipEnhancementEvent:
    case EventProtocolResponseSCollectEquipEnhancementEvent:
    case EventProtocolResponseSRetrieveClanTowerScoresEvent:
    case EventProtocolResponseSRetrieveBoosterPackEvent:
    case EventProtocolResponseSPurchaseBoosterPackEvent:
    case EventProtocolResponseSResetBoosterPackEvent:
    case EventProtocolResponseSChangeClanJoinTypeEvent:
    case EventProtocolResponseSPurchaseForgeSlotEvent:
    case EventProtocolResponseSUpdateClientUserEvent:
    case EventProtocolResponseSQuestCompleteEvent:
    case EventProtocolResponseSReferralCodeUsedEvent:
    case EventProtocolResponseSPurgeStaticDataEvent:
    case EventProtocolResponseSReceivedGroupChatEvent:
    case EventProtocolResponseSSendAdminMessageEvent:
    case EventProtocolResponseSGeneralNotificationEvent:
    case EventProtocolResponseSReceivedRareBoosterPurchaseEvent:
      return YES;
    default:
      return NO;
  }
}
