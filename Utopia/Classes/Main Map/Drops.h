//
//  SilverStack.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/31/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"

@interface SilverStack : CCSprite <CCTargetedTouchDelegate> {
  BOOL _clicked;
}

@property (nonatomic, assign) int amount;

- (id) initWithAmount:(int)amt;

@end

@interface GoldStack : CCSprite <CCTargetedTouchDelegate> {
  BOOL _clicked;
}

@property (nonatomic, assign) int amount;

- (id) initWithAmount:(int)amt;

@end

@interface EquipDrop : CCSprite <CCTargetedTouchDelegate> {
  BOOL _clicked;
}

@property (nonatomic, assign) int equipId;

- (id) initWithEquipId:(int)equipId;

@end

@interface LockBoxDrop : CCSprite <CCTargetedTouchDelegate> {
  BOOL _clicked;
}

@property (nonatomic, assign) int eventId;

- (id) initWithEventId:(int)eventId;

@end