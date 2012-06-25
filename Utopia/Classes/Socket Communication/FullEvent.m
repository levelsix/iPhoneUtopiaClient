//
//  FullEvent.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/22/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "FullEvent.h"

@implementation FullEvent

@synthesize event;
@synthesize tag;

+ (id) createWithEvent:(PBGeneratedMessage *)e tag:(int)t {
  return [[[self alloc] initWithEvent:e tag:t] autorelease];
}

- (id) initWithEvent:(PBGeneratedMessage *)e tag:(int)t {
  if ((self = [super init])) {
    self.event = e;
    self.tag = t;
  }
return self;
}

- (void) dealloc {
  self.event = nil;
  [super dealloc];
}

@end
