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

@implementation BossEventCard

- (void) loadForEquipId:(int)equipId tagImage:(NSString *)tagImage {
  [Globals imageNamed:tagImage withImageView:self.tagIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:equipId];
  self.equipIcon.equipId = equipId;
  self.attackLabel.text = [Globals commafyNumber:[gl calculateAttackForEquip:equipId level:1]];
  self.defenseLabel.text = [Globals commafyNumber:[gl calculateDefenseForEquip:equipId level:1]];
  self.nameLabel.text = fep.name;
  self.nameLabel.textColor = [Globals colorForRarity:fep.rarity];
}

@end

@implementation BossEventMenuController

@synthesize mainView, bgdView;
@synthesize timer;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(BossEventMenuController);

//- (id) init {
//  Globals *gl = [Globals sharedGlobals];
//  return [self initWithNibName:@"BossEventMenuController" bundle:[Globals bundleNamed:gl.downloadableNibConstants.BossEventNibName]];
//}

- (void) viewWillAppear:(BOOL)animated {
  [self loadForCurrentEvent];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
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

- (void) loadForCurrentEvent {
  GameState *gs = [GameState sharedGameState];
  BossEventProto *lbe = [gs getCurrentBossEvent];
  
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

- (IBAction)visitBossClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  BossEventProto *lbe = [gs getCurrentBossEvent];
  
  if (lbe) {
    // Assume boss is asset 1
    [[OutgoingEventController sharedOutgoingEventController] loadNeutralCity:lbe.cityId asset:1];
    [self closeClicked:nil];
  } else {
    [Globals popupMessage:@"Woops! The event has ended! Try again next time."];
  }
}

- (IBAction)closeClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
  }];
}

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  if (!self.view.superview) {
    self.view = nil;
    self.eventTimeLabel = nil;
    self.mainView = nil;
    self.bgdView = nil;
    self.timer = nil;
  }
}

@end
