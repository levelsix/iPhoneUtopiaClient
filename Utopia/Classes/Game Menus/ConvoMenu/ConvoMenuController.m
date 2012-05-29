//
//  ConvoMenuController.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/22/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ConvoMenuController.h"
#import "LNSynthesizeSingleton.h"
#import "cocos2d.h"
#import "Globals.h"
#import "QuestLogController.h"
#import "OutgoingEventController.h"

@implementation ConvoMenuController

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(ConvoMenuController);

@synthesize mainView, bgdView;
@synthesize speechLabel, speakerImageView, speakerNameLabel;
@synthesize prevButton;
@synthesize quest;

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
}

- (void) viewDidDisappear:(BOOL)animated {
  self.quest = nil;
}

- (void)showCurrentSpeechSegment {
  NSArray *speechSegs = self.quest.acceptDialogue.speechSegmentList;
  
  if (speechSegs.count <= curSpeechSegment || curSpeechSegment < 0) {
    [Globals popupMessage:@"Speech segment index out of bounds."];
    return;
  }
  
  if (curSpeechSegment == 0) {
    self.prevButton.hidden = YES;
  } else {
    self.prevButton.hidden = NO;
  }
  
  DialogueProto_SpeechSegmentProto *speechSeg = [speechSegs objectAtIndex:curSpeechSegment];
  self.speechLabel.text = speechSeg.speakerText;
}

- (void)displayQuestConversationForQuest:(FullQuestProto *)fqp {
  self.quest = fqp;
  curSpeechSegment = 0;
  [self showCurrentSpeechSegment];
  [ConvoMenuController displayView];
}

- (void)dialogComplete {
  [ConvoMenuController removeView];
  [[OutgoingEventController sharedOutgoingEventController] acceptQuest:self.quest.questId];
  [[QuestLogController sharedQuestLogController] loadQuestAcceptScreen:self.quest];
}

- (IBAction)nextClicked:(id)sender {
  curSpeechSegment++;
  self.prevButton.hidden = NO;
  
  if (curSpeechSegment >= self.quest.acceptDialogue.speechSegmentList.count) {
    [self dialogComplete];
  } else {
    [self showCurrentSpeechSegment];
  }
}

- (IBAction)prevClicked:(id)sender {
  curSpeechSegment = MAX(curSpeechSegment-1, 0);
  [self showCurrentSpeechSegment];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  self.mainView = nil;
  self.bgdView = nil;
  self.prevButton = nil;
  self.speechLabel = nil;
  self.speakerImageView = nil;
  self.speakerNameLabel = nil;
  self.quest = nil;
}

@end
