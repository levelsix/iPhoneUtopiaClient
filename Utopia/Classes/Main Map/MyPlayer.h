//
//  MyPlayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/25/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "MapSprite.h"
#import "cocos2d.h"

@interface MyPlayer : MapSprite {
  //walk animations
  CCAction *_walkActionN;
  CCAction *_walkActionF;
  CCAction *_walkActionLR;
  CCAction *_walkActionU;
  CCAction *_walkActionD;
  CCAction *_currentAction;
  
  CCAnimation *_agAnimation;
  
  CCSprite *_sprite;
  CGPoint _oldMapPosition;
  
  BOOL _shouldContinueAnimation;
  
  SEL _soundSelector;
  
  int _incrementalLoadCounter;
  BOOL _isDownloading;
}
@property (nonatomic, retain) CCAction *walkActionN;
@property (nonatomic, retain) CCAction *walkActionF;
@property (nonatomic, retain) CCAction *walkActionLR;
@property (nonatomic, retain) CCAction *walkActionU;
@property (nonatomic, retain) CCAction *walkActionD;

@property (nonatomic, retain) CCAction *currentAction;

@property (nonatomic, retain) CCAnimation *agAnimation;

@property (nonatomic, retain) CCSprite *sprite;

- (void) stopWalking;
- (void) stopPerformingAnimation;
- (id) initWithLocation:(CGRect)loc map:(GameMap *)map;
- (void) performAnimation:(AnimationType)type atLocation:(CGPoint)point inDirection:(float)angle;
- (void) moveToLocation:(CGRect)loc;
- (void) repeatCurrentAttackAnimation;

@end