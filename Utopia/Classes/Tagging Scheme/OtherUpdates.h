//
//  OtherUpdates.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/4/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "GameStateUpdate.h"
#import "UserData.h"

@interface NoUpdate : NSObject <GameStateUpdate>

+ (id) updateWithTag:(int)tag;
- (id) initWithTag:(int)tag;

@end

@interface ChangeEquipUpdate : NSObject <GameStateUpdate> {
  int _equipId;
  int _change;
  BOOL _equipped;
}

+ (id) updateWithTag:(int)tag equipId:(int)equipId change:(int)change;
- (id) initWithTag:(int)tag equipId:(int)equipId change:(int)change;

@end

@interface AddStructUpdate : NSObject <GameStateUpdate>

@property (nonatomic, retain) UserStruct *userStruct;

+ (id) updateWithTag:(int)tag userStruct:(UserStruct *)us;
- (id) initWithTag:(int)tag userStruct:(UserStruct *)us;

@end

@interface SellStructUpdate : NSObject <GameStateUpdate>

@property (nonatomic, retain) UserStruct *userStruct;

+ (id) updateWithTag:(int)tag userStruct:(UserStruct *)us;
- (id) initWithTag:(int)tag userStruct:(UserStruct *)us;

@end

@interface ExpForNextLevelUpdate : NSObject <GameStateUpdate> {
  int _prevLevel;
  int _curLevel;
  int _nextLevel;
}

+ (id) updateWithTag:(int)tag prevLevel:(int)prevLevel curLevel:(int)curLevel nextLevel:(int)nextLevel;
- (id) initWithTag:(int)tag prevLevel:(int)prevLevel curLevel:(int)curLevel nextLevel:(int)nextLevel;

@end