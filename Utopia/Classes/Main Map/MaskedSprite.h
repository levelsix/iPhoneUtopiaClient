//
//  MaskedSprite.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/2/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"

@interface MaskedSprite : CCSprite {
  CCSprite *_maskSprite;
  CCSprite *_textureSprite;
  float _percentage;
}

@property (nonatomic, assign) float percentage;

- (CCSprite *) updateSprite;

@end

@interface MaskedBar : MaskedSprite

+ (id) maskedBarWithFile: (CCSprite *) textureSprite andMask: (CCSprite *) maskedSprite;
- (id) initBarWithFile: (CCSprite *) textureSprite andMask: (CCSprite *) maskedSprite;

@end

@interface MaskedHealth : MaskedSprite {
  int _direction;
}

+ (id) maskedHealthWithFile: (CCSprite *) textureSprite andMask: (CCSprite *) maskedSprite;
- (id) initHealthWithFile: (CCSprite *) textureSprite andMask: (CCSprite *) maskedSprite;
- (void) flow;

@end