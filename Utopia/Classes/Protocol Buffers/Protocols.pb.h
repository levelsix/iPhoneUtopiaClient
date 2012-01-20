// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "Event.pb.h"

@class ArmoryRequestProto;
@class ArmoryRequestProto_Builder;
@class ArmoryResponseProto;
@class ArmoryResponseProto_Builder;
@class BattleRequestProto;
@class BattleRequestProto_Builder;
@class BattleResponseProto;
@class BattleResponseProto_Builder;
@class ChangeUserLocationRequestProto;
@class ChangeUserLocationRequestProto_Builder;
@class ChatRequestProto;
@class ChatRequestProto_Builder;
@class ChatResponseProto;
@class ChatResponseProto_Builder;
@class ClericHealRequestProto;
@class ClericHealRequestProto_Builder;
@class ClericHealResponseProto;
@class ClericHealResponseProto_Builder;
@class CoordinateProto;
@class CoordinateProto_Builder;
@class FullEquipProto;
@class FullEquipProto_Builder;
@class FullMarketplacePostProto;
@class FullMarketplacePostProto_Builder;
@class FullTaskProto;
@class FullTaskProto_Builder;
@class FullUserProto;
@class FullUserProto_Builder;
@class FullUserStructureProto;
@class FullUserStructureProto_Builder;
@class InAppPurchaseRequestProto;
@class InAppPurchaseRequestProto_Builder;
@class InAppPurchaseResponseProto;
@class InAppPurchaseResponseProto_Builder;
@class LevelUpResponseProto;
@class LevelUpResponseProto_Builder;
@class LocationProto;
@class LocationProto_Builder;
@class MinimumUserProto;
@class MinimumUserProto_Builder;
@class MoveCriticalStructureRequestProto;
@class MoveCriticalStructureRequestProto_Builder;
@class MoveUserStructureRequestProto;
@class MoveUserStructureRequestProto_Builder;
@class PlaceCriticalStructureRequestProto;
@class PlaceCriticalStructureRequestProto_Builder;
@class PostToMarketplaceRequestProto;
@class PostToMarketplaceRequestProto_Builder;
@class PostToMarketplaceResponseProto;
@class PostToMarketplaceResponseProto_Builder;
@class PurchaseFromMarketplaceRequestProto;
@class PurchaseFromMarketplaceRequestProto_Builder;
@class PurchaseFromMarketplaceResponseProto;
@class PurchaseFromMarketplaceResponseProto_Builder;
@class PurchaseStructureRequestProto;
@class PurchaseStructureRequestProto_Builder;
@class RetractMarketplacePostRequestProto;
@class RetractMarketplacePostRequestProto_Builder;
@class RetractMarketplacePostResponseProto;
@class RetractMarketplacePostResponseProto_Builder;
@class RetrieveCurrentMarketplacePostsRequestProto;
@class RetrieveCurrentMarketplacePostsRequestProto_Builder;
@class RetrieveCurrentMarketplacePostsResponseProto;
@class RetrieveCurrentMarketplacePostsResponseProto_Builder;
@class RetrieveEquipmentForArmoryRequestProto;
@class RetrieveEquipmentForArmoryRequestProto_Builder;
@class RetrieveEquipmentForArmoryResponseProto;
@class RetrieveEquipmentForArmoryResponseProto_Builder;
@class RetrieveTasksForCityRequestProto;
@class RetrieveTasksForCityRequestProto_Builder;
@class RetrieveTasksForCityResponseProto;
@class RetrieveTasksForCityResponseProto_Builder;
@class StartupRequestProto;
@class StartupRequestProto_Builder;
@class StartupResponseProto;
@class StartupResponseProto_Builder;
@class TaskActionRequestProto;
@class TaskActionRequestProto_Builder;
@class TaskActionResponseProto;
@class TaskActionResponseProto_Builder;
@class UpdateClientUserResponseProto;
@class UpdateClientUserResponseProto_Builder;
@class UseSkillPointRequestProto;
@class UseSkillPointRequestProto_Builder;
@class UseSkillPointResponseProto;
@class UseSkillPointResponseProto_Builder;
@class UserCreateRequestProto;
@class UserCreateRequestProto_Builder;
@class UserCreateResponseProto;
@class UserCreateResponseProto_Builder;
@class VaultRequestProto;
@class VaultRequestProto_Builder;
@class VaultResponseProto;
@class VaultResponseProto_Builder;
typedef enum {
  EventProtocolRequestCChatEvent = 0,
  EventProtocolRequestCBattleEvent = 1,
  EventProtocolRequestCVaultEvent = 2,
  EventProtocolRequestCTaskActionEvent = 3,
  EventProtocolRequestCClericHealEvent = 4,
  EventProtocolRequestCStartupEvent = 5,
  EventProtocolRequestCRetrieveTasksForCityEvent = 6,
  EventProtocolRequestCRetrieveQuestsForCityEvent = 7,
  EventProtocolRequestCRetrieveEquipsForArmoryEvent = 8,
  EventProtocolRequestCArmoryEvent = 9,
  EventProtocolRequestCInAppPurchaseEvent = 10,
  EventProtocolRequestCRetrieveCurrentMarketplacePostsEvent = 11,
  EventProtocolRequestCPostToMarketplaceEvent = 12,
  EventProtocolRequestCRetractPostFromMarketplaceEvent = 13,
  EventProtocolRequestCPurchaseFromMarketplaceEvent = 14,
  EventProtocolRequestCUseSkillPointEvent = 15,
} EventProtocolRequest;

BOOL EventProtocolRequestIsValidValue(EventProtocolRequest value);

typedef enum {
  EventProtocolResponseSChatEvent = 0,
  EventProtocolResponseSBattleEvent = 1,
  EventProtocolResponseSVaultEvent = 2,
  EventProtocolResponseSTaskActionEvent = 3,
  EventProtocolResponseSClericHealEvent = 4,
  EventProtocolResponseSStartupEvent = 5,
  EventProtocolResponseSRetrieveTasksForCityEvent = 6,
  EventProtocolResponseSRetrieveQuestsForCityEvent = 7,
  EventProtocolResponseSRetrieveEquipsForArmoryEvent = 8,
  EventProtocolResponseSArmoryEvent = 9,
  EventProtocolResponseSInAppPurchaseEvent = 10,
  EventProtocolResponseSRetrieveCurrentMarketplacePostsEvent = 11,
  EventProtocolResponseSPostToMarketplaceEvent = 12,
  EventProtocolResponseSRetractPostFromMarketplaceEvent = 13,
  EventProtocolResponseSPurchaseFromMarketplaceEvent = 14,
  EventProtocolResponseSUseSkillPointEvent = 15,
  EventProtocolResponseSLevelUpEvent = 19,
  EventProtocolResponseSUpdateClientUserEvent = 20,
} EventProtocolResponse;

BOOL EventProtocolResponseIsValidValue(EventProtocolResponse value);


@interface ProtocolsRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

