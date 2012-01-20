//
//  GameMap.h
//  IsoMap
//
//  Created by Ashwin Kamath on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@class Building;
@class SelectableSprite;

#define MAX_ZOOM 1.5f
#define MIN_ZOOM 0.5f

@interface GameMap : CCTMXTiledMap {
@private
  NSMutableArray *_buildableData;
  SelectableSprite *_selected;
  BOOL _isHome;
  CCArray *_selectables;
  BOOL _moveSprite;
}

@property (nonatomic, retain) NSMutableArray *buildableData;

+(id) tiledMapWithTMXFile:(NSString*)tmxFile;
-(id) initWithTMXFile:(NSString *)tmxFile;
-(void) changeTiles: (CGRect) buildBlock toBuildable:(BOOL)canBuild;
-(BOOL) isBlockBuildable: (CGRect) buildBlock;
-(CGPoint)convertVectorToGL:(CGPoint)uiPoint;
-(void) doReorder;

@end

@interface HomeMap : GameMap {
@private
}
@end

@interface MissionMap : GameMap {
@private
}
@end

@interface PlayerMap : GameMap {
@private
}
@end