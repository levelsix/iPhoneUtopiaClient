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

@implementation NiceFontButton

- (void) awakeFromNib {
  [Globals adjustFontSizeForSize:self.titleLabel.font.pointSize withUIView:self];
  self.titleLabel.font = [UIFont fontWithName:[Globals font] size:self.titleLabel.font.pointSize];
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

@implementation NiceFontTextFieldDelegate
@synthesize otherDelegate;

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
  NiceFontTextField *nftf = (NiceFontTextField *)textField;
  [nftf.label setText:str];
  [nftf.label sizeToFit];
  
  if ([otherDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
    return [otherDelegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
  }
  return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
  if ([otherDelegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
    [otherDelegate textFieldDidEndEditing:textField];
  }
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
  if ([otherDelegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
    [otherDelegate textFieldDidBeginEditing:textField];
  }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
  if ([otherDelegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
    return [otherDelegate textFieldShouldReturn:textField];
  }
  return NO;
}

- (void) dealloc {
  self.otherDelegate = nil;
  [super dealloc];
}

@end

@implementation NiceFontTextField

@synthesize label, nfDelegate;

- (void) awakeFromNib {
  UIView *clipView = [[UIView alloc] initWithFrame:self.frame];
//  [self.superview insertSubview:clipView belowSubview:self];
  [clipView release];
  
  label = [[UILabel alloc] initWithFrame:self.bounds];
//  [clipView addSubview:label];
  
  self.font =  [UIFont fontWithName:[Globals font] size:self.font.pointSize];
  label.font = self.font;
  label.backgroundColor = [UIColor clearColor];
  [Globals adjustFontSizeForUILabel:label];
  label.textColor = self.textColor;
  self.textColor = [UIColor whiteColor];
  
  //Adjust frame a bit
  CGRect f = self.frame;
  f.origin.y += 3;
  self.frame = f;
  
  nfDelegate = [[NiceFontTextFieldDelegate alloc] init];
  nfDelegate.otherDelegate = self.delegate;
  self.delegate = nfDelegate;
}

- (void) setText:(NSString *)text {
  [super setText:text];
  label.text = self.text;
}

- (void) dealloc {
  self.label = nil;
  self.nfDelegate = nil;
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

@implementation CancellableTableView

- (BOOL) touchesShouldCancelInContentView:(UIView *)view {
  return YES;
}

@end