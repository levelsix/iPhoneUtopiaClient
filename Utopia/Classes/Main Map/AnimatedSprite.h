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

#define ABOVE_HEAD_FADE_DURATION 1.5f
#define ABOVE_HEAD_FADE_OPACITY 100
#define ANIMATATION_DELAY 0.05f
#define MOVE_DISTANCE 6.0f

#define MY_WALKING_SPEED 75.f
#define WALKING_SPEED 25.f

#define VERTICAL_OFFSET 10.f

@class MissionMap;

@interface CharacterSprite : SelectableSprite {
  CCLabelTTF *_nameLabel;
}

@property (nonatomic, retain) CCLabelTTF *nameLabel;

@end

@interface AnimatedSprite : CharacterSprite
{
  CCSprite *_sprite;
  CCAction *_curAction;
  CCAction *_walkActionN;
  CCAction *_walkActionF;
  
  CGPoint _oldMapPos;
  BOOL _moving;
}

@property (nonatomic, retain) CCSprite *sprite;
@property (nonatomic, retain) CCAction *walkActionN;
@property (nonatomic, retain) CCAction *walkActionF;

- (void) walk;

@end

typedef enum {
  kNoQuest = 1,
  kAvailable,
  kInProgress,
  kCompleted
} QuestGiverState;

@interface QuestGiver : AnimatedSprite {
  CCNode *_aboveHeadMark;
}

@property (nonatomic, retain) FullQuestProto *quest;
@property (nonatomic, assign) QuestGiverState questGiverState;
@property (nonatomic, copy) NSString *name;

- (id) initWithQuest:(FullQuestProto *)fqp questGiverState:(QuestGiverState)qgs file:(NSString *)file map:(GameMap *)map location:(CGRect)location;

@end

@interface Enemy : AnimatedSprite

@property (nonatomic, retain) FullUserProto *user;

- (id) initWithUser:(FullUserProto *)fup location:(CGRect)loc map:(GameMap *)map;

@end

@interface TutorialGirl : QuestGiver

- (id) initWithLocation:(CGRect)loc map:(GameMap *)map;

@end

@interface Carpenter : AnimatedSprite

- (id) initWithLocation:(CGRect)loc map:(GameMap *)map;

@end

@interface NeutralEnemy : AnimatedSprite <TaskElement>

@end

@interface MoveToLocation : CCActionInterval <NSCopying> {
  CGRect startLocation_;
  CGRect endLocation_;
  CGPoint delta_;
}

+ (id) actionWithDuration: (ccTime) t location: (CGRect) p;
- (id) initWithDuration: (ccTime) t location: (CGRect) p;

@end