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
#import "AnimatedSprite.h"

#define OVER_HOME_BUILDING_MENU_OFFSET 5.f

@class Building;
@class SelectableSprite;

#define MAX_ZOOM 1.5f
#define MIN_ZOOM 0.5f

@interface EnemyPopupView : UIView

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *levelLabel;

@end

@interface GameMap : CCTMXTiledMap {
  SelectableSprite *_selected;
  NSMutableArray *_mapSprites;
}

@property (nonatomic, retain) IBOutlet UIView *aviaryMenu;
@property (nonatomic, retain) IBOutlet EnemyPopupView *enemyMenu;

@property (nonatomic, retain) SelectableSprite *selected;

@property (nonatomic, assign) CGSize tileSizeInPoints;

+ (id) tiledMapWithTMXFile:(NSString*)tmxFile;
- (id) initWithTMXFile:(NSString *)tmxFile;
- (CGPoint)convertVectorToGL:(CGPoint)uiPoint;
- (void) doReorder;
- (SelectableSprite *) selectableForPt:(CGPoint)pt;
- (void) layerWillDisappear;

- (IBAction)attackClicked:(id)sender;
- (IBAction)profileClicked:(id)sender;

- (void) drag:(UIGestureRecognizer*)recognizer node:(CCNode*)node;
- (void) tap:(UIGestureRecognizer*)recognizer node:(CCNode*)node;
- (void) scale:(UIGestureRecognizer*)recognizer node:(CCNode*)node;

@end