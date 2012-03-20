//
//  ImageDownloader.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/14/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageDownloader : NSObject {
  dispatch_queue_t _queue;
  NSString *_cacheDir;
}

+ (ImageDownloader *) sharedImageDownloader;
- (void) downloadImage:(NSString *)imageName;
- (void) downloadImage:(NSString *)imageName completion:(void (^)(void))completed;

@end
