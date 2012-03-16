//
//  AnimatedSprite.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "MapSprite.h"
#import "Protocols.pb.h"

@class MissionMap;

@interface AnimatedSprite : SelectableSprite
{
  CCSprite *_sprite;
  CCAction *_walkAction;
  CGPoint _oldMapPos;
  BOOL _moving;
}

@property (nonatomic, retain) CCSprite *sprite;
@property (nonatomic, retain) CCAction *walkAction;

@end

@interface QuestGiver : AnimatedSprite {
  CCSprite *_aboveHeadMark;
}

@property (nonatomic, retain) FullQuestProto *quest;
@property (nonatomic, assign) BOOL isInProgress;

- (id) initWithQuest:(FullQuestProto *)fqp inProgress:(BOOL)inProg map:(GameMap *)map location:(CGRect)location;

@end

@interface Enemy : AnimatedSprite

@property (nonatomic, retain) FullUserProto *user;

@end

@interface MoveToLocation : CCActionInterval <NSCopying> {
  CGRect startLocation_;
  CGRect endLocation_;
  CGPoint delta_;
}

+ (id) actionWithDuration: (ccTime) t location: (CGRect) p;
- (id) initWithDuration: (ccTime) t location: (CGRect) p;

@end