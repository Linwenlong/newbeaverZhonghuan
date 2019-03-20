//
//  EBVideoUtil.m
//  beaver
//
//  Created by LiuLian on 8/13/15.
//  Copyright (c) 2015 eall. All rights reserved.
//

#import "EBVideoUtil.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "EBHttpClient.h"
#import "EBVideoUpload.h"
#import "AESCrypt.h"
#import <CommonCrypto/CommonDigest.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "EBCache.h"
#import "EBController.h"
#import "EBPreferences.h"

#define VIDEO_UPLOAD_HOST @"http://vod.qcloud.com"
#define VIDEO_UPLOAD_URI @"/v2/index.php"

#define BEAVER_CUSTOMER_GET_SIGNATURE @"customer/getSignature"

#define SLICE_SIZE 1024*512
#define VIDEO_UPLOAD_ERROR_MAX_COUNTS 3
#define TIMEOUT_MAX 30

#define VIDEO_CACHE_KEY @"UploadVideos"
#define VIDEO_CACHE_PATH [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@interface EBVideoUtil() <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURL *sourceURL;//当前视频缩略图的url
@property (nonatomic, strong) id target;//controller
@property (nonatomic, strong) MPMoviePlayerViewController* playerViewController;

@property (nonatomic, strong) NSOperationQueue *uploadQueue;
@property (nonatomic, strong) NSMutableDictionary *operationDic;
@property (nonatomic, strong) NSMutableDictionary *videoDic;
@property (nonatomic, strong) NSMutableArray *curVideoArr;

@property (nonatomic, strong) NSArray *videoTypes;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation EBVideoUtil

+ (instancetype)sharedInstance
{
    static EBVideoUtil *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EBVideoUtil alloc] init];
    });
    return instance;
}

#pragma mark - video upload
+ (void)upload:(EBVideoUpload *)video
{
    [[self sharedInstance] setCurVideoArrWithVideo:video];
    [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_UPLOADING_VIDEO object:video]];
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:[self sharedInstance] selector:@selector(uploadOperation:) object:video];
    [[[self sharedInstance] operationDic] setObject:operation forKey:video.name];
    [[[self sharedInstance] videoDic] setObject:video forKey:video.name];
    [[[self sharedInstance] uploadQueue] addOperation:operation];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//        if (video.status == VideoStatusFinish) {
//            return;
//        }
//        
//        NSURL *videoURL = video.assetURL ? : video.tmpURL;
//        
//        NSUInteger fileSize = [self fileSizeWithURL:videoURL];
//        NSString *fileType = [self fileTypeWithURL:videoURL];
//        NSString *fileName = [self fileNameWithURL:videoURL];
//        NSString *fileSha = [self sha1WithURL:videoURL];
//        
//        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//        params[@"fileName"] = fileName;
//        params[@"fileSha"] = fileSha;
//        params[@"fileSize"] = @(fileSize);
//        params[@"fileType"] = fileType;
//        params[@"name"] = [NSString stringWithFormat:@"%@.%@", fileName, fileType];
//        NSUInteger realSliceSize = SLICE_SIZE;
//        if (video.offset + realSliceSize > fileSize) {
//            realSliceSize -= video.offset + realSliceSize - fileSize;
//        }
//        params[@"dataSize"] = @(realSliceSize);
//        params[@"offset"] = @(video.offset);
//        params[@"Nonce"] = @(arc4random() % 1000000);
//        params[@"Timestamp"] = @([[NSDate date] timeIntervalSince1970]);
//        
//        [self doUpload:params video:video];
//    });
}

- (void)uploadOperation:(EBVideoUpload *)video
{
    if (video.status == VideoStatusError) {
        return;
    }
    
    if (video.status == VideoStatusFinish) {
        if ([_curVideoArr containsObject:video]) {
            [self mapRoom:video];
        }
        return;
    }
    
    NSUInteger fileSize = video.size;
    NSString *fileType = video.type;
    NSString *fileName = video.name;
    NSString *fileSha = video.sha1;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"fileName"] = fileName;
    params[@"fileSha"] = fileSha;
    params[@"fileSize"] = @(fileSize);
    params[@"fileType"] = fileType;
    params[@"name"] = [NSString stringWithFormat:@"%@.%@", fileName, fileType];
    NSUInteger realSliceSize = SLICE_SIZE;
    if (video.offset + realSliceSize > fileSize) {
        realSliceSize -= video.offset + realSliceSize - fileSize;
    }
    params[@"dataSize"] = @(realSliceSize);
    params[@"offset"] = @(video.offset);
    params[@"Nonce"] = @(arc4random() % 1000000);
    params[@"Timestamp"] = @([[NSDate date] timeIntervalSince1970]);
    
    [self doUpload:params video:video];
}

- (void)doUpload:(NSDictionary *)params video:(EBVideoUpload *)video
{
    [[EBHttpClient sharedInstance] customerRequest:params getSignature:^(BOOL success, id result) {
        if (success) {
//            NSURL *videoURL = video.assetURL ? : video.tmpURL;
            NSURL *videoURL = video.tmpURL;
            NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%s", [videoURL fileSystemRepresentation]]];
            NSData *data = [EBVideoUtil fileDataWithFile:fileURL offset:(NSUInteger)[result[@"offset"] longLongValue] size:(NSUInteger)[result[@"dataSize"] longLongValue]];
            if (!data) {
                [self uploadError:video];
            }
            
            NSMutableArray *paramArr = [[NSMutableArray alloc] init];
            [result enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [paramArr addObject:[NSString stringWithFormat:@"%@=%@", key, [EBVideoUtil encodeStr:obj]]];
            }];
            NSString *paramStr = [paramArr componentsJoinedByString:@"&"];
            NSString *requestStr = [NSString stringWithFormat:@"%@%@?%@", VIDEO_UPLOAD_HOST, VIDEO_UPLOAD_URI, paramStr];
            
            NSInputStream *is = [NSInputStream inputStreamWithData:data];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestStr]];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBodyStream:is];
            [request addValue:@"*/*" forHTTPHeaderField:@"accept"];
            [request addValue:@"Keep-Alive" forHTTPHeaderField:@"connection"];
            [request addValue:@"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1;SV1)" forHTTPHeaderField:@"user-agent"];
            [request addValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
            [request addValue:result[@"dataSize"] forHTTPHeaderField:@"Content-Length"];
            [request setTimeoutInterval:TIMEOUT_MAX];
            
            NSURLConnection *conn = [NSURLConnection connectionWithRequest:request delegate:self];
            [conn start];
        } else {
            [self uploadError:video];
        }
    }];
}

- (void)uploadError:(EBVideoUpload *)video
{
    video.errorCounts++;
    if (video.errorCounts < VIDEO_UPLOAD_ERROR_MAX_COUNTS) {
        [self uploadOperation:video];
    } else {
        video.status = VideoStatusError;
        if ([_curVideoArr containsObject:video]) {
            [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_UPLOADING_VIDEO_FINISHED object:video]];
        }
    }
}

+ (NSUInteger)fileSizeWithURL:(NSURL *)videoURL
{
    NSUInteger size = 0;
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    NSString *filePath = [NSString stringWithFormat:@"%s", [videoURL fileSystemRepresentation]];
    if ([fileMgr fileExistsAtPath:filePath]) {
        NSDictionary *attr = [fileMgr attributesOfItemAtPath:filePath error:nil];
        size = (NSUInteger)[[attr objectForKey:NSFileSize] longLongValue];
    }
    return size;
}

+ (NSString *)fileNameWithURL:(NSURL *)videoURL
{
    NSString *filePath = [NSString stringWithFormat:@"%s", [videoURL fileSystemRepresentation]];
    NSString *tmpStr = [AESCrypt encryptStr:filePath];
    if (tmpStr.length > 28) {
        tmpStr = [tmpStr substringToIndex:29];
    }
    NSUInteger time = [[NSDate date] timeIntervalSince1970];
    
    return [NSString stringWithFormat:@"%@_%d", tmpStr, time];
}

+ (NSString *)fileTypeWithURL:(NSURL *)videoURL
{
    return [videoURL pathExtension];
}

+ (NSString*)sha1WithURL:(NSURL *)videoURL
{
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"video" ofType:@".mp4"];
    NSString *filePath = [NSString stringWithFormat:@"%s", [videoURL fileSystemRepresentation]];
    
    NSString *result = nil;
    CFReadStreamRef readStream = NULL;
    CFURLRef fileURL = NULL;
    @try {
        fileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)filePath, kCFURLPOSIXPathStyle, (Boolean)false);
        if (!fileURL) {
            return result;
        }
        
        readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault, fileURL);
        if (!readStream) {
            return result;
        }
        if (!CFReadStreamOpen(readStream)) {
            return result;
        }
        
        CC_SHA1_CTX ctx;
        CC_SHA1_Init(&ctx);
        size_t chunkSize = 4096;
        
        bool hasMoreData = true;
        while (hasMoreData) {
            uint8_t buffer[chunkSize];
            CFIndex readBytesCount = CFReadStreamRead(readStream, buffer, sizeof(buffer));
            if (readBytesCount == -1) {
                return result;
            }
            if (readBytesCount == 0) {
                hasMoreData = false;
            } else {
                CC_SHA1_Update(&ctx, buffer, (CC_LONG)readBytesCount);
            }
        }
        
        unsigned char digest[CC_SHA1_DIGEST_LENGTH];
        CC_SHA1_Final(digest, &ctx);
        
        NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
        
        for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
            [output appendFormat:@"%02x", digest[i]];
        }
        result = output;
        NSLog(@"%@", result);
        
        return result;
    }
    @catch (NSException *exception) {
        return result;
    }
    @finally {
        if (readStream) {
            CFReadStreamClose(readStream);
            CFRelease(readStream);
        }
        
        if (fileURL) {
            CFRelease(fileURL);
        }
    }
}

+ (NSData *)fileDataWithFile:(NSURL *)file offset:(NSUInteger)offset size:(NSUInteger)size
{
    NSString *filePath = [file absoluteString];
    
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    if (![fileMgr fileExistsAtPath:filePath]) {
        return nil;
    }
    
    NSDictionary *attr = [fileMgr attributesOfItemAtPath:filePath error:nil];
    NSUInteger fileSize = (NSUInteger)[[attr objectForKey:NSFileSize] longLongValue];
    if (offset >= fileSize) {
        return nil;
    }
    if (offset + size > fileSize) {
        size -= offset + size - fileSize;
    }
    
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForReadingAtPath:[file absoluteString]];
    [fileHandler seekToFileOffset:offset];
    return [fileHandler readDataOfLength:size];
}

+ (NSString *)encodeStr:(NSString *)str
{
    //    __block NSString *encode = [str stringByReplacingOccurrencesOfString:@"%" withString:@"%25"];
    //    encode = [encode stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    NSDictionary *specialChars = @{@"+":@"%2B", @" ":@"%20", @"/":@"%2F", @"?":@"%3F", @"#":@"%23", @"&":@"%26", @"=":@"%3D"};
    //    [specialChars enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    //        encode = [encode stringByReplacingOccurrencesOfString:key withString:obj];
    //    }];
    
    NSString *encode = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return encode;
}

+ (NSString *)saveToDocument:(ALAsset *)asset
{
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    NSString * videoPath = [VIDEO_CACHE_PATH stringByAppendingPathComponent:[asset defaultRepresentation].filename];
    char const *cvideoPath = [videoPath UTF8String];
    FILE *file = fopen(cvideoPath, "a+");
    if (file) {
        const int bufferSize = 1024 * 1024;
        Byte *buffer = (Byte*)malloc(bufferSize);
        NSUInteger read = 0, offset = 0, written = 0;
        NSError* err = nil;
        if (rep.size != 0) {
            do {
                read = [rep getBytes:buffer fromOffset:offset length:bufferSize error:&err];
                written = fwrite(buffer, sizeof(char), read, file);
                offset += read;
            } while (read != 0 && !err);
        }
        free(buffer);
        buffer = NULL;
        fclose(file);
        file = NULL;
    } else {
        return nil;
    }
    
    return videoPath;
}

- (NSOperationQueue *)uploadQueue
{
    if (!_uploadQueue) {
        _uploadQueue = [[NSOperationQueue alloc] init];
    }
    return _uploadQueue;
}

- (NSMutableDictionary *)operationDic
{
    if (!_operationDic) {
        _operationDic = [[NSMutableDictionary alloc] init];
    }
    return _operationDic;
}

- (NSMutableDictionary *)videoDic
{
    if (!_videoDic) {
        _videoDic = [[NSMutableDictionary alloc] init];
    }
    return _videoDic;
}

+ (void)stop
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
//        NSArray *allVideos = [[[self sharedInstance] videoDic] allValues];
        NSMutableArray *allVideos = [NSMutableArray arrayWithArray:[[self sharedInstance] curVideoArr]];
        for (EBVideoUpload *video in allVideos) {
            if (!video.asset) {
                [library writeVideoAtPathToSavedPhotosAlbum:video.tmpURL completionBlock:^(NSURL *assetURL, NSError *error) {
                    [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                        video.asset = asset;
                        [[EBCache sharedInstance] setObject:allVideos forKey:VIDEO_CACHE_KEY];
                    } failureBlock:^(NSError *error) {
                        [allVideos removeObject:video];
                    }];
                }];
            }
        }
        [[EBCache sharedInstance] setObject:allVideos forKey:VIDEO_CACHE_KEY];
        
        [[[self sharedInstance] uploadQueue] cancelAllOperations];
        
        [[[self sharedInstance] operationDic] removeAllObjects];
        [[self sharedInstance] setOperationDic:nil];
        
        [[[self sharedInstance] videoDic] removeAllObjects];
        [[self sharedInstance] setVideoDic:nil];
        
        [[self sharedInstance] setUploadQueue:nil];
    });
}

+ (void)resume
{
    NSArray *arr = [[EBCache sharedInstance] objectForKey:VIDEO_CACHE_KEY];
    
    [[self sharedInstance] setCurVideoArr:[NSMutableArray arrayWithArray:arr]];
    for (EBVideoUpload *video in arr) {
        if (video.asset) {
            [self upload:video];
        }
    }
}

+ (void)retry:(NSUInteger)index
{
    EBVideoUpload *video = [[self sharedInstance] curVideoArr][index];
    video.status = video.offset == video.size ? VideoStatusFinish : VideoStatusUploading;
    [self upload:video];
}

+ (void)cancel:(NSUInteger)index
{
    EBVideoUpload *video = [[self sharedInstance] curVideoArr][index];
    NSOperation *op = [[[self sharedInstance] operationDic] objectForKey:video.name];
    [op cancel];
    [[[self sharedInstance] operationDic] removeObjectForKey:video.name];
    
    [[[self sharedInstance] curVideoArr] removeObjectAtIndex:index];
}

+ (BOOL)isUploading
{
    return [[self sharedInstance] curVideoArr].count > 0;
}

#pragma mark - nsurlconnection data delegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    EBVideoUpload *video = [self videoWithConnection:connection];
    if (!video) {
        return;
    }
    
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    if ([response[@"code"] integerValue] == 0) {
        video.errorCounts = 0;
        if ([response[@"flag"] integerValue] == 1) {
            video.remoteUid = [response[@"fileId"] stringValue];
            video.status = VideoStatusFinish;
            video.offset = video.size;
            
            [[self operationDic] removeObjectForKey:video.name];
            [[self videoDic] removeObjectForKey:video.name];
            
            [self mapRoom:video];
        } else {
            video.offset = [response[@"offset"] integerValue];
            
            if ([_curVideoArr containsObject:video]) {
                [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_UPLOADING_VIDEO_PROGRESS object:video]];
            }
            
            [self uploadOperation:video];
        }
    } else {
        [self uploadError:video];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    EBVideoUpload *video = [self videoWithConnection:connection];
    if (!video) {
        return;
    }
    [self uploadError:video];
}

- (EBVideoUpload *)videoWithConnection:(NSURLConnection *)connection
{
    NSString *videoName = nil;
    NSString *requestStr = [[connection.currentRequest URL] absoluteString];
    NSArray *tmpArr = [requestStr componentsSeparatedByString:@"&"];
    NSString *prefix = @"fileName=";
    for (NSString *tmpStr in tmpArr) {
        if ([tmpStr hasPrefix:prefix]) {
            videoName = [tmpStr substringFromIndex:prefix.length];
            break;
        }
    }
    
    if (videoName) {
        return [self.videoDic objectForKey:videoName];
    }
    return nil;
}

- (void)mapRoom:(EBVideoUpload *)video
{
    if ([_curVideoArr containsObject:video]) {
        [[EBHttpClient sharedInstance] customerRequest:@{@"room_id": video.houseUid, @"file_id": video.remoteUid, @"company_code": [EBPreferences sharedInstance].companyCode} mapRoomAudioUri:^(BOOL success, id result) {
            [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_UPLOADING_VIDEO_FINISHED object:video]];
            if (success) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_curVideoArr removeObject:video];
                    [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_UPLOADING_VIDEO_FINISHED object:video]];
                });
            } else {
                [self uploadError:video];
            }
        }];
    }
}

#pragma mark - video play
+ (UIView *)getThumbViewWithURL:(NSURL *)videoURL frame:(CGRect)frame target:(id)target
{
    [EBVideoUtil sharedInstance].sourceURL = videoURL;
    [EBVideoUtil sharedInstance].target = target;
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:view.bounds];
    [view addSubview:imageView];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        UIImage *image = [self getThumbnailWithURL:videoURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = image;
        });
    });
    
    UIButton *modalView = [[UIButton alloc] initWithFrame:view.bounds];
    [view addSubview:modalView];
    modalView.backgroundColor = [UIColor colorWithRed:0x00/255.0 green:0x00/255.0 blue:0x00/255.0 alpha:0.5];
    [modalView addTarget:[EBVideoUtil sharedInstance] action:@selector(houseVideoPlay:) forControlEvents:UIControlEventTouchUpInside];
    
    return view;
}

+ (UIImage *)getThumbnailWithURL:(NSURL *)videoURL
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    
    return thumb;
}

+ (BOOL)validVideoSelected:(ALAsset *)asset assets:(NSArray *)assets
{
    BOOL hasVideo = NO;
    for (ALAsset *as in assets) {
        NSString *tmpType = [self typeWithAsset:as];
        if ([[[self sharedInstance] videoTypes] containsObject:tmpType]) {
            hasVideo = YES;
            break;
        }
    }
    
    if (hasVideo) {
        NSString *type = [self typeWithAsset:asset];
        if ([[[self sharedInstance] videoTypes] containsObject:type]) {
            return NO;
        }
    }
    
    return YES;
}

+ (BOOL)isVideoWithAsset:(ALAsset *)asset
{
    NSString *type = [self typeWithAsset:asset];
    return [[[self sharedInstance] videoTypes] containsObject:type];
}

+ (NSString *)typeWithAsset:(ALAsset *)asset
{
    NSString *type = nil;
    NSString *assetUrl = [[asset.defaultRepresentation url] absoluteString];
    NSArray *arr = [assetUrl componentsSeparatedByString:@"&"];
    NSString *prefixt = @"ext=";
    for (NSString *str in arr) {
        NSRange range = [str rangeOfString:prefixt];
        if (range.location != NSNotFound) {
            type = [[str substringFromIndex:prefixt.length] lowercaseString];
        }
    }
    return type;
}

- (void)houseVideoPlay:(id)sender
{
    _playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:_sourceURL];
    MPMoviePlayerController *pc = [_playerViewController moviePlayer];
    pc.controlStyle = MPMovieControlStyleNone;
    pc.repeatMode = MPMovieRepeatModeOne;
    pc.scalingMode = MPMovieScalingModeAspectFit;
    pc.movieSourceType = MPMovieSourceTypeFile;
    
    
    _indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 44.0, 44.0)];
    _indicator.center = _playerViewController.view.center;
    [_playerViewController.view addSubview:_indicator];
    [_indicator startAnimating];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAction:) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoTapAction:)];
    UIView *view = [[_playerViewController.view subviews] objectAtIndex:0];
    [view addGestureRecognizer:tap];
    
    [(UIViewController *)_target presentMoviePlayerViewControllerAnimated:_playerViewController];
}

- (void)notificationAction:(id)sender
{
    if (!_indicator) {
        return;
    }
    
    [_indicator stopAnimating];
    [_indicator removeFromSuperview];
    _indicator = nil;
}

+ (void)playWithURL:(id)target remoteURL:(NSURL *)url
{
    [[self sharedInstance] setSourceURL:url];
    [[self sharedInstance] setTarget:target];
    
    [[self sharedInstance] houseVideoPlay:nil];
}

- (void)videoTapAction:(id)sender
{
    [_playerViewController.moviePlayer stop];
    [_playerViewController dismissMoviePlayerViewControllerAnimated];
}

#pragma mark - getters and setters
- (NSArray *)videoTypes
{
    if (!_videoTypes) {
        _videoTypes = @[@"avi", @"mov", @"mpeg", @"mpg", @"dat", @"asf", @"wmv", @"navi", @"3gp", @"ram", @"ra", @"mkv", @"flv", @"f4v", @"rmvb", @"rm", @"webm"];
    }
    return _videoTypes;
}

- (void)setCurVideoArrWithVideo:(EBVideoUpload *)video
{
    if (!_curVideoArr) {
        _curVideoArr = [[NSMutableArray alloc] init];
    }
    
    BOOL hasVideo = NO;
    NSUInteger i = 0;
    for (; i < _curVideoArr.count; i++) {
        EBVideoUpload *tmpVideo = [_curVideoArr objectAtIndex:i];
        if ([video.houseUid isEqualToString:tmpVideo.houseUid]) {
            hasVideo = YES;
            break;
        }
    }
    
    if (!hasVideo) {
        [_curVideoArr addObject:video];
    } else {
        [_curVideoArr replaceObjectAtIndex:i withObject:video];
    }
}

- (NSArray *)uploadingVideos
{
    return _curVideoArr;
}

@end
