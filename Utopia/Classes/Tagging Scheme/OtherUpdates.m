//
//  OtherUpdates.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/4/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "OtherUpdates.h"
#import "GameState.h"

@implementation NoUpdate

@synthesize tag;

+ (id) updateWithTag:(int)tag {
  return [[[self alloc] initWithTag:tag] autorelease];
}

- (id) initWithTag:(int)t {
  if ((self = [super init])) {
    self.tag = t;
  } 
  return self;
}

@end

@implementation ChangeEquipUpdate

@synthesize tag;

+ (id) updateWithTag:(int)tag equipId:(int)equipId change:(int)change {
  return [[[self alloc] initWithTag:tag equipId:equipId change:change] autorelease];
}

- (id) initWithTag:(int)t equipId:(int)equipId change:(int)change {
  if ((self = [super init])) {
    self.tag = t;
    _equipId = equipId;
    _change = change;
  }
  return self;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  [gs changeQuantityForEquip:_equipId by:_change];
}

@end
