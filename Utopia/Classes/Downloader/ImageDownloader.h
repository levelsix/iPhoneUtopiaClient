//
//  ImageDownloader.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/14/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageDownloader : NSObject

+ (ImageDownloader *) sharedImageDownloader;
- (UIImage *) downloadImage: (NSString *)imageName;

@end
