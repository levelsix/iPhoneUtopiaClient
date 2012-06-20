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

@interface Carpenter : CharacterSprite

- (id) initWithLocation:(CGRect)loc map:(GameMap *)map;

@end

@interface MyPlayer : CharacterSprite {
  //walk animations
  CCAction *_walkActionN;
  CCAction *_walkActionF;
  CCAction *_walkActionLR;
  CCAction *_walkActionU;
  CCAction *_walkActionD;
  CCAction *_currentAction;
  
  CCAnimation *_agAnimation;
  
  CCSprite *_sprite;
  CGPoint _oldMapPosition;
  
  BOOL _shouldContinueAnimation;
}
@property (nonatomic, retain) CCAction *walkActionN;
@property (nonatomic, retain) CCAction *walkActionF;
@property (nonatomic, retain) CCAction *walkActionLR;
@property (nonatomic, retain) CCAction *walkActionU;
@property (nonatomic, retain) CCAction *walkActionD;

@property (nonatomic, retain) CCAction *currentAction;

@property (nonatomic, retain) CCAnimation *agAnimation;

@property (nonatomic, retain) CCSprite *sprite;

- (void)stopWalking;
- (void)stopPerformingAnimation;
- (id) initWithLocation:(CGRect)loc map:(GameMap *)map;
- (void) performAnimation:(AnimationType)type atLocation:(CGPoint)point inDirection:(float)angle;
- (void) moveToLocation:(CGRect)loc;

@end

@interface MoveToLocation : CCActionInterval <NSCopying> {
  CGRect startLocation_;
  CGRect endLocation_;
  CGPoint delta_;
}

+ (id) actionWithDuration: (ccTime) t location: (CGRect) p;
- (id) initWithDuration: (ccTime) t location: (CGRect) p;

@end