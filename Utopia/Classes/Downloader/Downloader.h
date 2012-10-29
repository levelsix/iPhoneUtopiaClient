//
//  ImageDownloader.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/14/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloaderLoadingView : UIView

@property (nonatomic, retain) IBOutlet UIView *darkView;
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *actIndView;

@end

@interface Downloader : NSObject {
  dispatch_queue_t _syncQueue;
  dispatch_queue_t _asyncQueue;
  NSString *_cacheDir;
}

@property (nonatomic, retain) IBOutlet DownloaderLoadingView *loadingView;

+ (Downloader *) sharedDownloader;

- (void) syncDownloadFile:(NSString *)fileName;
- (void) asyncDownloadFile:(NSString *)imageName completion:(void (^)(void))completed;
- (void) syncDownloadBundle:(NSString *)bundleName;
- (void) asyncDownloadBundle:(NSString *)bundleName;

@end
