//
//  Building.h
//  IsoMap
//
//  Created by Ashwin Kamath on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "UserData.h"

@class GameMap;
@class HomeMap;

@interface SelectableSprite : CCSprite {
  GameMap *_map;
  BOOL _isSelected;
  CCSprite *_glow;
  NSString *_name;
  CGRect _location;
}

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, assign) CGRect location;
@property (nonatomic, assign) BOOL isSelected;

-(id) initWithFile: (NSString *) file location: (CGRect)loc map: (GameMap *) map;

@end

@interface Building : SelectableSprite

@property (nonatomic, assign) StructOrientation orientation;

@end

@interface HomeBuilding : Building {
  CGPoint _startTouchLocation;
  BOOL _isSetDown;
  HomeMap *_homeMap;
  CGPoint _startMoveCoordinate;
  StructOrientation _startOrientation;
  int _level;
}
@property (nonatomic, readonly) int level;
@property (nonatomic, assign) CGPoint startTouchLocation;
@property (nonatomic, assign) BOOL isSetDown;

+ (id) homeWithFile: (NSString *) file location: (CGRect) loc map: (HomeMap *) map;
- (id) initWithFile: (NSString *) file location: (CGRect)loc map: (HomeMap *) map;
- (void) locationAfterTouch: (CGPoint) touchLocation;
- (void) placeBlock;
- (void) liftBlock;
- (void) updateMeta;
- (void) clearMeta;
- (void) cancelMove;

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

- (void) createTimerForCurrentState;

@end

@interface MissionBuilding : Building

@property (nonatomic, retain) FullTaskProto *ftp;
@property (nonatomic, assign) int numTimesActed;
@property (nonatomic, copy) NSString *name;

@end