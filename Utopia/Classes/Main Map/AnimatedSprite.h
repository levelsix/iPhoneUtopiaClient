//
//  AnimatedSprite.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"

@interface AnimatedSprite : CCSprite 
{
  CCSprite *_sprite;
  CCAction *_walkAction;
  CCAction *_moveAction;
  BOOL _moving;
}

@property (nonatomic, retain) CCSprite *sprite;
@property (nonatomic, retain) CCAction *walkAction;
@property (nonatomic, retain) CCAction *moveAction;

@end
