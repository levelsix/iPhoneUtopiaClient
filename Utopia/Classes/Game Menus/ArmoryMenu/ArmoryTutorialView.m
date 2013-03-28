//
//  ArmoryTutorialView.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/12/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "ArmoryTutorialView.h"
#import "GameState.h"
#import "DialogMenuController.h"

@implementation ArmoryTutorialView

static CGPoint origCenter;

- (void) awakeFromNib {
  origCenter = self.speechLabel.center;
}

- (void) displayDescriptionForFirstLossTutorial {
  GameState *gs = [GameState sharedGameState];
  self.speechLabel.text = [NSString stringWithFormat:@"Hey %@, this starter pack contains 1 rare weapon, armor, and amulet. Buying this will give you the edge you need to dominate!", gs.name];
  self.buttonView.hidden = YES;
  self.closeButton.hidden = NO;
  self.girlImageView.image = [Globals imageNamed:[Globals userTypeIsGood:gs.type] ? @"rubyspeech.png" : @"adrianaspeech.png"];
  [self popupSpeechBubble];
}

- (void) displayInfoForStarterPack {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  self.speechLabel.text = [NSString stringWithFormat:@"You can only buy %d of these starter packs. That's enough to forge these equips to level %d in the Blacksmith's forge. You need to be level %d to access it though.", gl.numTimesToBuyStarterPack, (int)log2(gl.numTimesToBuyStarterPack)+1, gl.minLevelConstants.blacksmithMinLevel];
  self.buttonView.hidden = YES;
  self.closeButton.hidden = NO;
  self.girlImageView.image = [Globals imageNamed:[Globals userTypeIsGood:gs.type] ? @"rubyspeech.png" : @"adrianaspeech.png"];
  self.speechLabel.center = origCenter;
  [self popupSpeechBubble];
}

- (void) displayCloseClicked {
  self.speechLabel.text = @"Are you sure you're not interested? We're offering a huge discount for new players! Would you like to see it?";
  self.buttonView.hidden = NO;
  self.closeButton.hidden = YES;
  self.speechLabel.center = ccpAdd(origCenter, ccp(0,-5));
  [self popupSpeechBubble];
}

- (void) displayNotEnoughGold {
  self.speechLabel.text = @"Looks like you don't have enough gold, but don't worry! We're offering a huge discount for new players!";
  self.buttonView.hidden = NO;
  self.closeButton.hidden = YES;
  self.speechLabel.center = ccpAdd(origCenter, ccp(0,-5));
  [self popupSpeechBubble];
}

- (void) popupSpeechBubble {
  // Alpha will only start at 0 if it is not already there
  CGPoint oldCenter = self.speechBubble.center;
  self.alpha = 0.f;
  self.speechBubble.center = CGPointMake(oldCenter.x-(1.f-SPEECH_BUBBLE_SCALE)/2.f*self.speechBubble.frame.size.width, oldCenter.y);
  self.speechBubble.transform = CGAffineTransformMakeScale(SPEECH_BUBBLE_SCALE, SPEECH_BUBBLE_SCALE);
  self.buttonView.alpha = 0.f;
  [UIView animateWithDuration:SPEECH_BUBBLE_ANIMATION_DURATION animations:^{
    self.alpha = 1.f;
    self.speechBubble.center = oldCenter;
    self.speechBubble.transform = CGAffineTransformIdentity;
  } completion:^(BOOL finished) {
    self.buttonView.alpha = 1.f;
    [Globals bounceView:self.buttonView];
  }];
}

- (IBAction)closeClicked:(id)sender {
  [UIView animateWithDuration:SPEECH_BUBBLE_ANIMATION_DURATION animations:^{
    self.speechBubble.center = CGPointMake(self.speechBubble.center.x-30, self.speechBubble.center.y);
    self.alpha = 0.f;
    self.speechBubble.transform = CGAffineTransformMakeScale(SPEECH_BUBBLE_SCALE, SPEECH_BUBBLE_SCALE);
  } completion:^(BOOL finished) {
    if (finished) {
      [self removeFromSuperview];
    }
    
    // Move center back to where it originally was
    self.speechBubble.center = CGPointMake(self.speechBubble.center.x+30, self.speechBubble.center.y);
  }];
}

- (void) dealloc {
  self.speechLabel = nil;
  self.speechBubble = nil;
  self.girlImageView = nil;
  self.buttonLabel = nil;
  self.buttonView = nil;
  [super dealloc];
}

@end
