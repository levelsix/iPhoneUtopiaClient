//
//  BattleLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/23/11.
//  Copyright (c) 2011 LVL6. All rights reserved.
//

#import "cocos2d.h"

@interface BattleLayer : CCLayer {
  CCSprite *_left;
  CCSprite *_right;
  
  CCSprite *_leftHealthBar;
  CCSprite *_rightHealthBar;
  
  CCSprite *_attackButton;
  CCProgressTimer *_attackProgressTimer;
  
  CCSprite *_comboBar;
  CCProgressTimer *_comboProgressTimer;
  
  CCMenu *_bottomMenu;
  
  BOOL _comboBarMoving;
}

+ (CCScene *) scene;
- (void) doAttackAnimation;

@end
