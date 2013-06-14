//
//  SilverStack.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/31/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "Drops.h"
#import "GameMap.h"
#import "Globals.h"
#import "GameState.h"

#define RECT_LEEWAY 10

@implementation Drop

- (id) initWithFile:(NSString *)file {
  if ((self = [super initWithFile:file])) {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    // Set isTouchEnabled to YES so that gesture recognizers will ignore
    self.isTouchEnabled = YES;
  }
  return self;
}

- (BOOL) isPointInArea:(CGPoint)pt {
  CGRect rect = CGRectInset(CGRectMake(0, 0, self.contentSize.width, self.contentSize.height), -RECT_LEEWAY, -RECT_LEEWAY);
  
  if ([self isKindOfClass:[GemDrop class]]) {
    NSLog(@"%@, %@", NSStringFromCGRect(rect), NSStringFromCGPoint(pt));
  }
  
  pt = [self convertToNodeSpace:pt];
  
  if ([self isKindOfClass:[GemDrop class]]) {
    NSLog(@"%@", NSStringFromCGPoint(pt));
  }
  
  if (CGRectContainsPoint(rect, pt)) {
    return YES;
  }
  return NO;
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  if (!_clicked) {
    CGPoint pt = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
    return [self isPointInArea:pt];
  }
  return NO;
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
  CCNode *n = self.parent;
  if ([n isKindOfClass:[GameMap class]]) {
    GameMap *map = (GameMap *)self.parent;
    [map pickUpDrop:self];
#warning change back
//    _clicked = YES;
  }
}

@end

@implementation SilverStack

@synthesize amount;

- (id) initWithAmount:(int)amt {
  if ((self = [super initWithFile:@"coinstack.png"])) {
    amount = amt;
  }
  return self;
}

@end

@implementation GoldStack

@synthesize amount;

- (id) initWithAmount:(int)amt {
  NSString *file = amt == 1 ? @"pickupgold.png" : @"smallgoldstack.png";
  if ((self = [super initWithFile:file])) {
    amount = amt;
  }
  return self;
}

@end

@implementation EquipDrop

@synthesize equipId;

- (id) initWithEquipId:(int)eq {
  if ((self = [super initWithFile:[Globals imageNameForEquip:eq]])) {
    equipId = eq;
  }
  return self;
}

@end

@implementation LockBoxDrop

- (id) initWithEventId:(int)e {
  GameState *gs = [GameState sharedGameState];
  LockBoxEventProto *ev = [gs lockBoxEventWithId:e];
  if (!ev) {
    [self release];
    return nil;
  }
  
  return [super initWithFile:ev.lockBoxImageName];
}

@end

@implementation GemDrop

- (id) initWithGemId:(int)gemId {
  GameState *gs = [GameState sharedGameState];
  CityGemProto *g = [gs gemForId:gemId];
  if (!g) {
    [self release];
    return nil;
  }
  
  if ((self = [super initWithFile:g.gemImageName])) {
    self.gemId = gemId;
  }
  
  return self;
}

@end
