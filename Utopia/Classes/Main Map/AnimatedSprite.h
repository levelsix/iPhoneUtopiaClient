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
  CCAction *_walkAction;
  CGPoint _oldMapPos;
  BOOL _moving;
}

@property (nonatomic, retain) CCSprite *sprite;
@property (nonatomic, retain) CCAction *walkAction;

@end

typedef enum {
  kNoQuest = 1,
  kAvailable,
  kInProgress,
  kCompleted
} QuestGiverState;

@interface QuestGiver : CharacterSprite {
  CCSprite *_aboveHeadMark;
}

@property (nonatomic, retain) FullQuestProto *quest;
@property (nonatomic, assign) QuestGiverState questGiverState;
@property (nonatomic, copy) NSString *name;

- (id) initWithQuest:(FullQuestProto *)fqp questGiverState:(QuestGiverState)qgs file:(NSString *)file map:(GameMap *)map location:(CGRect)location;

@end

@interface Enemy : CharacterSprite

@property (nonatomic, retain) FullUserProto *user;

- (id) initWithUser:(FullUserProto *)fup location:(CGRect)loc map:(GameMap *)map;

@end

@interface MoveToLocation : CCActionInterval <NSCopying> {
  CGRect startLocation_;
  CGRect endLocation_;
  CGPoint delta_;
}

+ (id) actionWithDuration: (ccTime) t location: (CGRect) p;
- (id) initWithDuration: (ccTime) t location: (CGRect) p;

@end