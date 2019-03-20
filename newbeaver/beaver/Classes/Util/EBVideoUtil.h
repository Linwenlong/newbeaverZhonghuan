//
//  EBVideoUtil.h
//  beaver
//
//  Created by LiuLian on 8/13/15.
//  Copyright (c) 2015 eall. All rights reserved.
//

@class EBVideoUpload, ALAsset;

@interface EBVideoUtil : NSObject

+ (instancetype)sharedInstance;

+ (NSString *)fileNameWithURL:(NSURL *)videoURL;
+ (NSString *)fileTypeWithURL:(NSURL *)videoURL;
+ (NSUInteger)fileSizeWithURL:(NSURL *)videoURL;
+ (NSString *)sha1WithURL:(NSURL *)videoURL;
+ (NSString *)saveToDocument:(ALAsset *)assetURL;

+ (UIView *)getThumbViewWithURL:(NSURL *)videoURL frame:(CGRect)frame target:(id)target;
+ (UIImage *)getThumbnailWithURL:(NSURL *)videoURL;
+ (void)playWithURL:(id)target remoteURL:(NSURL *)url;

+ (void)upload:(EBVideoUpload *)video;
+ (BOOL)isUploading;

+ (void)resume;
+ (void)stop;
+ (void)retry:(NSUInteger)index;
+ (void)cancel:(NSUInteger)index;

+ (BOOL)validVideoSelected:(ALAsset *)asset assets:(NSArray *)assets;
+ (BOOL)isVideoWithAsset:(ALAsset *)asset;
+ (NSString *)typeWithAsset:(ALAsset *)asset;

- (NSArray *)uploadingVideos;

@end