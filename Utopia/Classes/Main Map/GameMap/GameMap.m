
//
//  GameMap.m
//  IsoMap
//
//  Created by Ashwin Kamath on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GameMap.h"
#import "Building.h"
#import "Globals.h"
#import "NibUtils.h"
#import "MapViewController.h"
#import "BattleLayer.h"
#import "GameLayer.h"
#import "ProfileViewController.h"
#import "SoundEngine.h"
#import "TopBar.h"
#import "GameState.h"
#import "CCLabelFX.h"

#define REORDER_START_Z 150

#define SILVER_STACK_BOUNCE_DURATION 1.f
#define DROP_LABEL_DURATION 3.f
#define PICK_UP_WAIT_TIME 2.5f
#define DROP_ROTATION 0

//CCMoveByCustom
@interface CCMoveByCustom : CCMoveBy

-(void) update: (ccTime) t;

@end

@implementation CCMoveByCustom
- (void) update: (ccTime) t {
	//Here we neglect to change something with a zero delta.
  if (delta_.x == 0 && delta_.y == 0) {
    // Do nothing
  } else if (delta_.x == 0) {
		[target_ setPosition: ccp( [(CCNode*)target_ position].x, (startPosition_.y + delta_.y * t ) )];
	} else if (delta_.y == 0) {
		[target_ setPosition: ccp( (startPosition_.x + delta_.x * t ), [(CCNode*)target_ position].y )];
	} else {
		[target_ setPosition: ccp( (startPosition_.x + delta_.x * t ), (startPosition_.y + delta_.y * t ) )];
	}
}
@end

//CClCustom
@interface CCMoveToCustom : CCMoveTo

- (void) update: (ccTime) t;

@end

@implementation CCMoveToCustom
- (void) update: (ccTime) t {
	//Here we neglect to change something with a zero delta.
	if (delta_.x == 0) {
		[target_ setPosition: ccp( [(CCNode*)target_ position].x, (startPosition_.y + delta_.y * t ) )];
	} else if (delta_.y == 0) {
		[target_ setPosition: ccp( (startPosition_.x + delta_.x * t ), [(CCNode*)target_ position].y )];
	} else{
		[target_ setPosition: ccp( (startPosition_.x + delta_.x * t ), (startPosition_.y + delta_.y * t ) )];
	}
}
@end

@implementation EnemyPopupView

@synthesize nameLabel, levelLabel, imageIcon, enemyView, allyView;

- (void) awakeFromNib {
  [self addSubview:allyView];
  allyView.frame = enemyView.frame;
}

- (void) dealloc {
  self.nameLabel = nil;
  self.levelLabel = nil;
  self.imageIcon = nil;
  self.enemyView = nil;
  self.allyView = nil;
  [super dealloc];
}

@end

@implementation GameMap

@synthesize selected = _selected;
@synthesize tileSizeInPoints;
@synthesize enemyMenu;
@synthesize mapSprites = _mapSprites;
@synthesize silverOnMap, goldOnMap;
@synthesize decLayer;
@synthesize walkableData = _walkableData;

+(id) tiledMapWithTMXFile:(NSString*)tmxFile
{
	return [[[self alloc] initWithTMXFile:tmxFile] autorelease];
}

-(void) addChild:(CCNode *)node z:(NSInteger)z tag:(NSInteger)tag {
  if ([[node class] isSubclassOfClass:[MapSprite class]]) {
    [_mapSprites addObject:node];
  }
  [super addChild:node z:z tag:tag];
}

- (void) removeChild:(CCNode *)node cleanup:(BOOL)cleanup {
  if ([_mapSprites containsObject:node]) {
    [_mapSprites removeObject:node];
  }
  [super removeChild:node cleanup:cleanup];
}

-(id) initWithTMXFile:(NSString *)tmxFile {
  if ((self = [super initWithTMXFile:tmxFile])) {
    _mapSprites = [[NSMutableArray array] retain];
    
    int width = self.mapSize.width;
    int height = self.mapSize.height;
    bottomLeftCorner = ccp(width, height);
    CCTMXLayer * layer = [self layerNamed:@"Border of Doom"];
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
        // Convert their coordinates to our coordinate system
        CGPoint tileCoord = ccp(height-j-1, width-i-1);
        int tileGid = [layer tileGIDAt:tileCoord];
        if (tileGid) {
          if (i < bottomLeftCorner.x) {
            bottomLeftCorner = ccp(i, j);
          }
          if (i > topRightCorner.x) {
            topRightCorner = ccp(i, j);
          }
        }
      }
    }
    [self removeChild:layer cleanup:YES];
    
    // add UIPanGestureRecognizer
    UIPanGestureRecognizer *uig = [[[UIPanGestureRecognizer alloc ]init] autorelease];
    uig.maximumNumberOfTouches = 1;
    CCGestureRecognizer *recognizer = [CCGestureRecognizer CCRecognizerWithRecognizerTargetAction: uig target:self action:@selector(drag:node:)];
    [self addGestureRecognizer:recognizer];
    
    // add UIPinchGestureRecognizer
    recognizer = [CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[[UIPinchGestureRecognizer alloc ]init] autorelease] target:self action:@selector(scale:node:)];
    [self addGestureRecognizer:recognizer];
    
    self.isTouchEnabled = YES;
    
    // add UITapGestureRecognizer
    recognizer = [CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[[UITapGestureRecognizer alloc ]init] autorelease] target:self action:@selector(tap:node:)];
    [self addGestureRecognizer:recognizer];
    
    if (CC_CONTENT_SCALE_FACTOR() == 2) {
      tileSizeInPoints = CGSizeMake(self.tileSize.width/2, self.tileSize.height/2);
    } else {
      tileSizeInPoints = tileSize_;
    }
    
    [self createMyPlayer];
    
    // Add the decoration layer for clouds
    decLayer = [[DecorationLayer alloc] initWithSize:self.contentSize];
    [self addChild:self.decLayer z:2000];
    [decLayer release];
    
    [[NSBundle mainBundle] loadNibNamed:@"EnemyPopupView" owner:self options:nil];
    [Globals displayUIView:self.enemyMenu];
    [[[CCDirector sharedDirector] openGLView] setUserInteractionEnabled:YES];
    
    enemyMenu.hidden = YES;
    
    self.scale = DEFAULT_ZOOM;
  }
  return self;
}

- (void) createMyPlayer {
  // Do this so that tutorial classes can override
  _myPlayer = [[MyPlayer alloc] initWithLocation:CGRectMake(mapSize_.width/2, mapSize_.height/2, 1, 1) map:self];
  [self addChild:_myPlayer];
  [_myPlayer release];
}

- (void) setVisible:(BOOL)visible {
  [super setVisible:visible];
  self.selected = nil;
}

// Position (0,0) means choose a random position
- (void) addSilverDrop:(int)amount fromSprite:(MapSprite *)sprite toPosition:(CGPoint)pt secondsToPickup:(int)secondsToPickup {
  
  silverOnMap += amount;
  
  SilverStack *ss = [[SilverStack alloc] initWithAmount:amount];
  [self addChild:ss z:1004];
  [ss release];
  ss.position = ccpAdd(sprite.position, ccp(0,sprite.contentSize.height/2));
  ss.scale = 0.01;
  ss.opacity = 5;
  
  // Need to fade in, scale to 1, bounce in y dir, move normal in x dir
  float xPos = CGPointEqualToPoint(pt, CGPointZero) ? ((float)(arc4random()%((unsigned)RAND_MAX+1))/RAND_MAX)*120-60 : pt.x-ss.position.x;
  float yPos = CGPointEqualToPoint(pt, CGPointZero) ? ((float)(arc4random()%((unsigned)RAND_MAX+1))/RAND_MAX)*20-10 : pt.y-ss.position.y;
  
  // -1 seconds means don't pickup, 0 seconds means default
  secondsToPickup = secondsToPickup == 0 ? PICK_UP_WAIT_TIME : secondsToPickup;
  CCDelayTime *dt = secondsToPickup > 0 ? [CCDelayTime actionWithDuration:secondsToPickup] : nil;
  [ss runAction:[CCSpawn actions:
                 [CCFadeIn actionWithDuration:0.1],
                 [CCScaleTo actionWithDuration:0.1 scale:1],
                 [CCRotateBy actionWithDuration:SILVER_STACK_BOUNCE_DURATION angle:DROP_ROTATION],
                 [CCSequence actions:
                  [CCMoveByCustom actionWithDuration:SILVER_STACK_BOUNCE_DURATION*0.2 position:ccp(0,40)],
                  [CCEaseBounceOut actionWithAction:
                   [CCMoveByCustom actionWithDuration:SILVER_STACK_BOUNCE_DURATION*0.8 position:ccp(0,-85+yPos)]],
                  dt,
                  [CCCallFuncN actionWithTarget:self selector:@selector(pickUpSilverDrop:)],
                  nil],
                 [CCMoveByCustom actionWithDuration:SILVER_STACK_BOUNCE_DURATION position:ccp(xPos, 0)],
                 nil]];
  
  [[SoundEngine sharedSoundEngine] coinDrop];
}

- (void) pickUpSilverDrop:(SilverStack *)ss {
  silverOnMap -= ss.amount;
  
  [ss stopAllActions];
  
  CCLabelTTF *coinLabel = [CCLabelFX labelWithString:[NSString stringWithFormat:@"+%d Silver", ss.amount] fontName:@"DINCond-Black" fontSize:25 shadowOffset:CGSizeMake(0, -1) shadowBlur:1.f];
  [self addChild:coinLabel z:1005];
  coinLabel.position = ss.position;
  coinLabel.color = ccc3(174, 237, 0);
  [coinLabel runAction:[CCSequence actions:
                        [CCSpawn actions:
                         [CCFadeOut actionWithDuration:DROP_LABEL_DURATION],
                         [CCMoveBy actionWithDuration:DROP_LABEL_DURATION position:ccp(0,40)],nil],
                        [CCCallBlock actionWithBlock:^{[coinLabel removeFromParentAndCleanup:YES];}], nil]];
  
  TopBar *tb = [TopBar sharedTopBar];
  CGPoint world = [ss.parent convertToWorldSpace:ss.position];
  CGPoint pos = [tb convertToNodeSpace:world];
  [ss removeFromParentAndCleanup:NO];
  ss.position = pos;
  ss.scale *= self.scale;
  [tb addChild:ss z:-1];
  
  CCNode *coinBar = [tb getChildByTag:COIN_BAR_TAG];
  
  [ss runAction:[CCSequence actions:
                 [CCSpawn actions:
                  [CCEaseSineIn actionWithAction:
                   [CCMoveToCustom actionWithDuration:0.5 position:ccp(ss.position.x,292)]],
                  [CCEaseSineOut actionWithAction:
                   [CCMoveToCustom actionWithDuration:0.5 position:ccp(coinBar.position.x-21.f,ss.position.y)]],
                  [CCScaleTo actionWithDuration:0.5 scale:0.5],
                  nil],
                 [CCCallBlock actionWithBlock:^{[ss removeFromParentAndCleanup:YES];}],
                 nil]];
  
  [[SoundEngine sharedSoundEngine] coinPickup];
}

- (void) addGoldDrop:(int)amount fromSprite:(MapSprite *)sprite toPosition:(CGPoint)pt secondsToPickup:(int)secondsToPickup {
  goldOnMap += amount;
  
  GoldStack *gs = [[GoldStack alloc] initWithAmount:amount];
  [self addChild:gs z:1004];
  [gs release];
  gs.position = ccpAdd(sprite.position, ccp(0,sprite.contentSize.height/2));
  gs.scale = 0.01;
  gs.opacity = 5;
  
  // Need to fade in, scale to 1, bounce in y dir, move normal in x dir
  float xPos = CGPointEqualToPoint(pt, CGPointZero) ? ((float)(arc4random()%((unsigned)RAND_MAX+1))/RAND_MAX)*120-60 : pt.x-gs.position.x;
  float yPos = CGPointEqualToPoint(pt, CGPointZero) ? ((float)(arc4random()%((unsigned)RAND_MAX+1))/RAND_MAX)*20-10 : pt.y-gs.position.y;
  
  // -1 seconds means don't pickup, 0 seconds means default
  secondsToPickup = secondsToPickup == 0 ? PICK_UP_WAIT_TIME : secondsToPickup;
  CCDelayTime *dt = secondsToPickup > 0 ? [CCDelayTime actionWithDuration:secondsToPickup] : nil;
  [gs runAction:[CCSpawn actions:
                 [CCFadeIn actionWithDuration:0.1],
                 [CCScaleTo actionWithDuration:0.1 scale:1],
                 [CCRotateBy actionWithDuration:SILVER_STACK_BOUNCE_DURATION angle:DROP_ROTATION],
                 [CCSequence actions:
                  [CCMoveByCustom actionWithDuration:SILVER_STACK_BOUNCE_DURATION*0.2 position:ccp(0,40)],
                  [CCEaseBounceOut actionWithAction:
                   [CCMoveByCustom actionWithDuration:SILVER_STACK_BOUNCE_DURATION*0.8 position:ccp(0,-85+yPos)]],
                  dt,
                  [CCCallFuncN actionWithTarget:self selector:@selector(pickUpGoldDrop:)],
                  nil],
                 [CCMoveByCustom actionWithDuration:SILVER_STACK_BOUNCE_DURATION position:ccp(xPos, 0)],
                 nil]];
  
  [[SoundEngine sharedSoundEngine] coinDrop];
}

- (void) pickUpGoldDrop:(GoldStack *)ss {
  goldOnMap -= ss.amount;
  
  [ss stopAllActions];
  
  CCLabelTTF *coinLabel = [CCLabelFX labelWithString:[NSString stringWithFormat:@"+%d Gold", ss.amount] fontName:@"DINCond-Black" fontSize:25 shadowOffset:CGSizeMake(0, -1) shadowBlur:1.f];
  [self addChild:coinLabel z:1005];
  coinLabel.position = ss.position;
  coinLabel.color = ccc3(255, 200, 0);
  [coinLabel runAction:[CCSequence actions:
                        [CCSpawn actions:
                         [CCFadeOut actionWithDuration:DROP_LABEL_DURATION],
                         [CCMoveBy actionWithDuration:DROP_LABEL_DURATION position:ccp(0,40)],nil],
                        [CCCallBlock actionWithBlock:^{[coinLabel removeFromParentAndCleanup:YES];}], nil]];
  
  TopBar *tb = [TopBar sharedTopBar];
  CGPoint world = [ss.parent convertToWorldSpace:ss.position];
  CGPoint pos = [tb convertToNodeSpace:world];
  [ss removeFromParentAndCleanup:NO];
  ss.position = pos;
  ss.scale *= self.scale;
  [tb addChild:ss z:-1];
  
  CCNode *coinBar = [tb getChildByTag:COIN_BAR_TAG];
  
  [ss runAction:[CCSequence actions:
                 [CCSpawn actions:
                  [CCEaseSineIn actionWithAction:
                   [CCMoveToCustom actionWithDuration:0.5 position:ccp(ss.position.x,292)]],
                  [CCEaseSineOut actionWithAction:
                   [CCMoveToCustom actionWithDuration:0.5 position:ccp(coinBar.position.x+47.f,ss.position.y)]],
                  [CCScaleTo actionWithDuration:0.5 scale:0.5],
                  nil],
                 [CCCallBlock actionWithBlock:^{[ss removeFromParentAndCleanup:YES];}],
                 nil]];
  
  [[SoundEngine sharedSoundEngine] coinPickup];
}

- (void) addEquipDrop:(int)equipId fromSprite:(MapSprite *)sprite toPosition:(CGPoint)pt secondsToPickup:(int)secondsToPickup {
  EquipDrop *ed = [[EquipDrop alloc] initWithEquipId:equipId];
  [self addChild:ed z:1004];
  [ed release];
  ed.position = ccpAdd(sprite.position, ccp(0,sprite.contentSize.height/2));
  ed.scale = 0.01;
  ed.opacity = 5;
  
  float scale = 50.f/ed.contentSize.width;
  
  // Need to fade in, scale to 1, bounce in y dir, move normal in x dir
  float xPos = CGPointEqualToPoint(pt, CGPointZero) ? ((float)(arc4random()%((unsigned)RAND_MAX+1))/RAND_MAX)*120-60 : pt.x-ed.position.x;
  float yPos = CGPointEqualToPoint(pt, CGPointZero) ? ((float)(arc4random()%((unsigned)RAND_MAX+1))/RAND_MAX)*20-10 : pt.y-ed.position.y;
  
  // -1 seconds means don't pickup, 0 seconds means default
  secondsToPickup = secondsToPickup == 0 ? PICK_UP_WAIT_TIME : secondsToPickup;
  CCDelayTime *dt = secondsToPickup > 0 ? [CCDelayTime actionWithDuration:secondsToPickup] : nil;
  [ed runAction:[CCSpawn actions:
                 [CCFadeIn actionWithDuration:0.1],
                 [CCScaleTo actionWithDuration:0.1 scale:scale],
                 [CCRotateBy actionWithDuration:SILVER_STACK_BOUNCE_DURATION angle:DROP_ROTATION],
                 [CCSequence actions:
                  [CCMoveByCustom actionWithDuration:SILVER_STACK_BOUNCE_DURATION*0.2 position:ccp(0,40)],
                  [CCEaseBounceOut actionWithAction:
                   [CCMoveByCustom actionWithDuration:SILVER_STACK_BOUNCE_DURATION*0.8 position:ccp(0,-85+yPos)]],
                  dt,
                  [CCCallFuncN actionWithTarget:self selector:@selector(pickUpEquipDrop:)],
                  nil],
                 [CCMoveByCustom actionWithDuration:SILVER_STACK_BOUNCE_DURATION position:ccp(xPos, 0)],
                 nil]];
}

- (void) pickUpEquipDrop:(EquipDrop *)ed {
  [ed stopAllActions];
  
  FullEquipProto *fep = [[GameState sharedGameState] equipWithId:ed.equipId];
  CCLabelFX *nameLabel = [CCLabelFX labelWithString:fep.name fontName:@"DINCond-Black" fontSize:25 shadowOffset:CGSizeMake(0, -1) shadowBlur:1.f];
  [self addChild:nameLabel z:1005];
  nameLabel.position = ed.position;
  UIColor *col = [Globals colorForRarity:fep.rarity];
  CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
  [col getRed:&red green:&green blue:&blue alpha:&alpha];
  nameLabel.color = ccc3((int)(red*255), (int)(green*255), (int)(blue*255));
  [nameLabel runAction:[CCSequence actions:
                        [CCSpawn actions:
                         [CCFadeOut actionWithDuration:DROP_LABEL_DURATION],
                         [CCMoveBy actionWithDuration:DROP_LABEL_DURATION position:ccp(0,40)],nil],
                        [CCCallBlock actionWithBlock:^{[nameLabel removeFromParentAndCleanup:YES];}], nil]];
  
  TopBar *tb = [TopBar sharedTopBar];
  CGPoint world = [ed.parent convertToWorldSpace:ed.position];
  CGPoint pos = [tb convertToNodeSpace:world];
  [ed removeFromParentAndCleanup:NO];
  ed.position = pos;
  ed.scale *= self.scale;
  [tb addChild:ed z:-1];
  
  float scale = 40.f/ed.contentSize.width;
  [ed runAction:[CCSequence actions:
                 [CCSpawn actions:
                  [CCEaseSineIn actionWithAction:
                   [CCMoveToCustom actionWithDuration:0.5 position:ccp(ed.position.x,tb.profilePic.position.y)]],
                  [CCEaseSineOut actionWithAction:
                   [CCMoveToCustom actionWithDuration:0.5 position:ccp(tb.profilePic.position.x,ed.position.y)]],
                  [CCScaleTo actionWithDuration:0.5 scale:scale],
                  nil],
                 [CCCallBlock actionWithBlock:^{[ed removeFromParentAndCleanup:YES];}],
                 nil]];
}

- (void) addLockBoxDrop:(int)eventId fromSprite:(MapSprite *)sprite secondsToPickup:(int)secondsToPickup {
  LockBoxDrop *lbd = [[LockBoxDrop alloc] initWithEventId:eventId];
  if (lbd) {
    [self addChild:lbd z:1004];
    [lbd release];
    lbd.position = ccpAdd(sprite.position, ccp(0,sprite.contentSize.height/2));
    lbd.scale = 0.01;
    lbd.opacity = 5;
    
    // Need to fade in, scale to 1, bounce in y dir, move normal in x dir
    float xPos = ((float)(arc4random()%((unsigned)RAND_MAX+1))/RAND_MAX)*120-60;
    float yPos = ((float)(arc4random()%((unsigned)RAND_MAX+1))/RAND_MAX)*20-10;
    
    // -1 seconds means don't pickup, 0 seconds means default
    secondsToPickup = secondsToPickup == 0 ? PICK_UP_WAIT_TIME : secondsToPickup;
    CCDelayTime *dt = secondsToPickup > 0 ? [CCDelayTime actionWithDuration:secondsToPickup] : nil;
    [lbd runAction:[CCSpawn actions:
                    [CCFadeIn actionWithDuration:0.1],
                    [CCScaleTo actionWithDuration:0.1 scale:0.4],
                    [CCRotateBy actionWithDuration:SILVER_STACK_BOUNCE_DURATION angle:DROP_ROTATION],
                    [CCSequence actions:
                     [CCMoveByCustom actionWithDuration:SILVER_STACK_BOUNCE_DURATION*0.2 position:ccp(0,40)],
                     [CCEaseBounceOut actionWithAction:
                      [CCMoveByCustom actionWithDuration:SILVER_STACK_BOUNCE_DURATION*0.8 position:ccp(0,-85+yPos)]],
                     dt,
                     [CCCallFuncN actionWithTarget:self selector:@selector(pickUpLockBoxDrop:)],
                     nil],
                    [CCMoveByCustom actionWithDuration:SILVER_STACK_BOUNCE_DURATION position:ccp(xPos, 0)],
                    nil]];
  }
}

- (void) pickUpLockBoxDrop:(LockBoxDrop *)lbd {
  [lbd stopAllActions];
  
  CCLabelFX *nameLabel = [CCLabelFX labelWithString:@"+1 Lock Box" fontName:@"DINCond-Black" fontSize:25 shadowOffset:CGSizeMake(0, -1) shadowBlur:1.f];
  [self addChild:nameLabel z:1005];
  nameLabel.position = lbd.position;
  nameLabel.color = ccc3(255, 200, 0);
  [nameLabel runAction:[CCSequence actions:
                        [CCSpawn actions:
                         [CCFadeOut actionWithDuration:DROP_LABEL_DURATION],
                         [CCMoveBy actionWithDuration:DROP_LABEL_DURATION position:ccp(0,40)],nil],
                        [CCCallBlock actionWithBlock:^{[nameLabel removeFromParentAndCleanup:YES];}], nil]];
  
  TopBar *tb = [TopBar sharedTopBar];
  CGPoint world = [lbd.parent convertToWorldSpace:lbd.position];
  CGPoint pos = [tb convertToNodeSpace:world];
  [lbd removeFromParentAndCleanup:NO];
  lbd.position = pos;
  lbd.scale *= self.scale;
  [tb addChild:lbd z:-1];
  
  [lbd runAction:[CCSequence actions:
                  [CCSpawn actions:
                   [CCEaseSineIn actionWithAction:
                    [CCMoveToCustom actionWithDuration:0.5 position:ccp(lbd.position.x,195)]],
                   [CCEaseSineOut actionWithAction:
                    [CCMoveToCustom actionWithDuration:0.5 position:ccp(452,lbd.position.y)]],
                   [CCScaleTo actionWithDuration:0.5 scale:0.2],
                   nil],
                  [CCCallBlock actionWithBlock:^{[lbd removeFromParentAndCleanup:YES];}],
                  nil]];
}

- (void) pickUpDrop:(CCNode *)drop {
  if ([drop isKindOfClass:[EquipDrop class]]) {
    [self pickUpEquipDrop:(EquipDrop *)drop];
  } else if ([drop isKindOfClass:[SilverStack class]]) {
    [self pickUpSilverDrop:(SilverStack *)drop];
  } else if ([drop isKindOfClass:[GoldStack class]]) {
    [self pickUpGoldDrop:(GoldStack *)drop];
  } else if ([drop isKindOfClass:[LockBoxDrop class]]) {
    [self pickUpLockBoxDrop:(LockBoxDrop *)drop];
  }
}

- (void) pickUpAllDrops {
  NSMutableArray *toPickUp = [NSMutableArray array];
  for (CCNode *n in children_) {
    [toPickUp addObject:n];
  }
  for (CCNode *n in toPickUp) {
    [self pickUpDrop:n];
  }
}

- (BOOL) mapSprite:(MapSprite *)front isInFrontOfMapSprite: (MapSprite *)back {
  if (front == back) {
    return YES;
  }
  
  CGRect frontLoc = front.location;
  CGRect backLoc = back.location;
  
  BOOL leftX = frontLoc.origin.x < backLoc.origin.x && frontLoc.origin.x+frontLoc.size.width <= backLoc.origin.x;
  BOOL rightX = frontLoc.origin.x >= backLoc.origin.x+backLoc.size.width && frontLoc.origin.x+frontLoc.size.width > backLoc.origin.x+backLoc.size.width;
  
  if (leftX || rightX) {
    return frontLoc.origin.x <= backLoc.origin.x;
  }
  
  BOOL leftY = frontLoc.origin.y < backLoc.origin.y && frontLoc.origin.y+frontLoc.size.height <= backLoc.origin.y;
  BOOL rightY = frontLoc.origin.y >= backLoc.origin.y+backLoc.size.height && frontLoc.origin.y+frontLoc.size.height > backLoc.origin.y+backLoc.size.height;
  
  if (leftY || rightY) {
    return frontLoc.origin.y <= backLoc.origin.y;
  }
  return front.position.y <= back.position.y;
}

- (Enemy *) enemyWithUserId:(int)userId {
  for (CCNode *child in children_) {
    if ([child isKindOfClass:[Enemy class]]) {
      Enemy *enemy = (Enemy *)child;
      if (enemy.user.userId == userId) {
        return enemy;
      }
    }
  }
  return nil;
}

- (void) updateEnemyMenu {
  if (_selected && ([_selected isKindOfClass:[Enemy class]] || [_selected isKindOfClass:[Ally class]])) {
    CGPoint pt = [_selected convertToWorldSpace:ccp(_selected.contentSize.width/2, _selected.contentSize.height-OVER_HOME_BUILDING_MENU_OFFSET+5)];
    
    float width = enemyMenu.frame.size.width;
    float height = enemyMenu.frame.size.height;
    enemyMenu.frame = CGRectMake(pt.x-width/2, ([[CCDirector sharedDirector] winSize].height-pt.y)-height, width, height);
    
    enemyMenu.hidden = NO;
  } else {
    enemyMenu.hidden = YES;
  }
}

- (void) setSelected:(SelectableSprite *)selected {
  if (_selected != selected) {
    _selected.isSelected = NO;
    _selected = selected;
    if ([selected isKindOfClass: [Enemy class]]) {
      FullUserProto *fup = [(Enemy *)selected user];
      [[self.enemyMenu nameLabel] setText:fup.name];
      [[self.enemyMenu levelLabel] setText:[NSString stringWithFormat:@"Lvl %d", fup.level]];
      [[self.enemyMenu imageIcon] setImage:[Globals squareImageForUser:fup.userType]];
      self.enemyMenu.enemyView.hidden = NO;
      self.enemyMenu.allyView.hidden = YES;
    } else if ([selected isKindOfClass:[Ally class]]) {
      MinimumUserProtoWithLevel *mup = [(Ally *)selected user];
      [[self.enemyMenu nameLabel] setText:mup.minUserProto.name];
      [[self.enemyMenu levelLabel] setText:[NSString stringWithFormat:@"Lvl %d", mup.level]];
      [[self.enemyMenu imageIcon] setImage:[Globals squareImageForUser:mup.minUserProto.userType]];
      self.enemyMenu.enemyView.hidden = YES;
      self.enemyMenu.allyView.hidden = NO;
    }
    _selected.isSelected = YES;
    [self updateEnemyMenu];
  }
}

- (void) doReorder {
  for (int i = 1; i < [_mapSprites count]; i++) {
    MapSprite *toSort = [_mapSprites objectAtIndex:i];
    MapSprite *sorted = [_mapSprites objectAtIndex:i-1];
    if (![self mapSprite:toSort isInFrontOfMapSprite:sorted]) {
      int j;
      for (j = i-2; j >= 0; j--) {
        sorted = [_mapSprites objectAtIndex:j];
        if ([self mapSprite:toSort isInFrontOfMapSprite:sorted]) {
          break;
        }
      }
      
      [_mapSprites removeObjectAtIndex:i];
      [_mapSprites insertObject:toSort atIndex:j+1];
    }
  }
  
  for (int i = 0; i < [_mapSprites count]; i++) {
    MapSprite *child = [_mapSprites objectAtIndex:i];
    [self reorderChild:child z:i+REORDER_START_Z];
  }
}

- (SelectableSprite *) selectableForPt:(CGPoint)pt {
  // Find sprite that has center closest to pt
  SelectableSprite *toRet = nil;
  float distToCenter = 320.f;
  for(MapSprite *spr in _mapSprites) {
    if (![spr isKindOfClass:[SelectableSprite class]]) {
      continue;
    }
    SelectableSprite *child = (SelectableSprite *)spr;
    if ([child isPointInArea:pt] && child.visible && child.opacity > 0.f) {
      CGPoint center = ccp(child.contentSize.width/2, child.contentSize.height/2);
      float thisDistToCenter = ccpDistance(center, [child convertToNodeSpace:pt]);
      
      if (thisDistToCenter < distToCenter) {
        distToCenter = thisDistToCenter;
        toRet = child;
      }
    }
  }
  return toRet;
}

- (void) tap:(UIGestureRecognizer*)recognizer node:(CCNode*)node
{
  CGPoint pt = [recognizer locationInView:recognizer.view];
  pt = [[CCDirector sharedDirector] convertToGL:pt];
  
  if (_selected && ![_selected isPointInArea:pt]) {
    self.selected = nil;
  }
  
  SelectableSprite *ss = [self selectableForPt:pt];
  self.selected = ss;
  
  if (ss == nil) {
    pt = [self convertToNodeSpace:pt];
    pt = [self convertCCPointToTilePoint:pt];
    CGRect loc = CGRectMake(pt.x, pt.y, 1, 1);
    
    [_myPlayer moveToLocation:loc];
  }
}

- (void) drag:(UIGestureRecognizer*)recognizer node:(CCNode*)node
{
  // Now do drag motion
  UIPanGestureRecognizer* pan = (UIPanGestureRecognizer*)recognizer;
  
  if([recognizer state] == UIGestureRecognizerStateBegan ||
     [recognizer state] == UIGestureRecognizerStateChanged )
  {
    [node stopActionByTag:190];
    CGPoint translation = [pan translationInView:pan.view.superview];
    
    CGPoint delta = [self convertVectorToGL: translation];
    [node setPosition:ccpAdd(node.position, delta)];
    [pan setTranslation:CGPointZero inView:pan.view.superview];
    self.enemyMenu.hidden = YES;
  } else if ([recognizer state] == UIGestureRecognizerStateEnded) {
    [self updateEnemyMenu];
    CGPoint vel = [pan velocityInView:pan.view.superview];
    vel = [self convertVectorToGL: vel];
    
    float dist = ccpDistance(ccp(0,0), vel);
    if (dist < 500) {
      return;
    }
    
    vel.x /= 3;
    vel.y /= 3;
    id actionID = [CCMoveBy actionWithDuration:dist/1500 position:vel];
    CCEaseOut *action = [CCEaseSineOut actionWithAction:actionID];
    action.tag = 190;
    [node runAction:action];
  }
}

- (void) scale:(UIGestureRecognizer*)recognizer node:(CCNode*)node
{
  UIPinchGestureRecognizer* pinch = (UIPinchGestureRecognizer*)recognizer;
  
  // See if zoom should even be allowed
  float newScale = node.scale * pinch.scale;
  pinch.scale = 1.0f; // we just reset the scaling so we only wory about the delta
  if (newScale > MAX_ZOOM || newScale < MIN_ZOOM) {
    return;
  }
  
  CCDirector* director = [CCDirector sharedDirector];
  CGPoint pt = [recognizer locationInView:recognizer.view.superview];
  pt = [director convertToGL:pt];
  CGPoint beforeScale = [node convertToNodeSpace:pt];
  
  node.scale = newScale;
  CGPoint afterScale = [node convertToNodeSpace:pt];
  CGPoint diff = ccpSub(afterScale, beforeScale);
  
  node.position = ccpAdd(node.position, ccpMult(diff, node.scale));
  
  [self updateEnemyMenu];
  [self.decLayer updateAllCloudOpacities];
}

-(void) setPosition:(CGPoint)position {
  // For y, make sure to account for anchor point being at bottom middle.
  CGPoint blPt = [self convertTilePointToCCPoint:bottomLeftCorner];
  CGPoint trPt = [self convertTilePointToCCPoint:topRightCorner];
  float minX = blPt.x;
  float minY = blPt.y+self.tileSizeInPoints.height/2;
  float maxX = trPt.x;
  float maxY = trPt.y+self.tileSizeInPoints.height/2;
  
  float x = MAX(MIN(-minX*self.scaleX, position.x), -maxX*self.scaleX + [[CCDirector sharedDirector] winSize].width);
  float y = MAX(MIN(-minY*self.scaleY, position.y), -maxY*self.scaleY + [[CCDirector sharedDirector] winSize].height);
  
  CGPoint oldPos = position_;
  [super setPosition:ccp(x,y)];
  if (!enemyMenu.hidden) {
    CGPoint diff = ccpSub(oldPos, position_);
    diff.x *= -1;
    CGRect curRect = enemyMenu.frame;
    curRect.origin = ccpAdd(curRect.origin, diff);
    enemyMenu.frame = curRect;
  }
}

- (void) setScale:(float)scale {
  CGPoint tr = [self convertTilePointToCCPoint:topRightCorner];
  CGPoint bl = [self convertTilePointToCCPoint:bottomLeftCorner];
  int newWidth = (tr.x-bl.x)*scale;
  int newHeight = (tr.y-bl.y)*scale;
  
  if (newWidth >= self.parent.contentSize.width && newHeight >= self.parent.contentSize.height) {
    [super setScale:scale];
  }
}

- (BOOL) isPointInArea:(CGPoint)pt {
  // Whole screen is in area
  return YES;
}

- (IBAction)attackClicked:(id)sender {
  if ([_selected isKindOfClass:[Enemy class]]) {
    Enemy *enemy = (Enemy *)_selected;
    FullUserProto *fup = enemy.user;
    if (fup) {
      int city = [[GameLayer sharedGameLayer] currentCity];
      
      if (city > 0) {
        [[BattleLayer sharedBattleLayer] beginBattleAgainst:fup inCity:city];
      } else {
        [[BattleLayer sharedBattleLayer] beginBattleAgainst:fup];
      }
    }
  }
}

- (IBAction)enemyProfileClicked:(id)sender {
  if ([_selected isKindOfClass:[Enemy class]]) {
    Enemy *enemy = (Enemy *)_selected;
    [[ProfileViewController sharedProfileViewController] loadProfileForPlayer:enemy.user buttonsEnabled:YES];
    [ProfileViewController displayView];
    
    [Analytics enemyProfileFromSprite];
  }
}

- (IBAction)allyProfileClicked:(id)sender {
  if ([_selected isKindOfClass:[Ally class]]) {
    Ally *ally = (Ally *)_selected;
    [[ProfileViewController sharedProfileViewController] loadProfileForMinimumUser:ally.user.minUserProto withState:kProfileState];
  }
}

- (void) layerWillDisappear {
  self.selected = nil;
}

-(CGPoint)convertVectorToGL:(CGPoint)uiPoint
{
  float newY = - uiPoint.y;
  float newX = - uiPoint.x;
  
  CGPoint ret = CGPointZero;
  switch ([[CCDirector sharedDirector] deviceOrientation]) {
    case CCDeviceOrientationPortrait:
      ret = ccp( uiPoint.x, newY );
      break;
    case CCDeviceOrientationPortraitUpsideDown:
      ret = ccp(newX, uiPoint.y);
      break;
    case CCDeviceOrientationLandscapeLeft:
      ret.x = uiPoint.y;
      ret.y = uiPoint.x;
      break;
    case CCDeviceOrientationLandscapeRight:
      ret.x = newY;
      ret.y = newX;
      break;
  }
  return ret;
}

- (CGPoint) randomWalkablePosition {
  while (true) {
    int x = arc4random() % (int)self.mapSize.width;
    int y = arc4random() % (int)self.mapSize.height;
    NSNumber *num = [[_walkableData objectAtIndex:x] objectAtIndex:y];
    if (num.boolValue == YES) {
      // Make sure it is not too close to another sprite
      BOOL acceptable = YES;
      for (CCNode *child in self.children) {
        if ([child isKindOfClass:[CharacterSprite class]]) {
          CharacterSprite *cs = (CharacterSprite *)child;
          int xDiff = ABS(cs.location.origin.x-x);
          int yDiff = ABS(cs.location.origin.y-y);
          if (xDiff <= 2 && yDiff <= 2) {
            acceptable = NO;
            break;
          }
        }
      }
      
      if (acceptable) {
        return CGPointMake(x, y);
      }
    }
  }
}

- (CGPoint) nextWalkablePositionFromPoint:(CGPoint)point prevPoint:(CGPoint)prevPt {
  CGPoint diff = ccpSub(point, prevPt);
  if (diff.y > 0.5f) {
    diff = ccp(0, 1);
  } else if (diff.y < -0.5f) {
    diff = ccp(0, -1);
  } else if (diff.x > 0.5f) {
    diff = ccp(1, 0);
  } else {
    // Use some default :/ in case stuck
    diff = ccp(-1, 0);
  }
  
  CGPoint straight = ccpAdd(point, diff);
  CGPoint left = ccpAdd(point, ccpRotateByAngle(diff, ccp(0,0), M_PI_2));
  CGPoint right = ccpAdd(point, ccpRotateByAngle(diff, ccp(0,0), -M_PI_2));
  CGPoint back = ccpSub(point, diff);
  
  CGPoint pts[4] = {straight, right, left, back};
  int width = mapSize_.width;
  int height = mapSize_.height;
  
  // Don't let it infinite loop in case its stuck
  int max = 50;
  while (max > 0) {
    // 75% chance to go straight, 10% chance to turn (for each way), 5% chance to go back
    int x = arc4random() % 100;
    if (x <= 75) x = 0;
    else if (x <= 85) x = 1;
    else if (x <= 95) x = 2;
    else x = 3;
    
    CGPoint pt = pts[x];
    if (pt.x >= 0 && pt.x < width && pt.y >= 0 && pt.y < height) {
      if ([[[_walkableData objectAtIndex:pt.x] objectAtIndex:pt.y] boolValue] == YES) {
        return ccp((int)pt.x, (int)pt.y);
      }
    }
    max--;
  }
  return point;
}

- (void) moveToCenterAnimated:(BOOL)animated {
  // move map to the center of the screen
  CGSize ms = [self mapSize];
  CGSize ts = [self tileSizeInPoints];
  CGSize size = [[CCDirector sharedDirector] winSize];
  
  float x = -ms.width*ts.width/2*scaleX_+size.width/2;
  float y = -ms.height*ts.height/2*scaleY_+size.height/2;
  CGPoint newPos = ccp(x,y);
  if (animated) {
    [self runAction:[CCMoveTo actionWithDuration:0.2f position:newPos]];
  } else {
    self.position = newPos;
  }
}

- (void) moveToSprite:(CCSprite *)spr animated:(BOOL)animated withOffset:(CGPoint)offset {
  if (spr) {
    CGPoint pt = spr.position;
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    // Since all sprites have anchor point ccp(0.5,0) adjust accordingly
    float x = -pt.x*scaleX_+size.width/2;
    float y = (-pt.y-spr.contentSize.height*3/4)*scaleY_+size.height/2;
    CGPoint newPos = ccpAdd(offset,ccp(x,y));
    if (animated) {
      float dur = ccpDistance(newPos, self.position)/1000.f;
      [self runAction:[CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:dur position:newPos]]];
    } else {
      self.position = newPos;
    }
  }
}

- (void) moveToSprite:(CCSprite *)spr animated:(BOOL)animated {
  [self moveToSprite:spr animated:animated withOffset:ccp(0,0)];
}

- (CGPoint) convertTilePointToCCPoint:(CGPoint)pt {
  CGSize ms = mapSize_;
  CGSize ts = tileSizeInPoints;
  return ccp( ms.width * ts.width/2.f + ts.width * (pt.x-pt.y)/2.f,
             ts.height * (pt.y+pt.x)/2.f);
}

- (CGPoint) convertCCPointToTilePoint:(CGPoint)pt {
  CGSize ms = mapSize_;
  CGSize ts = tileSizeInPoints;
  float a = (pt.x - ms.width*ts.width/2.f)/ts.width;
  float b = pt.y/ts.height;
  float x = a+b;
  float y = b-a;
  return ccp(x,y);
}

- (void) reloadQuestGivers {
  NSAssert(NO, @"Implement reloadQuestGivers in map");
}

- (void) questAccepted:(FullQuestProto *)fqp {
  NSAssert(NO, @"Implement questAccepted: in map");
}

- (void) questRedeemed:(FullQuestProto *)fqp {
  NSAssert(NO, @"Implement questAccepted: in map");
}

- (void) moveToEnemyType:(DefeatTypeJobProto_DefeatTypeJobEnemyType)type animated:(BOOL)animated {
  Enemy *enemyWithType = nil;
  for (CCNode *child in children_) {
    if ([child isKindOfClass:[Enemy class]]) {
      Enemy *enemy = (Enemy *)child;
      if (enemy.user.userType == type || type == DefeatTypeJobProto_DefeatTypeJobEnemyTypeAllTypesFromOpposingSide) {
        enemyWithType = enemy;
        break;
      }
    }
  }
  [self moveToSprite:enemyWithType animated:animated];
}

- (void) onExit {
  [super onExit];
  self.selected = nil;
}

- (void) dealloc {
  [self.enemyMenu removeFromSuperview];
  self.enemyMenu = nil;
  self.walkableData = nil;
  self.mapSprites = nil;
  [super dealloc];
}

@end
