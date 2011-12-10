//
//  GameMap.h
//  IsoMap
//
//  Created by Ashwin Kamath on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

#define MAX_ZOOM 2.0f
#define MIN_ZOOM 0.5f

@interface GameMap : CCTMXTiledMap {
@private
  NSMutableArray *_buildableData;
}

@property (nonatomic, retain) NSMutableArray *buildableData;

+(id) tiledMapWithTMXFile:(NSString*)tmxFile;
-(id) initWithTMXFile:(NSString *)tmxFile;
-(void) changeTiles: (CGRect) buildBlock toBuildable:(BOOL)canBuild;
-(BOOL) isBlockBuildable: (CGRect) buildBlock;
-(CGPoint)convertVectorToGL:(CGPoint)uiPoint;

@end
