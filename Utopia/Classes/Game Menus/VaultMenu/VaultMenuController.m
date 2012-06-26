//
//  VaultMenuController.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/17/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "VaultMenuController.h"
#import "LNSynthesizeSingleton.h"
#import "Globals.h"
#import "SBTickerView.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "SoundEngine.h"

#define BUTTON_FONT_SIZE 14

#define VIEW_JUMP_UPON_TEXT_FIELD 60
#define TICK_DURATION 0.2
#define TICK_DIVISOR 3
#define TICK_MIN_JUMP 30

@implementation VaultTickView

@synthesize num, bgImage, font;

- (id) initWithImage:(UIImage *)image {
  if ((self = [super initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)])) {
    self.backgroundColor = [UIColor clearColor];
    self.bgImage = image;
    self.font = [UIFont fontWithName:[Globals font] size:[Globals fontSize]];
  }
  return self;
}

- (void) drawRect:(CGRect)rect {
  [bgImage drawInRect:self.bounds];
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGContextSetRGBStrokeColor(context, 231/255.f, 223/255.f, 198/255.f, 1.f);
  CGRect f = self.bounds;
  CGContextMoveToPoint(context, CGRectGetMinX(f), CGRectGetMidY(f)+0.5);
  CGContextAddLineToPoint(context, CGRectGetMaxX(f), CGRectGetMidY(f)+0.5);
  CGContextSetLineWidth(context, 0.5f);
  CGContextSetAllowsAntialiasing(context, false);
  CGContextStrokePath(context);
  
  CGContextSetAllowsAntialiasing(context, true);
  CGContextSetRGBFillColor(context, 65/255.f, 65/255.f, 65/255.f, 1.0);
  NSString *str = [NSString stringWithFormat:@"%d", num];
  [str drawInRect:CGRectMake(0, 4, self.bounds.size.width, self.bounds.size.height-4) withFont:font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
}

- (void) setNum:(int)n {
  if (num != n) {
    num = n;
    [self setNeedsDisplay];
  }
}

- (void) dealloc {
  self.bgImage = nil;
  self.font = nil;
  [super dealloc];
}

@end

@implementation VaultMenuController

@synthesize depositButton, withdrawButton, transferField, bottomLabel;
@synthesize mainView, bgdView;
@synthesize tickers, tickerHolderView, vaultBalance;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(VaultMenuController);

#pragma mark - View lifecycle

- (IBAction)closeClicked:(id)sender {
  [self close];
}

- (void) close {
  if (self.view.superview) {
    [transferField resignFirstResponder];
    
    [[SoundEngine sharedSoundEngine] vaultLeave];
    
    [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
      [VaultMenuController removeView];       
    }];
  }
}

- (IBAction)depositClicked:(id)sender {
  [transferField resignFirstResponder];
  GameState *gs = [GameState sharedGameState];
  int amount = transferField.text.intValue;
  if (amount > gs.silver) {
    [Globals popupMessage:[NSString stringWithFormat: @"You don't have %d silver on hand! Please try again.", amount]];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] vaultDeposit:amount];
    [self updateBalance];
    
    [[SoundEngine sharedSoundEngine] vaultDeposit];
  }
  transferField.text = @"0";
  
  [Analytics vaultDeposit];
}

- (IBAction)withdrawClicked:(id)sender {
  [transferField resignFirstResponder];
  GameState *gs = [GameState sharedGameState];
  int amount = transferField.text.intValue;
  if (amount > gs.vaultBalance) {
    [Globals popupMessage:[NSString stringWithFormat: @"You don't have %d silver in the vault! Please try again.", amount]];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] vaultWithdrawal:amount];
    [self updateBalance];
    
    [[SoundEngine sharedSoundEngine] vaultWithdraw];
  }
  transferField.text = @"0";
  
  [Analytics vaultWithdraw];
}

- (IBAction)clearClicked:(id)sender {
  transferField.text = @"";
  [transferField becomeFirstResponder];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  depositButton.text = @"Deposit";
  withdrawButton.text = @"Withdraw";
  depositButton.label.font = [depositButton.label.font fontWithSize:BUTTON_FONT_SIZE];
  withdrawButton.label.font = [withdrawButton.label.font fontWithSize:BUTTON_FONT_SIZE];
  
  UIColor *shadowColor = [UIColor darkGrayColor];
  depositButton.label.shadowColor = shadowColor;
  withdrawButton.label.shadowColor = shadowColor;
  
  NSMutableArray *m = [NSMutableArray array];
  UIImage *img = [Globals imageNamed:@"numbertickerbg.png"];
  for (int i = 0; i < 9; i++) {
    CGRect r = CGRectZero;
    r.size = img.size;
    r.origin.x = i*img.size.width + 2*i + 10*(i/3);
    SBTickerView *tv = [[SBTickerView alloc] initWithFrame:r];
    [tv setBackgroundColor:[UIColor clearColor]];
    [tv setFrontView:[[[VaultTickView alloc] initWithImage:img] autorelease]];
    [tv setBackView:[[[VaultTickView alloc] initWithImage:img] autorelease]];
    tv.duration = TICK_DURATION;
    [tickerHolderView addSubview:tv];
    [m addObject:tv];
    [tv release];
  }
  self.tickers = m;
  
  self.bottomLabel.text = [NSString stringWithFormat:@"Bank Notice: There is a %d%% fee on deposits.", (int)([[Globals sharedGlobals] cutOfVaultDepositTaken]*100)];
}

- (void) viewDidUnload {
  [super viewDidUnload];
  self.depositButton = nil;
  self.withdrawButton = nil;
  self.transferField = nil;
  self.bottomLabel = nil;
  self.mainView = nil;
  self.bgdView = nil;
  self.tickers = nil;
  self.tickerHolderView = nil;
  self.vaultBalance = nil;
}

- (void) viewWillAppear:(BOOL)animated {
  vaultBalance = @"000000000";
  [tickers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    ((VaultTickView *)[(SBTickerView *)obj frontView]).num = 0;
  }];
  transferField.text = [NSString stringWithFormat:@"%d", [[GameState sharedGameState] silver]];
  
  [self performSelector:@selector(updateBalance) withObject:nil afterDelay:0.5];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  [[SoundEngine sharedSoundEngine] vaultEnter];
  
  [Analytics vaultOpen];
}

- (int) firstDifference: (NSString *)firstStr second:(NSString *)secondStr {
  for (int i = 0; i < firstStr.length; i++) {
    if ([firstStr characterAtIndex:i] != [secondStr characterAtIndex:i]) {
      return i;
    }
  }
  return firstStr.length;
}

- (void) updateBalance {
  int num = [vaultBalance intValue];
  int realBalance = [[GameState sharedGameState] vaultBalance];
  
  NSString *newStr = [NSString stringWithFormat:@"%09d", realBalance];
  _index = [self firstDifference:vaultBalance second:newStr];
  self.vaultBalance = newStr;
  if (!_animating && realBalance != num) {
    _animating = YES;
    [self animateNextNum];
  }
}

- (void) animateNextNum {
  _numTicksComplete = 0;
  if (_index < vaultBalance.length) {
    [tickers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      if (idx >= _index) {
        VaultTickView *back = (VaultTickView *)[(SBTickerView *)obj backView];
        int realVal = -1;
        if (idx == _index) {
          // Put in real value
          realVal = [[vaultBalance substringWithRange:NSMakeRange(idx, 1)] intValue];
          back.num = realVal;
        } else if (idx == _index+1) {
          // If it is the next index, put in a random value less than the real one
          realVal = [[vaultBalance substringWithRange:NSMakeRange(idx, 1)] intValue];
          if (realVal == 0) {
            // Anything but 0
            back.num = 1+(arc4random() % 9);
          } else {
            back.num = arc4random() % realVal;
          }
        } else {
          back.num = arc4random() % 10;
        }
        [obj tick:SBTickerViewTickDirectionDown animated:YES completion:^{
          _numTicksComplete++;
          if (_numTicksComplete >= 9) {
            _index++;
            [self animateNextNum];
          }
        }];
      } else {
        _numTicksComplete++;
      }
    }];
  } else {
    _animating = NO;
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [transferField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  [UIView animateWithDuration:0.25 delay:0.f options:UIViewAnimationCurveEaseInOut animations:^{
    CGRect frame = mainView.frame;
    frame.origin.y -= VIEW_JUMP_UPON_TEXT_FIELD;
    frame.size.height += VIEW_JUMP_UPON_TEXT_FIELD;
    mainView.frame = frame;
  } completion:nil];
  
  if ([textField.text isEqualToString:@"0"]) {
    textField.text = @"";
  }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  [UIView animateWithDuration:0.25 delay:0.f options:UIViewAnimationCurveEaseInOut animations:^{
    CGRect frame = mainView.frame;
    frame.origin.y += VIEW_JUMP_UPON_TEXT_FIELD;
    frame.size.height -= VIEW_JUMP_UPON_TEXT_FIELD;
    mainView.frame = frame;
  } completion:nil];
  
  if ([textField.text isEqualToString:@""]) {
    textField.text = @"0";
  }
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
  if (str.length > 9) {
    return NO;
  }
  [[(NiceFontTextField *)textField label] setText:str];
  return YES;
}

- (void) dealloc {
  self.tickers = nil;
  [super dealloc];
}

@end
