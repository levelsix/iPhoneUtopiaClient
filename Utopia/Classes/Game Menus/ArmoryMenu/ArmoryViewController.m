//
//  ArmoryViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/25/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ArmoryViewController.h"
#import "LNSynthesizeSingleton.h"
#import "GameState.h"
#import "Globals.h"
#import "OutgoingEventController.h"
#import "RefillMenuController.h"
#import "SoundEngine.h"
#import "EquipDeltaView.h"
#import "GenericPopupController.h"

@implementation ArmoryRow

- (void) updateForBoosterPack:(BoosterPackProto *)bpp {
  GameState *gs = [GameState sharedGameState];
  
  [self.bgdView setImage:[Globals imageNamed:bpp.backgroundImage] forState:UIControlStateNormal];
  [Globals imageNamed:bpp.chestImage withImageView:self.chestIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  [Globals imageNamed:bpp.middleImage withImageView:self.middleImageView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  self.levelsLabel.text = [NSString stringWithFormat:@"%d-%d", bpp.minLevel, bpp.maxLevel];
  
  int total = 0, collected = 0;
  UserBoosterPackProto *userPack = [gs myBoosterPackForId:bpp.boosterPackId];
  for (BoosterItemProto *item in bpp.boosterItemsList) {
    UserBoosterItemProto *userItem = nil;
    for (UserBoosterItemProto *ui in userPack.userBoosterItemsList) {
      if (ui.boosterItemId == item.boosterItemId) {
        userItem = ui;
        break;
      }
    }
    
    total += item.quantity;
    collected += userItem.numReceived;
  }
  self.equipsLeftLabel.text = [NSString stringWithFormat:@"%d / %d", total-collected, total];
  
  self.boosterPack = bpp;
}

- (void) dealloc {
  self.bgdView = nil;
  self.chestIcon = nil;
  self.middleImageView = nil;
  self.levelsLabel = nil;
  self.equipsLeftLabel = nil;
  self.boosterPack = nil;
  [super dealloc];
}

@end

@implementation ArmoryViewController

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(ArmoryViewController);

@synthesize armoryTableView, armoryRow;
@synthesize equipClicked;
@synthesize coinBar;
@synthesize spinner;
@synthesize loadingView;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Add rope to the very top
  UIColor *c = [UIColor colorWithPatternImage:[Globals imageNamed:@"rope.png"]];
  UIView *leftRope = [[UIView alloc] initWithFrame:CGRectMake(15, -150, 3, 150)];
  UIView *rightRope = [[UIView alloc] initWithFrame:CGRectMake(463, -150, 3, 150)];
  leftRope.backgroundColor = c;
  rightRope.backgroundColor = c;
  [self.armoryTableView addSubview:leftRope];
  [self.armoryTableView addSubview:rightRope];
  [leftRope release];
  [rightRope release];
  
  self.carouselView.frame = self.armoryTableView.frame;
  [self.armoryTableView.superview addSubview:self.carouselView];
  self.carouselView.hidden = YES;
}

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  if (self.isViewLoaded && !self.view.superview) {
    self.view = nil;
    
    self.armoryTableView = nil;
    self.armoryRow = nil;
    self.coinBar = nil;
    self.boosterPacks = nil;
    self.carouselView = nil;
    self.spinner = nil;
    self.loadingView = nil;
  }
}

- (void) viewWillAppear:(BOOL)animated {
  GameState *gs = [GameState sharedGameState];
  if (gs.boosterPacks.count <= 0) {
    [[OutgoingEventController sharedOutgoingEventController] retrieveBoosterPacks];
  }
  
  [self refresh];
  [self.loadingView stop];
  [coinBar updateLabels];
  
  CGRect f = self.view.frame;
  self.view.center = CGPointMake(self.view.center.x, f.size.height*3/2);
  [UIView animateWithDuration:FULL_SCREEN_APPEAR_ANIMATION_DURATION animations:^{
    self.view.center = CGPointMake(self.view.center.x, f.size.height/2);
  }];
  
  [[SoundEngine sharedSoundEngine] armoryEnter];
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  int num = self.boosterPacks.count;
  
  if (num > 0) {
    [self.spinner stopAnimating];
    self.spinner.hidden = YES;
  } else {
    [self.spinner startAnimating];
    self.spinner.hidden = NO;
  }
  
  return num;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"ArmoryRow";
  
  ArmoryRow *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"ArmoryRow" owner:self options:nil];
    cell = self.armoryRow;
  }
  
  BoosterPackProto *bpp = [self.boosterPacks objectAtIndex:indexPath.row];
  [cell updateForBoosterPack:bpp];
  
  return cell;
}

- (void) refresh {
  // Order boosters
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *bp = [NSMutableArray arrayWithArray:gs.boosterPacks];
  [bp sortUsingComparator:^NSComparisonResult(BoosterPackProto *obj1, BoosterPackProto *obj2) {
    return NSOrderedSame;
  }];
  self.boosterPacks = bp;
  
  [self.armoryTableView reloadData];
}

- (IBAction)armoryRowClicked:(UIView *)sender {
  ArmoryRow *row = nil;
  while (![sender isKindOfClass:[ArmoryRow class]]) {
    sender = sender.superview;
  }
  row = (ArmoryRow *)sender;
  
  GameState *gs = [GameState sharedGameState];
  UserBoosterPackProto *userPack = [gs myBoosterPackForId:row.boosterPack.boosterPackId];
  [self.carouselView updateForBoosterPack:row.boosterPack userPack:userPack];
  
  CGRect curRect = self.armoryTableView.frame;
  CGRect r = self.carouselView.frame;
  r.origin.x = self.view.frame.size.width;
  self.carouselView.frame = r;
  self.carouselView.hidden = NO;
  [UIView animateWithDuration:0.3f animations:^{
    CGRect r = self.armoryTableView.frame ;
    r.origin.x = -r.size.width;
    self.armoryTableView.frame = r;
    
    self.carouselView.frame = curRect;
  } completion:^(BOOL finished) {
    self.armoryTableView.frame = curRect;
    self.armoryTableView.hidden = YES;
  }];
}

- (IBAction)backClicked:(id)sender {
  CGRect curRect = self.armoryTableView.frame;
  CGRect r = self.armoryTableView.frame;
  r.origin.x = -r.size.width;
  self.armoryTableView.frame = r;
  self.armoryTableView.hidden = NO;
  [UIView animateWithDuration:0.3f animations:^{
    CGRect r = self.carouselView.frame ;
    r.origin.x = self.view.frame.size.width;
    self.carouselView.frame = r;
    
    self.armoryTableView.frame = curRect;
  } completion:^(BOOL finished) {
    self.carouselView.frame = curRect;
    self.carouselView.hidden = YES;
  }];
}

- (IBAction)purchaseClicked:(UIView *)sender {
  PurchaseOption option = 0;
  if (sender.tag == 1) {
    option = PurchaseOptionOne;
  } else if (sender.tag == 2) {
    option = PurchaseOptionTwo;
  }
  
  [[OutgoingEventController sharedOutgoingEventController] purchaseBoosterPack:self.carouselView.booster.boosterPackId purchaseOption:option];
  [self.loadingView display:self.view];
}

- (IBAction)closeClicked:(id)sender {
  [self close];
}

- (void) close {
  if (self.view.superview) {
    CGRect f = self.view.frame;
    [UIView animateWithDuration:FULL_SCREEN_DISAPPEAR_ANIMATION_DURATION animations:^{
      self.view.center = CGPointMake(self.view.center.x, f.size.height*3/2);
    } completion:^(BOOL finished) {
      [ArmoryViewController removeView];
    }];
    
    [[SoundEngine sharedSoundEngine] armoryLeave];
  }
}

- (void) receivedPurchaseBoosterPackResponse:(PurchaseBoosterPackResponseProto *)proto {
  if (proto.status == PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatusSuccess) {
    [self.view addSubview:_cardDisplayView];
    [self.cardDisplayView beginAnimatingForEquips:proto.userEquipsList];
  }
  
  [self.loadingView stop];
}

@end
