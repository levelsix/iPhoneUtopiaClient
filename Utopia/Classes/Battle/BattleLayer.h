//
//  BattleLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/23/11.
//  Copyright (c) 2011 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "Protocols.pb.h"

@interface BattleLayer : CCLayer {
  CCSprite *_left;
  CCSprite *_right;
  
  CCSprite *_leftHealthBar;
  CCSprite *_rightHealthBar;
  
  CCSprite *_attackButton;
  CCProgressTimer *_attackProgressTimer;
  
  CCSprite *_comboBar;
  CCProgressTimer *_comboProgressTimer;
  
  CCLabelTTF *_leftMaxHealthLabel;
  CCLabelTTF *_leftCurHealthLabel;
  CCLabelTTF *_rightMaxHealthLabel;
  CCLabelTTF *_rightCurHealthLabel;
  
  CCMenu *_bottomMenu;
  
  BOOL _comboBarMoving;
  
  int _leftMaxHealth;
  int _leftCurrentHealth;
  int _rightMaxHealth;
  int _rightCurrentHealth;
  
  int _leftAttack;
  int _leftDefense;
  int _rightAttack;
  int _rightDefense;
  
  float _comboPercentage;
}

+ (CCScene *) scene;
+ (BattleLayer *) sharedBattleLayer;
- (void) beginBattleAgainst:(FullUserProto *)user;
- (void) doAttackAnimation;

@end
