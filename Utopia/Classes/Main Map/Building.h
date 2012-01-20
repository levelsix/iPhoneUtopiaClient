//
//  Building.h
//  IsoMap
//
//  Created by Ashwin Kamath on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@class GameMap;

@interface SelectableSprite : CCSprite {
@private
@protected
  GameMap *_map;
  BOOL _isSelected;
  CCSprite *_glow;
  CCSprite *_pin;
  NSString *_name;
  CGRect _location;
}

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, assign) CGRect location;
@property (nonatomic, assign) BOOL isSelected;

-(id) initWithFile: (NSString *) file location: (CGRect)loc map: (GameMap *) map;

@end

@interface Building : SelectableSprite

+(id) buildingWithFile: (NSString *) file location: (CGRect)loc map: (GameMap *) map;

@end

@interface HomeBuilding : Building {
@private
  CGPoint _startTouchLocation;
  BOOL _isSetDown;
@protected
  int _level;
}
@property (nonatomic, readonly) int level;
@property (nonatomic, assign) CGPoint startTouchLocation;
@property (nonatomic, assign) BOOL isSetDown;

+(id) homeWithFile: (NSString *) file location: (CGRect) loc map: (GameMap *) map;
-(id) initWithFile: (NSString *) file location: (CGRect)loc map: (GameMap *) map;
-(void) locationAfterTouch: (CGPoint) touchLocation;
-(void) placeBlock;
-(void) updateMeta;
-(void) clearMeta;

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
  int _experience;
  //Interaction
}

@property (nonatomic, readonly) NSRange bountyRange;
@property (nonatomic, readonly) int experience;

@end