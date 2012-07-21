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
#import "TutorialTopBar.h"
#import "TutorialProfilePicture.h"
#import "TutorialConstants.h"
#import "DialogMenuController.h"
#import "GameLayer.h"
#import "OutgoingEventController.h"
#import "GameViewController.h"
#import "ProfileViewController.h"
#import "SoundEngine.h"

@implementation TutorialHomeMap

@synthesize tutCoords;

- (void) refresh {
  return;
}

- (void) preparePurchaseOfStruct:(int)structId {
  [super preparePurchaseOfStruct:structId];
  
  [_purchBuilding liftBlock];
  
  // Move purch building off the road
  CGRect r = _purchBuilding.location;
  r.origin = ccpAdd(r.origin, ccp(3, -2));
  _purchBuilding.location = r;
  
  [_purchBuilding placeBlock];
  
  [self openMoveMenuOnSelected];
  
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [DialogMenuController displayViewForText:tc.beforePlacingText];
}

- (void) startCarpPhase {
  _carpenterPhase = YES;
  
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [DialogMenuController displayViewForText:tc.beforeCarpenterText];
  
  [self moveToSprite:_carpenter];
  self.position = ccpAdd(self.position, ccp(120, 0));
  
  _ccArrow = [[CCSprite spriteWithFile:@"3darrow.png"] retain];
  [_carpenter addChild:_ccArrow z:2000];
  _ccArrow.position = ccp(_carpenter.contentSize.width/2, _carpenter.contentSize.height+_ccArrow.contentSize.height/2+40);
  [Globals animateCCArrow:_ccArrow atAngle:-M_PI_2];
  
  [TutorialCarpenterMenuController sharedCarpenterMenuController];
}

- (void) tap:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  if (!_canMove) {
    [super tap:recognizer node:node];
    
    CGPoint pt = [recognizer locationInView:recognizer.view];
    pt = [[CCDirector sharedDirector] convertToGL:pt];
    if (_carpenterPhase  && [self selectableForPt:pt] == _carpenter) {
      _carpenterPhase = NO;
      
      [DialogMenuController closeView];
      
      // Reset ccArrow
      [_ccArrow removeFromParentAndCleanup:YES];
    } else if (_waitingForBuildPhase && [_selected isKindOfClass:[MoneyBuilding class]]) {
      [DialogMenuController closeView];
      
      [_ccArrow removeFromParentAndCleanup:YES];
      
      [_uiArrow removeFromSuperview];
      [_uiArrow release];
      _uiArrow = nil;
      
      _uiArrow = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"3darrow.png"]];
      UIView *finishNowButton = [self.upgradeMenu.upgradingBottomView viewWithTag:17];
      [self.upgradeMenu.upgradingBottomView addSubview:_uiArrow];
      _uiArrow.center = CGPointMake(CGRectGetMinX(finishNowButton.frame)-_uiArrow.frame.size.width/2, finishNowButton.center.y);
      _uiArrow.tag = 111;
      [Globals animateUIArrow:_uiArrow atAngle:0];
    } else {
      self.selected = nil;
    }
  }
}

- (void) createMyPlayer {
  return;
}

- (SelectableSprite *) selectableForPt:(CGPoint)pt {
  // Find sprite that has center closest to pt
  SelectableSprite *node = nil;
  if (_carpenterPhase) {
    node = _carpenter;
  } else if (_canMove) {
    node = _purchBuilding;
  } else if (_waitingForBuildPhase) {
    node = _constrBuilding;
  }
  CGRect r = CGRectZero;
  r.origin = CGPointMake(-20, -5);
  pt = [node convertToNodeSpace:pt];
  r.size = CGSizeMake(node.contentSize.width+40, node.contentSize.height+150);
  if (CGRectContainsPoint(r, pt)) {
    return node;
  }
  return nil;
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
    
    _waitingForBuildPhase = YES;
    
    TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
    [DialogMenuController displayViewForText:tc.afterPurchaseText];
    
    [_ccArrow removeFromParentAndCleanup:YES];
    [_constrBuilding addChild:_ccArrow];
    _ccArrow.position = ccp(_constrBuilding.contentSize.width/2, _constrBuilding.contentSize.height+_ccArrow.contentSize.height/2);
    [Globals animateCCArrow:_ccArrow atAngle:-M_PI_2];
    
    // Set the struct coords and time of purchase
    tc.structCoords = moneyBuilding.location.origin;
    tc.structTimeOfPurchase = [NSDate date];
    
    _canMove = NO;
    self.selected = nil;
    [self doReorder];
    
    [Analytics tutorialPlaceInn];
    
    [[SoundEngine sharedSoundEngine] carpenterPurchase];
  }
}

- (IBAction)beginMoveClicked:(id)sender {
  return;
}

- (IBAction)sellClicked:(id)sender {
  return;
}

- (void) buildComplete:(NSTimer *)timer {
  MoneyBuilding *mb = [timer userInfo];
  UserStruct *userStruct = mb.userStruct;
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:userStruct.structId];
  
  userStruct.lastRetrieved = [NSDate dateWithTimeInterval:fsp.minutesToBuild*60 sinceDate:userStruct.purchaseTime];
  userStruct.isComplete = YES;
  
  mb.isConstructing = NO;
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
  
  int64_t ms = (uint64_t)([[NSDate date] timeIntervalSince1970]*1000);
  userStruct.isComplete = YES;
  userStruct.lastRetrieved = [NSDate dateWithTimeIntervalSince1970:ms/1000.f];
  
  // Update game state
  FullStructureProto *fsp = [gs structWithId:userStruct.structId];
  gs.gold -= fsp.instaBuildDiamondCost;
  
  [_uiArrow removeFromSuperview];
  
  _constrBuilding = nil;
  
  [self.upgradeMenu finishNow:^{
    mb.isConstructing = NO;
    [self  buildingComplete];
  }];
  
  [self updateTimersForBuilding:mb];
  
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  tc.structUsedDiamonds = YES;
  
  [Analytics tutorialFinishNow];
}

- (void) buildingComplete {
  self.selected = nil;
  
  [self.upgradeMenu closeClicked:nil];
  
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  tc.structTimeOfBuildComplete = [NSDate date];
  
  [(TutorialProfilePicture *)[TutorialTopBar sharedTopBar].profilePic beginFaceDialPhase];
  
  _waitingForBuildPhase = NO;
  
  _ccArrow.visible = NO;
  [_uiArrow removeFromSuperview];
}

- (void) drag:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  [super drag:recognizer node:node];
  if (_canMove) {
    [DialogMenuController closeView];
  }
}

- (void) startGoToAviaryPhase {
  _goToAviary = YES;
}

- (void) endTutorial {
  [self removeFromParentAndCleanup:YES];
  
  [[GameState sharedGameState] setIsTutorial:NO];
  
  [[TopBar sharedTopBar] removeFromParentAndCleanup:YES];
  [TutorialHomeMap purgeSingleton];
  [ProfileViewController purgeSingleton];
  [TutorialConstants purgeSingleton];
  [TopBar purgeSingleton];
  
  [[GameLayer sharedGameLayer] begin];
  [[TopBar sharedTopBar] start];
  [[HomeMap sharedHomeMap] refresh];
  [[CCDirector sharedDirector] purgeCachedData];
  
  [Analytics tutorialComplete];
}

- (void) dealloc {
  [_ccArrow release];
  [_uiArrow release];
  self.tutCoords = nil;
  [super dealloc];
}

@end
