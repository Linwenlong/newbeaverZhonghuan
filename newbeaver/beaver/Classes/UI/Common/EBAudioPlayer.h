//
//  EBAudioPlayer.h
//  beaver
//
//  Created by wangyuliang on 14-7-2.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger , EBPlayerStatus)
{
    EBPlayerStatusError = -1,
    EBPlayerStatusDownloading = 0,
    EBPlayerStatusConverting = 1,
    EBPlayerStatusPlaying = 2,
    EBPlayerStatusFinished = 3,
    EBPlayerStatusCanceled = 4
};

@interface EBAudioPlayer : NSObject

+ (EBAudioPlayer *)sharedInstance;
+ (NSString *)urlToKey:(NSString *)url;

- (NSString *)wavFilePathWithKey:(NSString *)key format:(NSString *)format;

- (void)startRecording:(void(^)(BOOL success, NSDictionary *result))finished;
- (void)resumeRecording;
- (void)pauseRecording;
- (void)finishRecording;
- (void)cancelRecording;
- (NSInteger)recordingAmp;

- (void)loadAudio:(NSString *)url format:(NSString *)format withProgress:(void(^)(NSInteger progess))progressBlock withBlock:(void(^)(EBPlayerStatus status, NSDictionary *playerInfo))playBlock;
- (void)playAudio:(NSString *)url format:(NSString *)format withBlock:(void(^)(EBPlayerStatus status, NSDictionary *playerInfo))playBlock;
- (void)stopPlaying;

- (BOOL)isAudioLocalExist:(NSString *)url format:(NSString *)format;

@end
