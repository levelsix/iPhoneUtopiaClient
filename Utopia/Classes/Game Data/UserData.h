//
//  UserData.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/9/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.pb.h"

@interface UserEquip : NSObject

@property (nonatomic, assign) int userId;
@property (nonatomic, assign) int equipId;
@property (nonatomic, assign) int quantity;
@property (nonatomic, assign) BOOL isStolen;

+ (id) userEquipWithProto:(FullUserEquipProto *)proto;

@end

typedef enum {
  kRetrieving = 1,
  kWaitingForIncome,
  kUpgrading,
  kBuilding
} UserStructState;

@interface UserStruct : NSObject 

@property (nonatomic, assign) int userStructId;
@property (nonatomic, assign) int userId;
@property (nonatomic, assign) int structId;
@property (nonatomic, retain) NSDate *lastRetrieved;
@property (nonatomic, assign) CGPoint coordinates;
@property (nonatomic, assign) int level;
@property (nonatomic, retain) NSDate *purchaseTime;
@property (nonatomic, retain) NSDate *lastUpgradeTime;
@property (nonatomic, assign) BOOL isComplete;
@property (nonatomic, assign) StructOrientation orientation;

+ (id) userStructWithProto:(FullUserStructureProto *)proto;
- (UserStructState) state;
- (FullStructureProto *) fsp;

@end

@interface UserCity : NSObject

@property (nonatomic, assign) int curRank;
@property (nonatomic, assign) int cityId;
@property (nonatomic, assign) int numTasksComplete;

+ (id) userCityWithProto:(FullUserCityProto *)proto;

@end

@interface CritStruct : NSObject 

@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) CritStructType type;
@property (nonatomic, assign) CGRect location;
@property (nonatomic, assign) StructOrientation orientation;

+ (id) critStructWithProto:(FullUserCritstructProto *)proto;
- (void) openMenu;

@end