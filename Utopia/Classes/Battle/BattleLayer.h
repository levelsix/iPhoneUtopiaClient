//
//  BattleLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/23/11.
//  Copyright (c) 2011 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "Protocols.pb.h"

@interface BattleSummaryView : UIView

@end

@interface StolenEquipView : UIView

@end

@interface BattleLayer : CCLayer {
  CCSprite *_left;
  CCSprite *_right;
  
  CCSprite *_leftHealthBar;
  CCSprite *_rightHealthBar;
  
  CCSprite *_attackButton;
  CCProgressTimer *_attackProgressTimer;
  
  CCSprite *_comboBar;
  CCProgressTimer *_comboProgressTimer;
  CCSprite *_flippedComboBar;
  CCProgressTimer *_flippedComboProgressTimer;
  
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
  
  float _damageDone;
  
  CCLayer *_pausedLayer;
  CCLayer *_winLayer;
  CCLayer *_loseLayer;
  
  FullUserProto *_fup;
}

@property (nonatomic, retain) IBOutlet StolenEquipView *stolenEquipView;
@property (nonatomic, retain) IBOutlet BattleSummaryView *summaryView;

@property (nonatomic, retain) BattleResponseProto *brp;

+ (CCScene *) scene;
+ (BattleLayer *) sharedBattleLayer;
- (void) beginBattleAgainst:(FullUserProto *)user;
- (void) doAttackAnimation;

- (IBAction)stolenEquipOkayClicked:(id)sender;
- (IBAction)closeClicked:(id)sender;
- (IBAction)attackAgainClicked:(id)sender;
- (IBAction)profileButtonClicked:(id)sender;

@end
