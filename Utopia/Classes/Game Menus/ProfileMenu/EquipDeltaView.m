//
//  EquipDeltaView.m
//  Utopia
//
//  Created by Kevin Calloway on 6/7/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "EquipDeltaView.h"
#import "Globals.h"

static NSString *viewName = @"EquipDeltaView";

@implementation EquipDeltaView
@synthesize mainView;
@synthesize lowerLabel;
@synthesize upperLabel;


- (id)initWithCenter:(CGPoint)center
     andUpperString:(NSString *)upper 
     andLowerString:(NSString *)lower
{
  self = [super init];  
  if (self) {
    [[NSBundle mainBundle] loadNibNamed:viewName owner:self options:nil];
    upperLabel.text = upper;
    lowerLabel.text = lower;
    CGRect frame  = self.frame;
    frame.size   = mainView.frame.size;
    
    CGPoint newOrigin;
    newOrigin.x = center.x - frame.size.width/2;
    newOrigin.y = center.y - frame.size.height/2;
    frame.origin = newOrigin;
    
    [self setFrame:frame];
    [self addSubview:mainView];
  }
  return self;
}

+ (UIView *) createForUpperString:(NSString *)upper andLowerString:(NSString *)lower andCenter:(CGPoint)curCenter topColor:(UIColor *)topColor botColor:(UIColor *)botColor
{
  EquipDeltaView *newView = [[EquipDeltaView alloc] initWithCenter:curCenter 
                                                   andUpperString:upper 
                                                   andLowerString:lower];

  newView.upperLabel.textColor = topColor;
  newView.lowerLabel.textColor = botColor;
  [newView autorelease];
  return newView;
}

@end
