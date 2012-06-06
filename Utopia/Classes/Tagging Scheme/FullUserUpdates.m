//
//  FullUserUpdates.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/3/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "FullUserUpdates.h"

@implementation FullUserUpdate

@synthesize tag;

+ (id) updateWithTag:(int)t change:(int)change {
  return [[[self alloc] initWithTag:t change:change] autorelease];
}

- (id) initWithTag:(int)t change:(int)change {
  if ((self = [super init])) {
    tag = t;
    _change = change;
  }
  return self;
}

@end

@implementation GoldUpdate

- (void) update {
  GameState *gs = [GameState sharedGameState];
  gs.gold += _change;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  gs.gold -= _change;
}

@end

@implementation SilverUpdate

- (void) update {
  GameState *gs = [GameState sharedGameState];
  gs.silver += _change;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  gs.silver -= _change;
}

@end

@implementation EnergyUpdate

- (void) update {
  GameState *gs = [GameState sharedGameState];
  gs.currentEnergy += MIN(_change, gs.maxEnergy-gs.currentEnergy);
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  gs.currentEnergy -= MAX(0, _change);
}

@end

@implementation StaminaUpdate

- (void) update {
  GameState *gs = [GameState sharedGameState];
  gs.currentStamina += MIN(_change, gs.maxStamina-gs.currentStamina);
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  gs.currentStamina -= MAX(0, _change);
}

@end

@implementation SkillPointsUpdate

- (void) update {
  GameState *gs = [GameState sharedGameState];
  gs.skillPoints += _change;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  gs.skillPoints -= _change;
}

@end

@implementation AttackUpdate

- (void) update {
  GameState *gs = [GameState sharedGameState];
  gs.attack += _change;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  gs.attack -= _change;
}

@end

@implementation DefenseUpdate

- (void) update {
  GameState *gs = [GameState sharedGameState];
  gs.defense += _change;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  gs.defense -= _change;
}

@end

@implementation MaxEnergyUpdate

- (void) update {
  GameState *gs = [GameState sharedGameState];
  gs.maxEnergy += _change;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  gs.maxEnergy -= _change;
}

@end

@implementation MaxStaminaUpdate

- (void) update {
  GameState *gs = [GameState sharedGameState];
  gs.maxStamina += _change;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  gs.maxStamina -= _change;
}

@end

@implementation HealthUpdate

- (void) update {
  GameState *gs = [GameState sharedGameState];
  gs.maxHealth += _change;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  gs.maxHealth -= _change;
}

@end

@implementation LevelUpdate

- (void) update {
  GameState *gs = [GameState sharedGameState];
  gs.level += _change;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  gs.level -= _change;
}

@end

@implementation VaultUpdate

- (void) update {
  GameState *gs = [GameState sharedGameState];
  gs.vaultBalance += _change;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  gs.vaultBalance -= _change;
}

@end

@implementation ExperienceUpdate

- (void) update {
  GameState *gs = [GameState sharedGameState];
  gs.experience += _change;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  gs.experience -= _change;
}

@end

@implementation LastEnergyRefillUpdate

@synthesize previousDate, nextDate;

+ (id) updateWithTag:(int)t prevDate:(NSDate *)pd nextDate:(NSDate *)nd {
  return [[[self alloc] initWithTag:t prevDate:pd nextDate:nd] autorelease];
}

- (id) initWithTag:(int)t prevDate:(NSDate *)pd nextDate:(NSDate *)nd {
  if ((self = [super init])) {
    self.tag = t;
    self.previousDate = pd;
    self.nextDate = nd;
  }
  return self;
}

- (void) update {
  GameState *gs = [GameState sharedGameState];
  gs.lastEnergyRefill = nextDate;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  gs.lastEnergyRefill = previousDate;
}

- (void) dealloc {
  self.previousDate = nil;
  self.nextDate = nil;
  [super dealloc];
}

@end

@implementation LastStaminaRefillUpdate

@synthesize previousDate, nextDate;

+ (id) updateWithTag:(int)t prevDate:(NSDate *)pd nextDate:(NSDate *)nd {
  return [[[self alloc] initWithTag:t prevDate:pd nextDate:nd] autorelease];
}

- (id) initWithTag:(int)t prevDate:(NSDate *)pd nextDate:(NSDate *)nd {
  if ((self = [super init])) {
    self.tag = t;
    self.previousDate = pd;
    self.nextDate = nd;
  }
  return self;
}

- (void) update {
  GameState *gs = [GameState sharedGameState];
  gs.lastStaminaRefill = nextDate;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  gs.lastStaminaRefill = previousDate;
}

- (void) dealloc {
  self.previousDate = nil;
  self.nextDate = nil;
  [super dealloc];
}

@end