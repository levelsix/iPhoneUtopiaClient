//
//  TutorialQuestLogController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/15/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "QuestLogController.h"

@class TutorialMissionMap;

@interface TutorialQuestLogController : QuestLogController <UIScrollViewDelegate> {
  StartupResponseProto_TutorialConstants_FullTutorialQuestProto *_tutQuest;
  BOOL _canClose;
  BOOL _acceptingPhase;
  
//  id<UIScrollViewDelegate> oldDelegate;
  UIImageView *_arrow;
}

@end
