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

+ (id) updateWithTag:(int)tag equipId:(int)equipId change:(int)change {
  return [[[self alloc] initWithTag:tag equipId:equipId change:change] autorelease];
}

- (id) initWithTag:(int)t equipId:(int)equipId change:(int)change {
  if ((self = [super init])) {
    self.tag = t;
    _equipId = equipId;
    _change = change;
    
    GameState *gs = [GameState sharedGameState];
    if (gs.weaponEquipped == equipId || gs.armorEquipped == equipId || gs.amuletEquipped == equipId) {
      _equipped = YES;
    }
  
  [gs changeQuantityForEquip:equipId by:_change];
}
return self;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  [gs changeQuantityForEquip:_equipId by:-_change];
  
  if (_equipped) {
    FullEquipProto *fep = [gs equipWithId:_equipId];
    
    if (fep.equipType == FullEquipProto_EquipTypeWeapon) {
      gs.weaponEquipped = _equipId;
    } else if (fep.equipType == FullEquipProto_EquipTypeArmor) {
      gs.armorEquipped = _equipId;
    } else if (fep.equipType == FullEquipProto_EquipTypeAmulet) {
      gs.amuletEquipped = _equipId;
    }
  }
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
