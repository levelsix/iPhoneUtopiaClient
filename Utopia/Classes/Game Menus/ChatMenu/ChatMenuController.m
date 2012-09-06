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

@implementation ChatCell

@synthesize bubbleView;
@synthesize bubbleBotMid, bubbleMidMid, bubbleTopMid;
@synthesize bubbleBotLeft, bubbleMidLeft, bubbleTopLeft;
@synthesize bubbleBotRight, bubbleMidRight, bubbleTopRight;
@synthesize chatLine, nameButton, textLabel, typeIcon;
@synthesize typeCircle;
@synthesize chatMessage;

static float chatLabelWidth = 342.f;
static float cellHeight = 66.f;
static float cellLabelHeight = 19.f;
static float cellLabelFontSize = 14.f;

- (void) awakeFromNib {
  chatLabelWidth = self.textLabel.frame.size.width;
  cellHeight = self.frame.size.height;
  cellLabelHeight = self.textLabel.frame.size.height;
  cellLabelFontSize = self.textLabel.font.pointSize;
}

- (void) updateForChat:(ChatMessage *)msg {
  self.chatMessage = msg;
  //  [UIView commitAnimations];
  
  [self.typeIcon setImage:[Globals imageNamed:[Globals headshotImageNameForUser:msg.sender.userType]] forState:UIControlStateNormal];
  
  self.textLabel.text = msg.message;
  CGSize size = [msg.message sizeWithFont:self.textLabel.font constrainedToSize:CGSizeMake(chatLabelWidth, 999) lineBreakMode:self.textLabel.lineBreakMode];
  
  NSString *buttonText = msg.sender.name;
  [self.nameButton setTitle:buttonText forState:UIControlStateNormal];
  CGSize buttonSize = [buttonText sizeWithFont:self.nameButton.titleLabel.font constrainedToSize:CGSizeMake(self.nameButton.frame.size.width, 999) lineBreakMode:self.nameButton.titleLabel.lineBreakMode];
  size.width = MAX(size.width, buttonSize.width+2*self.nameButton.frame.origin.x);
  
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
    self.nameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.textLabel.textAlignment = UITextAlignmentRight;
  } else {
    self.transform = CGAffineTransformIdentity;
    self.nameButton.transform = CGAffineTransformIdentity;
    self.textLabel.transform = CGAffineTransformIdentity;
    self.typeIcon.transform = CGAffineTransformIdentity;
    self.nameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.textLabel.textAlignment = UITextAlignmentLeft;
  }
}

- (IBAction)profileClicked:(id)sender {
  if (self.chatMessage) {
    [[ProfileViewController sharedProfileViewController] loadProfileForMinimumUser:chatMessage.sender withState:kProfileState];
    [ProfileViewController displayView];
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
@synthesize mainView, bgdView;

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated {
  [self.chatTable reloadData];
  [self updateNumChatsLabel];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  GameState *gs = [GameState sharedGameState];
  return gs.chatMessages.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell"];
  
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed:@"ChatCell" owner:self options:nil];
    cell = self.chatCell;
  }
  
  GameState *gs = [GameState sharedGameState];
  [cell updateForChat:[gs.chatMessages objectAtIndex:indexPath.row]];
  
  return cell;
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  GameState *gs = [GameState sharedGameState];
  ChatMessage *cm = [gs.chatMessages objectAtIndex:indexPath.row];
  CGSize size = [cm.message sizeWithFont:[UIFont fontWithName:@"SanvitoPro-Semibold" size:cellLabelFontSize] constrainedToSize:CGSizeMake(chatLabelWidth, 999) lineBreakMode:UILineBreakModeWordWrap];
  
  return cellHeight + (size.height-cellLabelHeight);
}

- (void) updateNumChatsLabel {
  GameState *gs = [GameState sharedGameState];
  self.numChatsLabel.text = [Globals commafyNumber:gs.numGroupChatsRemaining];
}

- (void) close {
  if (self.view.superview) {
    [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^(void) {
      [ChatMenuController removeView];
    }];
  }
}

- (IBAction)closeClicked:(id)sender {
  [self.postTextField resignFirstResponder];
  [self close];
}

- (IBAction)addChatsClicked:(id)sender {
  if (![self.postTextField isFirstResponder]) {
    [[RefillMenuController sharedRefillMenuController] displayBuySpeakersView];
  }
}

- (IBAction)chatRulesClicked:(id)sender {
  if (![self.postTextField isFirstResponder]) {
    [Globals popupMessage:@"No Swearing. No Bashing. No Advertising. No Spamming."];
  }
}

- (IBAction)sendClicked:(id)sender {
  [self send];
}

- (void) send {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  NSString *msg = self.postTextField.text;
  if (gs.numGroupChatsRemaining > 0) {
    if (msg.length > 0 && msg.length < gl.maxLengthOfChatString) {
      [[OutgoingEventController sharedOutgoingEventController] sendGroupChat:GroupChatScopeGlobal message:msg];
      [self updateNumChatsLabel]; 
    }
    self.postTextField.text = nil;
  } else {
    [self addChatsClicked:nil];
  }
  [self.postTextField resignFirstResponder];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
  [UIView animateWithDuration:0.3f animations:^{
    self.bottomView.center = ccpAdd(self.bottomView.center, ccp(0, -146));
    
    CGRect r = self.chatTable.frame;
    CGRect s = [chatTable.superview convertRect:self.bottomView.frame fromView:self.bottomView.superview];
    r.size.height = s.origin.y-r.origin.y;
    self.chatTable.frame = r;
  }];
  
  int numRows = [self.chatTable numberOfRowsInSection:0];
  if (numRows > 0) {
    [self.chatTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numRows-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
  }
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

- (void) textFieldDidEndEditing:(UITextField *)textField {
  [UIView animateWithDuration:0.3f animations:^{
    self.bottomView.center = ccpAdd(self.bottomView.center, ccp(0, 146));
    
    CGRect r = self.chatTable.frame;
    CGRect s = [chatTable.superview convertRect:self.bottomView.frame fromView:self.bottomView.superview];
    r.size.height = s.origin.y-r.origin.y;
    self.chatTable.frame = r;
  }];
  
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [postTextField resignFirstResponder];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  self.chatCell = nil;
  self.chatTable = nil;
  self.numChatsLabel = nil;
  self.bottomView = nil;
  self.postTextField = nil;
  self.bgdView = nil;
  self.mainView = nil;
}

@end
