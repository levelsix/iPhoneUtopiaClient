// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

@class AdminChangeRequestProto;
@class AdminChangeRequestProto_Builder;
typedef enum {
  AdminChangeRequestProto_StaticDataReloadTypeAll = 0,
  AdminChangeRequestProto_StaticDataReloadTypeBuildStructJobs = 1,
  AdminChangeRequestProto_StaticDataReloadTypeCities = 2,
  AdminChangeRequestProto_StaticDataReloadTypeDefeatTypeJobs = 3,
  AdminChangeRequestProto_StaticDataReloadTypeEquipment = 4,
  AdminChangeRequestProto_StaticDataReloadTypeQuests = 5,
  AdminChangeRequestProto_StaticDataReloadTypeTaskEquipRequirements = 6,
  AdminChangeRequestProto_StaticDataReloadTypeTasks = 7,
  AdminChangeRequestProto_StaticDataReloadTypeUpgradeStructJobs = 8,
  AdminChangeRequestProto_StaticDataReloadTypeStructures = 9,
  AdminChangeRequestProto_StaticDataReloadTypePossessEquipJobs = 10,
  AdminChangeRequestProto_StaticDataReloadTypeLevelsRequiredExperience = 11,
} AdminChangeRequestProto_StaticDataReloadType;

BOOL AdminChangeRequestProto_StaticDataReloadTypeIsValidValue(AdminChangeRequestProto_StaticDataReloadType value);


@interface AdminRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface AdminChangeRequestProto : PBGeneratedMessage {
@private
  BOOL hasMultipleOfRecruitsBaseReward_:1;
  BOOL hasSalePercentOff_:1;
  BOOL hasStaticDataReloadType_:1;
  Float32 multipleOfRecruitsBaseReward;
  int32_t salePercentOff;
  AdminChangeRequestProto_StaticDataReloadType staticDataReloadType;
}
- (BOOL) hasStaticDataReloadType;
- (BOOL) hasSalePercentOff;
- (BOOL) hasMultipleOfRecruitsBaseReward;
@property (readonly) AdminChangeRequestProto_StaticDataReloadType staticDataReloadType;
@property (readonly) int32_t salePercentOff;
@property (readonly) Float32 multipleOfRecruitsBaseReward;

+ (AdminChangeRequestProto*) defaultInstance;
- (AdminChangeRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (AdminChangeRequestProto_Builder*) builder;
+ (AdminChangeRequestProto_Builder*) builder;
+ (AdminChangeRequestProto_Builder*) builderWithPrototype:(AdminChangeRequestProto*) prototype;

+ (AdminChangeRequestProto*) parseFromData:(NSData*) data;
+ (AdminChangeRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (AdminChangeRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (AdminChangeRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (AdminChangeRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (AdminChangeRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface AdminChangeRequestProto_Builder : PBGeneratedMessage_Builder {
@private
  AdminChangeRequestProto* result;
}

- (AdminChangeRequestProto*) defaultInstance;

- (AdminChangeRequestProto_Builder*) clear;
- (AdminChangeRequestProto_Builder*) clone;

- (AdminChangeRequestProto*) build;
- (AdminChangeRequestProto*) buildPartial;

- (AdminChangeRequestProto_Builder*) mergeFrom:(AdminChangeRequestProto*) other;
- (AdminChangeRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (AdminChangeRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasStaticDataReloadType;
- (AdminChangeRequestProto_StaticDataReloadType) staticDataReloadType;
- (AdminChangeRequestProto_Builder*) setStaticDataReloadType:(AdminChangeRequestProto_StaticDataReloadType) value;
- (AdminChangeRequestProto_Builder*) clearStaticDataReloadType;

- (BOOL) hasSalePercentOff;
- (int32_t) salePercentOff;
- (AdminChangeRequestProto_Builder*) setSalePercentOff:(int32_t) value;
- (AdminChangeRequestProto_Builder*) clearSalePercentOff;

- (BOOL) hasMultipleOfRecruitsBaseReward;
- (Float32) multipleOfRecruitsBaseReward;
- (AdminChangeRequestProto_Builder*) setMultipleOfRecruitsBaseReward:(Float32) value;
- (AdminChangeRequestProto_Builder*) clearMultipleOfRecruitsBaseReward;
@end

