//
//  ClientProperties.h
//  Utopia
//
//  Created by Ashwin Kamath on 5/22/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#ifndef DEBUG

#define HOST_NAME @"184.169.148.243"
#define HOST_PORT 8888

#define UDID [[UIDevice currentDevice] uniqueDeviceIdentifier]
#else

#define HOST_NAME @"10.1.10.26"//@"184.169.148.243"
#define HOST_PORT 8888

#define UDID @"1a"//[[UIDevice currentDevice] uniqueDeviceIdentifier]//@"m";//@"42d1cadaa64dbf3c3e8133e652a2df06"//
//#define FORCE_TUTORIAL
#endif

// Tags for keeping state
#define READING_HEADER_TAG -1
#define HEADER_SIZE 12

#define RECONNECT_TIMEOUT 0.5f
#define NUM_SILENT_RECONNECTS 5
