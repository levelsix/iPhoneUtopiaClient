//
//  OtherUpdates.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/4/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "OtherUpdates.h"
#import "GameState.h"

@implementation NoUpdate

@synthesize tag;

+ (id) updateWithTag:(int)tag {
  return [[[self alloc] initWithTag:tag] autorelease];
}

- (id) initWithTag:(int)t {
  if ((self = [super init])) {
    self.tag = t;
  } 
  return self;
}

@end

@implementation ChangeEquipUpdate

@synthesize tag;

+ (id) updateWithTag:(int)tag userEquip:(UserEquip *)ue remove:(BOOL)remove {
  return [[[self alloc] initWithTag:tag userEquip:ue remove:remove] autorelease];
}

- (id) initWithTag:(int)t userEquip:(UserEquip *)ue remove:(BOOL)remove {
  if ((self = [super init])) {
    self.tag = t;
    _userEquip = [ue retain];
    _remove = remove;
    
    GameState *gs = [GameState sharedGameState];
    int equipId = ue.userEquipId;
    if (gs.weaponEquipped == equipId) {
      gs.weaponEquipped = 0;
      _equipped = YES;
    } else if (gs.armorEquipped == equipId) {
      gs.armorEquipped = 0;
      _equipped = YES;
    } else if (gs.amuletEquipped == equipId) {
      gs.amuletEquipped = 0;
      _equipped = YES;
    }
    
    if (_remove) {
      [gs.myEquips removeObject:_userEquip];
    } else {
      [gs.myEquips addObject:_userEquip];
    }
  }
  return self;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  if (_remove) {
    [gs.myEquips addObject:_userEquip];
  } else {
    [gs.myEquips removeObject:_userEquip];
  }
  
  if (_equipped) {
    FullEquipProto *fep = [gs equipWithId:_userEquip.equipId];
    
    int userEquipId = _userEquip.userEquipId;
    if (fep.equipType == FullEquipProto_EquipTypeWeapon) {
      gs.weaponEquipped = userEquipId;
    } else if (fep.equipType == FullEquipProto_EquipTypeArmor) {
      gs.armorEquipped = userEquipId;
    } else if (fep.equipType == FullEquipProto_EquipTypeAmulet) {
      gs.amuletEquipped = userEquipId;
    }
  }
}

- (void) dealloc {
  [_userEquip release];
  [super dealloc];
}

@end

@implementation AddStructUpdate

@synthesize tag;
@synthesize userStruct;

+ (id) updateWithTag:(int)tag userStruct:(UserStruct *)us {
  return [[[self alloc] initWithTag:tag userStruct:us] autorelease];
}

- (id) initWithTag:(int)t userStruct:(UserStruct *)us {
  if ((self = [super init])) {
    self.tag = t;
    self.userStruct = us;
    
    GameState *gs = [GameState sharedGameState];
    [gs.myStructs addObject:us];
  }
  return self;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  [gs.myStructs removeObject:self.userStruct];
}

@end

@implementation SellStructUpdate

@synthesize tag;
@synthesize userStruct;

+ (id) updateWithTag:(int)tag userStruct:(UserStruct *)us {
  return [[[self alloc] initWithTag:tag userStruct:us] autorelease];
}

- (id) initWithTag:(int)t userStruct:(UserStruct *)us {
  if ((self = [super init])) {
    self.tag = t;
    self.userStruct = us;
    
    GameState *gs = [GameState sharedGameState];
    [gs.myStructs removeObject:us];
  }
  return self;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  [gs.myStructs addObject:self.userStruct];
}

@end

@implementation ExpForNextLevelUpdate

@synthesize tag;

+ (id) updateWithTag:(int)tag prevLevel:(int)prevLevel curLevel:(int)curLevel nextLevel:(int)nextLevel {
  return [[[self alloc] initWithTag:tag prevLevel:prevLevel curLevel:curLevel nextLevel:nextLevel] autorelease];
}

- (id) initWithTag:(int)t prevLevel:(int)prevLevel curLevel:(int)curLevel nextLevel:(int)nextLevel {
  if ((self = [super init])) {
    self.tag = t;
    _prevLevel = prevLevel;
    _curLevel = curLevel;
    _nextLevel = nextLevel;
    
    GameState *gs = [GameState sharedGameState];
    gs.expRequiredForCurrentLevel = _curLevel;
    gs.expRequiredForNextLevel = _nextLevel;
  }
  return self;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  gs.expRequiredForCurrentLevel = _prevLevel;
  gs.expRequiredForNextLevel = _curLevel;
}

@end
