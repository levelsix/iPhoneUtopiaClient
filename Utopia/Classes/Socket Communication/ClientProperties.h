//
//  ClientProperties.h
//  Utopia
//
//  Created by Ashwin Kamath on 5/22/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#include "OpenUDID.h"

#ifndef DEBUG

#define HOST_NAME @"production.lvl6.com"
#define HOST_PORT 10001

#define UDID [OpenUDID value]

#else

#define HOST_NAME @"production.lvl6.com"//@"184.169.148.243"
#define HOST_PORT 10001

#define UDID [OpenUDID value]
//#define FORCE_TUTORIAL

#endif
