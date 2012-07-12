//
//  LoggingContextFilter.h
//  Utopia
//
//  Created by Kevin Calloway on 7/10/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDLog.h"

@interface LoggingContextFilter : NSObject <DDLogFormatter> {
  int _contextToFilter;
}

+(id<DDLogFormatter>)createTagFilter;
+(id<DDLogFormatter>)createMapFilter;
+(id<DDLogFormatter>)createDownloadFilter;
+(id<DDLogFormatter>)createIAPFilter;
+(id<DDLogFormatter>)createGamestateFilter;
+(id<DDLogFormatter>)createCommunicationFilter;
+(id<DDLogFormatter>)createImagesFilter;

@end
