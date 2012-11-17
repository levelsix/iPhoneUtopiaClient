//
//  LoggingContexts.h
//  Utopia
//
//  Created by Kevin Calloway on 7/10/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "DDTTYLogger.h"
#import "DDASLLogger.h"
#import "DDLog.h"

#ifndef Utopia_Header_h
#define Utopia_Header_h

static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#define LN_CONTEXT_COMMUNICATION  1
#define LN_CONTEXT_MAP            2
#define LN_CONTEXT_DOWNLOAD       3
#define LN_CONTEXT_IAP            4
#define LN_CONTEXT_GAMESTATE      5
#define LN_CONTEXT_TAGS           6

#ifdef DEBUG
#define ContextLogError(curContext, frmt, ...)   LOG_OBJC_MAYBE(LOG_ASYNC_ERROR,   ddLogLevel, LOG_FLAG_ERROR,   curContext, frmt, ##__VA_ARGS__)
#define ContextLogWarn(curContext, frmt, ...)    LOG_OBJC_MAYBE(LOG_ASYNC_WARN,    ddLogLevel, LOG_FLAG_WARN,    curContext, frmt, ##__VA_ARGS__)
#define ContextLogInfo(curContext, frmt, ...)    LOG_OBJC_MAYBE(LOG_ASYNC_INFO,    ddLogLevel, LOG_FLAG_INFO,    curContext, frmt, ##__VA_ARGS__)
#define ContextLogVerbose(curContext, frmt, ...) LOG_OBJC_MAYBE(LOG_ASYNC_VERBOSE, ddLogLevel, LOG_FLAG_VERBOSE, curContext, frmt, ##__VA_ARGS__)
#else
#define ContextLogError(curContext, frmt, ...)   LOG_OBJC_MAYBE(LOG_ASYNC_ERROR,   ddLogLevel, LOG_FLAG_ERROR,   curContext, nil, ##__VA_ARGS__)
#define ContextLogWarn(curContext, frmt, ...)    LOG_OBJC_MAYBE(LOG_ASYNC_ERROR,   ddLogLevel, LOG_FLAG_ERROR,   curContext, nil, ##__VA_ARGS__)
#define ContextLogInfo(curContext, frmt, ...)    LOG_OBJC_MAYBE(LOG_ASYNC_ERROR,   ddLogLevel, LOG_FLAG_ERROR,   curContext, nil, ##__VA_ARGS__)
#define ContextLogVerbose(curContext, frmt, ...) LOG_OBJC_MAYBE(LOG_ASYNC_ERROR,   ddLogLevel, LOG_FLAG_ERROR,   curContext, nil, ##__VA_ARGS__)
#endif
#endif
