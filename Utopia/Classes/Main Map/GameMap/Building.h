//
//  Building.h
//  IsoMap
//
//  Created by Ashwin Kamath on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "UserData.h"
#import "MapSprite.h"

@class GameMap;
@class HomeMap;

@interface Building : SelectableSprite

@property (nonatomic, assign) StructOrientation orientation;
@property (nonatomic, assign) float verticalOffset;

@end

@interface HomeBuilding : Building {
  CGPoint _startTouchLocation;
  BOOL _isSetDown;
  BOOL _isConstructing;
  HomeMap *_homeMap;
  CGPoint _startMoveCoordinate;
  StructOrientation _startOrientation;
}

@property (nonatomic, assign) CGPoint startTouchLocation;
@property (nonatomic, assign) BOOL isSetDown;
@property (nonatomic, assign) BOOL isConstructing;

+ (id) homeWithFile: (NSString *) file location: (CGRect) loc map: (HomeMap *) map;
- (id) initWithFile: (NSString *) file location: (CGRect)loc map: (HomeMap *) map;
- (void) locationAfterTouch: (CGPoint) touchLocation;
- (void) placeBlock;
- (void) liftBlock;
- (void) updateMeta;
- (void) clearMeta;
- (void) cancelMove;

@end

@interface CritStructBuilding : Building {
  CCSprite *_retrieveBubble;
  BOOL _retrievable;
}

@property (nonatomic, retain) CritStruct *critStruct;
@property (nonatomic, assign) BOOL retrievable;

- (id) initWithCritStruct:(CritStruct *)cs location:(CGRect)loc map:(GameMap *)map;

@end

@interface MoneyBuilding : HomeBuilding {
  ccTime _timeLeft;
  int _income;
  UserStruct *_userStruct;
  BOOL _retrievable;
  CCSprite *_retrieveBubble;
  NSTimer *_timer;
}

@property (nonatomic, retain) UserStruct *userStruct;
@property (nonatomic, assign) BOOL retrievable;
@property (nonatomic, retain) NSTimer *timer;

- (void) displayUpgradeIcon;
- (void) removeUpgradeIcon;

- (void) createTimerForCurrentState;

@end

@interface MissionBuilding : Building <TaskElement>

@end