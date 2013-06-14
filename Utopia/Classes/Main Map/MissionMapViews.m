//
//  ResetStaminaView.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "MissionMapViews.h"
#import "Globals.h"
#import "GameState.h"
#import "ProfileViewController.h"
#import "Protocols.pb.h"
#import "ArmoryViewController.h"
#import "OutgoingEventController.h"
#import "GameLayer.h"

@implementation ResetStaminaView

- (void) display {
  Globals *gl = [Globals sharedGlobals];
  int percent = [gl percentOfSkillPointsInStamina];
  
  self.descriptionLabel.text = [NSString stringWithFormat:@"You are only using %d%% of your skill points in Stamina. Redistribute skill points to defeat the boss faster!", percent];
  
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

@implementation GemView

- (void) loadForGemId:(int)gemId hasGem:(BOOL)hasGem {
  GameState *gs = [GameState sharedGameState];
  CityGemProto *gem = [gs gemForId:gemId];
  if (gem) {
    [Globals imageNamed:gem.gemImageName withView:self.itemIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    if (hasGem) {
      self.itemIcon.alpha = 1.f;
    } else {
      self.itemIcon.alpha = 0.4f;
    }
  }
}

- (void) dealloc {
  self.itemIcon = nil;
  self.maskedItemIcon = nil;
  [super dealloc];
}

@end

@implementation CityGemsView

- (void) animateGem:(UIImageView *)gem withGemId:(int)gemId andGems:(NSArray *)gems andCityId:(int)cityId {
  NSMutableArray *mut = gems.mutableCopy;
  for (UserCityGemProto *gem in gems) {
    if (gem.gemId == gemId) {
      [mut removeObject:gem];
    }
  }
  
  [self displayWithGems:mut andCityId:cityId];
  
  [self addSubview:gem];
  
  UIImageView *img = [[self.gemViews objectAtIndex:gemId-1] itemIcon];
  [UIView animateWithDuration:0.5f animations:^{
    gem.frame = [gem.superview convertRect:img.frame fromView:img.superview];
  } completion:^(BOOL finished) {
    [gem removeFromSuperview];
    img.alpha = 1.f;
    
    [self performSelector:@selector(closeClicked:) withObject:nil afterDelay:0.5f];
  }];
}

- (void) displayWithGems:(NSArray *)gems andCityId:(int)cityId {
  [Globals displayUIView:self];
  
  [self updateWithGems:gems];
  _cityId = cityId;
  
  self.bgdView.alpha = 0.f;
  self.mainView.center = CGPointMake(self.mainView.center.x, self.mainView.frame.size.height*3/2);
  [UIView animateWithDuration:0.5f animations:^{
    self.bgdView.alpha = 1.f;
    self.mainView.center = CGPointMake(self.mainView.center.x, self.mainView.frame.size.height/2);
  }];
}

- (void) updateWithGems:(NSArray *)gems {
  for (int i = 0; i < self.gemViews.count; i++) {
    BOOL hasGem = NO;
    for (UserCityGemProto *gem in gems) {
      if (gem.gemId == i+1) {
        if (gem.quantity > 0) {
          hasGem = YES;
        }
      }
    }
    
    [[self.gemViews objectAtIndex:i] loadForGemId:i+1 hasGem:hasGem];
  }
  
  self.gems = gems;
}

- (void) receivedRedeemGemsResponse:(RedeemUserCityGemsResponseProto *)proto withUpdatedGems:(NSArray *)gems {
  [self.loadingView stop];
  
  if (proto.equipsList.count > 0) {
    NSMutableArray *arr = [NSMutableArray array];
    for (GemView *gv in self.gemViews) {
      [arr addObject:gv.itemIcon];
    }
    
    [self.prizeView beginPrizeAnimationForImageView:arr prize:[proto.equipsList objectAtIndex:0]];
    
    self.prizeView.frame = self.bounds;
    [self addSubview:self.prizeView];
    
    [self updateWithGems:gems];
  }
}

- (IBAction)redeemClicked:(id)sender {
  for (int i = 1; i <= 5; i++) {
    UserCityGemProto *gem = nil;
    for (UserCityGemProto *g in self.gems) {
      if (g.gemId == i) {
        gem = g;
      }
    }
    
    if (gem.quantity < 1) {
      [Globals popupMessage:@"You must collect all 5 items to redeem!"];
      return;
    }
  }
  
  [[OutgoingEventController sharedOutgoingEventController] redeemUserCityGems:_cityId];
  
  [self.loadingView display:self];
}

- (IBAction)closeClicked:(id)sender {
  [UIView animateWithDuration:0.5f animations:^{
    self.bgdView.alpha = 0.f;
    self.mainView.center = CGPointMake(self.mainView.center.x, self.mainView.frame.size.height*3/2);
  } completion:^(BOOL finished) {
    [self removeFromSuperview];
  }];
}

- (void) dealloc {
  self.bgdView = nil;
  self.mainView = nil;
  [super dealloc];
}

@end

@implementation CityGemsPrizeView

@synthesize imgView1, imgView2, imgView3, imgView4, imgView5;
@synthesize bgdView, mainView;

- (void) awakeFromNib {
  oldRects = [[NSArray arrayWithObjects:[NSValue valueWithCGRect:imgView1.frame], [NSValue valueWithCGRect:imgView2.frame], [NSValue valueWithCGRect:imgView3.frame], [NSValue valueWithCGRect:imgView4.frame], [NSValue valueWithCGRect:imgView5.frame], nil] retain];
}

- (void) beginPrizeAnimationForImageView:(NSArray *)startImgViews prize:(FullUserEquipProto *)fuep {
  NSArray *imgViews = [NSArray arrayWithObjects:imgView1, imgView2, imgView3, imgView4, imgView5, nil];
  
  for (int i = 0; i < imgViews.count; i++) {
    UIImageView *origView = [startImgViews objectAtIndex:i];
    UIImageView *newView = [imgViews objectAtIndex:i];
    newView.frame = [origView.superview.superview convertRect:origView.frame fromView:origView.superview];
    newView.image = origView.image;
    newView.hidden = NO;
    origView.hidden = YES;
  }
  
  bgdView.alpha = 0.f;
  mainView.transform = CGAffineTransformIdentity;
  [UIView animateWithDuration:2.f animations:^{
    bgdView.alpha = 1.f;
    
    for (int i = 0; i < imgViews.count; i++) {
      UIImageView *newView = [imgViews objectAtIndex:i];
      newView.frame = [[oldRects objectAtIndex:i] CGRectValue];
    }
  } completion:^(BOOL finished) {
    // Spin the views
    float duration = 5.f;
    float scale = 0.3f;
    CABasicAnimation* spinAnimation = [CABasicAnimation
                                       animationWithKeyPath:@"transform.rotation"];
    spinAnimation.toValue = [NSNumber numberWithFloat:8*2*M_PI];
    spinAnimation.duration = duration;
    spinAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [mainView.layer addAnimation:spinAnimation forKey:@"spinAnimation"];
    
    CABasicAnimation* scaleAnimation = [CABasicAnimation
                                        animationWithKeyPath:@"transform.scale"];
    scaleAnimation.toValue = [NSNumber numberWithFloat:scale];
    scaleAnimation.duration = duration;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [mainView.layer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    
    for (UIImageView *iv in imgViews) {
      CABasicAnimation* newAnim = [CABasicAnimation
                                   animationWithKeyPath:@"transform.rotation"];
      newAnim.toValue = [NSNumber numberWithFloat:-[spinAnimation.toValue floatValue]];
      newAnim.duration = spinAnimation.duration;
      newAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
      [iv.layer addAnimation:newAnim forKey:@"spinAnimation"];
    }
    
    UIView *view = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:view];
    view.backgroundColor = [UIColor whiteColor];
    view.alpha = 0.f;
    
    float percentTillWhiteLight = 0.75f;
    [UIView animateWithDuration:(1-percentTillWhiteLight)*duration delay:percentTillWhiteLight*duration options:UIViewAnimationOptionTransitionNone animations:^{
      view.alpha = 1.f;
    } completion:^(BOOL finished) {
      for (UIImageView *iv in imgViews) {
        iv.hidden = YES;
      }
      for (UIImageView *iv in startImgViews) {
        iv.hidden = NO;
      }
      // This is the gems view
      self.superview.hidden = YES;
      
      ArmoryViewController *amc = [ArmoryViewController sharedArmoryViewController];
      [Globals displayUIViewWithoutAdjustment:amc.cardDisplayView];
      [amc.cardDisplayView beginAnimatingForEquips:[NSArray arrayWithObject:fuep] withTarget:nil andSelector:nil];
      self.bgdView.alpha = 0.f;
      
      [UIView animateWithDuration:0.2f animations:^{
        view.alpha = 0.f;
      } completion:^(BOOL finished) {
        [view removeFromSuperview];
        [view release];
        
        self.superview.hidden = NO;
        [self.superview removeFromSuperview];
        [self removeFromSuperview];
      }];
    }];
  }];
}

- (void) dealloc {
  self.imgView1 = nil;
  self.imgView2 = nil;
  self.imgView3 = nil;
  self.imgView4 = nil;
  self.imgView5 = nil;
  self.bgdView = nil;
  self.mainView = nil;
  [oldRects release];
  [super dealloc];
}

@end
