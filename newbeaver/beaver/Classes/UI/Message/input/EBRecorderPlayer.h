//
// Created by 何 义 on 14-4-5.
// Copyright (c) 2014 eall. All rights reserved.
//

typedef NS_ENUM(NSInteger , EBPlayerStatus)
{
    EBPlayerStatusError = -1,
    EBPlayerStatusDownloading = 0,
    EBPlayerStatusConverting = 1,
    EBPlayerStatusPlaying = 2,
    EBPlayerStatusFinished = 3,
    EBPlayerStatusCanceled = 4
};

@interface EBRecorderPlayer : NSObject

+ (EBRecorderPlayer *)sharedInstance;

+ (NSString *)urlToKey:(NSString *)url;

- (NSString *)wavFilePathWithKey:(NSString *)key;
- (NSString *)amrFilePathWithKey:(NSString *)key;

- (void)startRecording:(void(^)(BOOL success, NSDictionary *result))finished;
- (void)resumeRecording;
- (void)pauseRecording;
- (void)finishRecording;
- (void)cancelRecording;
- (NSInteger)recordingAmp;

//播放二进制流文件
- (void)playAudioData:(NSData *)data withBlock:(void(^)(EBPlayerStatus status, NSDictionary *playerInfo))playBlock;
- (void)palyByData:(NSData *)data;

- (void)playAudio:(NSDictionary *)audioInfo withBlock:(void(^)(EBPlayerStatus status, NSDictionary *playerInfo))playBlock;
- (void)stopPlaying;

- (BOOL)isFollowRecordLocal:(NSString *)url;
- (void)playFollowRecord:(NSString *)url withBlock:(void(^)(EBPlayerStatus status, NSDictionary *playerInfo))playBlock;

@end
