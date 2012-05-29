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

SYNTHESIZE_SINGLETON_FOR_CLASS(BazaarMap);

- (id) init {
  if ((self = [super initWithTMXFile:@"Bazaar.tmx"])) {
    CritStruct *cs = [[CritStruct alloc] initWithType:CritStructTypeMarketplace];
    CritStructBuilding *csb = [[CritStructBuilding alloc] initWithCritStruct:cs location:CGRectMake(36, 36, 2, 2) map:self];
    [self addChild:csb z:100];
    
    cs = [[CritStruct alloc] initWithType:CritStructTypeArmory];
    csb = [[CritStructBuilding alloc] initWithCritStruct:cs location:CGRectMake(43, 36, 2, 2) map:self];
    [self addChild:csb z:100];
    
    cs = [[CritStruct alloc] initWithType:CritStructTypeVault];
    csb = [[CritStructBuilding alloc] initWithCritStruct:cs location:CGRectMake(36, 43, 2, 2) map:self];
    [self addChild:csb z:100];
  }
  return self;
}

- (void) setSelected:(SelectableSprite *)selected {
  if (selected != _selected) {
    if ([selected isKindOfClass: [CritStructBuilding class]]) {
      [super setSelected:nil];
      [[(CritStructBuilding *)selected critStruct] openMenu];
    } else {
      [super setSelected:selected];
    }
  }
}

- (void) drag:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  self.selected = nil;
  [super drag:recognizer node:node];
}

- (void) scale:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  self.selected = nil;
  [super scale:recognizer node:node];
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

@end
