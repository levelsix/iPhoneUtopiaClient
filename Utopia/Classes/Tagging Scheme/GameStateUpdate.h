//
//  GameStateUpdate.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/3/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GameStateUpdate <NSObject>

@property (nonatomic, assign) int tag;

@optional
- (void) update;
- (void) undo;

@end
