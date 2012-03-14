//
//  TutorialHomeMap.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/13/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TutorialHomeMap.h"
#import "Globals.h"

@implementation TutorialHomeMap

- (void) refresh {
  Globals *gl = [Globals sharedGlobals];
  
  // Add aviary
  CritStruct *cs = [[CritStruct alloc] init];
  cs.type = CritStructTypeAviary;
  cs.location = CGRectMake(10, 10, gl.aviaryXLength, gl.aviaryYLength);
  cs.orientation = StructOrientationPosition1;
  cs.name = @"Armory";
  
  _av = [[Aviary alloc] initWithFile:@"Aviary.png" location:cs.location map:self];
  [self addChild:_av];
  [_av release];
  
  _av.orientation = cs.orientation;
  [self changeTiles:_av.location toBuildable:NO];
  [cs release];
  
  // Add carpenter
  cs = [[CritStruct alloc] init];
  cs.type = CritStructTypeCarpenter;
  cs.location = CGRectMake(10, 6, gl.carpenterXLength, gl.carpenterYLength);
  cs.orientation = StructOrientationPosition1;
  cs.name = @"Carpenter";
  
  _csb = [[CritStructBuilding alloc] initWithFile:[cs.name stringByAppendingString:@".png"] location:cs.location map:self];
  [self addChild:_csb];
  [_csb release];
  
  _csb.orientation = cs.orientation;
  _csb.critStruct = cs;
  [cs release];
  
  _carpenterPhase = YES;
  
  _ccArrow = [CCSprite spriteWithFile:@"green.png"];
  [self addChild:_ccArrow];
  _ccArrow.position = ccp(_csb.position.x, _csb.position.y+_csb.contentSize.height+_ccArrow.contentSize.height/2);
  
  CCMoveBy *upAction = [CCEaseSineInOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, 20)]];
  [_ccArrow runAction:[CCRepeatForever actionWithAction:[CCSequence actions:upAction, 
                                                       [upAction reverse], nil]]];
}

- (void) tap:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  if (!_visitCarpPhase) {
    [super tap:recognizer node:node];
    if (_carpenterPhase && _selected != _csb) {
      self.selected = nil;
    } else if (_selected == _csb) {
      _carpenterPhase = NO;
      _visitCarpPhase = YES;
      
      // Reset ccArrow
      [_ccArrow stopAllActions];
      _ccArrow.visible = NO;
      
      _uiArrow = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"green.png"]];
      [self.csMenu addSubview:_uiArrow];
      [_uiArrow release];
      _uiArrow.layer.transform = CATransform3DMakeRotation(-M_PI/2, 0.0f, 0.0f, 1.0f);
      
//      NSLog(@"%f, %f", -_uiArrow.frame.size.width/2, [self.csMenu viewWithTag:10].center.y);
      _uiArrow.center = CGPointMake(-_uiArrow.frame.size.width/2+10, [self.csMenu viewWithTag:10].center.y);
      
      UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat;
      [UIView animateWithDuration:1.f delay:0.f options:opt animations:^{
        _uiArrow.center = CGPointMake(-_uiArrow.frame.size.width/2, [self.csMenu viewWithTag:10].center.y);
      } completion:nil];
    }
  }
}

- (IBAction)criticalStructMoveClicked:(id)sender {
  return;
}

@end
