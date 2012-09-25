//
//  LeaderboardController.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/14/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "LeaderboardController.h"
#import "Globals.h"
#import "OutgoingEventController.h"
#import "GameState.h"
#import "LNSynthesizeSingleton.h"
#import "ProfileViewController.h"

#define REFRESH_ROWS 5

@implementation LeaderboardBar

@synthesize button1, button2, button3, button4;
@synthesize button1Label, button2Label, button3Label, button4Label;

- (void) awakeFromNib {
  [self clickButton:kButton1];
  [self unclickButton:kButton2];
  [self unclickButton:kButton3];
  [self unclickButton:kButton4];
}

- (void) clickButton:(LeaderboardBarButton)button {
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
      
    case kButton4:
      button4Label.highlighted = YES;
      button4.hidden = NO;
      _clickedButtons |= kButton4;
      break;
      
    default:
      break;
  }
}

- (void) unclickButton:(LeaderboardBarButton)button {
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
      break;
      
    case kButton4:
      button4Label.highlighted = NO;
      button4.hidden = YES;
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
      
      [[LeaderboardController sharedLeaderboardController] setState:LeaderboardTypeBestKdr];
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
      
      [[LeaderboardController sharedLeaderboardController] setState:LeaderboardTypeMostBattlesWon];
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
      
      [[LeaderboardController sharedLeaderboardController] setState:LeaderboardTypeMostExp];
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
      
      [[LeaderboardController sharedLeaderboardController] setState:LeaderboardTypeMostCoins];
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
  [self unclickButton:kButton1];
  [self unclickButton:kButton3];
  [self unclickButton:kButton2];
  [self unclickButton:kButton4];
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
  [super dealloc];
}

@end

@implementation LeaderboardCell

@synthesize userIcon, nameLabel, typeLabel;
@synthesize rankLabel, rightLabel, user;

- (void) awakeFromNib {
  CAGradientLayer *gradient = [CAGradientLayer layer];
  gradient.frame = self.bounds;
  UIColor *topColor = [UIColor colorWithRed:35/255.f green:35/255.f blue:35/255.f alpha:0.5f];
  UIColor *botColor = [UIColor colorWithRed:12/255.f green:12/255.f blue:12/255.f alpha:0.5f];
  gradient.colors = [NSArray arrayWithObjects:(id)[topColor CGColor], (id)[botColor CGColor], nil];
  [self.contentView.layer insertSublayer:gradient atIndex:0];
}

- (void) updateForUser:(MinimumUserProtoWithLevelForLeaderboard *)u forState:(LeaderboardType)type {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  self.user = u;
  [self.nameLabel setTitle:[Globals fullNameWithName:user.minUserProto.name clanTag:user.minUserProto.clan.tag] forState:UIControlStateNormal];
  self.typeLabel.text = [NSString stringWithFormat:@"Level %d %@ %@", user.level, [Globals factionForUserType:user.minUserProto.userType], [Globals classForUserType:user.minUserProto.userType]];
  [userIcon setImage:[Globals squareImageForUser:user.minUserProto.userType] forState:UIControlStateNormal];
  self.rankLabel.text = [Globals commafyNumber:user.leaderboardRank];
  
  if ([Globals userTypeIsGood:u.minUserProto.userType]) {
    [self.nameLabel setTitleColor:[Globals blueColor] forState:UIControlStateNormal];
  } else {
    [self.nameLabel setTitleColor:[Globals redColor] forState:UIControlStateNormal];
  }
  
  if (u.minUserProto.userId == gs.userId) {
    self.rankLabel.textColor = [Globals greenColor];
  } else {
    self.rankLabel.textColor = [Globals creamColor];
  }
  
  NSString *str = nil;
  if (type == LeaderboardTypeBestKdr) {
    if (u.leaderboardScore == 0.f) {
      str = [NSString stringWithFormat:@"Need %d Battles", gl.minBattlesRequiredForKDRConsideration];
      self.rankLabel.text = @"N/A";
    } else {
      str = [NSString stringWithFormat:@"%.1f%%", u.leaderboardScore*100.f];
    }
  } else if (type == LeaderboardTypeMostBattlesWon) {
    str = [NSString stringWithFormat:@"%@ Win%@", [Globals commafyNumber:(int)u.leaderboardScore], u.leaderboardScore != 1 ? @"s" : @""];
  } else if (type == LeaderboardTypeMostCoins) {
    str = [NSString stringWithFormat:@"%@ Silver", [Globals commafyNumber:(int)u.leaderboardScore]];
  } else if (type == LeaderboardTypeMostExp) {
    str = [NSString stringWithFormat:@"%@ Exp.", [Globals commafyNumber:(int)u.leaderboardScore]];
  }
  self.rightLabel.text = str;
}

- (IBAction)profileClicked:(id)sender {
  if (user) {
    [[ProfileViewController sharedProfileViewController] loadProfileForMinimumUser:user.minUserProto withState:kProfileState];
    [ProfileViewController displayView];
  }
}

- (void) dealloc {
  self.user = nil;
  self.userIcon = nil;
  self.nameLabel = nil;
  self.typeLabel = nil;
  self.rankLabel = nil;
  self.rightLabel = nil;
  [super dealloc];
}

@end

@implementation LeaderboardController

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(LeaderboardController);

@synthesize state;
@synthesize youHeaderView, topPlayersHeaderView;
@synthesize kdrList, winsList, levelList, silverList;
@synthesize kdrMup, winsMup, levelMup, silverMup;
@synthesize topBar;
@synthesize leaderboardCell, loadingCell;
@synthesize leaderboardTable;
@synthesize mainView, bgdView;
@synthesize spinner;
@synthesize shouldReload;

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  state = LeaderboardTypeBestKdr;
  
  self.leaderboardTable.tableFooterView = [[[UIView alloc] init] autorelease];
  
  [super addPullToRefreshHeader:self.leaderboardTable];
  [self.leaderboardTable addSubview:self.refreshHeaderView];
  self.refreshHeaderView.center = ccp(self.leaderboardTable.frame.size.width/2, -self.refreshHeaderView.frame.size.height/2);
  
  [(UIActivityIndicatorView *)[self.loadingCell viewWithTag:31] startAnimating];
}

- (void) viewWillAppear:(BOOL)animated {
  [Globals bounceView:mainView fadeInBgdView:bgdView];
  
  self.kdrList = [NSMutableArray array];
  self.winsList = [NSMutableArray array];
  self.levelList = [NSMutableArray array];
  self.silverList = [NSMutableArray array];
  self.kdrMup = nil;
  self.winsMup = nil;
  self.levelMup = nil;
  self.silverMup = nil;
  
  [[OutgoingEventController sharedOutgoingEventController] retrieveLeaderboardForType:state];
  self.shouldReload = NO;
  [self.leaderboardTable reloadData];
}

- (void) setState:(LeaderboardType)st {
  if (state != st) {
    state = st;
    
    NSArray *arr = [self arrayForCurrentState];
    if (arr.count == 0) {
      [[OutgoingEventController sharedOutgoingEventController] retrieveLeaderboardForType:state];
      self.shouldReload = NO;
    }
    
    [self.leaderboardTable setContentOffset:ccp(0,0)];
    [self.leaderboardTable reloadData];
  }
}

- (void) refresh {
  [[OutgoingEventController sharedOutgoingEventController] retrieveLeaderboardForType:state];
  [[self arrayForCurrentState] removeAllObjects];
  [self.leaderboardTable reloadData];
  self.shouldReload = NO;
  [self stopLoading];
}

- (NSMutableArray *) arrayForCurrentState {
  switch (state) {
    case LeaderboardTypeBestKdr:
      return kdrList;
      break;
      
    case LeaderboardTypeMostBattlesWon:
      return winsList;
      break;
      
    case LeaderboardTypeMostExp:
      return levelList;
      break;
      
    case LeaderboardTypeMostCoins:
      return silverList;
      break;
      
    default:
      break;
  }
}

- (void) receivedLeaderboardResponse:(RetrieveLeaderboardResponseProto *)proto {
  switch (proto.leaderboardType) {
    case LeaderboardTypeBestKdr:
      [self addUsersFrom:proto.resultPlayersList toArray:kdrList];
      self.kdrMup = proto.retriever;
      break;
      
    case LeaderboardTypeMostExp:
      [self addUsersFrom:proto.resultPlayersList toArray:levelList];
      self.levelMup = proto.retriever;
      break;
      
    case LeaderboardTypeMostCoins:
      [self addUsersFrom:proto.resultPlayersList toArray:silverList];
      self.silverMup = proto.retriever;
      break;
      
    case LeaderboardTypeMostBattlesWon:
      [self addUsersFrom:proto.resultPlayersList toArray:winsList];
      self.winsMup = proto.retriever;
      break;
      
    default:
      break;
  }
  
  [self.leaderboardTable reloadData];
  self.shouldReload = YES;
}

- (void) addUsersFrom:(NSArray *)arr toArray:(NSMutableArray *)mut {
  for (MinimumUserProtoWithLevelForLeaderboard *usr in arr) {
    MinimumUserProtoWithLevelForLeaderboard *remove = nil;
    for (MinimumUserProtoWithLevelForLeaderboard *chk in mut) {
      if (chk.leaderboardRank == usr.leaderboardRank) {
        remove = chk;
        break;
      }
    }
    if (remove) {
      [mut removeObject:remove];
    }
    [mut addObject:usr];
  }
  
  [mut sortUsingComparator:^NSComparisonResult(MinimumUserProtoWithLevelForLeaderboard *obj1, MinimumUserProtoWithLevelForLeaderboard *obj2) {
    if (obj1.leaderboardRank > obj2.leaderboardRank) {
      return NSOrderedDescending;
    } else if (obj1.leaderboardRank == obj2.leaderboardRank) {
      return NSOrderedSame;
    } else {
      return NSOrderedAscending;
    }
  }];
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSMutableArray *arr = [self arrayForCurrentState];
  if (arr.count == 0) {
    [self.spinner startAnimating];
    self.spinner.hidden = NO;
    
    return 0;
  } else {
    [self.spinner stopAnimating];
    self.spinner.hidden = YES;
    
    if (section == 0) {
      return 1;
    } else if (section == 1) {
      return arr.count+1;
    }
  }
  return 0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  NSMutableArray *arr = [self arrayForCurrentState];
  if (arr.count == 0) {
    // return empty view
  } else if (section == 0) {
    return self.youHeaderView;
  } else if (section == 1) {
    return self.topPlayersHeaderView;
  }
  return [[[UIView alloc] init] autorelease];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  NSMutableArray *arr = [self arrayForCurrentState];
  if (indexPath.section == 1 && indexPath.row >= arr.count) {
    return self.loadingCell;
  }
  
  LeaderboardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LeaderboardCell"];
  
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed:@"LeaderboardCell" owner:self options:nil];
    cell = self.leaderboardCell;
  }
  
  MinimumUserProtoWithLevelForLeaderboard *u = nil;
  if (indexPath.section == 0) {
    if (state == LeaderboardTypeBestKdr) {
      u = kdrMup;
    } else if (state == LeaderboardTypeMostBattlesWon) {
      u = winsMup;
    } else if (state == LeaderboardTypeMostCoins) {
      u = silverMup;
    } else if (state == LeaderboardTypeMostExp) {
      u = levelMup;
    }
  } else if (indexPath.section == 1) {
    u = [arr objectAtIndex:indexPath.row];
  }
  [cell updateForUser:u forState:self.state];
  
  return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  // Load more rows when we get low enough
  if (scrollView.contentOffset.y > scrollView.contentSize.height-scrollView.frame.size.height-REFRESH_ROWS*self.leaderboardTable.rowHeight) {
    if (shouldReload) {
      NSArray *arr = [self arrayForCurrentState];
      MinimumUserProtoWithLevelForLeaderboard *mup = [arr lastObject];
      [[OutgoingEventController sharedOutgoingEventController] retrieveLeaderboardForType:self.state afterRank:mup.leaderboardRank];
      self.shouldReload = NO;
    }
  }
  [super scrollViewDidScroll:scrollView];
}

- (IBAction) closeClicked:(id)sender {
  if (self.view.superview) {
    [Globals popOutView:mainView fadeOutBgdView:bgdView completion:^{
      [self.view removeFromSuperview];
    }];
  }
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  self.topBar = nil;
  self.mainView = nil;
  self.bgdView = nil;
  self.youHeaderView = nil;
  self.topPlayersHeaderView = nil;
  self.kdrList = nil;
  self.winsList = nil;
  self.levelList = nil;
  self.silverList = nil;
  self.kdrMup = nil;
  self.winsMup = nil;
  self.levelMup = nil;
  self.silverMup = nil;
  self.leaderboardTable = nil;
  self.leaderboardCell = nil;
  self.spinner = nil;
  self.refreshArrow = nil;
  self.refreshHeaderView = nil;
  self.refreshLabel = nil;
  self.refreshSpinner = nil;
  self.loadingCell = nil;
}

@end
