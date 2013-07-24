//
//  MapSprite.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/8/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "CCSprite.h"
#import "Protocols.pb.h"

@class GameMap;

@interface MapSprite : CCSprite {
  GameMap *_map;
  CGRect _location;
}

@property (nonatomic, assign) CGRect location;
@property (nonatomic, assign) BOOL isFlying;

-(id) initWithFile: (NSString *) file  location: (CGRect)loc map: (GameMap *) map;

@end

@interface SelectableSprite : MapSprite {
  BOOL _isSelected;
  CCSprite *_glow;
  
  CCSprite *_arrow;
}

@property (nonatomic, assign) CCSprite *arrow;
@property (nonatomic, assign) BOOL isSelected;

- (void) displayArrow;
- (void) removeArrowAnimated:(BOOL)animated;
- (void) displayCheck;

@end

@protocol TaskElement <NSObject>

@required

@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) FullTaskProto *ftp;
@property (nonatomic, assign) int numTimesActedForTask;
@property (nonatomic, assign) int numTimesActedForQuest;

@property (nonatomic, assign) BOOL partOfQuest;

// So we can access these
@property (nonatomic, assign) CGRect location;
@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) CGSize contentSize;

- (void) displayArrow;
- (void) removeArrowAnimated:(BOOL)animated;
- (void) displayCheck;

@end