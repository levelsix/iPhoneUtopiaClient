//
//  ClientProperties.h
//  Utopia
//
//  Created by Ashwin Kamath on 5/22/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#include "OpenUDID.h"

#ifndef DEBUG

#define USE_PROD

#define UDID [OpenUDID value]

#else

//#define USE_PROD

#define UDID @"1112235254-1488611566-1501794292"
//#define FORCE_TUTORIAL

#endif

#ifdef USE_PROD

#define HOST_NAME @"amqp.lvl6.com"
#define HOST_PORT 5672
#define MQ_USERNAME @"lvl6client"
#define MQ_PASSWORD @"LvL6Pr0dCl!3nT"
#define MQ_VHOST @"prodageofchaos"

#else

#define HOST_NAME @"robot.lvl6.com"
#define HOST_PORT 5672
#define MQ_USERNAME @"lvl6client"
#define MQ_PASSWORD @"devclient"
#define MQ_VHOST @"devageofchaos"

#endif
