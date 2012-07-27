//
//  ImageDownloader.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/14/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "Downloader.h"
#import "LNSynthesizeSingleton.h"
#import "Globals.h"

#define URL_BASE @"https://s3.amazonaws.com/lvl6utopia/Resources/";

@implementation Downloader

SYNTHESIZE_SINGLETON_FOR_CLASS(Downloader);

@synthesize loadingView;

- (id) init {
  if ((self = [super init])) {
    _queue = dispatch_queue_create("Image Downloader", NULL);
    _cacheDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] copy];
    
    //    [[NSBundle mainBundle] loadNibNamed:@"DownloaderSpinner" owner:self options:nil];
  }
  return self;
}

- (void) downloadFile:(NSString *)imageName {
  // LNLogs here are NOT thread safe, be careful
  NSString *urlBase = URL_BASE;
  NSURL *url = [[NSURL alloc] initWithString:[urlBase stringByAppendingString:imageName]];
  NSString *filePath = [[NSString alloc] initWithFormat:@"%@/%@",_cacheDir, [[url pathComponents] lastObject]];
  if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    if (data) {
      [data writeToFile:filePath atomically:YES];
    }
    [data release];
  }
  [url release];
  [filePath release];
}

- (void) asyncDownloadFile:(NSString *)imageName completion:(void (^)(void))completed {
  // Get an image from the URL below
  ContextLogInfo(LN_CONTEXT_DOWNLOAD, @"Beginning async download of %@", imageName);
  dispatch_async(_queue, ^{
    [self downloadFile:imageName];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      if (completed) {
        completed();
      }
      ContextLogInfo(LN_CONTEXT_DOWNLOAD, @"Download of %@ complete", imageName);
    });
  });
}

- (void) syncDownloadFile:(NSString *)fileName {
  ContextLogInfo(LN_CONTEXT_DOWNLOAD, @"Beginning sync download of file %@", fileName);
  dispatch_sync(_queue, ^{
    [self downloadFile:fileName];
  });
  ContextLogInfo(LN_CONTEXT_DOWNLOAD, @"Download of %@ complete", fileName);
}

//- (void) beginLoading {
//  dispatch_async(dispatch_get_main_queue(), ^{
//    [Globals displayUIView:loadingView];
//    [loadingView.actIndView startAnimating];
//  });
//}
//
//- (void) stopLoading {
//  dispatch_async(dispatch_get_main_queue(), ^{
//    [loadingView removeFromSuperview];
//    [loadingView.actIndView stopAnimating];
//  });
//}

- (void) dealloc {
  dispatch_release(_queue);
  [_cacheDir release];
  self.loadingView = nil;
  [super dealloc];
}

@end

@implementation DownloaderLoadingView

@synthesize darkView, actIndView, label;

- (void) awakeFromNib {
  self.darkView.layer.cornerRadius = 10.f;
}

- (void) dealloc {
  self.darkView = nil;
  self.actIndView = nil;
  self.label = nil;
  
  [super dealloc];
}

@end
