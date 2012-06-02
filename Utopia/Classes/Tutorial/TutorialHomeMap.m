//
//  TutorialHomeMap.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/13/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TutorialHomeMap.h"
#import "Globals.h"
#import "GameState.h"
#import "TutorialCarpenterMenuController.h"
#import "TopBar.h"
#import "TutorialConstants.h"
#import "DialogMenuController.h"
#import "GameLayer.h"
#import "OutgoingEventController.h"
#import "GameViewController.h"

@implementation TutorialHomeMap

@synthesize tutCoords;

- (void) refresh {
//  Globals *gl = [Globals sharedGlobals];
//  GameState *gs = [GameState sharedGameState];
  
  if (_refreshed) {
    return;
  }
  _refreshed = YES;
  
  // Add aviary
//  UserCritStruct *cs = [[UserCritStruct alloc] init];
//  cs.type = CritStructTypeAviary;
//  cs.location = CGRectMake(10, 10, gl.aviaryXLength, gl.aviaryYLength);
//  cs.orientation = StructOrientationPosition1;
//  cs.name = @"Aviary";
//  cs.minLevel = 1;
//  cs.size = CGSizeMake(gl.aviaryXLength, gl.aviaryYLength);
//  [gs.myCritStructs addObject:cs];
//  
//  _av = [[Aviary alloc] initWithFile:@"Aviary.png" location:cs.location map:self];
//  [self addChild:_av];
//  [_av release];
//  
//  _av.orientation = cs.orientation;
//  [self changeTiles:_av.location toBuildable:NO];
//  [cs release];
//  
//  // Add carpenter
//  cs = [[UserCritStruct alloc] init];
//  cs.type = CritStructTypeCarpenter;
//  cs.location = CGRectMake(10, 6, gl.carpenterXLength, gl.carpenterYLength);
//  cs.orientation = StructOrientationPosition1;
//  cs.name = @"Carpenter";
//  cs.minLevel = 1;
//  cs.size = CGSizeMake(gl.carpenterXLength, gl.carpenterYLength);
//  [gs.myCritStructs addObject:cs];
//  
//  _csb = [[CritStructBuilding alloc] initWithFile:[cs.name stringByAppendingString:@".png"] location:cs.location map:self];
//  [self addChild:_csb];
//  [_csb release];
//  
//  _csb.orientation = cs.orientation;
//  _csb.critStruct = cs;
//  [cs release];
  
  _carpenterPhase = YES;
  
  TopBar *tb = [TopBar sharedTopBar];
  [tb setIsTouchEnabled:NO];
}

- (void) preparePurchaseOfStruct:(int)structId {
  [super preparePurchaseOfStruct:structId];
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [DialogMenuController displayViewForText:tc.beforePlacingText callbackTarget:nil action:nil];
}

- (void) beforeCarpDialog {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [DialogMenuController displayViewForText:tc.beforeCarpenterText callbackTarget:nil action:nil];
  
  [self moveToSprite:_csb];
  _ccArrow = [[CCSprite spriteWithFile:@"3darrow.png"] retain];
  [self addChild:_ccArrow z:2000];
  _ccArrow.position = ccp(_csb.position.x, _csb.position.y+_csb.contentSize.height+_ccArrow.contentSize.height/2);
  
  CCMoveBy *upAction = [CCEaseSineInOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, 20)]];
  [_ccArrow runAction:[CCRepeatForever actionWithAction:[CCSequence actions:upAction, 
                                                         [upAction reverse], nil]]];
}

- (void) tap:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  if (!_visitCarpPhase) {
    [super tap:recognizer node:node];
    if (_carpenterPhase && _selected == _csb) {
      _carpenterPhase = NO;
      _visitCarpPhase = YES;
      
      // Reset ccArrow
      [_ccArrow stopAllActions];
      _ccArrow.visible = NO;
      
//      _uiArrow = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"3darrow.png"]];
//      [self.csMenu addSubview:_uiArrow];
//      _uiArrow.layer.transform = CATransform3DMakeRotation(-M_PI/2, 0.0f, 0.0f, 1.0f);
//      
//      [TutorialCarpenterMenuController sharedCarpenterMenuController];
//      
//      UIView *enterButton = [self.csMenu viewWithTag:10];
//      _uiArrow.center = CGPointMake(-_uiArrow.frame.size.width/2+10, enterButton.center.y);
//      
//      UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat;
//      [UIView animateWithDuration:1.f delay:0.f options:opt animations:^{
//        _uiArrow.center = CGPointMake(-_uiArrow.frame.size.width/2, enterButton.center.y);
//      } completion:nil];
    } else if (_waitingForBuildPhase && [_selected isKindOfClass:[MoneyBuilding class]]) {
      [_ccArrow stopAllActions];
      _ccArrow.visible = NO;
      [_uiArrow removeFromSuperview];
      [self.hbMenu addSubview:_uiArrow];
      UIView *finishNowButton = [self.hbMenu viewWithTag:17];
      _uiArrow.center = CGPointMake(-_uiArrow.frame.size.width/2+10, finishNowButton.center.y);
      
      UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat;
      [UIView animateWithDuration:1.f delay:0.f options:opt animations:^{
        _uiArrow.center = CGPointMake(_uiArrow.center.x-10, _uiArrow.center.y);
      } completion:nil];
    } else {
      self.selected = nil;
    }
  }
}

- (IBAction)criticalStructMoveClicked:(id)sender {
  return;
}

- (IBAction)rotateClicked:(id)sender {
  return;
}

- (IBAction)cancelMoveClicked:(id)sender {
  return;
}

- (IBAction)bigUpgradeClicked:(id)sender {
  return;
}

- (IBAction)leftButtonClicked:(id)sender {
  return;
}

- (IBAction)redButtonClicked:(id)sender {
  return;
}

- (IBAction)moveCheckClicked:(id)sender {
  MoneyBuilding *moneyBuilding = (MoneyBuilding *)_selected;
  if (moneyBuilding.isSetDown) {
    _canMove = NO;
    self.selected = nil;
    [self doReorder];
    
    _purchasing = NO;
    _constrBuilding = moneyBuilding;
    
    GameState *gs = [GameState sharedGameState];
    FullStructureProto *fsp = [gs structWithId:_purchStructId];
    UserStruct *us = [[UserStruct alloc] init];
    
    // UserStructId will come in the response
    us.userId = [[GameState sharedGameState] userId];
    us.structId = fsp.structId;
    us.level = 1;
    us.isComplete = NO;
    us.coordinates = moneyBuilding.location.origin;
    us.orientation = 0;
    us.purchaseTime = [NSDate date];
    us.lastRetrieved = nil;
    moneyBuilding.userStruct = us;
    [[gs myStructs] addObject:us];
    [us release];
    
    _constrBuilding = moneyBuilding;
    _purchBuilding = nil;
    
    self.tutCoords = [[[[CoordinateProto builder] setX:moneyBuilding.location.origin.x] setY:moneyBuilding.location.origin.y] build];
    
    // Update game state
    gs.silver -= fsp.coinPrice;
    gs.gold -= fsp.diamondPrice;
    
    moneyBuilding.userStruct = us;
    [self updateTimersForBuilding:_constrBuilding];
    moneyBuilding.isConstructing = YES;
    
    _visitCarpPhase = NO;
    _waitingForBuildPhase = YES;
    
    TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
    [DialogMenuController displayViewForText:tc.afterPurchaseText callbackTarget:nil action:nil];
    
    _ccArrow.visible = YES;
    _ccArrow.position = ccp(_constrBuilding.position.x, _constrBuilding.position.y+_constrBuilding.contentSize.height+_ccArrow.contentSize.height/2);
    
    CCMoveBy *upAction = [CCEaseSineInOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, 20)]];
    [_ccArrow runAction:[CCRepeatForever actionWithAction:[CCSequence actions:upAction, 
                                                           [upAction reverse], nil]]];
    
    // Set the struct coords and time of purchase
    tc.structCoords = moneyBuilding.location.origin;
    tc.structTimeOfPurchase = [NSDate date];
    
    [Analytics tutorialPlaceInn];
  }
}

- (void) buildComplete:(NSTimer *)timer {
  MoneyBuilding *mb = [timer userInfo];
  UserStruct *userStruct = mb.userStruct;
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:userStruct.structId];
  
  userStruct.lastRetrieved = [NSDate dateWithTimeInterval:fsp.minutesToBuild*60 sinceDate:userStruct.purchaseTime];
  userStruct.isComplete = YES;
  
  [self updateTimersForBuilding:mb];
//  if (mb == _selected && self.hbMenu.state != kMoveState) {
//    [self.hbMenu updateLabelsForUserStruct:mb.userStruct];
//  }
  mb.isConstructing = NO;
//  [self updateHomeBuildingMenu];
  _constrBuilding = nil;
  
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  tc.structUsedDiamonds = NO;
  [self buildingComplete];
  [Analytics tutorialWaitBuild];
}

- (IBAction)finishNowClicked:(id)sender {
  MoneyBuilding *mb = (MoneyBuilding *)_selected;
  UserStruct *userStruct = mb.userStruct;
  GameState *gs = [GameState sharedGameState];
//  self.hbMenu.finishNowButton.enabled = NO;
//  self.hbMenu.blueButton.enabled = NO;
  
  int64_t ms = (uint64_t)([[NSDate date] timeIntervalSince1970]*1000);
  userStruct.isComplete = YES;
  userStruct.lastRetrieved = [NSDate dateWithTimeIntervalSince1970:ms/1000];
  
  // Update game state
  FullStructureProto *fsp = [gs structWithId:userStruct.structId];
  gs.gold -= fsp.instaBuildDiamondCost;
  
  _constrBuilding = nil;
  
  [[[CCDirector sharedDirector] openGLView] setUserInteractionEnabled:NO];
  // animate bar to top
//  [self.hbMenu.timer invalidate];
//  float secs = PROGRESS_BAR_SPEED*(1-[self.hbMenu progressBarProgress]);
//  [UIView animateWithDuration:secs animations:^{
//    [self.hbMenu setProgressBarProgress:1.f];
//  } completion:^(BOOL finished) {
//    [self.hbMenu updateLabelsForUserStruct:mb.userStruct];
//    [self.hbMenu startTimer];
//    self.hbMenu.finishNowButton.enabled = YES;
//    self.hbMenu.blueButton.enabled = YES;
//    [[[CCDirector sharedDirector] openGLView] setUserInteractionEnabled:YES];
//    [self updateHomeBuildingMenu];
//    mb.isConstructing = NO;
//    [self buildingComplete];
//  }];
  [self updateTimersForBuilding:mb];
  
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  tc.structUsedDiamonds = YES;
  
  [Analytics tutorialFinishNow];
}

- (void) buildingComplete {
  self.selected = nil;
  
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  GameState *gs = [GameState sharedGameState];
  [DialogMenuController incrementProgress];
  [DialogMenuController displayViewForText:[NSString stringWithFormat:tc.afterSpeedUpText, [Globals factionForUserType:gs.type]] callbackTarget:self action:@selector(showReferralDialog)];
  
  tc.structTimeOfBuildComplete = [NSDate date];
  
  _waitingForBuildPhase = NO;
  
  _ccArrow.visible = NO;
  [_uiArrow removeFromSuperview];
  
}

- (void) showReferralDialog {
  [DialogMenuController incrementProgress];
  [DialogMenuController displayViewForReferral];
}

- (void) startGoToAviaryPhase {
  _goToAviary = YES;
}

- (void) endTutorial {
  [self removeFromParentAndCleanup:YES];
  [[TopBar sharedTopBar] removeFromParentAndCleanup:YES];
  [TutorialHomeMap purgeSingleton];
  [TutorialConstants purgeSingleton];
  [TopBar purgeSingleton];
  
  [[GameLayer sharedGameLayer] begin];
  [[TopBar sharedTopBar] start];
  [[HomeMap sharedHomeMap] refresh];
  [[CCDirector sharedDirector] purgeCachedData];
  
  [[GameState sharedGameState] setIsTutorial:NO];
  
  [Analytics tutorialComplete];
}

- (void) dealloc {
  [_ccArrow release];
  [_uiArrow release];
  self.tutCoords = nil;
  [super dealloc];
}

@end
