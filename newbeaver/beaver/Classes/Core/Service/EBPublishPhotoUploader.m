//
//  EBPublishPhotoUploader.m
//  beaver
//
//  Created by LiuLian on 9/4/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "EBPublishPhotoUploader.h"
#import "EBCache.h"
#import "AFHTTPRequestOperation.h"
#import "EBHousePhoto.h"
#import "AGImagePickerController.h"
#import "EBHttpClient.h"
#import "WTStatusBar.h"

#define KEY_PUBLISH_PHOTO_QUEUE @"publish_photo_queue"

@interface EBPublishPhotoUploader()
{
    NSMutableArray *_uploadingPhotos;
    AFHTTPRequestOperation *_currentOperation;
}
@end

@implementation EBPublishPhotoUploader

+ (EBPublishPhotoUploader *)sharedInstance
{
    static EBPublishPhotoUploader *instance;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [EBPublishPhotoUploader new];
    });
    return instance;
}

- (void)loadUploadingQueue
{
    NSArray *dicPhotos = [[EBCache sharedInstance] privateObjectForKey:KEY_PUBLISH_PHOTO_QUEUE];
    
    if (dicPhotos)
    {
        _uploadingPhotos = [self fromDictionaryArray:dicPhotos];
        for (EBHousePhoto *photo in _uploadingPhotos)
        {
            [[AGImagePickerController defaultAssetsLibrary] assetForURL:photo.localUrl resultBlock:^(ALAsset *asset)
             {
                 if (photo.status == EPhotoAddStatusUploading)
                 {
                     photo.status = EPhotoAddStatusWaiting;
                 }
                 else if (photo.status == EPhotoAddStatusAdding)
                 {
                     photo.status = EPhotoAddStatusUploadSuccess;
                 }
                 
             } failureBlock:^(NSError *error)
             {
                 [_uploadingPhotos removeObject:photo];
             }];
        }
    }
}

- (NSArray *)toDictionaryArray:(NSArray *)photos
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:photos.count];
    for (EBHousePhoto *photo in photos)
    {
        [array addObject:@{@"house_id": photo.houseId, @"status": @(photo.status), @"local_url": photo.localUrl, @"remote_url": (photo.remoteUrl ? photo.remoteUrl : @"")}];
    }
    
    return array;
}

- (NSMutableArray *)fromDictionaryArray:(NSArray *)dicPhotos
{
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    for (NSDictionary *dictionary in dicPhotos)
    {
        EBHousePhoto *photo = [EBHousePhoto new];
        photo.houseId = dictionary[@"house_id"];
        photo.status = [dictionary[@"status"] boolValue];
        photo.localUrl = dictionary[@"local_url"];
        photo.remoteUrl = dictionary[@"remote_url"];
        [photos addObject:photo];
    }
    
    return photos;
}

- (void)persistentUploadingQueue
{
    NSArray *dicArray = [self toDictionaryArray:_uploadingPhotos];
    [[EBCache sharedInstance] setPrivateObject:dicArray forKey:KEY_PUBLISH_PHOTO_QUEUE];
}

- (BOOL)photoExist:(EBHousePhoto *)housePhoto
{
    for (EBHousePhoto *photo in _uploadingPhotos)
    {
        if ([photo.houseId isEqualToString:housePhoto.houseId]
            && [photo.localUrl isEqual:housePhoto.localUrl])
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)addPublishPhotos:(NSArray *)photos
{
    if (!_uploadingPhotos)
    {
        _uploadingPhotos = [[NSMutableArray alloc] init];
    }
    for (EBHousePhoto *photo in photos)
    {
        if (![self photoExist:photo])
        {
            [_uploadingPhotos addObject:photo];
        }
    }
    
    [self persistentUploadingQueue];
    [self resumeUploading];
}

- (BOOL)checkUploading
{
    if (!_uploadingPhotos) {
        [self loadUploadingQueue];
    }
    if (_uploadingPhotos.count > 0) {
        return YES;
    }
    else
    {
        [WTStatusBar clearStatus];
        return NO;
    }
}

- (void)resumeUploading
{
    if (!_uploadingPhotos)
    {
        [self loadUploadingQueue];
    }
    if (_uploadingPhotos && _uploadingPhotos.count)
    {
        [self uploadNext];
    }
}

- (void)pauseUploading
{
    [self persistentUploadingQueue];
    _uploadingPhotos = nil;
}

- (void)finishUploading
{
    _currentOperation = nil;
    [[EBCache sharedInstance] removeObjectForKey:KEY_PUBLISH_PHOTO_QUEUE];
    _uploadingPhotos = nil;
}

- (void)uploadPhoto:(EBHousePhoto *)photo
{
    [[AGImagePickerController defaultAssetsLibrary] assetForURL:photo.localUrl resultBlock:^(ALAsset *asset) {
        photo.status = EPhotoAddStatusUploading;
        UIImage *image =[UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage scale:asset.defaultRepresentation.scale orientation:asset.defaultRepresentation.orientation];
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        CGFloat lenth = imageData.length / (1024 * 1024 * 0.2);
        CGFloat compress = 1.0;
        if (lenth > 1.0) {
            compress = 1 / lenth;
        }
        _currentOperation = [[EBHttpClient sharedInstance] dataRequest:@{@"type": @"house"} uploadImage:image withCompression:compress progress:^(id operation, CGFloat progress) {
            _currentOperation = operation;
            photo.progress = progress;
        } handler:^(BOOL success, id result) {
            if (success) {
                NSDictionary *data = (NSDictionary *)result;
                photo.remoteUrl = data[@"url"];
                photo.status = EPhotoAddStatusUploadSuccess;
                [self persistentUploadingQueue];
                [self addPhotoToPublish:photo];
            } else {
                photo.status = EPhotoAddStatusErrorUpload;
                [self persistentUploadingQueue];
                [self resumeUploading];
            }
        }];
    } failureBlock:^(NSError *error) {
        photo.status = EPhotoAddStatusAddSuccess;
        [self persistentUploadingQueue];
        [self resumeUploading];
    }];
}

- (void)uploadNext
{
    BOOL hasJobToDo = NO;
    for (EBHousePhoto *photo in _uploadingPhotos)
    {
        if (photo.status == EPhotoAddStatusWaiting || photo.status == EPhotoAddStatusUploading || photo.status == EPhotoAddStatusErrorUpload)
        {
            hasJobToDo = YES;
            [self uploadPhoto:photo];
            break;
        }
        else if (photo.status == EPhotoAddStatusUploadSuccess || photo.status == EPhotoAddStatusAdding)
        {
            hasJobToDo = YES;
            [self addPhotoToPublish:photo];
            break;
        }
    }
    
    if (!hasJobToDo)
    {
        [self finishUploading];
    }
}

- (void)addPhotoToPublish:(EBHousePhoto *)photo
{
    [[EBHttpClient sharedInstance] gatherPublishRequest:@{@"publish_house_id": photo.houseId, @"url": photo.remoteUrl} addPublishPhoto:^(BOOL success, id result) {
        
    }];
    photo.status = EPhotoAddStatusAddSuccess;
    [self persistentUploadingQueue];
    [self resumeUploading];
}



@end
