//
//  MapSprite.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/8/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "CCSprite.h"

@class GameMap;

@interface MapSprite : CCSprite {
  GameMap *_map;
  CGRect _location;
}

@property (nonatomic, assign) CGRect location;

-(id) initWithFile: (NSString *) file  location: (CGRect)loc map: (GameMap *) map;

@end

@interface SelectableSprite : MapSprite {
  BOOL _isSelected;
  CCSprite *_glow;
  
  CCSprite *_arrow;
}

@property (nonatomic, assign) BOOL isSelected;

- (void) displayArrow;
- (void) removeArrowAnimated:(BOOL)animated;
- (void) displayCheck;

@end