//
//  ClanMenuController.m
//  Utopia
//
//  Created by Ashwin Kamath on 9/10/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ClanMenuController.h"
#import "GameState.h"
#import "Globals.h"
#import "LNSynthesizeSingleton.h"
#import "GoldShoppeViewController.h"
#import "OutgoingEventController.h"
#import "RefillMenuController.h"
#import "GenericPopupController.h"

@implementation UIView (WakeupAndCleanup)

- (void) wakeup {
  for (UIView *v in self.subviews) {
    [v wakeup];
  }
}

- (void) cleanup {
  for (UIView *v in self.subviews) {
    [v cleanup];
  }
}

@end

@implementation ClanTopBar

@synthesize button1, button2, button3;
@synthesize button1Label, button2Label, button3Label;
@synthesize buttonBgd1, buttonBgd2, buttonBgd3;

- (void) awakeFromNib {
  [self clickButton:kButton1];
  [self unclickButton:kButton2];
  [self unclickButton:kButton3];
  
  [self loadTwoButtonConfiguration];
  //  [self performSelector:@selector(loadThreeButtonConfiguration) withObject:nil afterDelay:10];
}

- (void) loadTwoButtonConfiguration {
  UIView *v = nil;
  CGRect r = CGRectZero;
  
  v = button1;
  r = v.frame;
  r.origin.x = self.frame.size.width/2-r.size.width;
  v.frame = r;
  
  v = buttonBgd1;
  r = v.frame;
  r.origin.x = self.frame.size.width/2-r.size.width;
  v.frame = r;
  
  v = button3;
  r = v.frame;
  r.origin.x = CGRectGetMaxX(button1.frame)-1.f;
  v.frame = r;
  
  v = buttonBgd3;
  r = v.frame;
  r.origin.x = CGRectGetMaxX(button3.frame)-r.size.width;
  v.frame = r;
  
  button1Label.center = CGPointMake(buttonBgd1.center.x, button1Label.center.y);
  button3Label.center = CGPointMake(buttonBgd3.center.x, button3Label.center.y);
  buttonBgd2.hidden = YES;
  button2Label.hidden = YES;
  
  [self clickButton:kButton1];
  [self unclickButton:kButton2];
  [self unclickButton:kButton3];
}

- (void) loadThreeButtonConfiguration {
  UIView *v = nil;
  CGRect r = CGRectZero;
  
  v = button1;
  r = v.frame;
  r.origin.x = 0;
  v.frame = r;
  
  v = buttonBgd1;
  r = v.frame;
  r.origin.x = 0;
  v.frame = r;
  
  v = button3;
  r = v.frame;
  r.origin.x = self.frame.size.width-v.frame.size.width;
  v.frame = r;
  
  v = buttonBgd3;
  r = v.frame;
  r.origin.x = self.frame.size.width-v.frame.size.width;
  v.frame = r;
  
  button1Label.center = CGPointMake(buttonBgd1.center.x, button1Label.center.y);
  button3Label.center = CGPointMake(buttonBgd3.center.x, button3Label.center.y);
  buttonBgd2.hidden = NO;
  button2Label.hidden = NO;
  
  [self clickButton:kButton1];
  [self unclickButton:kButton2];
  [self unclickButton:kButton3];
}

- (void) loadMyClanConfiguration {
  [self loadThreeButtonConfiguration];
  button1Label.text = @"board";
  button2Label.text = @"clan info";
  button3Label.text = @"members";
}

- (void) loadBrowseClanConfiguration {
  [self loadThreeButtonConfiguration];
  button1Label.text = @"alliance";
  button2Label.text = @"legion";
  button3Label.text = @"search";
  
  GameState *gs = [GameState sharedGameState];
  if ([Globals userTypeIsBad:gs.type]) {
    [self unclickButton:kButton1];
    [self clickButton:kButton2];
  }
}

- (void) loadViewClanConfiguration {
  [self loadTwoButtonConfiguration];
  button1Label.text = @"clan info";
  button3Label.text = @"members";
}

- (void) clickButton:(ClanBarButton)button {
  switch (button) {
    case kButton1:
      button1Label.highlighted = YES;
      button1.hidden = NO;
      _clickedButtons |= kButton1;
      break;
      
    case kButton2:
      button2Label.highlighted = YES;
      button2.hidden = NO;
      _clickedButtons |= kButton2;
      break;
      
    case kButton3:
      button3Label.highlighted = YES;
      button3.hidden = NO;
      _clickedButtons |= kButton3;
      break;
      
    default:
      break;
  }
}

- (void) unclickButton:(ClanBarButton)button {
  switch (button) {
    case kButton1:
      button1Label.highlighted = NO;
      button1.hidden = YES;
      _clickedButtons &= ~kButton1;
      break;
      
    case kButton2:
      button2Label.highlighted = NO;
      button2.hidden = YES;
      _clickedButtons &= ~kButton2;
      break;
      
    case kButton3:
      button3Label.highlighted = NO;
      button3.hidden = YES;
      _clickedButtons &= ~kButton3;
      
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
  if (!buttonBgd2.hidden && !(_clickedButtons & kButton2) && [button2 pointInside:pt withEvent:nil]) {
    _trackingButton2 = YES;
    [self clickButton:kButton2];
  }
  
  pt = [touch locationInView:button3];
  if (!(_clickedButtons & kButton3) && [button3 pointInside:pt withEvent:nil]) {
    _trackingButton3 = YES;
    [self clickButton:kButton3];
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
  
  pt = [touch locationInView:button3];
  if (_trackingButton3) {
    if (CGRectContainsPoint(CGRectInset(button3.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton3];
    } else {
      [self unclickButton:kButton3];
    }
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:button1];
  if (_trackingButton1) {
    if (CGRectContainsPoint(CGRectInset(button1.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton1];
      [self unclickButton:kButton3];
      [self unclickButton:kButton2];
      
      [[ClanMenuController sharedClanMenuController] topBarButtonClicked:kButton1];
    } else {
      [self unclickButton:kButton1];
    }
  }
  
  pt = [touch locationInView:button2];
  if (_trackingButton2) {
    if (CGRectContainsPoint(CGRectInset(button2.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton2];
      [self unclickButton:kButton3];
      [self unclickButton:kButton1];
      
      [[ClanMenuController sharedClanMenuController] topBarButtonClicked:kButton2];
    } else {
      [self unclickButton:kButton2];
    }
  }
  
  pt = [touch locationInView:button3];
  if (_trackingButton3) {
    if (CGRectContainsPoint(CGRectInset(button3.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton3];
      [self unclickButton:kButton1];
      [self unclickButton:kButton2];
      
      [[ClanMenuController sharedClanMenuController] topBarButtonClicked:kButton3];
    } else {
      [self unclickButton:kButton3];
    }
  }
  
  _trackingButton1 = NO;
  _trackingButton3 = NO;
  _trackingButton2 = NO;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_trackingButton1) [self unclickButton:kButton1];
  if (_trackingButton2) [self unclickButton:kButton2];
  if (_trackingButton3) [self unclickButton:kButton3];
  _trackingButton1 = NO;
  _trackingButton3 = NO;
  _trackingButton2 = NO;
}

- (void) dealloc {
  self.button3Label = nil;
  self.button2Label = nil;
  self.button1Label = nil;
  self.button3 = nil;
  self.button2 = nil;
  self.button1 = nil;
  self.buttonBgd1 = nil;
  self.buttonBgd2 = nil;
  self.buttonBgd3 = nil;
  [super dealloc];
}

@end

@implementation ClanBar

@synthesize button1, button2, button3, button4;
@synthesize button1Label, button2Label, button3Label, button4Label;
@synthesize button1Icon, button2Icon, button3Icon, button4Icon;

- (void) awakeFromNib {
  [self clickButton:kButton1];
  [self unclickButton:kButton2];
  [self unclickButton:kButton3];
  [self unclickButton:kButton4];
}

- (void) loadButtonsForClanState:(ClanState)state {
  [self unclickButton:kButton1];
  [self unclickButton:kButton2];
  [self unclickButton:kButton3];
  [self unclickButton:kButton4];
  
  switch (state) {
    case kMyClan:
      [self clickButton:kButton1];
      break;
    case kBrowseClans:
      [self clickButton:kButton2];
      break;
    case kAboutClans:
      [self clickButton:kButton3];
      break;
    case kCreateClan:
      [self clickButton:kButton4];
      break;
    default:
      break;
  }
}

- (void) clickButton:(ClanBarButton)button {
  switch (button) {
    case kButton1:
      button1Label.highlighted = YES;
      button1.hidden = NO;
      button1Icon.highlighted = YES;
      _clickedButtons |= kButton1;
      break;
      
    case kButton2:
      button2Label.highlighted = YES;
      button2.hidden = NO;
      button2Icon.highlighted = YES;
      _clickedButtons |= kButton2;
      break;
      
    case kButton3:
      button3Label.highlighted = YES;
      button3.hidden = NO;
      button3Icon.highlighted = YES;
      _clickedButtons |= kButton3;
      break;
      
    case kButton4:
      button4Label.highlighted = YES;
      button4.hidden = NO;
      button4Icon.highlighted = YES;
      _clickedButtons |= kButton4;
      break;
      
    default:
      break;
  }
}

- (void) unclickButton:(ClanBarButton)button {
  switch (button) {
    case kButton1:
      button1Label.highlighted = NO;
      button1.hidden = YES;
      button1Icon.highlighted = NO;
      _clickedButtons &= ~kButton1;
      break;
      
    case kButton2:
      button2Label.highlighted = NO;
      button2.hidden = YES;
      button2Icon.highlighted = NO;
      _clickedButtons &= ~kButton2;
      break;
      
    case kButton3:
      button3Label.highlighted = NO;
      button3.hidden = YES;
      button3Icon.highlighted = NO;
      _clickedButtons &= ~kButton3;
      break;
      
    case kButton4:
      button4Label.highlighted = NO;
      button4.hidden = YES;
      button4Icon.highlighted = NO;
      _clickedButtons &= ~kButton4;
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
  
  pt = [touch locationInView:button3];
  if (!(_clickedButtons & kButton3) && [button3 pointInside:pt withEvent:nil]) {
    _trackingButton3 = YES;
    [self clickButton:kButton3];
  }
  
  pt = [touch locationInView:button2];
  if (!(_clickedButtons & kButton2) && [button2 pointInside:pt withEvent:nil]) {
    _trackingButton2 = YES;
    [self clickButton:kButton2];
  }
  
  pt = [touch locationInView:button4];
  if (!(_clickedButtons & kButton4) && [button4 pointInside:pt withEvent:nil]) {
    _trackingButton4 = YES;
    [self clickButton:kButton4];
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
  
  pt = [touch locationInView:button3];
  if (_trackingButton3) {
    if (CGRectContainsPoint(CGRectInset(button3.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton3];
    } else {
      [self unclickButton:kButton3];
    }
  }
  
  pt = [touch locationInView:button4];
  if (_trackingButton4) {
    if (CGRectContainsPoint(CGRectInset(button4.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton4];
    } else {
      [self unclickButton:kButton4];
    }
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:button1];
  if (_trackingButton1) {
    if (CGRectContainsPoint(CGRectInset(button1.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton1];
      [self unclickButton:kButton3];
      [self unclickButton:kButton2];
      [self unclickButton:kButton4];
      
      [[ClanMenuController sharedClanMenuController] setState:kMyClan];
    } else {
      [self unclickButton:kButton1];
    }
  }
  
  pt = [touch locationInView:button2];
  if (_trackingButton2) {
    if (CGRectContainsPoint(CGRectInset(button2.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton2];
      [self unclickButton:kButton3];
      [self unclickButton:kButton1];
      [self unclickButton:kButton4];
      
      [[ClanMenuController sharedClanMenuController] setState:kBrowseClans];
    } else {
      [self unclickButton:kButton2];
    }
  }
  
  pt = [touch locationInView:button3];
  if (_trackingButton3) {
    if (CGRectContainsPoint(CGRectInset(button3.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton3];
      [self unclickButton:kButton1];
      [self unclickButton:kButton2];
      [self unclickButton:kButton4];
      
      [[ClanMenuController sharedClanMenuController] setState:kAboutClans];
    } else {
      [self unclickButton:kButton3];
    }
  }
  
  pt = [touch locationInView:button4];
  if (_trackingButton4) {
    if (CGRectContainsPoint(CGRectInset(button4.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton4];
      [self unclickButton:kButton3];
      [self unclickButton:kButton2];
      [self unclickButton:kButton1];
      
      [[ClanMenuController sharedClanMenuController] setState:kCreateClan];
    } else {
      [self unclickButton:kButton4];
    }
  }
  
  _trackingButton1 = NO;
  _trackingButton3 = NO;
  _trackingButton2 = NO;
  _trackingButton4 = NO;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_trackingButton1) [self unclickButton:kButton1];
  if (_trackingButton2) [self unclickButton:kButton3];
  if (_trackingButton3) [self unclickButton:kButton2];
  if (_trackingButton4) [self unclickButton:kButton4];
  _trackingButton1 = NO;
  _trackingButton3 = NO;
  _trackingButton2 = NO;
  _trackingButton4 = NO;
}

- (void) dealloc {
  self.button3Label = nil;
  self.button2Label = nil;
  self.button1Label = nil;
  self.button4Label = nil;
  self.button3 = nil;
  self.button2 = nil;
  self.button1 = nil;
  self.button4 = nil;
  self.button1Icon = nil;
  self.button2Icon = nil;
  self.button3Icon = nil;
  self.button4Icon = nil;
  [super dealloc];
}

@end

@implementation ClanMenuController

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(ClanMenuController);

@synthesize clanBar, goldLabel;
@synthesize loadingView;
@synthesize state;
@synthesize containerView;
@synthesize clanCreateView;
@synthesize membersView;
@synthesize clanInfoView;
@synthesize clanBrowseView;
@synthesize clanBoardView;
@synthesize clanAboutView;
@synthesize goldView, editView, backView;
@synthesize titleLabel, topBar;
@synthesize editLabel, backLabel;
@synthesize myClan;
@synthesize myClanMembers;
@synthesize secondTopBar;

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  self.editView.frame = goldView.frame;
  [self.view addSubview:self.editView];
  
  self.backView.frame = goldView.frame;
  [self.view addSubview:self.backView];
  
  self.membersView.frame = self.clanCreateView.frame;
  [self.containerView addSubview:self.membersView];
  
  self.clanInfoView.frame = self.clanCreateView.frame;
  [self.containerView addSubview:self.clanInfoView];
  
  self.clanBrowseView.frame = self.clanCreateView.frame;
  [self.containerView addSubview:self.clanBrowseView];
  
  self.clanBoardView.frame = self.clanCreateView.frame;
  [self.containerView addSubview:self.clanBoardView];
  
  self.clanAboutView.frame = self.clanCreateView.frame;
  [self.containerView addSubview:self.clanAboutView];
  
  self.secondTopBar.frame = self.topBar.frame;
  [self.topBar.superview addSubview:self.secondTopBar];
  self.secondTopBar.alpha = 0.f;
}

- (void) viewWillAppear:(BOOL)animated {
  [self updateGoldLabel];
  
  [[OutgoingEventController sharedOutgoingEventController] retrieveClanInfo:nil clanId:0 grabType:RetrieveClanInfoRequestProto_ClanInfoGrabTypeClanInfo isForBrowsingList:YES beforeClanId:0];
  
  GameState *gs = [GameState sharedGameState];
  if (gs.clan) {
    [[OutgoingEventController sharedOutgoingEventController] retrieveClanInfo:nil clanId:gs.clan.clanId grabType:RetrieveClanInfoRequestProto_ClanInfoGrabTypeAll isForBrowsingList:NO beforeClanId:0];
    [[OutgoingEventController sharedOutgoingEventController] retrieveClanBulletinPosts:0];
    
    [self setState:kMyClan];
  } else {
    [self setState:kBrowseClans];
  }
  
  [self.view wakeup];
  
  CGRect r = self.view.frame;
  r.origin.x = 0;
  r.origin.y = r.size.height;
  self.view.frame = r;
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGoldLabel) name:IAP_SUCCESS_NOTIFICATION object:nil];
}

- (void) viewDidAppear:(BOOL)animated {
  CGRect r = self.view.frame;
  r.origin.y = r.size.height;
  r.origin.x = 0;
  r.size.width = self.view.superview.frame.size.width;
  self.view.frame = r;
  [UIView animateWithDuration:0.3f animations:^{
    CGRect r = self.view.frame;
    r.origin.y = 0;
    self.view.frame = r;
  }];
}

- (void) viewDidDisappear:(BOOL)animated {
  [self.view cleanup];
  self.myClanMembers = nil;
  self.myClan = nil;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setState:(ClanState)s {
  state = s;
  
  [self.clanBar loadButtonsForClanState:state];
  
  self.clanInfoView.canEdit = NO;
  
  GameState *gs = [GameState sharedGameState];
  switch (state) {
    case kMyClan:
      self.clanCreateView.hidden = YES;
      self.membersView.hidden = YES;
      self.clanInfoView.hidden = YES;
      self.clanBrowseView.hidden = YES;
      self.clanBoardView.hidden = YES;
      self.clanAboutView.hidden = YES;
      self.goldView.hidden = YES;
      self.editView.hidden = YES;
      self.backView.hidden = YES;
      self.topBar.hidden = NO;
      self.titleLabel.hidden = YES;
      
      [self.topBar loadMyClanConfiguration];
      if (gs.clan) {
        self.clanBoardView.hidden = NO;
        [self.clanBoardView loadForCurrentClan];
        [self.clanInfoView loadForClan:self.myClan];
        [self.membersView loadForMembers:self.myClanMembers isMyClan:YES];
      } else {
        self.clanCreateView.hidden = NO;
        [self.clanCreateView loadNotInClanView];
      }
      break;
      
    case kBrowseClans:
      self.clanCreateView.hidden = YES;
      self.membersView.hidden = YES;
      self.clanInfoView.hidden = YES;
      self.clanBrowseView.hidden = NO;
      self.clanBoardView.hidden = YES;
      self.clanAboutView.hidden = YES;
      self.goldView.hidden = YES;
      self.editView.hidden = YES;
      self.backView.hidden = YES;
      self.topBar.hidden = NO;
      self.titleLabel.hidden = YES;
      
      self.clanBrowseView.state = [Globals userTypeIsGood:gs.type] ? kBrowseAlliance : kBrowseLegion;
      [self.topBar loadBrowseClanConfiguration];
      break;
      
    case kAboutClans:
      self.clanCreateView.hidden = YES;
      self.membersView.hidden = YES;
      self.clanInfoView.hidden = YES;
      self.clanBrowseView.hidden = YES;
      self.clanBoardView.hidden = YES;
      self.goldView.hidden = YES;
      self.editView.hidden = YES;
      self.backView.hidden = YES;
      self.topBar.hidden = YES;
      self.titleLabel.hidden = NO;
      self.clanAboutView.hidden = NO;
      
      self.titleLabel.text = @"ABOUT CLANS";
      
      break;
      
    case kCreateClan:
      self.clanCreateView.hidden = NO;
      self.membersView.hidden = YES;
      self.clanInfoView.hidden = YES;
      self.clanBrowseView.hidden = YES;
      self.clanBoardView.hidden = YES;
      self.clanAboutView.hidden = YES;
      self.goldView.hidden = NO;
      self.editView.hidden = YES;
      self.backView.hidden = YES;
      self.topBar.hidden = YES;
      self.titleLabel.hidden = NO;
      
      self.titleLabel.text = @"CREATE A CLAN";
      
      if (gs.clan) {
        [self.clanCreateView loadAlreadyInClanView];
      } else {
        [self.clanCreateView loadClanCreationView];
      }
      break;
      
    default:
      break;
  }
  _lastButton = kButton1;
}

- (void) topBarButtonClicked:(ClanBarButton)button {
  GameState *gs = [GameState sharedGameState];
  
  [self.view endEditing:YES];
  
  _lastButton = button;
  if (self.state == kMyClan) {
    if (gs.clan) {
      if (button == kButton1) {
        self.clanInfoView.hidden = YES;
        self.membersView.hidden = YES;
        self.clanBoardView.hidden = NO;
        self.editView.hidden = YES;
      } else if (button == kButton2) {
        self.clanInfoView.hidden = NO;
        self.membersView.hidden = YES;
        self.clanBoardView.hidden = YES;
        
        if (self.myClan.clan.owner.userId == gs.userId) {
          self.editView.hidden = NO;
          self.editLabel.text = @"Edit";
          
          clanInfoView.canEdit = NO;
        } else {
          self.editView.hidden = YES;
        }
      } else if (button == kButton3) {
        self.clanInfoView.hidden = YES;
        self.membersView.hidden = NO;
        self.clanBoardView.hidden = YES;
        
        if (self.myClan.clan.owner.userId == gs.userId) {
          self.editView.hidden = NO;
          self.editLabel.text = @"Edit";
          
          [membersView turnOffEditing];
        } else {
          self.editView.hidden = YES;
        }
      }
    }
  } else if (self.state == kBrowseClans) {
    // Check whether we are viewing specific clan or not
    if (self.backView.hidden) {
      // On list
      if (button == kButton1) {
        self.clanBrowseView.state = kBrowseAlliance;
      } else if (button == kButton2) {
        self.clanBrowseView.state = kBrowseLegion;
      } else if (button == kButton3) {
        self.clanBrowseView.state = kBrowseSearch;
      }
    } else {
      if (button == kButton1) {
        self.clanInfoView.hidden = NO;
        self.membersView.hidden = YES;
      } else if (button == kButton3) {
        self.clanInfoView.hidden = YES;
        self.membersView.hidden = NO;
      }
    }
  }
}

- (void) viewClan:(FullClanProtoWithClanSize *)clan {
  // Came from browse clans list
  [self.secondTopBar loadViewClanConfiguration];
  
  _lastBrowseButton = _lastButton;
  
  // Do animation
  self.backLabel.text = @"Back";
  self.backView.hidden = NO;
  self.backView.alpha = 0.f;
  self.clanInfoView.hidden = NO;
  CGPoint ciCenter = self.clanInfoView.center;
  CGPoint cbCenter = self.clanBrowseView.center;
  self.clanInfoView.center = ccpAdd(ciCenter, ccp(clanInfoView.frame.size.width, 0));
  [UIView animateWithDuration:0.3f animations:^{
    self.clanInfoView.center = ciCenter;
    self.clanBrowseView.center = ccpAdd(cbCenter, ccp(-clanBrowseView.frame.size.width, 0));
    self.backView.alpha = 1.f;
    
    self.secondTopBar.alpha = 1.f;
    self.topBar.alpha = 0.f;
    ClanTopBar *tb = self.secondTopBar;
    self.secondTopBar = self.topBar;
    self.topBar = tb;
  } completion:^(BOOL finished) {
    clanBrowseView.center = cbCenter;
    self.clanBrowseView.hidden = YES;
  }];
  
  [self.clanInfoView loadForClan:clan];
  [self.membersView preloadMembersForClan:clan.clan.clanId leader:clan.clan.owner.userId];
  
  _browsingClanId = clan.clan.clanId;
}

- (void) updateGoldLabel {
  GameState *gs = [GameState sharedGameState];
  goldLabel.text = [Globals commafyNumber:gs.gold];
}

- (IBAction)editClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  if (state == kMyClan && myClan.clan.owner.userId == gs.userId) {
    if (_lastButton == kButton2) {
      if (!clanInfoView.canEdit) {
        clanInfoView.canEdit = YES;
        [clanInfoView.textView becomeFirstResponder];
        editLabel.text = @"Done";
      } else {
        clanInfoView.canEdit = NO;
        [clanInfoView endEditing:YES];
        editLabel.text = @"Edit";
        
        if (![myClan.clan.description isEqualToString:clanInfoView.textView.text]) {
          int tag = [[OutgoingEventController sharedOutgoingEventController] changeClanDescription:clanInfoView.textView.text];
          [self beginLoading:tag];
        }
      }
    } else if (_lastButton == kButton3) {
      if (!membersView.editModeOn) {
        editLabel.text = @"Done";
        [membersView turnOnEditing];
      } else {
        editLabel.text = @"Edit";
        [membersView turnOffEditing];
      }
    }
  }
}

- (void) loadTransferOwnership {
  [self.topBar unclickButton:kButton1];
  [self.topBar unclickButton:kButton2];
  [self.topBar clickButton:kButton3];
  [self topBarButtonClicked:kButton3];
  [self editClicked:nil];
}

- (IBAction)closeClicked:(id)sender {
  [self close];
}

- (void) close {
  if (self.view.superview) {
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.3f animations:^{
      CGRect r = self.view.frame;
      r.origin.y = r.size.height;
      self.view.frame = r;
    } completion:^(BOOL finished) {
      [self.view removeFromSuperview];
    }];
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.view endEditing:YES];
}

- (IBAction)goldBarClicked:(id)sender {
  [GoldShoppeViewController displayView];
}

- (IBAction)backClicked:(id)sender {
  [secondTopBar loadBrowseClanConfiguration];
  [secondTopBar unclickButton:kButton1];
  [secondTopBar clickButton:_lastBrowseButton];
  
  // Do animation
  self.clanBrowseView.hidden = NO;
  CGPoint ciCenter = self.clanInfoView.center;
  CGPoint cmCenter = self.membersView.center;
  CGPoint cbCenter = self.clanBrowseView.center;
  self.clanBrowseView.center = ccpAdd(cbCenter, ccp(-clanBrowseView.frame.size.width, 0));
  [UIView animateWithDuration:0.3f animations:^{
    clanBrowseView.center = cbCenter;
    self.clanInfoView.center = ccpAdd(ciCenter, ccp(clanInfoView.frame.size.width, 0));
    self.membersView.center = ccpAdd(cmCenter, ccp(membersView.frame.size.width, 0));
    self.backView.alpha = 0.f;
    
    self.secondTopBar.alpha = 1.f;
    self.topBar.alpha = 0.f;
    ClanTopBar *tb = self.secondTopBar;
    self.secondTopBar = self.topBar;
    self.topBar = tb;
  } completion:^(BOOL finished) {
    self.clanInfoView.center = ciCenter;
    self.membersView.center = cmCenter;
    self.clanInfoView.hidden = YES;
    self.membersView.hidden = YES;
    self.backView.hidden = YES;
  }];
}

- (IBAction)upgradeClanClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  FullClanProtoWithClanSize *clan = self.clanInfoView.clan;
  if (clan.clan.clanId == gs.clan.clanId) {
    int maxTier = [gs maxClanTierLevel];
    if (gs.clan.currentTierLevel >= maxTier) {
      [Globals popupMessage:@"This clan is already at the max tier level!"];
    } else {
      int newSize = [gs clanTierForLevel:gs.clan.currentTierLevel+1].maxSize;
      int upgradeCost = [gs clanTierForLevel:gs.clan.currentTierLevel].upgradeCost;
      NSString *desc = [NSString stringWithFormat:@"Would you like to upgrade your clan to %d members for %d gold?", newSize, upgradeCost];
      [GenericPopupController displayConfirmationWithDescription:desc title:@"Upgrade Clan?" okayButton:@"Upgrade" cancelButton:@"Cancel" target:self selector:@selector(upgradeClan)];
    }
  }
}

- (void) upgradeClan {
  GameState *gs = [GameState sharedGameState];
  ClanTierLevelProto *p = [gs clanTierForLevel:gs.clan.currentTierLevel];
  int cost = p.upgradeCost;
  
  if (gs.gold < cost) {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:cost];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] upgradeClanTierLevel];
    [self updateGoldLabel];
    
    [self.loadingView display:self.view];
  }
}

- (void) beginLoading:(int)tag {
  if (tag != 0) {
    [self updateGoldLabel];
    [self.loadingView display:self.view];
    _loadingTag = tag;
  }
}

- (void) stopLoading:(int)tag {
  if (tag == _loadingTag) {
    [self.loadingView stop];
  }
}

- (void) loadForClan:(MinimumClanProto *)clan {
  // This is used from the profile
  GameState *gs = [GameState sharedGameState];
  if (gs.clan.clanId != clan.clanId) {
    self.state = kBrowseClans;
    self.backLabel.text = @"Browse";
    self.backView.alpha = 1.f;
    self.backView.hidden = NO;
    
    [topBar loadViewClanConfiguration];
    
    self.clanInfoView.hidden = NO;
    self.clanBrowseView.hidden = YES;
    
    [[OutgoingEventController sharedOutgoingEventController] retrieveClanInfo:nil clanId:clan.clanId grabType:RetrieveClanInfoRequestProto_ClanInfoGrabTypeAll isForBrowsingList:NO beforeClanId:0];
    
    [self.clanInfoView loadForClan:nil];
    [self.membersView preloadMembersForClan:clan.clanId leader:clan.ownerId];
    
    _browsingClanId = clan.clanId;
  } else {
    self.state = kMyClan;
  }
}

- (void) receivedClanCreateResponse:(CreateClanResponseProto *)proto {
  if (proto.status == CreateClanResponseProto_CreateClanStatusSuccess) {
    [self.clanCreateView loadAfterClanCreationView:proto.clanInfo.name];
    
    GameState *gs = [GameState sharedGameState];
    if (gs.clan) {
      [[OutgoingEventController sharedOutgoingEventController] retrieveClanInfo:nil clanId:gs.clan.clanId grabType:RetrieveClanInfoRequestProto_ClanInfoGrabTypeAll isForBrowsingList:NO beforeClanId:0];
      self.clanBoardView.boardPosts = [NSMutableArray array];
    }
  } else if (proto.status == CreateClanResponseProto_CreateClanStatusNameTaken) {
    [Globals popupMessage:@"This name is already taken."];
  } else if (proto.status == CreateClanResponseProto_CreateClanStatusTagTaken) {
    [Globals popupMessage:@"This tag is already taken."];
  } else {
    [Globals popupMessage:@"Server failed to create clan."];
  }
}

- (void) receivedRetrieveClanInfoResponse:(RetrieveClanInfoResponseProto *)proto {
  GameState *gs = [GameState sharedGameState];
  if (proto.isForBrowsingList) {
    if ((proto.isForSearch && proto.hasClanName && [proto.clanName isEqualToString:clanBrowseView.searchString]) || !proto.isForSearch) {
      [self.clanBrowseView loadClans:proto.clanInfoList isForSearch:proto.isForSearch];
    }
  } else {
    if (proto.clanInfoList.count == 1) {
      FullClanProtoWithClanSize *clan = proto.clanInfoList.lastObject;
      if (gs.clan.clanId == clan.clan.clanId) {
        self.myClan = clan;
        self.myClanMembers = [proto.membersList.mutableCopy autorelease];
        
        if (state == kMyClan) {
          [self topBarButtonClicked:_lastButton];
          [self.clanInfoView loadForClan:self.myClan];
          [self.membersView loadForMembers:self.myClanMembers isMyClan:YES];
        }
      } else {
        if (state == kBrowseClans && proto.clanId == _browsingClanId) {
          [self.clanInfoView loadForClan:clan];
          [self.membersView loadForMembers:proto.membersList isMyClan:NO];
        }
      }
    } else {
      if (state == kBrowseClans && proto.clanId == _browsingClanId) {
        [self.membersView loadForMembers:proto.membersList isMyClan:NO];
      }
    }
  }
}

- (void) receivedRejectOrAcceptResponse:(ApproveOrRejectRequestToJoinClanResponseProto *)proto {
  GameState *gs = [GameState sharedGameState];
  // Check if already in this clan
  if (gs.userId != proto.requesterId) {
    MinimumUserProtoForClans *m = nil;
    for (MinimumUserProtoForClans *mup in self.myClanMembers) {
      if (mup.minUserProto.minUserProtoWithLevel.minUserProto.userId == proto.requesterId) {
        m = mup;
        break;
      }
    }
    
    if (m) {
      if (proto.accept) {
        MinimumUserProtoForClans *newMup = [[[MinimumUserProtoForClans builderWithPrototype:m] setClanStatus:UserClanStatusMember] build];
        [myClanMembers removeObject:m];
        [myClanMembers addObject:newMup];
        
        self.myClan = proto.fullClan;
        if (state == kMyClan) {
          [self.clanInfoView loadForClan:myClan];
        }
      } else {
        [myClanMembers removeObject:m];
      }
      if (state == kMyClan) {
        [self.membersView loadForMembers:myClanMembers isMyClan:YES];
      }
    }
  } else {
    if (gs.clan) {
      [[OutgoingEventController sharedOutgoingEventController] retrieveClanInfo:nil clanId:gs.clan.clanId grabType:RetrieveClanInfoRequestProto_ClanInfoGrabTypeAll isForBrowsingList:NO beforeClanId:0];
      [[OutgoingEventController sharedOutgoingEventController] retrieveClanBulletinPosts:0];
    }
    if (state == kMyClan) {
      self.state = kMyClan;
      [self topBarButtonClicked:_lastButton];
    } else {
      // Reload last clan
      [self.clanInfoView loadForClan:self.clanInfoView.clan];
    }
  }
}

- (void) receivedRequestJoinClanResponse:(RequestJoinClanResponseProto *)proto {
  GameState *gs = [GameState sharedGameState];
  if (proto.sender.userId == gs.userId) {
    [clanInfoView loadForClan:clanInfoView.clan];
  } else {
    if (gs.clan.clanId == proto.clanId) {
      [self.myClanMembers addObject:proto.requester];
      [self.membersView loadForMembers:myClanMembers isMyClan:YES];
    }
  }
}

- (void) receivedRetractRequestJoinClanResponse:(RetractRequestJoinClanResponseProto *)proto {
  GameState *gs = [GameState sharedGameState];
  if (proto.sender.userId == gs.userId) {
    [clanInfoView loadForClan:clanInfoView.clan];
  } else {
    MinimumUserProtoForClans *m = nil;
    for (MinimumUserProtoForClans *mup in self.myClanMembers) {
      if (mup.minUserProto.minUserProtoWithLevel.minUserProto.userId == proto.sender.userId) {
        m = mup;
        break;
      }
    }
    
    if (m) {
      [myClanMembers removeObject:m];
      if (state == kMyClan) {
        [self.membersView loadForMembers:myClanMembers isMyClan:YES];
      }
    }
  }
}

- (void) receivedTransferOwnershipResponse:(TransferClanOwnershipResponseProto *)proto {
  GameState *gs = [GameState sharedGameState];
  self.myClan = proto.fullClan;
  if (state == kMyClan) {
    [self.membersView loadForMembers:myClanMembers isMyClan:YES];
    [self.clanInfoView loadForClan:myClan];
    [self.clanBoardView loadForCurrentClan];
    
    if (myClan.clan.owner.userId == gs.userId && (!self.membersView.hidden || !self.clanInfoView.hidden)) {
      self.editView.hidden = NO;
      self.editLabel.text = @"Edit";
    } else {
      self.editView.hidden = YES;
    }
  }
}

- (void) receivedChangeDescriptionResponse:(ChangeClanDescriptionResponseProto *)proto {
  self.myClan = proto.fullClan;
  if (state == kMyClan) {
    [self.clanInfoView loadForClan:myClan];
  }
}

- (void) receivedBootPlayerResponse:(BootPlayerFromClanResponseProto *)proto {
  GameState *gs = [GameState sharedGameState];
  if (gs.userId != proto.playerToBoot) {
    MinimumUserProtoForClans *m = nil;
    for (MinimumUserProtoForClans *mup in self.myClanMembers) {
      if (mup.minUserProto.minUserProtoWithLevel.minUserProto.userId == proto.playerToBoot) {
        m = mup;
        break;
      }
    }
    
    if (m) {
      [myClanMembers removeObject:m];
      self.myClan = [[[FullClanProtoWithClanSize builderWithPrototype:myClan] setClanSize:myClan.clanSize-1] build];
      if (state == kMyClan) {
        [self.clanInfoView loadForClan:self.myClan];
        [self.membersView loadForMembers:myClanMembers isMyClan:YES];
      }
    }
  } else {
    self.myClan = nil;
    self.myClanMembers = nil;
    
    if (state == kMyClan) {
      self.state = kMyClan;
      [self topBarButtonClicked:_lastButton];
    } else {
      // Reload last clan
      [self.clanInfoView loadForClan:self.clanInfoView.clan];
    }
  }
}

- (void) receivedLeaveResponse:(LeaveClanResponseProto *)proto {
  GameState *gs = [GameState sharedGameState];
  if (gs.userId != proto.sender.userId) {
    MinimumUserProtoForClans *m = nil;
    for (MinimumUserProtoForClans *mup in self.myClanMembers) {
      if (mup.minUserProto.minUserProtoWithLevel.minUserProto.userId == proto.sender.userId) {
        m = mup;
        break;
      }
    }
    
    if (m) {
      [myClanMembers removeObject:m];
      self.myClan = [[[FullClanProtoWithClanSize builderWithPrototype:myClan] setClanSize:myClan.clanSize-1] build];
      if (state == kMyClan) {
        [self.clanInfoView loadForClan:self.myClan];
        [self.membersView loadForMembers:myClanMembers isMyClan:YES];
      }
    }
  } else {
    self.myClan = nil;
    self.myClanMembers = nil;
    
    if (state == kMyClan) {
      self.state = kMyClan;
      [self topBarButtonClicked:_lastButton];
    } else {
      // Reload last clan
      [self.clanInfoView loadForClan:self.clanInfoView.clan];
    }
  }
}

- (void) receivedPostOnWall:(PostOnClanBulletinResponseProto *)proto {
  GameState *gs = [GameState sharedGameState];
  if (proto.sender.userId != gs.userId) {
    [self.clanBoardView.boardPosts insertObject:proto.post atIndex:0];
    [self.clanBoardView displayNewBoardPost];
  }
}

- (void) receivedWallPosts:(RetrieveClanBulletinPostsResponseProto *)proto {
  clanBoardView.boardPosts = proto.clanBulletinPostsList ? [proto.clanBulletinPostsList.mutableCopy autorelease] : [NSMutableArray array];
}

- (void) receivedUpgradeClanTier:(UpgradeClanTierLevelResponseProto *)proto {
  self.myClan = proto.fullClan;
  if (state == kMyClan) {
    [self.clanInfoView loadForClan:myClan];
  }
  [self.loadingView stop];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  self.clanBar = nil;
  self.goldLabel = nil;
  self.loadingView = nil;
  self.clanCreateView = nil;
  self.membersView = nil;
  self.clanInfoView = nil;
  self.goldView = nil;
  self.editView = nil;
  self.backView = nil;
  self.titleLabel = nil;
  self.topBar = nil;
  self.editLabel = nil;
  self.myClan = nil;
  self.myClanMembers = nil;
  self.containerView = nil;
  self.secondTopBar = nil;
  self.clanBoardView = nil;
  self.backLabel = nil;
}

@end
