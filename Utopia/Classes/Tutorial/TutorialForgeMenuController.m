//
//  TutorialForgeMenuController.m
//  Utopia
//
//  Created by Ashwin Kamath on 5/22/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "TutorialForgeMenuController.h"
#import "TutorialConstants.h"
#import "DialogMenuController.h"
#import "GenericPopupController.h"
#import "UserData.h"
#import "TutorialTopBar.h"

@implementation TutorialForgeMenuController

- (id) init {
  // Need to load it with carpenter's nib
  return [super initWithNibName:@"ForgeMenuController" bundle:nil];
}

- (void) viewDidLoad {
  [super viewDidLoad];
  self.coinBar.userInteractionEnabled = NO;
  self.navBar.userInteractionEnabled = NO;
  self.slotBar.userInteractionEnabled = NO;
}

- (void) viewDidDisappear:(BOOL)animated {
  [ForgeMenuController purgeSingleton];
}

- (void) viewDidAppear:(BOOL)animated {
  [self.coinBar updateLabels];
  
  [self beforeForgeDialog];
}

- (void) beforeForgeDialog {
  _arrow = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"3darrow.png"]];
  [self displayArrowOnRedButton];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
  return;
}

- (void) forgeButtonClicked:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  int gold = [gl calculateGoldCostToGuaranteeForgingSuccess:self.curItem.equipId level:self.curItem.level];
  NSString *desc = [NSString stringWithFormat:@"Would you like to guarantee success for %d gold?", gold];
  GenericPopup *popup = [GenericPopupController displayConfirmationWithDescription:desc
                                                       title:nil
                                                  okayButton:@"Yes"
                                                cancelButton:@"No"
                                                      target:self
                                                    selector:@selector(submitWithGuarantee)];
  
  [popup.cancelButton removeTarget:popup action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
  [popup.mainView addSubview:_arrow];
  _arrow.center = [popup.mainView convertPoint:ccp(CGRectGetMaxX(popup.okButton.frame)+_arrow.frame.size.width/2, popup.okButton.frame.size.height/2) fromView:popup.okButton.superview];
  [Globals animateUIArrow:_arrow atAngle:M_PI];
}

- (void) submitWithGuarantee {
  ForgeAttempt *fa = [[ForgeAttempt alloc] init];
  fa.blacksmithId = 1;
  fa.equipId = self.curItem.equipId;
  fa.level = 1;
  fa.startTime = [NSDate date];
  fa.isComplete = NO;
  fa.guaranteed = YES;
  fa.slotNumber = 1;
  
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  [gs.myEquips removeObject:[gs myEquipWithUserEquipId:1]];
   [gs.myEquips removeObject:[gs myEquipWithUserEquipId:4]];
  gs.weaponEquipped = 0;
  [gs.forgeAttempts addObject:fa];
  [fa release];
  
  int gold = [gl calculateGoldCostToGuaranteeForgingSuccess:self.curItem.equipId level:self.curItem.level];
  gs.gold -= gold;
  
  [self.coinBar updateLabels];
  
  [self beginForgingSelectedItem];
  [self loadForgeItems];
  
  [self performSelector:@selector(displayArrowOnRedButton) withObject:nil afterDelay:1.f];
}

- (IBAction)finishNowClicked:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  ForgeAttempt *fa = [gs forgeAttemptForSlot:self.slotNumber];
  int gold = [gl calculateGoldCostToSpeedUpForging:fa.equipId level:fa.level];
  NSString *desc = [NSString stringWithFormat:@"Would you like to speed up forging for %d gold?", gold];
  GenericPopup *popup = [GenericPopupController displayConfirmationWithDescription:desc
                                                                             title:nil
                                                                        okayButton:@"Yes"
                                                                      cancelButton:@"No"
                                                                            target:self
                                                                          selector:@selector(finishNow)];
  
  [popup.cancelButton removeTarget:popup action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
  [popup.mainView addSubview:_arrow];
  _arrow.center = [popup.mainView convertPoint:ccp(CGRectGetMaxX(popup.okButton.frame)+_arrow.frame.size.width/2, popup.okButton.frame.size.height/2) fromView:popup.okButton.superview];
  [Globals animateUIArrow:_arrow atAngle:M_PI];
}

- (void) finishNow {
  [super finishNow];
  [self performSelector:@selector(displayArrowOnRedButton) withObject:nil afterDelay:1.f];
}

- (IBAction) checkResultsClicked:(id)sender {
  [super checkResultsClicked:sender];
  
  [_arrow removeFromSuperview];
  
  [self performSelector:@selector(fakeCollectEquipSuccess) withObject:nil afterDelay:1.5f];
  [self performSelector:@selector(arrowOnClose) withObject:nil afterDelay:3.f];
}

- (IBAction)okayClicked:(id)sender {
  return;
}

- (void) fakeCollectEquipSuccess {
  GameState *gs = [GameState sharedGameState];
  UserEquip *ue = [[UserEquip alloc] init];
  ue.equipId = self.curItem.equipId;
  ue.userId = gs.userId;
  ue.level = 2;
  ue.userEquipId = 5;
  [gs.myEquips addObject:ue];
  [ue release];
  
  [gs.forgeAttempts removeAllObjects];
  
  _forgedUserEquipId = ue.userEquipId;
  
  [self forgeSucceeded:2];
  
  self.okayButton.hidden = NO;
  self.collectButton.hidden = YES;
  
  [self loadForgeItems];
  _shouldShake = NO;
}

- (void) displayArrowOnRedButton {
  [self.mainView addSubview:_arrow];
  _arrow.center = [self.mainView convertPoint:ccp(-_arrow.frame.size.width/2, CGRectGetMidY(self.forgeButton.frame)) fromView:self.forgeButton.superview];
  [Globals animateUIArrow:_arrow atAngle:0];
}

- (void) arrowOnClose {
  [self.topBar addSubview:_arrow];
  UIView *close = [self.topBar viewWithTag:20];
  _arrow.center = CGPointMake(CGRectGetMinX(close.frame)-_arrow.frame.size.width/2, close.center.y);
  [Globals animateUIArrow:_arrow atAngle:0];
  
  _canClose = YES;
}

- (IBAction)closeClicked:(id)sender {
  if (_canClose) {
    [super closeClicked:sender];
    
    [(TutorialTopBar *)[TopBar sharedTopBar] beginMyCityPhase];
  }
}

- (void) dealloc {
  [_arrow release];
  [super dealloc];
}

@end
