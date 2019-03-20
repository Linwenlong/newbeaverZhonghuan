//
// Created by 何 义 on 14-7-23.
// Copyright (c) 2014 eall. All rights reserved.
//


#import <AssetsLibrary/AssetsLibrary.h>

#import "EBHousePhotoUploader.h"
#import "EBHousePhoto.h"
#import "EBHttpClient.h"
#import "AGImagePickerController.h"
#import "EBCache.h"
#import "EBController.h"
#import "EBAlert.h"
#import "WTStatusBar.h"

#define KEY_UPLOADING_QUEUE @"uploading_photos_queue"

@interface EBHousePhotoUploader()
{
    NSMutableArray *_uploadingPhotos;
    AFHTTPRequestOperation *_currentOperation;
}
@end

@implementation EBHousePhotoUploader

+ (EBHousePhotoUploader *)sharedInstance
{
    static dispatch_once_t pred;
    static EBHousePhotoUploader *_sharedInstance = nil;

    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
        [_sharedInstance loadUploadingQueue];
    });
    return _sharedInstance;
}

- (NSArray *)uploadingPhotos
{
   return _uploadingPhotos;
}

- (void)loadUploadingQueue
{
    NSArray *dicPhotos = [[EBCache sharedInstance] privateObjectForKey:KEY_UPLOADING_QUEUE];

    if (dicPhotos)
    {
        _uploadingPhotos = [self fromDictionaryArray:dicPhotos];
        for (EBHousePhoto *photo in _uploadingPhotos)
        {
            [[AGImagePickerController defaultAssetsLibrary] assetForURL:photo.localUrl resultBlock:^(ALAsset *asset)
            {
                photo.thumbnail = CGImageRetain(asset.thumbnail);

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
       [array addObject:[photo toDictionary]];
   }

   return array;
}

- (NSMutableArray *)fromDictionaryArray:(NSArray *)dicPhotos
{
   NSMutableArray *photos = [[NSMutableArray alloc] init];
   for (NSDictionary *dictionary in dicPhotos)
   {
       [photos addObject:[EBHousePhoto fromDictionary:dictionary]];
   }

   return photos;
}

- (void)persistentUploadingQueue
{
    NSArray *dicArray = [self toDictionaryArray:_uploadingPhotos];
    [[EBCache sharedInstance] setPrivateObject:dicArray forKey:KEY_UPLOADING_QUEUE];
}

- (BOOL)photoExist:(EBHousePhoto *)housePhoto
{
   for (EBHousePhoto *photo in _uploadingPhotos)
   {
       if ([photo.houseId isEqualToString:housePhoto.houseId]
               && [photo.houseType isEqual: housePhoto.houseType]
               && [photo.localUrl isEqual:housePhoto.localUrl])
       {
           return YES;
       }
   }

   return NO;
}

- (void)addHousePhotos:(NSArray *)photos
{
    NSLog(@"photos=%@",photos);
    
    
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
    //持续更新的队列
    [self persistentUploadingQueue];
    [self resumeUploading];
    
    NSString *title = nil;
    if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
        if (title == nil) {
            title = @"";
        }
    }
//    "uploading_photo_start" = "您所选的照片已经开始上传了。在上传完成前，请不要退出app。";
    [[[UIAlertView alloc] initWithTitle:title
                                message:NSLocalizedString(@"uploading_photo_start", nil)
                               delegate:self
                      cancelButtonTitle:NSLocalizedString(@"yes_known", nil) otherButtonTitles:nil] show];

//    [EBAlert confirmWithTitle:nil message:NSLocalizedString(@"uploading_photo_start", nil) yes:NSLocalizedString(@"yes_known", nil) action:^
//    {
//
//    }];
}

- (void)pauseUploading
{
    [self persistentUploadingQueue];
    _uploadingPhotos = nil;
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
        for (EBHousePhoto *photo in _uploadingPhotos)
        {
//            photo.status = EPhotoAddStatusAdding;
            if (photo.status == EPhotoAddStatusUploading || photo.status == EPhotoAddStatusAdding)
            {
                break;
            }
        }

        [self uploadNext];
    }
//    if (_uploadingPhotos.count == 0)
//    {
//        [EBController broadcastNotification:[NSNotification
//                                             notificationWithName:NOTIFICATION_UPLOADING_PHOTO_FINISHED object:nil]];
//    }
//    if (_uploadingPhotos.count == 0) {
//        [WTStatusBar clearStatusAnimated:YES];
//    }
}
#pragma mark -- 上传每一张的图片
- (void)uploadPhoto:(EBHousePhoto *)photo
{
    
    NSLog(@"photo = %@",photo);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[AGImagePickerController defaultAssetsLibrary] assetForURL:photo.localUrl resultBlock:^(ALAsset *asset)
         {
             photo.status = EPhotoAddStatusUploading;
             //        ALAssetOrientation orientation = asset.defaultRepresentation.orientation;
             //        UIImage *image =[UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage];
//             UIImage *image =[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage scale:asset.defaultRepresentation.scale orientation:UIImageOrientationUp];
             UIImage *image = [[UIImage alloc] initWithCGImage:asset.defaultRepresentation.fullScreenImage];
             UIImageOrientation imageOrientation = image.imageOrientation;
             image = [self fixOrientation:image];
             imageOrientation = image.imageOrientation;
             NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
//              NSLog(@"imageData = %@",imageData);
             CGFloat lenth = imageData.length / (1024 * 1024 * 0.2);
             CGFloat compress = 1.0;
             if (lenth > 1.0)
             {
                 compress = 1 / lenth;
             }
             _currentOperation = [[EBHttpClient sharedInstance] dataRequest:@{@"type":@"house"} uploadImage:image
                                                            withCompression:compress
                                                                   progress:
                                  ^(id operation, CGFloat progress){
                                      _currentOperation = operation;
                                      photo.progress = progress;
                                      [EBController broadcastNotification:[NSNotification
                                                                           notificationWithName:NOTIFICATION_UPLOADING_PHOTO_PROGRESS object:nil]];
                                  }
                                                                    handler:
                                  ^(BOOL success, id result)
                                  {
                                      if (success)
                                      {
                                          NSDictionary *data = (NSDictionary *)result;
                                          photo.remoteUrl = data[@"url"];
                                          photo.status = EPhotoAddStatusUploadSuccess;
                                          [self persistentUploadingQueue];
                                          [self addPhotoToHouse:photo];
                                      }
                                      else
                                      {
                                          //加入失败
                                          photo.status = EPhotoAddStatusErrorUpload;
                                          [self persistentUploadingQueue];
                                          [self resumeUploading];
                                      }
                                  }];
         } failureBlock:^(NSError *error)
         {
             
         }];
    });
    
}


//添加图片到房源中
- (void)addPhotoToHouse:(EBHousePhoto *)photo
{
   photo.status = EPhotoAddStatusAdding;
   [[EBHttpClient sharedInstance] houseRequest:photo.toAddParams addPhoto:^(BOOL success, id result)
   {
       if (success)
       {
           photo.status = EPhotoAddStatusAddSuccess;
       }
       else
       {
           photo.status = EPhotoAddStatusErrorAdd;
       }

       [self persistentUploadingQueue];
       [self resumeUploading];
   }];
}

- (void)finishUploading
{
    _currentOperation = nil;
    [[EBCache sharedInstance] removeObjectForKey:KEY_UPLOADING_QUEUE];
    _uploadingPhotos = nil;
}

- (void)uploadNext
{
    BOOL hasJobToDo = NO;
    for (EBHousePhoto *photo in _uploadingPhotos)
    {
        if (photo.status == EPhotoAddStatusWaiting)
        {
            hasJobToDo = YES;
            [self uploadPhoto:photo];
            break;
        }
        else if (photo.status == EPhotoAddStatusUploadSuccess || photo.status == EPhotoAddStatusAdding)
        {
            hasJobToDo = YES;
            [self addPhotoToHouse:photo];
            break;
        }
    }

    if (!hasJobToDo && self.failureCount == 0)
    {
        [self finishUploading];
    }

    [EBController broadcastNotification:[NSNotification
            notificationWithName:hasJobToDo ? NOTIFICATION_UPLOADING_PHOTO : NOTIFICATION_UPLOADING_PHOTO_FINISHED object:nil]];
}

- (void)retry:(NSInteger)photoIndex
{
    if (photoIndex >= 0 && photoIndex < _uploadingPhotos.count)
    {
        EBHousePhoto *photo = _uploadingPhotos[photoIndex];
        if (photo.status == EPhotoAddStatusErrorUpload
                || photo.status == EPhotoAddStatusErrorAdd)
        {
//            [_uploadingPhotos removeObjectAtIndex:photoIndex];
            if (photo.status == EPhotoAddStatusErrorAdd)
            {
               photo.status = EPhotoAddStatusUploadSuccess;
            }
            else if (photo.status == EPhotoAddStatusErrorUpload)
            {
                photo.status = EPhotoAddStatusWaiting;
            }
//            [_uploadingPhotos addObject:photo];

            [self persistentUploadingQueue];
            [self resumeUploading];
        }
    }
}

- (void)cancel:(NSInteger)photoIndex
{
    if (photoIndex >= 0 && photoIndex < _uploadingPhotos.count)
    {
        EBHousePhoto *photo = _uploadingPhotos[photoIndex];
        if (photo.status == EPhotoAddStatusUploading
                || photo.status == EPhotoAddStatusAdding)
        {
           if (_currentOperation)
           {
               [_currentOperation cancel];
           }
        }

        [_uploadingPhotos removeObjectAtIndex:photoIndex];
        [self persistentUploadingQueue];

        [self resumeUploading];
    }
}

- (BOOL)isUploading
{
    for (EBHousePhoto *photo in _uploadingPhotos)
    {
        if (photo.status != EPhotoAddStatusAddSuccess)
        {
            return YES;
        }
    }

    return NO;
}

- (NSInteger)finishedCount
{
    NSInteger finishedCount = 0;
    for (EBHousePhoto *photo in _uploadingPhotos)
    {
        if (photo.status < 0 || photo.status == EPhotoAddStatusAddSuccess)
        {
            finishedCount++;
        }
    }

    return finishedCount;
}

- (NSInteger)failureCount
{
    NSInteger failureCount = 0;
    for (EBHousePhoto *photo in _uploadingPhotos)
    {
        if (photo.status < 0)
        {
            failureCount++;
        }
    }

    return failureCount;
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
