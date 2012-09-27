//
//  FullUserUpdates.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/3/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "GameStateUpdate.h"
#import "GameState.h"
#import "Globals.h"

@interface FullUserUpdate : NSObject <GameStateUpdate> {
  int _change;
}

+ (id) updateWithTag:(int)t change:(int)change;
- (id) initWithTag:(int)t change:(int)change;

@end

@interface GoldUpdate : FullUserUpdate
@end

@interface SilverUpdate : FullUserUpdate
@end

@interface EnergyUpdate : FullUserUpdate
@end

@interface StaminaUpdate : FullUserUpdate
@end

@interface SkillPointsUpdate : FullUserUpdate
@end

@interface AttackUpdate : FullUserUpdate
@end

@interface DefenseUpdate : FullUserUpdate
@end

@interface MaxEnergyUpdate : FullUserUpdate
@end

@interface MaxStaminaUpdate : FullUserUpdate
@end

@interface HealthUpdate : FullUserUpdate
@end

@interface LevelUpdate : FullUserUpdate
@end

@interface VaultUpdate : FullUserUpdate
@end

@interface ExperienceUpdate : FullUserUpdate
@end

@interface ChatUpdate : FullUserUpdate
@end

@interface LastEnergyRefillUpdate : FullUserUpdate

@property (nonatomic, retain) NSDate *previousDate;
@property (nonatomic, retain) NSDate *nextDate;

+ (id) updateWithTag:(int)t prevDate:(NSDate *)pd nextDate:(NSDate *)nd;
- (id) initWithTag:(int)t prevDate:(NSDate *)pd nextDate:(NSDate *)nd;

@end

@interface LastStaminaRefillUpdate : FullUserUpdate

@property (nonatomic, retain) NSDate *previousDate;
@property (nonatomic, retain) NSDate *nextDate;

+ (id) updateWithTag:(int)t prevDate:(NSDate *)pd nextDate:(NSDate *)nd;
- (id) initWithTag:(int)t prevDate:(NSDate *)pd nextDate:(NSDate *)nd;

@end

@interface GoldmineTimeUpdate : FullUserUpdate

@property (nonatomic, retain) NSDate *previousDate;
@property (nonatomic, retain) NSDate *nextDate;

+ (id) updateWithTag:(int)t prevDate:(NSDate *)pd nextDate:(NSDate *)nd;
- (id) initWithTag:(int)t prevDate:(NSDate *)pd nextDate:(NSDate *)nd;

@end