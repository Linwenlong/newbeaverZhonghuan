//
//  EBPublishPhotoUploader.h
//  beaver
//
//  Created by LiuLian on 9/4/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EBPublishPhotoUploader : NSObject

+ (EBPublishPhotoUploader *)sharedInstance;

- (BOOL)checkUploading;
- (void)resumeUploading;
- (void)pauseUploading;
- (void)addPublishPhotos:(NSArray *)photos;

@end
