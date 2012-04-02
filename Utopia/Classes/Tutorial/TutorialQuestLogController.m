//
//  TutorialQuestLogController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/15/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TutorialQuestLogController.h"
#import "GameState.h"
#import "Globals.h"
#import "TutorialMissionMap.h"
#import "DialogMenuController.h"
#import "TutorialConstants.h"

@implementation TutorialQuestLogController

- (id) init {
  // Need to load it with carpenter's nib
  return [super initWithNibName:@"QuestLogController" bundle:nil];
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
//  oldDelegate = self.questDescView.scrollView.delegate;
//  self.questDescView.scrollView.delegate = self;
}

- (void) displayRightPageForQuest:(id)fqp inProgress:(BOOL)inProgress {
  _tutQuest = (StartupResponseProto_TutorialConstants_FullTutorialQuestProto *)fqp;
  
  CGRect r = self.rightPage.frame;
  r.origin.x = 265;
  r.origin.y = 12;
  self.rightPage.frame = r;
  [self refreshQuestDescView];
  [[[[CCDirector sharedDirector] openGLView] superview] addSubview:self.rightPage];
  self.questDescView.alpha = 1.f;
  self.taskView.alpha = 0.f;
  
  [self.taskView unloadTasks];
  [self loadTutQuestData:fqp];
  
  self.toTaskButton.hidden = YES;
  _canClose = NO;
  _acceptingPhase = NO;
  
  if (!inProgress) {
    // Don't release.. need to use later for redeem
    _arrow = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"green.png"]];
    [self.questDescView addSubview:_arrow];
    _arrow.layer.transform = CATransform3DMakeRotation(-M_PI/2, 0.0f, 0.0f, 1.0f);
    
    _arrow.center = CGPointMake(CGRectGetMinX(self.acceptButtons.frame)-_arrow.frame.size.width/2-10, self.acceptButtons.center.y);
    
    UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat;
    [UIView animateWithDuration:1.f delay:0.f options:opt animations:^{
      _arrow.center = CGPointMake(_arrow.center.x+10, _arrow.center.y);
    } completion:nil];
    
//    CGRect r = self.questDescView.scrollView.frame;
//    int offset = 20;
//    _arrow.center = CGPointMake(CGRectGetMaxX(r)+3, CGRectGetMinY(r)+offset);
//    
//    UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat;
//    [UIView animateWithDuration:2.f delay:0.f options:opt animations:^{
//      _arrow.center = CGPointMake(_arrow.center.x, CGRectGetMaxY(r)-offset);
//    } completion:nil];
    
    self.acceptButtons.hidden = NO;
    self.redeemButton.hidden = YES;
    
    _acceptingPhase = YES;
  } else {
    [self.questDescView addSubview:_arrow];
    _arrow.center = CGPointMake(CGRectGetMinX(self.redeemButton.frame)-_arrow.frame.size.width-5, self.redeemButton.center.y);
    
    UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat;
    [UIView animateWithDuration:1.f delay:0.f options:opt animations:^{
      _arrow.center = CGPointMake(_arrow.center.x+10, _arrow.center.y);
    } completion:nil];
    
    self.acceptButtons.hidden = YES;
    self.redeemButton.hidden = NO;
  }
}

- (void) loadTutQuestData:(StartupResponseProto_TutorialConstants_FullTutorialQuestProto *)quest {
  // Not actually using _battleDone and _taskDone. Can add this later if right page is shown at some point
  // after quest accept
  GameState *gs = [GameState sharedGameState];
  UserType typeOfEnemy = gs.type < 3 ? UserTypeBadWarrior : UserTypeGoodWarrior;
  TaskItemView *tiv = [[TaskItemView alloc] initWithFrame:CGRectMake(0, 0, self.taskView.scrollView.frame.size.width, 0) 
                                                     text:[NSString stringWithFormat:@"Defeat 1 %@ %@", [Globals factionForUserType:typeOfEnemy], [Globals classForUserType:typeOfEnemy]]
                                             taskFinished:0
                                                    outOf:1
                                                     type:kDefeatTypeJob 
                                                    jobId:0];
  [self.taskView.scrollView addSubview:tiv];
  [self.taskView.taskItemViews addObject:tiv];
  [tiv release];
  
  FullTaskProto *q = gs.type < 3 ? quest.firstTaskGood : quest.firstTaskBad;
  tiv = [[TaskItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tiv.frame), self.taskView.scrollView.frame.size.width, 0) 
                                       text:q.name 
                               taskFinished:0
                                      outOf:1
                                       type:kTask 
                                      jobId:0];
  [self.taskView.scrollView addSubview:tiv];
  [self.taskView.taskItemViews addObject:tiv];
  [tiv release];
}

- (void) refreshQuestDescView {
  GameState *gs = [GameState sharedGameState];
  
  [self.questDescView.questDescLabel removeFromSuperview];
  
  self.questDescView.questNameLabel.text = gs.type < 3 ? _tutQuest.goodName : _tutQuest.badName;
  
  // Update the quest description label
  // We will find out how many lines need to be used, so init to zero
  UILabel *tmplabel = [[UILabel alloc] initWithFrame:CGRectZero];
  self.questDescView.questDescLabel = tmplabel;
  [tmplabel release];
  self.questDescView.questDescLabel.textColor = [UIColor blackColor];
  self.questDescView.questDescLabel.font = [UIFont fontWithName:@"AJensonPro-SemiboldDisp" size:14];
  self.questDescView.questDescLabel.numberOfLines = 0;
  self.questDescView.questDescLabel.lineBreakMode = UILineBreakModeWordWrap;
  self.questDescView.questDescLabel.text = gs.type < 3 ? _tutQuest.goodDescription : _tutQuest.badDescription;
  self.questDescView.questDescLabel.backgroundColor = [UIColor clearColor];
  
  //Calculate the expected size based on the font and linebreak mode of label
  CGSize maximumLabelSize = CGSizeMake(self.questDescView.scrollView.frame.size.width-10, 9999);
  CGSize expectedLabelSize = [self.questDescView.questDescLabel.text sizeWithFont:self.questDescView.questDescLabel.font constrainedToSize:maximumLabelSize lineBreakMode:self.questDescView.questDescLabel.lineBreakMode];
  
  //Adjust the label the the new height
  CGRect newFrame = self.questDescView.questDescLabel.frame;
  newFrame.origin.x = 5;
  newFrame.origin.y = self.questDescView.scrollView.topGradient.frame.size.height;
  newFrame.size.width = expectedLabelSize.width;
  newFrame.size.height = expectedLabelSize.height;
  self.questDescView.questDescLabel.frame = newFrame;
  [self.questDescView.scrollView insertSubview:self.questDescView.questDescLabel atIndex:0];
  
  newFrame = self.questDescView.rewardView.frame;
  newFrame.origin = CGPointMake(0, CGRectGetMaxY(self.questDescView.questDescLabel.frame));
  self.questDescView.rewardView.frame = newFrame;
  
  self.questDescView.rewardView.coinRewardLabel.text = [NSString stringWithFormat:@"+%d", _tutQuest.coinsGained];
  self.questDescView.rewardView.expRewardLabel.text = [NSString stringWithFormat:@"+%d", _tutQuest.expGained];
  self.questDescView.rewardView.equipView.hidden = YES;
  
  CGRect rect = self.questDescView.rewardView.frame;
  rect.size.height = self.questDescView.rewardView.equipView.frame.origin.y + 10;
  self.questDescView.rewardView.frame = rect;
  
  self.questDescView.scrollView.contentOffset = CGPointMake(0, 0);
  self.questDescView.scrollView.contentSize = CGSizeMake(self.questDescView.scrollView.frame.size.width, CGRectGetMaxY(self.questDescView.rewardView.frame)+self.questDescView.scrollView.botGradient.frame.size.height);
}

- (IBAction)acceptTapped:(id)sender {
  if (_acceptingPhase) {
    [[TutorialMissionMap sharedTutorialMissionMap] questGiverInProgress];
    self.acceptButtons.hidden = YES;
    self.toTaskButton.hidden = NO;
    [self taskButtonTapped:nil];
    
    TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
    [DialogMenuController displayViewForText:tc.afterQuestAcceptText callbackTarget:nil action:nil];
    [_arrow removeFromSuperview];
    
    [self performSelector:@selector(arrowOnClose) withObject:nil afterDelay:2.f];
    
    _canClose = YES;
  }
}

- (void) arrowOnClose {
  // Move arrow to close button (tag 20)
  [self.rightPage addSubview:_arrow];
  UIView *close = [self.rightPage viewWithTag:20];
  [_arrow.layer removeAllAnimations];
  _arrow.center = CGPointMake(CGRectGetMinX(close.frame)-_arrow.frame.size.width/2, close.center.y);
  
  _arrow.alpha = 0.f;
  UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat;
  // This is confusing, basically fade in, and then do repeated animation
  [UIView animateWithDuration:0.3f animations:^{
    _arrow.alpha = 1.f;
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:1.f delay:0.f options:opt animations:^{
      _arrow.center = CGPointMake(_arrow.center.x+10, _arrow.center.y);
    } completion:nil];
  }];
}

- (IBAction)closeButtonClicked:(id)sender {
  if (_canClose) {
    [super closeButtonClicked:sender];
    [[TutorialMissionMap sharedTutorialMissionMap] questLogClosed];
    [_arrow removeFromSuperview];
  }
}

- (IBAction)redeemTapped:(id)sender {
  [_arrow removeFromSuperview];
  [super closeButtonClicked:nil];
  [[TutorialMissionMap sharedTutorialMissionMap] redeemComplete];
}

- (void) didReceiveMemoryWarning {
  return;
}

//- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
//  [oldDelegate scrollViewDidScroll:scrollView];
//  if (scrollView.contentOffset.y+scrollView.frame.size.height >= scrollView.contentSize.height) {
//    // Scrollview reached the bottom, let's allow accept
//    _acceptingPhase = YES;
//    [_arrow removeFromSuperview];
//    [self.questDescView addSubview:_arrow];
//    _arrow.layer.transform = CATransform3DMakeRotation(-M_PI/2, 0.0f, 0.0f, 1.0f);
//    
//    _arrow.center = CGPointMake(CGRectGetMinX(self.acceptButtons.frame)-_arrow.frame.size.width/2-10, self.acceptButtons.center.y);
//    
//    UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat;
//    [UIView animateWithDuration:1.f delay:0.f options:opt animations:^{
//      _arrow.center = CGPointMake(_arrow.center.x+10, _arrow.center.y);
//    } completion:nil];
//  }
//}

- (void) dealloc {
  [_arrow release];
  [super dealloc];
}

@end
