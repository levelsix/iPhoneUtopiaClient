//
//  LabelButton.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/11/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "LabelButton.h"
#import "Globals.h"

@implementation NiceFontLabel

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
}

@end

@implementation LabelButton

@synthesize label = _label;
@synthesize text = _text;

- (void) awakeFromNib {
  [super awakeFromNib];
  _label = [[UILabel alloc] initWithFrame:self.bounds];
  _label.backgroundColor = [UIColor clearColor];
  _label.textAlignment = UITextAlignmentCenter;
  _label.textColor = [UIColor colorWithRed:235/255.f green:235/255.f blue:200/255.f alpha:1];
  _label.adjustsFontSizeToFitWidth = NO;
  [self addSubview:_label];
  [Globals adjustFontSizeForUIViewWithDefaultSize:_label];
  
  if (_text) {
    _label.text = _text;
  }
}

- (void) setText:(NSString *)text {
  _text = text;
  _label.text = text;
}

- (void) dealloc {
  self.label = nil;
}

@end

@implementation NiceFontTextField

@synthesize label;

- (void) awakeFromNib {
  label = [[UILabel alloc] initWithFrame:self.frame];
  [self.superview insertSubview:label belowSubview:self];
  self.font =  [UIFont fontWithName:[Globals font] size:self.font.pointSize];
  label.font = self.font;
  label.backgroundColor = [UIColor clearColor];
  [Globals adjustFontSizeForUILabel:label];
  self.textColor = [UIColor clearColor];
  label.textColor = [UIColor colorWithRed:65/255.f green:65/255.f blue:65/255.f alpha:1.f];
  
  //Adjust frame a bit
  CGRect f = self.frame;
  f.origin.y += 2;
  self.frame = f;
}

- (void) setText:(NSString *)text {
  [super setText:text];
  label.text = self.text;
}

- (void) dealloc {
  self.label = nil;
  [super dealloc];
}

@end