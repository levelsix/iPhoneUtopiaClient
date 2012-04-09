//
//  TutorialBattleLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "BattleLayer.h"

@interface TutorialBattleLayer : BattleLayer {
  CCSprite *_ccArrow;
  CCSprite *_tapToAttack;
  CCSprite *_tryAgain;
  
  BOOL _firstTurn;
  BOOL _firstAttack;
  
  UIImageView *_uiArrow;
}

@end
