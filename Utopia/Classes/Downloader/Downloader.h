//
//  ImageDownloader.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/14/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Downloader : NSObject {
  dispatch_queue_t _queue;
  NSString *_cacheDir;
}

+ (Downloader *) sharedDownloader;
- (void) syncDownloadImage:(NSString *)imageName;
- (void) downloadImage:(NSString *)imageName completion:(void (^)(void))completed;
- (void) syncDownloadFile:(NSString *)fileName;

@end
