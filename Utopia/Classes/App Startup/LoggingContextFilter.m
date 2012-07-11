//
//  LoggingContextFilter.m
//  Utopia
//
//  Created by Kevin Calloway on 7/10/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "LoggingContextFilter.h"
#import "LoggingContexts.h"

@implementation LoggingContextFilter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
	if (logMessage->logContext == _contextToFilter)
	{
		// We can filter this message by simply returning nil
		return nil;
	}
	else
	{
		// We could format this message if we wanted to here.
		// But this example is just about filtering.
		return logMessage->logMsg;
	}
}


#pragma Create/Destroy
-(id)initWithContextToFilter:(int)contextToFilter
{
  self = [super init];
  if (self) {
    _contextToFilter = contextToFilter;
  }
  return self;
}

+(id<DDLogFormatter>)createTagFilter
{
  LoggingContextFilter *filter = [[LoggingContextFilter alloc] initWithContextToFilter:LN_CONTEXT_TAGS];
  [filter autorelease];
  return filter;
}

@end
