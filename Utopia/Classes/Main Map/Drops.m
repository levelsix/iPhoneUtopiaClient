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

@implementation SilverStack

@synthesize amount;

- (id) initWithAmount:(int)amt {
  if ((self = [super initWithFile:@"coinstack.png"])) {
    amount = amt;
    
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    // Set isTouchEnabled to YES so that gesture recognizers will ignore
    self.isTouchEnabled = YES;
  }
  return self;
}

- (BOOL) isPointInArea:(CGPoint)pt {
  CGRect rect = CGRectInset(CGRectMake(0, 0, self.contentSize.width, self.contentSize.height), -RECT_LEEWAY, -RECT_LEEWAY);
  pt = [self convertToNodeSpace:pt];
  
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
    GameMap *map = (GameMap *)n;
    [map pickUpSilverDrop:self];
    _clicked = YES;
  }
}

@end

@implementation GoldStack

@synthesize amount;

- (id) initWithAmount:(int)amt {
  NSString *file = amt == 1 ? @"pickupgold.png" : @"smallgoldstack.png";
  if ((self = [super initWithFile:file])) {
    amount = amt;
    
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    // Set isTouchEnabled to YES so that gesture recognizers will ignore
    self.isTouchEnabled = YES;
  }
  return self;
}

- (BOOL) isPointInArea:(CGPoint)pt {
  CGRect rect = CGRectInset(CGRectMake(0, 0, self.contentSize.width, self.contentSize.height), -RECT_LEEWAY, -RECT_LEEWAY);
  pt = [self convertToNodeSpace:pt];
  
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
    [map pickUpGoldDrop:self];
    _clicked = YES;
  }
}

@end

@implementation EquipDrop

@synthesize equipId;

- (id) initWithEquipId:(int)eq {
  if ((self = [super initWithFile:[Globals imageNameForEquip:eq]])) {
    equipId = eq;
    
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    // Set isTouchEnabled to YES so that gesture recognizers will ignore
    self.isTouchEnabled = YES;
  }
  return self;
}

- (BOOL) isPointInArea:(CGPoint)pt {
  CGRect rect = CGRectInset(CGRectMake(0, 0, self.contentSize.width, self.contentSize.height), -RECT_LEEWAY, -RECT_LEEWAY);
  pt = [self convertToNodeSpace:pt];
  
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
    [map pickUpEquipDrop:self];
    _clicked = YES;
  }
}

@end

@implementation LockBoxDrop

@synthesize eventId;

- (id) initWithEventId:(int)e {
  GameState *gs = [GameState sharedGameState];
  LockBoxEventProto *ev = [gs lockBoxEventWithId:e];
  if (!ev) {
    [self release];
    return nil;
  }
  if ((self = [super initWithFile:ev.lockBoxImageName])) {
    eventId = e;
    
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    // Set isTouchEnabled to YES so that gesture recognizers will ignore
    self.isTouchEnabled = YES;
  }
  return self;
}

- (BOOL) isPointInArea:(CGPoint)pt {
  CGRect rect = CGRectInset(CGRectMake(0, 0, self.contentSize.width*self.scale, self.contentSize.height*self.scale), -RECT_LEEWAY, -RECT_LEEWAY);
  pt = [self convertToNodeSpace:pt];
  
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
    [map pickUpLockBoxDrop:self];
    _clicked = YES;
  }
}

@end
