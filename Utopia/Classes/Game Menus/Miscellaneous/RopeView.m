//
//  RopeView.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/21/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "RopeView.h"

@implementation RopeView

static UIColor *ropeImage = nil;

- (UIColor *)ropeImage {
  if (!ropeImage) {
    ropeImage = [UIColor colorWithPatternImage:[UIImage imageNamed:@"marketrope.png"]];
  }
  return ropeImage;
}

- (void) awakeFromNib {
  self.backgroundColor = [self ropeImage];
}

@end
