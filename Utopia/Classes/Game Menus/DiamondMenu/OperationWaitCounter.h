//
//  OperationWaitCounter.h
//  Utopia
//
//  Created by Kevin Calloway on 5/31/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#define SECONDS_PER_WEEK 1*60*60*24*7 

@protocol OperationWaitCounter <NSObject>
-(void)serialize;
-(BOOL)deserialize;
-(BOOL)canPerfomOperation;
-(void)performedOperation;
@property (readonly) NSString *operationKey;
@end

@interface OperationWaitCounter : NSObject <OperationWaitCounter> {
  NSDate         *_prevTimeUsed;
  NSTimeInterval _timeIntervalLength;
  NSString       *operationKey;
}

+(OperationWaitCounter *)createForKey:(NSString *)key
                      andTimeInterval:(NSTimeInterval)timeInterval;
-(id)initWithKey:(NSString *)key
 andTimeInterval:(NSTimeInterval)timeInterval                
  andDefaultPrev:(NSDate *)prevReqDate;
@end
