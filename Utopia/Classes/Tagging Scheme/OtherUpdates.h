//
//  OtherUpdates.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/4/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "GameStateUpdate.h"

@interface NoUpdate : NSObject <GameStateUpdate>

+ (id) updateWithTag:(int)tag;
- (id) initWithTag:(int)tag;

@end

@interface ChangeEquipUpdate : NSObject <GameStateUpdate> {
  int _equipId;
  int _change;
}

+ (id) updateWithTag:(int)tag equipId:(int)equipId change:(int)change;
- (id) initWithTag:(int)tag equipId:(int)equipId change:(int)change;

@end