//
//  TutorialStartLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/13/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "CCLabelFX.h"

@interface TutorialStartLayer : CCLayerColor <CCTargetedTouchDelegate> {
  CGPoint _origPos;
  CCSprite *_bgd;
  int _incrementor;
  CCLabelFX *_label;
  int _curLabel;
  
  BOOL _beforeCharSelectPhase;
  
  CCMenuItemImage *_backButton;
}

+ (id) scene;
- (void) start;

@end
