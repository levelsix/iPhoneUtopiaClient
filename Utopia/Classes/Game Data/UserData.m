//
//  UserData.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/9/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "UserData.h"
#import "GameState.h"
#import "Globals.h"
#import "OutgoingEventController.h"

@implementation UserEquip

@synthesize userId, equipId, quantity, isStolen;

- (id) initWithEquipProto:(FullUserEquipProto *)proto {
  if ((self = [super init])){
    self.userId = proto.userId;
    self.equipId = proto.equipId;
    self.quantity = proto.quantity;
    self.isStolen = proto.isStolen;
  }
  return self;
}

+ (id) userEquipWithProto:(FullUserEquipProto *)proto {
  return [[[self alloc] initWithEquipProto:proto] autorelease];
}

@end

@implementation UserStruct

@synthesize userStructId, userId, structId, level, isComplete, coordinates, orientation, purchaseTime, lastRetrieved, lastUpgradeTime;

- (id) initWithStructProto:(FullUserStructureProto *)proto {
  if ((self = [super init])) {
    self.userStructId = proto.userStructId;
    self.userId = proto.userId;
    self.structId = proto.structId;
    self.level = proto.level;
    self.isComplete = proto.isComplete;
    self.coordinates = CGPointMake(proto.coordinates.x, proto.coordinates.y);
    self.orientation = proto.orientation;
    self.purchaseTime = proto.hasPurchaseTime ? [NSDate dateWithTimeIntervalSince1970:proto.purchaseTime/1000] : nil;
    self.lastRetrieved = proto.hasLastRetrieved ? [NSDate dateWithTimeIntervalSince1970:proto.lastRetrieved/1000] : nil;
    self.lastUpgradeTime = proto.hasLastUpgradeTime ? [NSDate dateWithTimeIntervalSince1970:proto.lastUpgradeTime/1000] : nil;
  }
  return self;
}

+ (id) userStructWithProto:(FullUserStructureProto *)proto {
  return [[[self alloc] initWithStructProto:proto] autorelease];
}

- (FullStructureProto *) fsp {
  return [[GameState sharedGameState] structWithId:structId];
}

- (UserStructState) state {
  NSDate *now = [NSDate date];
  NSDate *done;
  FullStructureProto *fsp = self.fsp;
  
  if (!isComplete) {
    if (lastUpgradeTime) {
        return kUpgrading;
    } else {
        return kBuilding;
    }
  }
  
  done = [NSDate dateWithTimeInterval:fsp.minutesToGain*60 sinceDate:lastRetrieved];
  if ([now compare:done] == NSOrderedDescending) {
    return kRetrieving;
  }
  return kWaitingForIncome;
}

@end