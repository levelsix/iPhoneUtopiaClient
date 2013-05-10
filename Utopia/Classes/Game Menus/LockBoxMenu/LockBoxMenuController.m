//
//  LockBoxMenuController.m
//  Utopia
//
//  Created by Ashwin Kamath on 9/30/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "LockBoxMenuController.h"
#import "LNSynthesizeSingleton.h"
#import "GameState.h"
#import "Globals.h"
#import "Protocols.pb.h"
#import "GoldShoppeViewController.h"
#import "GenericPopupController.h"
#import "RefillMenuController.h"

@implementation LockBoxMenuController

@synthesize bottomPickLabel, chestIcon, eventTimeLabel;
@synthesize goldLabel, silverLabel, topPickLabel, numBoxesLabel;
@synthesize itemView1, itemView2, itemView3, itemView4, itemView5;
@synthesize mainView, bgdView;
@synthesize timer, lockBoxInfoView;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(LockBoxMenuController);

- (id) init {
  Globals *gl = [Globals sharedGlobals];
  return [self initWithNibName:@"LockBoxMenuController" bundle:[Globals bundleNamed:gl.downloadableNibConstants.lockBoxNibName]];
}

- (void) viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  itemViews = [[NSArray arrayWithObjects:itemView1, itemView2, itemView3, itemView4, itemView5, nil] retain];
}

- (void) viewWillAppear:(BOOL)animated {
  [self loadForCurrentEvent];
  
  [self.pickView removeFromSuperview];
  
  [Globals bounceView:mainView fadeInBgdView:bgdView];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabels) name:IAP_SUCCESS_NOTIFICATION object:nil];
}

- (void) viewDidDisappear:(BOOL)animated {
  self.timer = nil;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setTimer:(NSTimer *)t {
  if (timer != t) {
    [timer invalidate];
    [timer release];
    timer = [t retain];
  }
}

- (LockBoxInfoView *) lockBoxInfoView {
  if (!lockBoxInfoView) {
    Globals *gl = [Globals sharedGlobals];
#warning change back
    NSBundle *bundle = [NSBundle mainBundle]; //[Globals bundleNamed:gl.downloadableNibConstants.lockBoxNibName]
    [bundle loadNibNamed:@"LockBoxInfoView" owner:self options:nil];
  }
  return lockBoxInfoView;
}

- (void) loadForCurrentEvent {
  GameState *gs = [GameState sharedGameState];
  LockBoxEventProto *lbe = [gs getCurrentLockBoxEvent];
  
  NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:lbe.endDate/1000.0];
  int secs = endDate.timeIntervalSinceNow;
  if (!lbe || secs < 0) {
    [self closeClicked:nil];
    self.timer = nil;
    return;
  }
  
  UserLockBoxEventProto *ulbe = [gs.myLockBoxEvents objectForKey:[NSNumber numberWithInt:lbe.lockBoxEventId]];
  
  [Globals imageNamed:lbe.lockBoxImageName withView:chestIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  [self loadItems:lbe.itemsList userItems:ulbe.itemsList];
  
  [self updateLabels];
  self.timer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void) loadItems:(NSArray *)items userItems:(NSArray *)userItems {
  NSMutableArray *a = [[items mutableCopy] autorelease];
  NSMutableArray *ivs = [itemViews.mutableCopy autorelease];
  
  for (LockBoxItemProto *item in a) {
    UserLockBoxItemProto *ui = nil;
    for (UserLockBoxItemProto *userItem in userItems) {
      if (userItem.lockBoxItemId == item.lockBoxItemId) {
        ui = userItem;
        break;
      }
    }
    
    LockBoxItemView *iv = [ivs objectAtIndex:0];
    [iv loadForImage:item.imageName quantity:ui.quantity itemId:item.lockBoxItemId];
    [ivs removeObjectAtIndex:0];
  }
}

- (void) updateLabels {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  LockBoxEventProto *lbe = [gs getCurrentLockBoxEvent];
  
  NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:lbe.endDate/1000.0];
  int secs = endDate.timeIntervalSinceNow;
  if (!lbe || secs < 0) {
    [self loadForCurrentEvent];
    return;
  }
  
  UserLockBoxEventProto *ulbe = [gs.myLockBoxEvents objectForKey:[NSNumber numberWithInt:lbe.lockBoxEventId]];
  numBoxesLabel.text = [NSString stringWithFormat:@"x%d", ulbe.numLockBoxes];
  
  goldLabel.text = [Globals commafyNumber:gs.gold];
  silverLabel.text = [Globals commafyNumber:gs.silver];
  
  int days = (int)(secs/86400);
  secs %= 86400;
  eventTimeLabel.text = [NSString stringWithFormat:@"EVENT ENDS IN %d DAYS, %@", days, [Globals convertTimeToString:secs withDays:NO]];
  
  NSDate *curDate = [NSDate date];
  NSDate *nextPickDate = [NSDate dateWithTimeIntervalSince1970:ulbe.lastPickTime/1000.0 + 60*gl.numMinutesToRepickLockBox];
  if ([curDate compare:nextPickDate] == NSOrderedDescending) {
    topPickLabel.text = [NSString stringWithFormat:@"You have %d unopened chests.", ulbe.numLockBoxes];
    bottomPickLabel.text = @"You may attempt picking 1 now.";
    bottomPickLabel.textColor = [Globals greenColor];
  } else {
    topPickLabel.text = @"You can pick a box in:";
    bottomPickLabel.textColor = [Globals creamColor];
    
    int secs = nextPickDate.timeIntervalSinceNow;
    int mins = secs / 60;
    secs %= 60;
    bottomPickLabel.text = [NSString stringWithFormat:@"%02d:%02d", mins, secs];
  }
}

- (IBAction)pickNowClicked:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  LockBoxEventProto *lbe = [gs getCurrentLockBoxEvent];
  UserLockBoxEventProto *ulbe = [gs.myLockBoxEvents objectForKey:[NSNumber numberWithInt:lbe.lockBoxEventId]];
  
  if (ulbe.numLockBoxes > 0) {
    uint64_t secs = [[NSDate date] timeIntervalSince1970];
    uint64_t pickTime = ulbe.lastPickTime/1000 + 60*gl.numMinutesToRepickLockBox;
    
    if (secs > pickTime) {
      [self.pickView loadForView:self.view chestImage:lbe.lockBoxImageName reset:NO];
    } else {
      NSString *str = [NSString stringWithFormat:@"Would you like to pick a chest now for %d gold?", gl.goldCostToResetPickLockBox];
      [GenericPopupController displayConfirmationWithDescription:str title:@"Pick Now?" okayButton:@"Pick" cancelButton:nil target:self selector:@selector(openPickViewWithReset)];
    }
    
  } else {
    [Globals popupMessage:@"You must acquire unopened chests first!"];
  }
}

- (void) openPickViewWithReset {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  LockBoxEventProto *lbe = [gs getCurrentLockBoxEvent];
  if (gs.gold < gl.goldCostToResetPickLockBox) {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:gl.goldCostToResetPickLockBox];
  } else {
    [self.pickView loadForView:self.view chestImage:lbe.lockBoxImageName reset:YES];
  }
}

- (IBAction)goldBarClicked:(id)sender {
  [GoldShoppeViewController displayView];
}

- (IBAction)closeClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
  }];
}

- (IBAction)infoClicked:(id)sender {
  [self.lockBoxInfoView displayForCurrentLockBoxEvent];
}

- (void) flyItemToBottom:(LockBoxItemProto *)item prizeEquip:(FullUserEquipProto *)prizeEquip {
  LockBoxItemView *iv = nil;
  for (LockBoxItemView *itemView in itemViews) {
    if (itemView.itemId == item.lockBoxItemId) {
      iv = itemView;
    }
  }
  
  if (iv) {
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:[iv convertRect:self.pickView.chestIcon.frame fromView:self.pickView]];
    [iv insertSubview:imgView aboveSubview:iv.maskedItemIcon];
    imgView.contentMode = iv.itemIcon.contentMode;
    [Globals imageNamed:item.imageName withView:imgView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    [UIView animateWithDuration:0.9f animations:^{
      imgView.frame = iv.itemIcon.frame;
    } completion:^(BOOL finished) {
      [iv loadForImage:item.imageName quantity:iv.quantity+1 itemId:iv.itemId];
      [imgView removeFromSuperview];
      [imgView release];
      
      if (prizeEquip) {
        NSArray *arr = [NSArray arrayWithObjects:itemView1.itemIcon, itemView2.itemIcon, itemView3.itemIcon, itemView4.itemIcon, itemView5.itemIcon, nil];
        [self.prizeView beginPrizeAnimationForImageView:arr prize:prizeEquip];
        [self.view addSubview:self.prizeView];
      }
    }];
  }
}

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  if (self.isViewLoaded && !self.view.superview) {
    self.view = nil;
    self.bottomPickLabel = nil;
    self.chestIcon = nil;
    self.eventTimeLabel = nil;
    self.goldLabel = nil;
    self.silverLabel = nil;
    self.topPickLabel = nil;
    self.numBoxesLabel = nil;
    self.itemView1 = nil;
    self.itemView2 = nil;
    self.itemView3 = nil;
    self.itemView4 = nil;
    self.itemView5 = nil;
    self.mainView = nil;
    self.bgdView = nil;
    self.timer = nil;
    [lockBoxInfoView removeFromSuperview];
    self.lockBoxInfoView = nil;
    [itemViews release];
  }
}

@end
