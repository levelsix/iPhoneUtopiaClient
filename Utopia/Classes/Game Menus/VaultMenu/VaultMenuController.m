//
//  VaultMenuController.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/17/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "VaultMenuController.h"
#import "SynthesizeSingleton.h"
#import "Globals.h"
#import "SBTickerView.h"
#import "GameState.h"
#import "OutgoingEventController.h"

#define BUTTON_FONT_SIZE 15

#define VIEW_JUMP_UPON_TEXT_FIELD 60
#define TICK_DURATION 0.3
#define TICK_DIVISOR 3
#define TICK_MIN_JUMP 30

@interface VaultTickView : UIView

@property (nonatomic, assign) int num;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, retain) UIImage *bgImage;

- (id) initWithImage:(UIImage *)image;

@end

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

@end

@implementation VaultMenuController

@synthesize depositButton, withdrawButton, transferField;

@synthesize tickers, tickerHolderView, vaultBalance, timer;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(VaultMenuController);

#pragma mark - View lifecycle

- (IBAction)closeClicked:(id)sender {
  [VaultMenuController removeView];
}

- (IBAction)depositClicked:(id)sender {
  [transferField resignFirstResponder];
  [[OutgoingEventController sharedOutgoingEventController] vaultDeposit:transferField.text.intValue];
}

- (IBAction)withdrawClicked:(id)sender {
  [transferField resignFirstResponder];
  [[OutgoingEventController sharedOutgoingEventController] vaultWithdrawal:transferField.text.intValue];
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
  depositButton.label.font = [depositButton.label.font fontWithSize:BUTTON_FONT_SIZE];
  
  UIColor *shadowColor = [UIColor darkGrayColor];
  depositButton.label.shadowColor = shadowColor;
  withdrawButton.label.shadowColor = shadowColor;
  
  NSMutableArray *m = [NSMutableArray array];
  UIImage *img = [UIImage imageNamed:@"numbertickerbg.png"];
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
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  vaultBalance = @"000000000";
  
  self.timer = [NSTimer timerWithTimeInterval:TICK_DURATION target:self selector:@selector(updateBalance) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void) viewDidDisappear:(BOOL)animated {
  [self.timer invalidate];
  [super viewDidDisappear:animated];
}

- (void) updateBalance {
  int num = [vaultBalance intValue];
  int realBalance = [[GameState sharedGameState] vaultBalance];
  
  // increment by atleast 1 every time
  if (realBalance != num) {
    int newVal = realBalance > num ? MAX(MIN(TICK_MIN_JUMP, realBalance - num), (realBalance - num)/TICK_DIVISOR) : MIN(MAX(-TICK_MIN_JUMP, realBalance - num), (realBalance - num)/TICK_DIVISOR);
    NSString *newStr = [NSString stringWithFormat:@"%09d", num + newVal];
    
    [tickers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      VaultTickView *back = (VaultTickView *)[(SBTickerView *)obj backView];
      VaultTickView *front = (VaultTickView *)[(SBTickerView *)obj frontView];
      int new = [[newStr substringWithRange:NSMakeRange(idx, 1)] intValue];
      if (new != front.num) {
        back.num = new;
        [obj tick:SBTickerViewTickDirectionDown animated:YES completion:^{NSLog(@"Done");}];
      }
    }];
    self.vaultBalance = newStr;
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [transferField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  [UIView animateWithDuration:0.3 animations:^{
    CGRect frame = self.view.frame;
    frame.origin.y -= VIEW_JUMP_UPON_TEXT_FIELD;
    self.view.frame = frame;
  }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  [UIView animateWithDuration:0.3 animations:^{
    CGRect frame = self.view.frame;
    frame.origin.y += VIEW_JUMP_UPON_TEXT_FIELD;
    self.view.frame = frame;
  }];
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
  if (str.length > 9) {
    return NO;
  }
  return YES;
}

- (void) dealloc {
  self.tickers = nil;
  [super dealloc];
}

@end
