//
//  ImageDownloader.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/14/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ImageDownloader.h"
#import "SynthesizeSingleton.h"

@implementation ImageDownloader

static NSString *urlBase = @"http://blogs.silverlight.net/blogs/msnow/WindowsLiveWriter/PartVIICreatingTransparentPNGfilesforSil_D7DE/";

SYNTHESIZE_SINGLETON_FOR_CLASS(ImageDownloader);

- (UIImage *) downloadImage: (NSString *)imageName {
  // Get an image from the URL below
  NSURL *url = [NSURL URLWithString:[urlBase stringByAppendingString:imageName]];
  UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
  
  NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  
  // If you go to the folder below, you will find those pictures
  NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",cacheDir, [[url pathComponents] lastObject]];
  NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(image)];
  [data1 writeToFile:pngFilePath atomically:YES];
  
  NSLog(@"%@ image saved to %@", imageName, pngFilePath);
  
  return image;
}

@end
