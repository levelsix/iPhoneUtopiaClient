//
//  MaskedSprite.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/2/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "MaskedSprite.h"

#define HEALTH_FLOW_SPEED 0.4f

@implementation MaskedSprite

@synthesize percentage = _percentage;

- (CCSprite *) updateSprite {
  CCRenderTexture * rt = [CCRenderTexture renderTextureWithWidth:_textureSprite.contentSize.width height:_textureSprite.contentSize.height];
  [_maskSprite setBlendFunc:(ccBlendFunc){GL_ONE, GL_ZERO}];
  [_textureSprite setBlendFunc:(ccBlendFunc){GL_DST_ALPHA, GL_ZERO}];
  
  [rt begin];
  if (_percentage != 0.f) {
    [_maskSprite visit];        
    [_textureSprite visit]; 
  }   
  [rt end];
  
  CCSprite *toRet = [CCSprite spriteWithTexture:rt.sprite.texture];
  toRet.flipY = YES;
  return toRet;
}

- (void) dealloc {
  [_textureSprite release];
  [_maskSprite release];
  [super dealloc];
}

@end

@implementation MaskedBar

+ (id) maskedBarWithFile: (CCSprite *) textureSprite andMask: (CCSprite *) maskedSprite {
  return [[[self alloc] initBarWithFile: textureSprite andMask: maskedSprite] autorelease];
}

- (id) initBarWithFile: (CCSprite *) textureSprite andMask: (CCSprite *) maskedSprite {
  if ((self = [super init])) {
    _textureSprite = [textureSprite retain];
    _maskSprite = [maskedSprite retain];
    _textureSprite.position = ccp(_textureSprite.contentSize.width/2, _textureSprite.contentSize.height/2);
  }
  return self;
}

- (void) setPercentage:(float)percentage {
  if(_percentage != percentage) {
    _percentage = clampf( percentage, 0.f, 1.f);
    _maskSprite.position = ccp((-0.5+_percentage)*_maskSprite.contentSize.width, _maskSprite.contentSize.height/2);
	}
}

@end

@implementation MaskedHealth

+ (id) maskedHealthWithFile: (CCSprite *) textureSprite andMask: (CCSprite *) maskedSprite {
  return [[[self alloc] initHealthWithFile: textureSprite andMask: maskedSprite] autorelease];
}

- (id) initHealthWithFile: (CCSprite *) textureSprite andMask: (CCSprite *) maskedSprite {
  if ((self = [super init])) {
    _textureSprite = [textureSprite retain];
    _maskSprite = [maskedSprite retain];
    _textureSprite.position = ccp(_textureSprite.contentSize.width/2, _textureSprite.contentSize.height/2);
    _maskSprite.anchorPoint = ccp(0, 1);
    _maskSprite.position = ccp(0, _textureSprite.contentSize.height);
    _direction = -1;
  }
  return self;
}

- (CCSprite *)updateSprite {
  CCSprite *spr = [super updateSprite];
  spr.color = ccc3(255, 255*_percentage, 255*_percentage);
  return spr;
}

- (void) setPercentage:(float)percentage {
  if(_percentage != percentage) {
    _percentage = clampf( percentage, 0.f, 1.f);
    _maskSprite.position = ccp(_maskSprite.position.x, (0.35+0.6*_percentage)*_textureSprite.contentSize.height);
	}
}

- (void) flow {
  _maskSprite.position = ccp(_maskSprite.position.x+_direction*HEALTH_FLOW_SPEED, _maskSprite.position.y);
  
  if (_maskSprite.position.x <= -(_maskSprite.contentSize.width-_textureSprite.contentSize.width)) {
    _direction = 1;
  } else if (_maskSprite.position.x >= 0) {
    _direction = -1;
  }
}

@end
