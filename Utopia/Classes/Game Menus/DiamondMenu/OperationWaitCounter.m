//
//  OperationWaitCounter.m
//  Utopia
//
//  Created by Kevin Calloway on 5/31/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "OperationWaitCounter.h"

@implementation OperationWaitCounter
@synthesize operationKey;

-(void)serialize
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];  
  [defaults setObject:_prevTimeUsed forKey:operationKey];
  [defaults synchronize];  
}

-(BOOL)deserialize
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSDate *tempTime = [defaults objectForKey:operationKey];
  if (tempTime) {
    _prevTimeUsed = tempTime;
    return YES;
  }

  return NO;
}

-(BOOL)canPerfomOperation
{
  NSTimeInterval timeInterval = -[_prevTimeUsed timeIntervalSinceNow];
  if (timeInterval > _timeIntervalLength) {
    return YES;
  }
  
  return NO;
}

-(void)performedOperation
{
  [_prevTimeUsed release];
  _prevTimeUsed = [NSDate date];
  [_prevTimeUsed retain];
}

#pragma mark Create/Destroy
-(id)initWithKey:(NSString *)key
 andTimeInterval:(NSTimeInterval)timeInterval                
  andDefaultPrev:(NSDate *)prevReqDate
{
  self = [super init];
  
  if (self) {
    operationKey        = key;
    _timeIntervalLength = timeInterval;
    _prevTimeUsed       = prevReqDate;
    
    [operationKey  retain];
    [_prevTimeUsed retain];
  }
  return self;
}

-(void)dealloc
{
  [operationKey  release];
  [_prevTimeUsed release];
  
  [super dealloc];
}

+(id<OperationWaitCounter>)createForKey:(NSString *)key
                        andTimeInterval:(NSTimeInterval)timeInterval
{
  // Guarantee that the user will be able to perform
  // this action the first time with [NSDate distantPast].
  OperationWaitCounter *counter = [[OperationWaitCounter alloc]
                                   initWithKey:key
                                   andTimeInterval:timeInterval
                                   andDefaultPrev:[NSDate distantPast]];
  [counter autorelease];
  return counter;
}

@end
