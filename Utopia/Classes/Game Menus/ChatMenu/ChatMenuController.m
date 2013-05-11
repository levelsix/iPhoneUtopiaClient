//
//  ChatMenuController.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/28/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ChatMenuController.h"
#import "LNSynthesizeSingleton.h"
#import "cocos2d.h"
#import "Globals.h"
#import "GameState.h"
#import "ProfileViewController.h"
#import "RefillMenuController.h"
#import "OutgoingEventController.h"
#import "UserData.h"
#import "TopBar.h"

#define PRIVATE_CHAT_DEFAULTS_KEY @"PrivateChat%d"

@implementation ChatTopBar

@synthesize button1, button2, button3;

- (void) awakeFromNib {
  [self clickButton:kButton1];
  [self unclickButton:kButton2];
  [self unclickButton:kButton3];
  
  GameState *gs = [GameState sharedGameState];
  if (gs.clanChatBadgeNum > 0) {
    self.clanBadgeView.hidden = NO;
    self.clanBadgeLabel.text = gs.clanChatBadgeNum < 100 ? [NSString stringWithFormat:@"%d", gs.clanChatBadgeNum] : @"!";
  } else {
    self.clanBadgeView.hidden = YES;
  }
}

- (void) loadForChatState:(ChatState)state {
  [self unclickButton:kButton1];
  [self unclickButton:kButton2];
  [self unclickButton:kButton3];
  
  switch (state) {
    case kChatStateGlobal:
      [self clickButton:kButton1];
      break;
    case kChatStateClan:
      [self clickButton:kButton2];
      break;
    case kChatStatePrivate:
      [self clickButton:kButton3];
      break;
      
    default:
      break;
  }
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
      
    case kButton3:
      button3.hidden = NO;
      _clickedButtons |= kButton3;
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
      
    case kButton3:
      button3.hidden = YES;
      _clickedButtons &= ~kButton3;
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
      [self unclickButton:kButton2];
      [self unclickButton:kButton3];
      
      [[ChatMenuController sharedChatMenuController] setState:kChatStateGlobal];
    } else {
      [self unclickButton:kButton1];
    }
  }
  
  pt = [touch locationInView:button2];
  if (_trackingButton2) {
    if (CGRectContainsPoint(CGRectInset(button2.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton2];
      [self unclickButton:kButton1];
      [self unclickButton:kButton3];
      
      [[ChatMenuController sharedChatMenuController] setState:kChatStateClan];
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
      
      [[ChatMenuController sharedChatMenuController] setState:kChatStatePrivate];
    } else {
      [self unclickButton:kButton3];
    }
  }
  
  _trackingButton1 = NO;
  _trackingButton2 = NO;
  _trackingButton3 = NO;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self unclickButton:kButton1];
  [self unclickButton:kButton2];
  [self unclickButton:kButton3];
  _trackingButton1 = NO;
  _trackingButton2 = NO;
  _trackingButton3 = NO;
}

- (void) dealloc {
  self.button2 = nil;
  self.button1 = nil;
  self.button3 = nil;
  self.button1Label = nil;
  self.button2Label = nil;
  self.button3Label = nil;
  [super dealloc];
}

@end

@implementation PrivateChatCell

- (void) awakeFromNib {
  CAGradientLayer *gradient = [CAGradientLayer layer];
  gradient.frame = self.bounds;
  UIColor *topColor = [UIColor colorWithRed:35/255.f green:35/255.f blue:35/255.f alpha:0.5f];
  UIColor *botColor = [UIColor colorWithRed:12/255.f green:12/255.f blue:12/255.f alpha:0.5f];
  gradient.colors = [NSArray arrayWithObjects:(id)[topColor CGColor], (id)[botColor CGColor], nil];
  [self.contentView.layer insertSublayer:gradient atIndex:0];
  
  self.selectedBackgroundView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
  self.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5f];
}

- (void) updateForPrivateChat:(PrivateChatPostProto *)pcpp {
  GameState *gs = [GameState sharedGameState];
  self.privateChat = pcpp;
  
  MinimumUserProto *mup;
  if (pcpp.poster.userId == gs.userId) {
    mup = pcpp.recipient;
  } else {
    mup = pcpp.poster;
  }
  
  self.typeImage.image = [Globals squareImageForUser:mup.userType];
  self.nameLabel.text = mup.name;
  self.textLabel2.text = pcpp.content;
  self.timeLabel.text = [Globals stringForTimeSinceNow:[NSDate dateWithTimeIntervalSince1970:pcpp.timeOfPost/1000.] shortened:NO];
  
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  NSString *key = [NSString stringWithFormat:PRIVATE_CHAT_DEFAULTS_KEY, mup.userId];
  NSNumber *time = [ud objectForKey:key];
  NSNumber *time2 = [NSNumber numberWithLongLong:pcpp.timeOfPost];
  self.blueCircle.hidden = time && [time compare:time2] != NSOrderedAscending;
}

- (void) dealloc {
  self.blueCircle = nil;
  self.typeImage = nil;
  self.nameLabel = nil;
  self.textLabel2 = nil;
  self.timeLabel = nil;
  [super dealloc];
}

@end

@implementation PrivateChatView

- (void) awakeFromNib {
  self.privateChatTable.tableFooterView = [UIView new];
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  GameState *gs = [GameState sharedGameState];
  return gs.privateChats.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  PrivateChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PrivateChatCell"];
  
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed:@"PrivateChatCell" owner:self options:nil];
    cell = self.chatCell;
  }
  
  GameState *gs = [GameState sharedGameState];
  [cell updateForPrivateChat:[gs.privateChats objectAtIndex:indexPath.row]];
  
  return cell;
}

- (void) dealloc {
  self.privateChatTable = nil;
  self.chatCell = nil;
  [super dealloc];
}

@end

@implementation ChatCell

@synthesize bubbleView;
@synthesize bubbleBotMid, bubbleMidMid, bubbleTopMid;
@synthesize bubbleBotLeft, bubbleMidLeft, bubbleTopLeft;
@synthesize bubbleBotRight, bubbleMidRight, bubbleTopRight;
@synthesize chatLine, nameButton, textLabel, typeIcon;
@synthesize typeCircle, timeLabel;
@synthesize chatMessage;

static BOOL chatCellLoaded = NO;
static float chatLabelWidth = 0.f;
static float cellHeight = 66.f;
static float cellLabelHeight = 19.f;
static float cellLabelFontSize = 14.f;
static float buttonInitialWidth = 159.f;

- (void) awakeFromNib {
  chatLabelWidth = self.textLabel.frame.size.width;
  cellHeight = self.frame.size.height;
  cellLabelHeight = self.textLabel.frame.size.height;
  cellLabelFontSize = self.textLabel.font.pointSize;
  buttonInitialWidth = self.nameButton.frame.size.width;
}

- (void) updateForChat:(ChatMessage *)msg {
  self.chatMessage = msg;
  
  [self.typeIcon setImage:[Globals imageNamed:[Globals headshotImageNameForUser:msg.sender.userType]] forState:UIControlStateNormal];
  
  self.textLabel.text = msg.message;
  CGSize size = [msg.message sizeWithFont:self.textLabel.font constrainedToSize:CGSizeMake(chatLabelWidth, 999) lineBreakMode:self.textLabel.lineBreakMode];
  
  NSString *buttonText = [Globals fullNameWithName:msg.sender.name clanTag:msg.sender.clan.tag];
  
  if (msg.isAdmin) {
    buttonText = [buttonText stringByAppendingString:@" (Admin)"];
    [self.nameButton setTitleColor:[Globals redColor] forState:UIControlStateNormal];
  } else {
    [self.nameButton setTitleColor:[Globals goldColor] forState:UIControlStateNormal];
  }
  
  [self.nameButton setTitle:buttonText forState:UIControlStateNormal];
  CGSize buttonSize = [buttonText sizeWithFont:self.nameButton.titleLabel.font constrainedToSize:CGSizeMake(buttonInitialWidth, 999) lineBreakMode:self.nameButton.titleLabel.lineBreakMode];
  
  CGRect r = nameButton.frame;
  r.size.width = buttonSize.width;
  nameButton.frame = r;
  
  self.timeLabel.text = [Globals stringForTimeSinceNow:msg.date shortened:NO];
  
  r = timeLabel.frame;
  r.origin.x = MAX(CGRectGetMaxX(nameButton.frame), textLabel.frame.origin.x+size.width-r.size.width);
  timeLabel.frame = r;
  
  size.width = MAX(size.width, buttonSize.width+timeLabel.frame.size.width);
  
  int xDiff = size.width-self.textLabel.frame.size.width;
  int yDiff = size.height-self.textLabel.frame.size.height;
  
  UIView *cur;
  CGRect frame;
  
  cur = bubbleTopMid;
  frame = cur.frame;
  frame.size.width += xDiff;
  cur.frame = frame;
  
  cur = bubbleMidLeft;
  frame = cur.frame;
  frame.size.height += yDiff;
  cur.frame = frame;
  
  cur = bubbleMidMid;
  frame = cur.frame;
  frame.size.width += xDiff;
  frame.size.height += yDiff;
  cur.frame = frame;
  
  cur = bubbleTopRight;
  frame = cur.frame;
  frame.origin.x = CGRectGetMaxX(bubbleTopMid.frame);
  cur.frame = frame;
  
  cur = bubbleMidRight;
  frame = cur.frame;
  frame.size.height += yDiff;
  frame.origin.x = CGRectGetMaxX(bubbleMidMid.frame);
  cur.frame = frame;
  
  cur = bubbleBotLeft;
  frame = cur.frame;
  frame.origin.y = CGRectGetMaxY(bubbleMidLeft.frame);
  cur.frame = frame;
  
  cur = bubbleBotMid;
  frame = cur.frame;
  frame.size.width += xDiff;
  frame.origin.y = CGRectGetMaxY(bubbleMidMid.frame);
  cur.frame = frame;
  
  cur = bubbleBotRight;
  frame = cur.frame;
  frame.origin.y = CGRectGetMaxY(bubbleMidRight.frame);
  frame.origin.x = CGRectGetMaxX(bubbleBotMid.frame);
  cur.frame = frame;
  
  cur = self.textLabel;
  frame = cur.frame;
  frame.size = size;
  cur.frame = frame;
  
  cur = self.chatLine;
  frame = cur.frame;
  frame.size.width = bubbleMidMid.frame.size.width;
  cur.frame = frame;
  
  cur = self.typeIcon;
  frame = cur.frame;
  frame.origin.y += yDiff;
  cur.frame = frame;
  
  cur = self.typeCircle;
  frame = cur.frame;
  frame.origin.y += yDiff;
  cur.frame = frame;
  
  GameState *gs = [GameState sharedGameState];
  if (msg.sender.userId == gs.userId) {
    self.transform = CGAffineTransformMakeScale(-1, 1);
    self.nameButton.transform = CGAffineTransformMakeScale(-1, 1);
    self.textLabel.transform = CGAffineTransformMakeScale(-1, 1);
    self.typeIcon.transform = CGAffineTransformMakeScale(-1, 1);
    self.timeLabel.transform = CGAffineTransformMakeScale(-1, 1);
    self.nameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.textLabel.textAlignment = UITextAlignmentRight;
    self.timeLabel.textAlignment = UITextAlignmentLeft;
  } else {
    self.transform = CGAffineTransformIdentity;
    self.nameButton.transform = CGAffineTransformIdentity;
    self.textLabel.transform = CGAffineTransformIdentity;
    self.typeIcon.transform = CGAffineTransformIdentity;
    self.timeLabel.transform = CGAffineTransformIdentity;
    self.nameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.textLabel.textAlignment = UITextAlignmentLeft;
    self.timeLabel.textAlignment = UITextAlignmentRight;
  }
}

- (void) dealloc {
  self.bubbleView = nil;
  self.bubbleBotLeft = nil;
  self.bubbleBotMid = nil;
  self.bubbleBotRight = nil;
  self.bubbleMidLeft = nil;
  self.bubbleMidMid = nil;
  self.bubbleMidRight = nil;
  self.bubbleTopLeft = nil;
  self.bubbleTopMid = nil;
  self.bubbleTopRight = nil;
  self.chatLine = nil;
  self.nameButton = nil;
  self.textLabel = nil;
  self.typeIcon = nil;
  self.chatMessage = nil;
  [super dealloc];
}

@end

@implementation ChatMenuController

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(ChatMenuController);

@synthesize chatCell, chatTable, numChatsLabel;
@synthesize bottomView, postTextField;
@synthesize topBar;
@synthesize mainView, bgdView;
@synthesize state = _state;

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  self.state = kChatStateGlobal;
  
  self.privateChatView.frame = self.chatTableView.frame;
  [self.chatTableView.superview addSubview:self.privateChatView];
  
  [self.mainView addSubview:self.chatPopup];
}

- (void) viewWillAppear:(BOOL)animated {
  [self.chatTable reloadData];
  [self updateNumChatsLabel];
  
  self.chatPopup.hidden = YES;
  
  self.mainView.center = CGPointMake(self.mainView.center.x, self.mainView.superview.frame.size.height+self.mainView.frame.size.height/2);
  self.bgdView.alpha = 0.f;
  [UIView animateWithDuration:0.2f animations:^{
    self.mainView.center = CGPointMake(self.mainView.center.x, self.mainView.frame.size.height/2);
    self.bgdView.alpha = 1.f;
  }];
}

- (void) setState:(ChatState)state {
  GameState *gs = [GameState sharedGameState];
  if (state == kChatStateClan && !gs.clan) {
    [Globals popupMessage:@"You must be in a clan first!"];
    state = _state;
  } else {
    _state = state;
    
    if (state == kChatStateClan) {
      [gs clanChatViewed];
    }
  }
  
  if (state == kChatStatePrivate) {
    self.privateChatView.hidden = NO;
    self.chatTableView.hidden = YES;
    [self loadPrivateChatViewAnimated:NO];
  } else {
    self.privateChatView.hidden = YES;
    self.chatTableView.hidden = NO;
    [self loadChatTableAnimated:NO];
  }
  self.backView.hidden = YES;
  self.spinner.hidden = YES;
  
  self.chatPopup.hidden = YES;
  
  _otherUserId = 0;
  
  [self.postTextField resignFirstResponder];
  
  [self.chatTable reloadData];
  [self.topBar loadForChatState:state];
  [self updateNumChatsLabel];
  
  int numRows = [self.chatTable numberOfRowsInSection:0];
  if (numRows > 0) {
    [self.chatTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numRows-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
  }
}

- (NSArray *) arrayForState {
  GameState *gs = [GameState sharedGameState];
  if (self.state == kChatStateGlobal) {
    return gs.globalChatMessages;
  } else if (self.state == kChatStateClan) {
    return gs.clanChatMessages;
  } else {
    return self.privateChatMsgs;
  }
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.arrayForState.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell"];
  
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed:@"ChatCell" owner:self options:nil];
    cell = self.chatCell;
  }
  
  [cell updateForChat:[[self arrayForState] objectAtIndex:indexPath.row]];
  
  return cell;
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (tableView.tag == 1) {
    if (!chatCellLoaded) {
      [[NSBundle mainBundle] loadNibNamed:@"ChatCell" owner:self options:nil];
      chatCellLoaded = YES;
      self.chatCell = nil;
    }
    
    ChatMessage *cm = [[self arrayForState] objectAtIndex:indexPath.row];
    CGSize size = [cm.message sizeWithFont:[UIFont fontWithName:@"SanvitoPro-Semibold" size:cellLabelFontSize] constrainedToSize:CGSizeMake(chatLabelWidth, 999) lineBreakMode:UILineBreakModeWordWrap];
    
    return cellHeight + (size.height-cellLabelHeight);
  }
  return tableView.rowHeight;
}

- (void) loadPrivateChatViewAnimated:(BOOL)animated {
  CGRect r = self.chatTableView.frame;
  r.origin = CGPointMake(0, 0);
  self.chatTableView.frame = r;
  self.chatTableView.hidden = NO;
  self.backView.alpha = 1.f;
  
  _otherUserId = 0;
  
  void (^block)(void) = ^{
    CGRect r = self.chatTableView.frame;
    r.origin = CGPointMake(r.size.width, 0);
    self.chatTableView.frame = r;
    
    r = self.privateChatView.frame;
    r.origin = CGPointMake(0, 0);
    self.privateChatView.frame = r;
    
    self.backView.alpha = 0.f;
  };
  
  if (animated) {
    [UIView animateWithDuration:0.3f animations:block completion:^(BOOL finished) {
      self.backView.hidden = YES;
    }];
  } else {
    block();
    self.backView.hidden = YES;
  }
}

- (void) loadChatTableAnimated:(BOOL)animated {
  CGRect r = self.privateChatView.frame;
  r.origin = CGPointMake(0, 0);
  self.privateChatView.frame = r;
  self.privateChatView.hidden = NO;
  self.backView.hidden = NO;
  self.backView.alpha = 0.f;
  
  void (^block)(void) = ^{
    CGRect r = self.chatTableView.frame;
    r.origin = CGPointMake(0, 0);
    self.chatTableView.frame = r;
    
    r = self.privateChatView.frame;
    r.origin = CGPointMake(-r.size.width, 0);
    self.privateChatView.frame = r;
    
    self.backView.alpha = 1.f;
  };
  
  if (animated) {
    [UIView animateWithDuration:0.3f animations:block];
  } else {
    block();
  }
}

- (void) loadPrivateChatsForUserId:(int)userId animated:(BOOL)animated {
  if (self.state != kChatStatePrivate) {
    self.state = kChatStatePrivate;
  }
  
  [self loadChatTableAnimated:animated];
  [[OutgoingEventController sharedOutgoingEventController] retrievePrivateChatPosts:userId];
  _otherUserId = userId;
  self.privateChatMsgs = nil;
  [self.chatTable reloadData];
  self.spinner.hidden = NO;
}

- (void) displayChatPopupOnView:(UIView *)label {
  self.chatPopup.hidden = NO;
  self.chatPopup.alpha = 0.f;
  
  CGPoint translPt = [self.chatPopup.superview convertPoint:label.center fromView:label.superview];
  self.chatPopup.center = ccp(translPt.x, translPt.y-self.chatPopup.frame.size.height/2-label.frame.size.height/2);
  
  [UIView animateWithDuration:0.2f animations:^{
    self.chatPopup.alpha = 1.f;
  }];
}

- (void) removeChatPopup {
  if (!self.chatPopup.hidden) {
    [UIView animateWithDuration:0.2f animations:^{
      self.chatPopup.alpha = 0.f;
    } completion:^(BOOL finished) {
      self.chatPopup.hidden = YES;
    }];
  }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (tableView.tag == 1) {
    [self removeChatPopup];
  } else if (tableView.tag == 2) {
    // This is for the private chat list
    GameState *gs = [GameState sharedGameState];
    PrivateChatCell *pcc = (PrivateChatCell *)[tableView cellForRowAtIndexPath:indexPath];
    int userId = pcc.privateChat.poster.userId;
    userId = userId == gs.userId ? pcc.privateChat.recipient.userId : userId;
    [self loadPrivateChatsForUserId:userId animated:YES];
  }
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  [self.postTextField resignFirstResponder];
  [self removeChatPopup];
}

- (IBAction)backClicked:(id)sender {
  [self.postTextField resignFirstResponder];
  [self loadPrivateChatViewAnimated:YES];
}

- (void) updateNumChatsLabel {
  GameState *gs = [GameState sharedGameState];
  int badgeNum = 0;
  for (PrivateChatPostProto *p in gs.privateChats) {
    int userId = p.recipient.userId == gs.userId ? p.poster.userId : p.recipient.userId;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:PRIVATE_CHAT_DEFAULTS_KEY, userId];
    NSNumber *time = [ud objectForKey:key];
    NSNumber *time2 = [NSNumber numberWithLongLong:p.timeOfPost];
    BOOL viewed = time && [time compare:time2] != NSOrderedAscending;
    
    if (!viewed) {
      badgeNum += 1;
    }
  }
  
  if (badgeNum > 0) {
    self.topBar.privateBadgeView.hidden = NO;
    self.topBar.privateBadgeLabel.text = badgeNum < 100 ? [NSString stringWithFormat:@"%d", badgeNum] : @"!";
  } else {
    self.topBar.privateBadgeView.hidden = YES;
  }
}

- (void) close {
  if (self.view.superview) {
    [UIView animateWithDuration:0.2f animations:^{
      self.mainView.center = CGPointMake(self.mainView.center.x, self.mainView.superview.frame.size.height+self.mainView.frame.size.height/2);
      self.bgdView.alpha = 0.f;
    } completion:^(BOOL finished) {
      [ChatMenuController removeView];
    }];
  }
}

- (IBAction)closeClicked:(id)sender {
  [self.postTextField resignFirstResponder];
  [self close];
}

- (IBAction)addChatsClicked:(id)sender {
  //  if (isGlobal) {
  //    [[RefillMenuController sharedRefillMenuController] displayBuySpeakersView];
  //  } else {
  //    [Globals popupMessage:@"You don't need speakers to chat with your clan."];
  //  }
  //  [self.postTextField resignFirstResponder];
}

- (IBAction)chatRulesClicked:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  [self loadPrivateChatsForUserId:gl.adminChatUser.userId animated:NO];
  [self.postTextField resignFirstResponder];
}

- (IBAction)nameLabelClicked:(UIView *)sender {
  while (![sender isKindOfClass:[ChatCell class]]) {
    sender = [sender superview];
  }
  GameState *gs = [GameState sharedGameState];
  ChatCell *cell = (ChatCell *)sender;
  self.clickedMinUser = cell.chatMessage.sender;
  
  if (self.state == kChatStatePrivate || self.clickedMinUser.userId == gs.userId) {
    [self profileClicked:nil];
  } else {
    [self displayChatPopupOnView:cell.nameButton];
  }
}

- (IBAction)profileClicked:(id)sender {
  if (self.clickedMinUser) {
    [[ProfileViewController sharedProfileViewController] loadProfileForMinimumUser:self.clickedMinUser withState:kProfileState];
    [ProfileViewController displayView];
  }
}

- (IBAction)chatClicked:(id)sender {
  [self loadPrivateChatsForUserId:self.clickedMinUser.userId animated:NO];
}

- (IBAction)sendClicked:(id)sender {
  [self send];
}

- (void) send {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  NSString *msg = self.postTextField.text;
  if (msg.length > 0 && msg.length <= gl.maxLengthOfChatString) {
    if (self.state == kChatStatePrivate) {
      [[OutgoingEventController sharedOutgoingEventController] privateChatPost:_otherUserId content:msg];
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        ChatMessage *cm = [[ChatMessage alloc] init];
        cm.date = [NSDate date];
        cm.message = msg;
        cm.sender = gs.minUser;
        [self addChatMessage:cm];
      });
    } else {
      //  if ((isGlobal && gs.numGroupChatsRemaining > 0) || !isGlobal) {
      GroupChatScope scope = self.state == kChatStateGlobal ? GroupChatScopeGlobal : GroupChatScopeClan;
      [[OutgoingEventController sharedOutgoingEventController] sendGroupChat:scope message:msg];
      [self updateNumChatsLabel];
    }
    //  } else {
    //    [self addChatsClicked:nil];
    //  }
  }
  self.postTextField.text = nil;
  [self.postTextField resignFirstResponder];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
  [UIView animateWithDuration:0.3f animations:^{
    self.bottomView.center = ccpAdd(self.bottomView.center, ccp(0, -146));
    
    CGRect r = self.chatTable.frame;
    CGRect s = [chatTable.superview convertRect:self.bottomView.frame fromView:self.bottomView.superview];
    r.size.height = MIN(chatTable.contentSize.height, chatTable.superview.frame.size.height);
    r.origin.y = s.origin.y-r.size.height;
    self.chatTable.frame = r;
  }];
  
  self.chatPopup.hidden = YES;
  
  int numRows = [self.chatTable numberOfRowsInSection:0];
  if (numRows > 0) {
    [self.chatTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numRows-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
  }
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
  [UIView animateWithDuration:0.3f animations:^{
    self.bottomView.center = ccpAdd(self.bottomView.center, ccp(0, 146));
    
    CGRect r = self.chatTable.frame;
    r.origin.y = 0;
    r.size.height = self.chatTable.superview.frame.size.height;
    self.chatTable.frame = r;
  }];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
  [self send];
  return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  Globals *gl = [Globals sharedGlobals];
  NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
  if ([str length] > gl.maxLengthOfChatString) {
    return NO;
  }
  return YES;
}

- (void) addChatMessage:(ChatMessage *)msg {
  [self.privateChatMsgs addObject:msg];
  
  NSIndexPath *path = [NSIndexPath indexPathForRow:self.privateChatMsgs.count-1 inSection:0];
  [self.chatTable insertRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
  
  if (self.chatTable.contentOffset.y > self.chatTable.contentSize.height-self.chatTable.frame.size.height-100) {
    [self.chatTable scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
  }
}

- (void) updateUserDefaultsForUserId:(int)userId time:(uint64_t)time {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  NSNumber *t = [NSNumber numberWithLongLong:time];
  NSString *key = [NSString stringWithFormat:PRIVATE_CHAT_DEFAULTS_KEY, userId];
  [ud setObject:t forKey:key];
}

- (void) receivedRetrievePrivateChats:(RetrievePrivateChatPostsResponseProto *)proto {
  Globals *gl = [Globals sharedGlobals];
  if (_otherUserId == proto.otherUserId) {
    NSMutableArray *arr = [NSMutableArray array];
    uint64_t timeOfChat = 0;
    for (GroupChatMessageProto *chat in proto.postsList) {
      [arr addObject:[[ChatMessage alloc] initWithProto:chat]];
      
      if (chat.timeOfChat > timeOfChat) {
        timeOfChat = chat.timeOfChat;
      }
    }
    [arr sortUsingComparator:^NSComparisonResult(ChatMessage *obj1, ChatMessage *obj2) {
      return [obj1.date compare:obj2.date];
    }];
    
    if (_otherUserId == gl.adminChatUser.userId) {
      GroupChatMessageProto_Builder *p = [GroupChatMessageProto builder];
      p.sender = gl.adminChatUser;
      p.content = @"An admin has been notified and will be with you shortly. Thank you for your patience. In the meantime, can you let me know a bit more about your problem so we can better assist you?";
      p.timeOfChat = [[NSDate date] timeIntervalSince1970]*1000;
      [arr addObject:[[ChatMessage alloc] initWithProto:p.build]];
    }
    
    self.privateChatMsgs = arr;
    
    [self.chatTable reloadData];
    self.spinner.hidden = YES;
    
    int numRows = [self.chatTable numberOfRowsInSection:0];
    if (numRows > 0) {
      [self.chatTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numRows-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    
    [self updateUserDefaultsForUserId:proto.otherUserId time:timeOfChat];
    
    [self.privateChatView.privateChatTable reloadData];
    [self updateNumChatsLabel];
  }
}

- (void) receivedPrivateChatPost:(PrivateChatPostResponseProto *)proto {
  GameState *gs = [GameState sharedGameState];
  int userId = proto.post.recipient.userId == gs.userId ? proto.post.poster.userId : proto.post.recipient.userId;
  
  if (_otherUserId == proto.sender.userId && proto.sender.userId != gs.userId) {
    ChatMessage *cm = [[ChatMessage alloc] init];
    cm.sender = proto.post.poster;
    cm.date = [NSDate dateWithTimeIntervalSince1970:proto.post.timeOfPost/1000.];
    cm.message = proto.post.content;
    [self addChatMessage:cm];
  }
  
  if (_otherUserId == userId) {
    [self updateUserDefaultsForUserId:userId time:proto.post.timeOfPost];
  } else {
    TopBar *tb = [TopBar sharedTopBar];
    [tb addNotificationToDisplayQueue:[[UserNotification alloc] initWithPrivateChatPost:proto.post]];
  }
  
  PrivateChatPostProto *privChat = nil;
  for (PrivateChatPostProto *pcpp in gs.privateChats) {
    int otherUserId = pcpp.recipient.userId == gs.userId ? pcpp.poster.userId : pcpp.recipient.userId;
    if (userId == otherUserId) {
      privChat = pcpp;
    }
  }
  [gs.privateChats removeObject:privChat];
  [gs.privateChats insertObject:proto.post atIndex:0];
  [self.privateChatView.privateChatTable reloadData];
  
  [self.privateChatView.privateChatTable reloadData];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.postTextField resignFirstResponder];
  [self removeChatPopup];
}

- (void) didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  if (self.isViewLoaded && !self.view.superview) {
    self.view = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.chatCell = nil;
    self.chatTable = nil;
    self.numChatsLabel = nil;
    self.bottomView = nil;
    self.postTextField = nil;
    self.bgdView = nil;
    self.mainView = nil;
    self.topBar = nil;
    self.privateChatView = nil;
    self.chatTableView = nil;
    self.chatPopup = nil;
  }
}

@end
