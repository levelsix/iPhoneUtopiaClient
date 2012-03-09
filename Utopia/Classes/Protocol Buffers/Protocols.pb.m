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
    case EventProtocolResponseSUpdateClientUserEvent:
    case EventProtocolResponseSQuestCompleteEvent:
    case EventProtocolResponseSReferralCodeUsedEvent:
      return YES;
    default:
      return NO;
  }
}
