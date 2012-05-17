//
//  BazaarMap.m
//  Utopia
//
//  Created by Ashwin Kamath on 5/2/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "BazaarMap.h"
#import "SynthesizeSingleton.h"

@implementation BazaarMap

SYNTHESIZE_SINGLETON_FOR_CLASS(BazaarMap);

- (id) init {
  if ((self = [super initWithTMXFile:@"Bazaar.tmx"])) {
    CritStructBuilding *csb = [[CritStructBuilding alloc] initWithFile:@"Marketplace.png" location:CGRectMake(16, 16, 2, 2) map:self];
    CritStruct *cs = [[CritStruct alloc] initWithType:CritStructTypeMarketplace];
    csb.critStruct = cs;
    [self addChild:csb];
  }
  return self;
}

- (void) setSelected:(SelectableSprite *)selected {
  if (selected != _selected) {
    if ([selected isKindOfClass: [CritStructBuilding class]]) {
      [super setSelected:nil];
      [[self.csMenu titleLabel] setText:[(CritStructBuilding *)selected critStruct].name];
    }
    
    [self updateCritStructMenu];
  }
}

@end
