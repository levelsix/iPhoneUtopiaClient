//
//  LabelButton.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/11/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "NibUtils.h"
#import "Globals.h"
#import "GameState.h"

@implementation NiceFontLabel

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
}

@end

@implementation NiceFontLabel2

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Archer" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel3

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Trajan Pro" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel4

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"AJensonPro-SemiboldDisp" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel5

- (void) awakeFromNib {
  self.font = [UIFont fontWithName:@"Requiem Text-HTF-SmallCaps" size:self.font.pointSize];
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
  _label.shadowColor = [UIColor colorWithWhite:0.f alpha:0.3f];
  _label.shadowOffset = CGSizeMake(0, 1.f);
  _label.adjustsFontSizeToFitWidth = NO;
  _label.highlightedTextColor = [_label.textColor colorWithAlphaComponent:0.5f];
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

- (void) setEnabled:(BOOL)enabled {
  [super setEnabled:enabled];
  if (enabled) {
    _label.highlighted = NO;
  } else {
    _label.highlighted = YES;
  }
}

- (void) dealloc {
  self.label = nil;
  [super dealloc];
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
  label.lineBreakMode = UILineBreakModeHeadTruncation;
  
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

@implementation FlipImageView

- (void) awakeFromNib {
  self.transform = CGAffineTransformMakeScale(-1, 1);
}

@end

@implementation FlipButton

- (void) awakeFromNib {
  self.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
}

@end

@implementation ServerImageView

@synthesize path, highlightedPath;

- (void) awakeFromNib {
  if (path) {
    self.image = [Globals imageNamed:path];
  }
  if (highlightedPath) {
    self.highlightedImage = [Globals imageNamed:highlightedPath];
  }
}

- (void) dealloc {
  self.path = nil;
  self.highlightedPath = nil;
  [super dealloc];
}

@end

@implementation ServerButton

@synthesize path;

- (void) awakeFromNib {
  [self setImage:[Globals imageNamed:path] forState:UIControlStateNormal] ;
}

- (void) dealloc {
  self.path = nil;
  [super dealloc];
}

@end

@implementation RopeView

- (void) awakeFromNib {
  self.backgroundColor = [UIColor colorWithPatternImage:[Globals imageNamed:@"rope.png"]];
}

@end

@implementation TutorialGirlImageView

- (void) awakeFromNib {
  GameState *gs = [GameState sharedGameState];
  self.contentMode = UIViewContentModeScaleToFill;
  NSString *imageName = [Globals userTypeIsGood:gs.type] ? @"goodgirltall.png" : @"badgirltall.png";
  self.image = [Globals imageNamed:imageName];
}

@end