//
//  BazaarMap.m
//  Utopia
//
//  Created by Ashwin Kamath on 5/2/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "BazaarMap.h"
#import "SynthesizeSingleton.h"

@implementation CritStructMenu

@synthesize titleLabel;

- (void) awakeFromNib {
  [super awakeFromNib];
  self.hidden = YES;
}

- (void) setFrameForPoint:(CGPoint)pt {
  // place it so that the bottom middle is at pt
  // Remember, frame is relative to top left corner
  float width = self.frame.size.width;
  float height = self.frame.size.height;
  self.frame = CGRectMake(pt.x-width/2, ([[CCDirector sharedDirector] winSize].height - pt.y)-height, width, height);
}

- (void) dealloc {
  self.titleLabel = nil;
  [super dealloc];
}

@end

@implementation BazaarMap

@synthesize csMenu;

SYNTHESIZE_SINGLETON_FOR_CLASS(BazaarMap);

- (id) init {
  if ((self = [super initWithTMXFile:@"Bazaar.tmx"])) {
    CritStructBuilding *csb = [[CritStructBuilding alloc] initWithFile:@"Marketplace.png" location:CGRectMake(36, 36, 2, 2) map:self];
    CritStruct *cs = [[CritStruct alloc] initWithType:CritStructTypeMarketplace];
    csb.critStruct = cs;
    [self addChild:csb z:100];
    
    csb = [[CritStructBuilding alloc] initWithFile:@"Armory.png" location:CGRectMake(43, 36, 2, 2) map:self];
    cs = [[CritStruct alloc] initWithType:CritStructTypeArmory];
    csb.critStruct = cs;
    [self addChild:csb z:100];
    
    csb = [[CritStructBuilding alloc] initWithFile:@"Vault.png" location:CGRectMake(36, 43, 2, 2) map:self];
    cs = [[CritStruct alloc] initWithType:CritStructTypeVault];
    csb.critStruct = cs;
    [self addChild:csb z:100];
    
    [[NSBundle mainBundle] loadNibNamed:@"CriticalStructureMenu" owner:self options:nil];
    [[[[CCDirector sharedDirector] openGLView] superview] addSubview:self.csMenu];
    [[[CCDirector sharedDirector] openGLView] setUserInteractionEnabled:YES];
  }
  return self;
}

- (void) updateCritStructMenu {
  if (_selected && [_selected isKindOfClass:[CritStructBuilding class]]) {
    CGPoint pt = [_selected convertToWorldSpace:ccp(_selected.contentSize.width/2, _selected.contentSize.height-OVER_HOME_BUILDING_MENU_OFFSET)];
    [csMenu setFrameForPoint:pt];
    csMenu.hidden = NO;
  } else {
    csMenu.hidden = YES;
  }
}

- (void) setSelected:(SelectableSprite *)selected {
  if (selected != _selected) {
    if ([selected isKindOfClass: [CritStructBuilding class]]) {
      [super setSelected:nil];
      [[self.csMenu titleLabel] setText:[(CritStructBuilding *)selected critStruct].name];
    }
    [super setSelected:selected];
    [self updateCritStructMenu];
  }
}

- (void) drag:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  if ([recognizer state] == UIGestureRecognizerStateBegan) {
      self.csMenu.hidden = YES;
  } else if ([recognizer state] == UIGestureRecognizerStateEnded) {
    [self updateCritStructMenu];
  }
  
  [super drag:recognizer node:node];
}

- (void) scale:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  [super scale:recognizer node:node];
  [self updateCritStructMenu];
}

- (void) setPosition:(CGPoint)position {
  CGPoint oldPos = position_;
  [super setPosition:position];
  if (!csMenu.hidden) {
    CGPoint diff = ccpSub(oldPos, position_);
    diff.x *= -1;
    CGRect curRect = csMenu.frame;
    curRect.origin = ccpAdd(curRect.origin, diff);
    csMenu.frame = curRect;
  }
}

- (void) moveToCritStruct:(CritStructType)type {
  CCSprite *csb = nil;
  for (CCNode *c in children_) {
    if ([c isKindOfClass:[CritStructBuilding class]]) {
      CritStructBuilding *check = (CritStructBuilding *)c;
      if (check.critStruct.type == type) {
        csb = check;
        break;
      }
    }
  }
  [self moveToSprite:csb];
}

- (IBAction)criticalStructVisitClicked:(id)sender {
  CritStructBuilding *csb = (CritStructBuilding *)_selected;
  self.selected = nil;
  [csb.critStruct openMenu];
}

- (void) dealloc {
  [self.csMenu removeFromSuperview];
  self.csMenu = nil;
  [super dealloc];
}

@end
