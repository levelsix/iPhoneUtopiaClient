//
//  AnimatedSprite.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "MapSprite.h"

@interface AnimatedSprite : SelectableSprite
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

@interface MoveToLocation : CCActionInterval <NSCopying> {
  CGRect startLocation_;
  CGRect endLocation_;
  CGPoint delta_;
}

+(id) actionWithDuration: (ccTime) t location: (CGRect) p;
-(id) initWithDuration: (ccTime) t location: (CGRect) p;

@end