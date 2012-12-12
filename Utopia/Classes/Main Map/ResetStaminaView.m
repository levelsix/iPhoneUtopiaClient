//
//  ResetStaminaView.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ResetStaminaView.h"
#import "Globals.h"
#import "GameState.h"
#import "ProfileViewController.h"

@implementation ResetStaminaView

- (void) display {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int totalSkillPoints = (gs.level-1)*gl.skillPointsGainedOnLevelup;
  NSLog(@"%d, %d, %d", gs.maxStamina, gl.initStamina, totalSkillPoints);
  int percent = ((float)(gs.maxStamina-gl.initStamina))/totalSkillPoints*100;
  
  self.descriptionLabel.text = [NSString stringWithFormat:@"You are only using %d%% of your skill points in Stamina. Redistribute skill points to defeat the boss with less refills!", percent];
  
  [Globals displayUIView:self];
  [Globals bounceView:self.popupView fadeInBgdView:self.bgdView];
  
  self.dialogueView.center = CGPointMake(self.dialogueView.center.x, self.dialogueView.superview.frame.size.height+self.dialogueView.frame.size.height/2);
  [UIView animateWithDuration:0.3f animations:^{
    self.dialogueView.center = CGPointMake(self.dialogueView.center.x, self.dialogueView.superview.frame.size.height-self.dialogueView.frame.size.height/2);
  }];
}

- (IBAction)closeClicked:(id)sender {
  [Globals popOutView:self.popupView fadeOutBgdView:self.bgdView completion:^{
    [self removeFromSuperview];
  }];
  [UIView animateWithDuration:0.3f animations:^{
    self.dialogueView.center = CGPointMake(self.dialogueView.center.x, self.dialogueView.superview.frame.size.height+self.dialogueView.frame.size.height/2);
  }];
}

- (IBAction)redistributeClicked:(id)sender {
  [[ProfileViewController sharedProfileViewController] loadMyProfile];
  [ProfileViewController displayView];
  [[ProfileViewController sharedProfileViewController] openSkillsMenu];
  [[ProfileViewController sharedProfileViewController] resetSkillsClicked:nil];
  [self closeClicked:nil];
}

- (void) dealloc {
  self.bgdView = nil;
  self.popupView = nil;
  self.dialogueView = nil;
  self.descriptionLabel = nil;
  [super dealloc];
}

@end
