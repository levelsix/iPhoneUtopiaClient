//
//  BattleLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/23/11.
//  Copyright (c) 2011 LVL6. All rights reserved.
//

#import "cocos2d.h"

@interface BattleLayer : CCLayerColor {
  CCSprite *left;
  CCSprite *right;
  CCLayerColor *flash;
}

@property (nonatomic, retain) CCSprite *left;
@property (nonatomic, retain) CCSprite *right;
@property (nonatomic, retain) CCLayerColor *flash;

- (void) doAttackAnimation;

@end
