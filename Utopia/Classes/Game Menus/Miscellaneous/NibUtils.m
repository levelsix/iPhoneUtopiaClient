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
#import "EquipMenuController.h"

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

@implementation NiceFontLabel6

- (void) awakeFromNib {
  self.font = [UIFont fontWithName:@"DINCond-Black" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel7

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"SanvitoPro-Semibold" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel8

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Archer-BoldItalic" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel9

- (void) awakeFromNib {
//  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"UnZialish" size:self.font.pointSize];
}

@end

@implementation NiceFontButton

- (void) awakeFromNib {
  [Globals adjustFontSizeForSize:self.titleLabel.font.pointSize withUIView:self];
  self.titleLabel.font = [UIFont fontWithName:[Globals font] size:self.titleLabel.font.pointSize];
}

@end

@implementation NiceFontButton2

- (void) awakeFromNib {
  [Globals adjustFontSizeForSize:self.titleLabel.font.pointSize withUIView:self];
  self.titleLabel.font = [UIFont fontWithName:@"Trajan Pro" size:self.titleLabel.font.pointSize];
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
  //  label.textColor = self.textColor;
  //  self.textColor = [UIColor whiteColor];
  
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

@implementation NiceFontTextView

- (void) awakeFromNib {
  self.font =  [UIFont fontWithName:[Globals font] size:self.font.pointSize];
}

@end

@implementation NiceFontTextView2

- (void) awakeFromNib {
  self.font = [UIFont fontWithName:@"SanvitoPro-Semibold" size:self.font.pointSize];
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

@implementation CancellableScrollView

- (BOOL) touchesShouldCancelInContentView:(UIView *)view {
  return YES;
}

@end

@implementation EquipButton

@synthesize equipId, darkOverlay;

- (void) awakeFromNib {
  self.userInteractionEnabled = YES;
  self.darkOverlay = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
  self.darkOverlay.contentMode = UIViewContentModeScaleAspectFit;
  
  self.level = 1;
  self.enhancePercent = 0;
  
  [self addSubview:darkOverlay];
}

- (void) setEquipId:(int)eq {
  equipId = eq;
  
  [Globals loadImageForEquip:equipId toView:self maskedView:nil];
  darkOverlay.hidden = YES;
  darkOverlay.image = nil;
}

- (void) equipClicked {
  if (equipId != 0) {
    [EquipMenuController displayViewForEquip:self.equipId level:self.level enhancePercent:self.enhancePercent];
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (!equipId) {
    return;
  }
  
  if (!darkOverlay.image && self.image) {
    darkOverlay.image = [Globals maskImage:self.image withColor:[UIColor colorWithWhite:0.f alpha:0.5f]];
  }
  
  self.darkOverlay.hidden = NO;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  if (!equipId) {
    return;
  }
  
  if (!darkOverlay.image && self.image) {
    darkOverlay.image = [Globals maskImage:self.image withColor:[UIColor colorWithWhite:0.f alpha:0.3f]];
  }
  
  UITouch *touch = [touches anyObject];
  CGPoint loc = [touch locationInView:touch.view];
  if ([self pointInside:loc withEvent:event]) {
    self.darkOverlay.hidden = NO;
  } else {
    self.darkOverlay.hidden = YES;
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (!equipId) {
    return;
  }
  
  self.darkOverlay.hidden = YES;
  
  UITouch *touch = [touches anyObject];
  CGPoint loc = [touch locationInView:touch.view];
  if ([self pointInside:loc withEvent:event]) {
    [self equipClicked];
  }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  self.darkOverlay.hidden = YES;
}

- (void) dealloc {
  self.darkOverlay = nil;
  [super dealloc];
}

@end

@implementation EquipLevelIcon

@synthesize level;

- (void) setLevel:(int)l {
  if (level != l) {
    level = l;
    
    Globals *gl = [Globals sharedGlobals];
    if (level > 0 && level <= gl.forgeMaxEquipLevel) {
      [Globals imageNamed:[NSString stringWithFormat:@"lvl%d.png", l] withView:self maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    } else {
      self.image = nil;
    }
  }
}

@end

@implementation EnhancementLevelIcon

@synthesize level;

- (void) setLevel:(int)l {
  if (level != l) {
    level = l;
    
    Globals *gl = [Globals sharedGlobals];
    if (level > 0 && level <= gl.maxEnhancementLevel) {
      [Globals imageNamed:[NSString stringWithFormat:@"enhancelvl%d.png", l] withView:self maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    } else {
      self.image = nil;
    }
  }
}

@end

@implementation ProgressBar

@synthesize percentage;

- (void) awakeFromNib {
  self.contentMode = UIViewContentModeLeft;
  self.clipsToBounds = YES;
}

- (void) setPercentage:(float)p {
  percentage = clampf(p, 0.f, 1.f);
  CGSize imgSize = self.image.size;
  
  CGRect rect = self.frame;
  rect.size.width = imgSize.width * percentage;
  self.frame = rect;
}

@end

@implementation LoadingView

@synthesize darkView, actIndView;

- (void) awakeFromNib {
  self.darkView.layer.cornerRadius = 10.f;
  self.darkView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
}

- (void) display:(UIView *)view {
  [self.actIndView startAnimating];
  
  [view addSubview:self];
  self.frame = view.bounds;
  _isDisplayingLoadingView = YES;
  
  self.alpha = 0.f;
  [UIView animateWithDuration:0.15f animations:^{
    self.alpha = 1.f;
  }];
}

- (void) stop {
  if (_isDisplayingLoadingView) {
    [UIView animateWithDuration:0.15f animations:^{
      self.alpha = 0.f;
    } completion:^(BOOL finished) {
      [self.actIndView stopAnimating];
      [self removeFromSuperview];
      _isDisplayingLoadingView = NO;
    }];
  }
}

- (void) dealloc {
  self.darkView = nil;
  self.actIndView = nil;
  
  [super dealloc];
}

@end

@implementation SwitchButton

@synthesize handle, darkHandle, isOn;

- (void) awakeFromNib {
  isOn = YES;
  
  darkHandle = [[UIImageView alloc] initWithFrame:handle.bounds];
  [handle addSubview:darkHandle];
  darkHandle.image = [Globals maskImage:handle.image withColor:[UIColor colorWithWhite:0.f alpha:0.2f]];
  darkHandle.hidden = YES;
  
  UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(turnOn)];
  swipe.direction = UISwipeGestureRecognizerDirectionRight;
  [self addGestureRecognizer:swipe];
  [swipe release];
  
  swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(turnOff)];
  swipe.direction = UISwipeGestureRecognizerDirectionLeft;
  [self addGestureRecognizer:swipe];
  [swipe release];
}

- (void) turnOn {
  self.isOn = YES;
  [self.delegate switchButtonWasTurnedOn:self];
}

- (void) turnOff {
  self.isOn = NO;
  [self.delegate switchButtonWasTurnedOff:self];
}

- (void) setIsOn:(BOOL)i {
  isOn = i;
  
  CGRect r = handle.frame;
  float oldX = r.origin.x;
  r.origin.x = isOn ? self.frame.size.width-r.size.width : 0;
  float dur = ABS(oldX-r.origin.x)/self.frame.size.width*0.3f;
  
  [handle.layer removeAllAnimations];
  [UIView animateWithDuration:dur delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
    handle.frame = r;
  } completion:nil];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:self];
  
  self.darkHandle.hidden = NO;
  _initialTouch = pt;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:self];
  
  CGRect r = handle.frame;
  float maxX = self.frame.size.width-r.size.width;
  float originalX = isOn ? maxX : 0;
  float diff = pt.x-_initialTouch.x;
  float newX = clampf(originalX+diff, 0.f, maxX);
  r.origin.x = newX;
  handle.frame = r;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:self];
  float dist = ccpDistance(pt, _initialTouch);
  
  self.darkHandle.hidden = YES;
  
  if (dist > 10.f) {
    if (handle.center.x < self.frame.size.width/2) {
      if (!self.isOn) {
        [self turnOn];
      } else {
        [self turnOff];
      }
    } else {
      if (self.isOn) {
        [self turnOff];
      } else {
        [self turnOn];
      }
    }
  } else {
    if (self.isOn) {
      [self turnOff];
    } else {
      [self turnOn];
    }
  }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  self.darkHandle.hidden = YES;
  self.isOn = isOn;
}

- (void) dealloc {
  self.handle = nil;
  self.darkHandle = nil;
  [super dealloc];
}

@end

@implementation AutoScrollingScrollView

#define AUTOSCROLLDUR 0.25f
#define AUTOSCROLLX 5

- (void) setMaxX:(float)maxX {
  _maxX = maxX;
  self.contentOffset = ccp(0,0);
  _movingLeft = NO;
  self.timer = [NSTimer scheduledTimerWithTimeInterval:AUTOSCROLLDUR-0.05f target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
}

- (void) setTimer:(NSTimer *)timer {
  if (_timer != timer) {
    [_timer invalidate];
    [_timer release];
    _timer = [timer retain];
  }
}

- (void) onTimer {
  if (self.contentOffset.x <= 0 && self.contentOffset.x+self.frame.size.width >= self.maxX-AUTOSCROLLX) {
    return;
  }
  
  float h = self.contentOffset.x+(_movingLeft ? -1 : 1)*AUTOSCROLLX;
  if (!_movingLeft && h+self.frame.size.width > self.maxX) {
    _movingLeft = YES;
  } else if (_movingLeft && h < 0) {
    _movingLeft = NO;
  }
  [UIView animateWithDuration:AUTOSCROLLDUR delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
    [self setContentOffset:CGPointMake(h, 0) animated:NO];
  } completion:nil];
}

@end