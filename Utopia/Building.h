//
//  Building.h
//  IsoMap
//
//  Created by Ashwin Kamath on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@class GameMap;

@interface Building : CCSprite {
  @protected
  NSString *_name;
  CGRect _location;
  CCSprite* _outline;
  BOOL _isSelected;
  CCSprite *_glow;
}

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, assign) CGRect location;
@property (nonatomic, retain) CCSprite *outline;
@property (nonatomic, assign) BOOL isSelected;

+(id) buildingWithFile: (NSString *) file location: (CGRect)loc;
-(id) initWithFile: (NSString *) file location: (CGRect)loc;

@end

@interface HomeBuilding : Building {
@private
  CGPoint _startTouchLocation;
  GameMap *_map;
  BOOL _isSetDown;
  BOOL _alreadyClicked;
@protected
  int _level;
}
@property (nonatomic, readonly) int level;

+(id) homeWithFile: (NSString *) file location: (CGRect) loc map: (GameMap *) map;
-(id) initWithFile: (NSString *) file location: (CGRect)loc map: (GameMap *) map;
-(void) createStrokeWithSize:(float)size   color:(ccColor3B)cor;
-(void) locationAfterTouch: (CGPoint) touchLocation;
-(void) placeBlock;

@end

@interface MoneyBuilding : HomeBuilding {
@protected
  ccTime _timeLeft;
  int _income;
}

@property (nonatomic, readonly) ccTime timeLeft;
@property (nonatomic, readonly) int income;

@end

@interface DefenseBuilding : HomeBuilding {
@protected
  int _defense;
}

@property (nonatomic, readonly) int defense;

@end

@interface MissionBuilding : Building {
@protected
  NSRange _bountyRange;
}

@property (nonatomic, readonly) NSRange bountyRange;

@end