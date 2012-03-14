//
//  TutorialStartLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/13/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"

@interface TutorialStartLayer : CCLayerColor {
  CGPoint _origPos;
  CCSprite *_bgd;
  int _incrementor;
}

+ (id) scene;

@end