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
  CGRect rect = CGRectInset(CGRectMake(0, 0, self.contentSize.width, self.contentSize.height), -40, -40);
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
  GameMap *map = (GameMap *)self.parent;
  [map pickUpSilverDrop:self];
  _clicked = YES;
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
  CGRect rect = CGRectInset(CGRectMake(0, 0, self.contentSize.width*self.scale, self.contentSize.height*self.scale), -40, -40);
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
  GameMap *map = (GameMap *)self.parent;
  [map pickUpEquipDrop:self];
  _clicked = YES;
}

@end
