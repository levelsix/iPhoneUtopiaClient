//
//  ComboBar.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/10/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ComboBar.h"

#define START_OFFSET 20
#define BIG_BAR_SIZE 20
#define SMALL_BAR_SIZE 10
#define MIN_SPACING 10

@implementation Notch

@synthesize place = _place;

- (void) setPlace:(NSRange)place {
  _place = place;
  self.position = ccp(self.parent.contentSize.width*(place.location+place.length/2)/100, 
                                                     self.parent.contentSize.height/2);
}

@end

@implementation ComboBar

@synthesize progressBar = _progressBar;

- (int) totalSize: (NSArray *) array withMin: (int) min {
  int x = 0;
  for (NSValue *value in array) {
    if ([value rangeValue].length >= min) {
      x += [value rangeValue].length-min+1;
    }
  }
  return x;
}

- (NSRange) locationInArray:(NSMutableArray *)array index:(int)index size:(int)size {
//  for (NSValue *val in array) {
//    NSLog(@"Before: %d, %d", [val rangeValue].location, [val rangeValue].length);
//  }
//  NSLog(@"Rand: %d, Size: %d", index, size);
  NSRange range;
  NSValue *toRemove;
  NSRange left, right;
  for (NSValue *value in array) {
    int length = [value rangeValue].length;
    if (length >= size) {
      if (index <= length-size+1) {
        range.location = [value rangeValue].location+index;
        range.length = size;
        toRemove = value;
        left.location = [value rangeValue].location;
        left.length = MAX(index-MIN_SPACING, 0);
        right.location = [value rangeValue].location+index+size+MIN_SPACING;
        right.length = MAX(length-size-index-MIN_SPACING, 0);
      } else {
        index -= (length-size+1);
      }
    }
  }
  [array removeObject:toRemove];
  if (left.length > 0)
    [array addObject:[NSValue valueWithRange:left]];
  if (right.length > 0)
    [array addObject:[NSValue valueWithRange:right]];
  
//  NSLog(@"Returning: %d, %d", range.location, range.length);
//  for (NSValue *val in array) {
//    NSLog(@"After: %d, %d", [val rangeValue].location, [val rangeValue].length);
//  }
  
  return range;
}

- (void) randomizeNotches {
  // Start with chuck from 20% to 100% and keep pulling off that
  NSMutableArray *array = [[NSMutableArray alloc] init];
  
  while (true) {
    [array removeAllObjects];
    [array addObject:[NSValue valueWithRange:NSMakeRange(START_OFFSET, 100-START_OFFSET)]];
    
    int totalSize = [self totalSize:array withMin:BIG_BAR_SIZE];
    if (totalSize == 0) { continue; }
    int rand = arc4random() % totalSize;
    _bigBar.place = [self locationInArray:array index:rand size:BIG_BAR_SIZE];
    
    totalSize = [self totalSize:array withMin:SMALL_BAR_SIZE];
    if (totalSize == 0) { continue; }
    rand = arc4random() % totalSize;
    _lilBar1.place = [self locationInArray:array index:rand size:SMALL_BAR_SIZE];
    
    totalSize = [self totalSize:array withMin:SMALL_BAR_SIZE];
    if (totalSize == 0) { continue; }
    rand = arc4random() % totalSize;
    _lilBar2.place = [self locationInArray:array index:rand size:SMALL_BAR_SIZE];
    break;
  }
  
//  for (int i = 0; i < 100; i++) {
//    NSRange iRange = NSMakeRange(i, 1);
//    if (NSIntersectionRange(_bigBar.place, iRange).length > 0) {
//      printf("1");
//    }
//    else if (NSIntersectionRange(_lilBar1.place, iRange).length > 0) {
//      printf("2");
//    }
//    else if (NSIntersectionRange(_lilBar2.place, iRange).length > 0) {
//      printf("3");
//    }
//    else {
//      printf("0");
//    }
//  }
//  printf("\n");
  
  [array release];
}

+ (id) bar {
  return [[[self alloc] initBar] autorelease];
}

- (id) initBar {
  if ((self = [super initWithFile: @"comboBarBgd.png"])) {
    self.progressBar = [CCProgressTimer progressWithFile:@"comboBarProgress.png"];
    self.progressBar.type = kCCProgressTimerTypeHorizontalBarLR;
    self.progressBar.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    self.scale = 2;
    
    [self addChild:self.progressBar z:1];
    self.visible = NO;
    
    _bigBar = [[Notch spriteWithFile:@"comboBarProgress.png"] retain];
    _bigBar.scaleX = 0.2;
    [self addChild:_bigBar];
    _lilBar1 = [[Notch spriteWithFile:@"comboBarProgress.png"] retain];
    _lilBar1.scaleX = 0.1;
    [self addChild:_lilBar1];
    _lilBar2 = [[Notch spriteWithFile:@"comboBarProgress.png"] retain];
    _lilBar2.scaleX = 0.1;
    [self addChild:_lilBar2];
  }
  return self;
}

- (void) doComboSequence {
  self.progressBar.percentage = 0;
  self.visible = YES;
  [self randomizeNotches];
  [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:YES];
  [self.progressBar runAction:[CCSequence actions: 
                               [CCProgressTo actionWithDuration:2 percent:100],
                               [CCCallFunc actionWithTarget:self selector:@selector(finished)], nil]];
  _bigBar.color = ccBLUE;
  _lilBar1.color = ccBLUE;
  _lilBar2.color = ccBLUE;
}

- (void) finished {
  [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
  self.visible = NO;
  [self doComboSequence];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  NSRange iRange = NSMakeRange((int)self.progressBar.percentage, 1);
  if (NSIntersectionRange(_bigBar.place, iRange).length > 0) {
    NSLog(@"Hit Big");
    _bigBar.color = ccBLACK;
  }
  else if (NSIntersectionRange(_lilBar1.place, iRange).length > 0) {
    NSLog(@"Hit lil 1");
    _lilBar1.color = ccBLACK;
  }
  else if (NSIntersectionRange(_lilBar2.place, iRange).length > 0) {
    NSLog(@"hit lil 2");
    _lilBar2.color = ccBLACK;
  }
  else {
    NSLog(@"miss");
  }
  
  return YES;
}

- (void) dealloc {
  self.progressBar = nil;
  [_bigBar release];
  [_lilBar1 release];
  [_lilBar2 release];
  [super dealloc];
}

@end
