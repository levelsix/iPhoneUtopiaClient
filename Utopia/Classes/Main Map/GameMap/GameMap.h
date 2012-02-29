//
//  GameMap.h
//  IsoMap
//
//  Created by Ashwin Kamath on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "NibUtils.h"
#import "Building.h"

@class Building;
@class SelectableSprite;

#define MAX_ZOOM 1.5f
#define MIN_ZOOM 0.5f

@interface GameMap : CCTMXTiledMap {
@protected
  SelectableSprite *_selected;
  NSMutableArray *_selectables;
}

@property (nonatomic, retain) SelectableSprite *selected;

@property (nonatomic, assign) CGSize tileSizeInPoints;

+(id) tiledMapWithTMXFile:(NSString*)tmxFile;
-(id) initWithTMXFile:(NSString *)tmxFile;
-(CGPoint)convertVectorToGL:(CGPoint)uiPoint;
-(void) doReorder;
- (SelectableSprite *) selectableForPt:(CGPoint)pt;

- (void) drag:(UIGestureRecognizer*)recognizer node:(CCNode*)node;
- (void) tap:(UIGestureRecognizer*)recognizer node:(CCNode*)node;
- (void) scale:(UIGestureRecognizer*)recognizer node:(CCNode*)node;

@end

@interface MissionMap : GameMap {
@private
}
@end

@interface PlayerMap : GameMap {
@private
}
@end