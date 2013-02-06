//
//  BossEventMenuController.m
//  Utopia
//
//  Created by Ashwin Kamath on 9/30/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "BossEventMenuController.h"
#import "LNSynthesizeSingleton.h"
#import "GameState.h"
#import "Globals.h"
#import "Protocols.pb.h"
#import "OutgoingEventController.h"

@implementation BossEventTopBar

@synthesize button1, button2;

- (void) awakeFromNib {
  [self clickButton:kButton1];
  [self unclickButton:kButton2];
}

- (void) clickButton:(LeaderboardBarButton)button {
  switch (button) {
    case kButton1:
      button1.hidden = NO;
      _clickedButtons |= kButton1;
      break;
      
    case kButton2:
      button2.hidden = NO;
      _clickedButtons |= kButton2;
      break;
      
    default:
      break;
  }
}

- (void) unclickButton:(LeaderboardBarButton)button {
  switch (button) {
    case kButton1:
      button1.hidden = YES;
      _clickedButtons &= ~kButton1;
      break;
      
    case kButton2:
      button2.hidden = YES;
      _clickedButtons &= ~kButton2;
      break;
      
    default:
      break;
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:button1];
  if (!(_clickedButtons & kButton1) && [button1 pointInside:pt withEvent:nil]) {
    _trackingButton1 = YES;
    [self clickButton:kButton1];
  }
  
  pt = [touch locationInView:button2];
  if (!(_clickedButtons & kButton2) && [button2 pointInside:pt withEvent:nil]) {
    _trackingButton2 = YES;
    [self clickButton:kButton2];
  }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:button1];
  if (_trackingButton1) {
    if (CGRectContainsPoint(CGRectInset(button1.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton1];
    } else {
      [self unclickButton:kButton1];
    }
  }
  
  pt = [touch locationInView:button2];
  if (_trackingButton2) {
    if (CGRectContainsPoint(CGRectInset(button2.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton2];
    } else {
      [self unclickButton:kButton2];
    }
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:button1];
  if (_trackingButton1) {
    if (CGRectContainsPoint(CGRectInset(button1.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton1];
      [self unclickButton:kButton2];
      
      [[BossEventMenuController sharedBossEventMenuController] setState:kEventState];
    } else {
      [self unclickButton:kButton1];
    }
  }
  
  pt = [touch locationInView:button2];
  if (_trackingButton2) {
    if (CGRectContainsPoint(CGRectInset(button2.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton2];
      [self unclickButton:kButton1];
      
      [[BossEventMenuController sharedBossEventMenuController] setState:kInfoState];
    } else {
      [self unclickButton:kButton2];
    }
  }
  
  _trackingButton1 = NO;
  _trackingButton2 = NO;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self unclickButton:kButton1];
  [self unclickButton:kButton2];
  _trackingButton1 = NO;
  _trackingButton2 = NO;
}

- (void) dealloc {
  self.button2 = nil;
  self.button1 = nil;
  [super dealloc];
}

@end

@implementation BossEventCard

- (void) loadForEquipId:(int)equipId tagImage:(NSString *)tagImage {
  [Globals imageNamed:tagImage withImageView:self.tagIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:equipId];
  self.equipIcon.equipId = equipId;
  self.attackLabel.text = [Globals commafyNumber:[gl calculateAttackForEquip:equipId level:1 enhancePercent:0]];
  self.defenseLabel.text = [Globals commafyNumber:[gl calculateDefenseForEquip:equipId level:1 enhancePercent:0]];
  self.nameLabel.text = fep.name;
  self.nameLabel.textColor = [Globals colorForRarity:fep.rarity];
}

- (void) dealloc {
  self.equipIcon = nil;
  self.attackLabel = nil;
  self.defenseLabel = nil;
  self.nameLabel = nil;
  self.tagIcon = nil;
  [super dealloc];
}

@end

@implementation BossEventMenuController

@synthesize mainView, bgdView;
@synthesize timer;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(BossEventMenuController);

- (id) init {
  Globals *gl = [Globals sharedGlobals];
  return [self initWithNibName:@"BossEventMenuController" bundle:[Globals bundleNamed:gl.downloadableNibConstants.bossEventNibName]];
}

- (void) viewDidLoad {
  self.infoView.frame = self.eventView.frame;
  [self.mainView addSubview:self.infoView];
  
  self.state = kEventState;
}

- (void) viewWillAppear:(BOOL)animated {
  [self loadForCurrentEvent];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (void) viewDidDisappear:(BOOL)animated {
  self.timer = nil;
}

- (void) setTimer:(NSTimer *)t {
  if (timer != t) {
    [timer invalidate];
    [timer release];
    timer = [t retain];
  }
}

- (void) loadForCurrentEvent {
  GameState *gs = [GameState sharedGameState];
  BossEventProto *lbe = [[gs getCurrentBossEvent] retain];
  
  if (!lbe) {
    [self closeClicked:nil];
    self.timer = nil;
    return;
  }
  
  [self updateLabels];
  self.timer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
  
  [self.leftCard loadForEquipId:lbe.leftEquip.equipId tagImage:lbe.leftTagImage];
  [self.middleCard loadForEquipId:lbe.middleEquip.equipId tagImage:lbe.middleTagImage];
  [self.rightCard loadForEquipId:lbe.rightEquip.equipId tagImage:lbe.rightTagImage];
  
  [Globals imageNamed:lbe.headerImage withImageView:self.headerImageView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  self.infoLabel.text = lbe.infoDescription;
  
  [lbe release];
}

- (void) updateLabels {
  GameState *gs = [GameState sharedGameState];
  BossEventProto *lbe = [gs getCurrentBossEvent];
  
  if (!lbe) {
    [self loadForCurrentEvent];
    return;
  }
  
  NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:lbe.endDate/1000.0];
  int secs = endDate.timeIntervalSinceNow;
  int days = (int)(secs/86400);
  secs %= 86400;
  int hrs = (int)(secs/3600);
  secs %= 3600;
  int mins = (int)(secs/60);
  secs %= 60;
  NSString *daysString = days ? [NSString stringWithFormat:@"%dD, ", days] : @"";
  NSString *hrsString = days || hrs ? [NSString stringWithFormat:@"%dH, ", hrs] : @"";
  NSString *minsString = days || hrs || mins ? [NSString stringWithFormat:@"%dM, ", mins] : @"";
  NSString *secsString = [NSString stringWithFormat:@"%dS", secs];
  NSString *time = [NSString stringWithFormat:@"%@%@%@%@", daysString, hrsString, minsString, secsString];
  self.eventTimeLabel.text = [NSString stringWithFormat:lbe.eventName, time];
}

- (void) setState:(BossEventState)state {
  if (_state != state) {
    _state = state;
    
    if (_state == kEventState) {
      self.infoView.hidden = YES;
      self.eventView.hidden = NO;
    } else if (_state == kInfoState) {
      self.infoView.hidden = NO;
      self.eventView.hidden = YES;
    }
  }
}

- (IBAction)closeClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
  }];
}

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  if (self.isViewLoaded && !self.view.superview) {
    self.view = nil;
    self.eventTimeLabel = nil;
    self.mainView = nil;
    self.bgdView = nil;
    self.timer = nil;
    self.leftCard = nil;
    self.middleCard = nil;
    self.rightCard = nil;
    self.headerImageView = nil;
    self.infoLabel = nil;
    self.infoView = nil;
    self.eventView = nil;
  }
}

@end
