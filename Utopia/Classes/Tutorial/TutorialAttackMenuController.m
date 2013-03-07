//
//  TutorialAttackMenuController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/5/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "TutorialAttackMenuController.h"
#import "GameState.h"
#import "Globals.h"
#import "TutorialBattleLayer.h"
#import "TutorialConstants.h"
#import "DialogMenuController.h"

@implementation TutorialAttackMenuController

- (id) init {
  return [super initWithNibName:@"AttackMenuController" bundle:nil];
}

- (void) viewWillAppear:(BOOL)animated {
  GameState *gs = [GameState sharedGameState];
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  NSArray *arr = [NSArray arrayWithObjects:tc.enemyName, @"ashwinner101", @"kellz", @"JBiebs12", @"CoopaTroopa", @"aweezy", @"awestonlin", nil];
  gs.attackList = [NSMutableArray array];
  for (NSString *str in arr) {
    UserType type = UserTypeGoodWarrior;
    if ([str isEqualToString:tc.enemyName]) {
      type = tc.enemyType;
    } else {
      type = arc4random_uniform(3) + ([Globals userTypeIsGood:gs.type] ? 3 : 0);
    }
    
    FullUserProto *fup = [[[[[FullUserProto builder] setName:str] setLevel:1] setUserType:type] build];
    [gs.attackList addObject:fup];
  }
  
  [self.attackTableView reloadData];
  
  UIImageView *arrow = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"3darrow.png"]];
  [self.mainView addSubview:arrow];
  arrow.center = ccp(390, 85);
  [Globals animateUIArrow:arrow atAngle:-M_PI_2];
  self.attackTableView.scrollEnabled = NO;
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  self.topBar.userInteractionEnabled = NO;
  
  UIView *dark = [[UIView alloc] initWithFrame:self.attackTableView.bounds];
  dark.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.7f];
  [self.attackTableView addSubview:dark];
  
  CGRect r = dark.frame;
  r.origin.y += self.attackTableView.rowHeight;
  r.size.height -= self.attackTableView.rowHeight;
  dark.frame = r;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  AttackListCell *cell = (AttackListCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
  cell.userInteractionEnabled = (indexPath.row == 0);
  return cell;
}

- (void) refresh {
  [self stopLoading];
}

- (void) retrieveAttackListForCurrentBounds {
  return;
}

- (void) viewProfile:(FullUserProto *)fup {
  return;
}

- (void) battle:(FullUserProto *)fup {
  [DialogMenuController closeView];
  
  [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:1.f scene:[TutorialBattleLayer scene]]];
  [self close];
}

- (void) setState:(AttackListState)state {
  if (state == kAttackList) {
    [super setState:state];
  }
}

- (void) closeClicked:(id)sender {
  return;
}

@end
