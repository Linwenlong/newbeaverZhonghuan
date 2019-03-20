//
//  EBAudioPlayer.m
//  beaver
//
//  Created by wangyuliang on 14-7-2.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CommonCrypto/CommonDigest.h>
#import "EBAudioPlayer.h"
#import "EBAlert.h"
#import "VoiceConverter.h"
#import "EBHttpClient.h"

@interface EBAudioPlayer() <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (copy, nonatomic)   void(^playerBlock)(EBPlayerStatus status, NSDictionary *playerInfo);
@property (copy, nonatomic)   void(^recorderBlock)(BOOL success, NSDictionary *result);
@property (strong, nonatomic) NSString *audioKey;
@property (strong, nonatomic) NSString *audioDir;
@property (strong, nonatomic) NSString *audioFormat;

@end

@implementation EBAudioPlayer

@synthesize recorder,player,audioKey,audioDir,audioFormat;

+ (EBAudioPlayer *)sharedInstance
{
    static EBAudioPlayer *_sharedInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        //       audioDir = [NSString stringWithFormat:@"%@/Documents/im_audio/", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
        NSString* cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        audioDir = [[[cachesDirectory stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]] stringByAppendingPathComponent:@"follow_audio"] copy];
        if (![[NSFileManager defaultManager] fileExistsAtPath:audioDir])
        {
            NSError *error;
            [[NSFileManager defaultManager] createDirectoryAtPath:audioDir withIntermediateDirectories:YES attributes:nil error:&error];
        }
    }
    return self;
}

- (NSString *)wavFilePathWithKey:(NSString *)key format:(NSString *)format
{
    NSString *path =[NSString stringWithFormat:@"%@/%@.%@", audioDir, key, format];
    return path;
}

- (void)stopPlaying
{
    if (player && player.isPlaying)
    {
        [player stop];
        if (_playerBlock)
        {
            _playerBlock(EBPlayerStatusCanceled, nil);
        }
    }
    
    player = nil;
}

- (void)loadAudio:(NSString *)url format:(NSString *)format withProgress:(void(^)(NSInteger progess))progressBlock withBlock:(void(^)(EBPlayerStatus status, NSDictionary *playerInfo))playBlock
{
    NSString *newKey = [EBAudioPlayer urlToKey:url];
    [[EBHttpClient sharedInstance] downloadFile:url to:[self wavFilePathWithKey:newKey format:format] withProgress:^(id operation, CGFloat progress)
     {
         ;
     }
                                        handler:^(BOOL success, id result)
     {
         if (success)
         {
             ;
         }
         else
         {
//             self.playerBlock(EBPlayerStatusError, @{@"desc":@"downloading"});
         }
     }];
}

- (void)playAudio:(NSString *)url format:(NSString *)format withBlock:(void(^)(EBPlayerStatus status, NSDictionary *playerInfo))playBlock
{
    [self stopPlaying];
    self.playerBlock = playBlock;
    //
    NSString *newKey = [EBAudioPlayer urlToKey:url];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self wavFilePathWithKey:newKey format:format]])
    {
        [self playByKey:newKey format:format];
    }
    else
    {
        self.playerBlock(EBPlayerStatusDownloading, nil);
        [[EBHttpClient sharedInstance] downloadFile:url to:[self wavFilePathWithKey:newKey format:format] withProgress:^(id operation, CGFloat progress)
         {
             ;
         }
                                            handler:^(BOOL success, id result)
         {
             if (success)
             {
                 [self playByKey:newKey format:format];
                 //                 [self playByKey:newKey];
             }
             else
             {
                 self.playerBlock(EBPlayerStatusError, @{@"desc":@"downloading"});
             }
         }];
    }
}

- (BOOL)isAudioLocalExist:(NSString *)url format:(NSString *)format
{
    BOOL ret = NO;
    NSString *newKey = [EBAudioPlayer urlToKey:url];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self wavFilePathWithKey:newKey format:format]])
    {
        ret = YES;
    }
    else
    {
        ret = NO;
    }
    return ret;
}

- (void)playByKey:(NSString *)key format:(NSString *)format
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self wavFilePathWithKey:key format:format]])
    {
        self.playerBlock(EBPlayerStatusPlaying, nil);
        player = [self playerWithFilePath:[self wavFilePathWithKey:key format:format]];
        if (player)
        {
            [player play];
        }
    }
}

- (void)startRecording:(void(^)(BOOL success, NSDictionary *result))finished
{
    recorder = nil;
    audioKey = nil;
    self.recorderBlock = finished;
    if (self.recorder)
    {
        [recorder recordForDuration:60];
    }
}

- (void)resumeRecording
{
    if (recorder && !recorder.isRecording)
    {
        [recorder record];
    }
}

- (NSInteger)recordingLength
{
    return (NSInteger)recorder.currentTime;
}

- (void)pauseRecording
{
    if (recorder && recorder.isRecording)
    {
        [recorder pause];
    }
}

- (void)finishRecording
{
    if (recorder && recorder.isRecording)
    {
        NSTimeInterval length = recorder.currentTime;
        [recorder stop];
        recorder = nil;
        if (length < 1.0)
        {
            self.recorderBlock(NO, @{@"error":@"recording too short"});
        }
        else
        {
            NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
            result[@"length"] = @((NSInteger)length);
            result[@"key"] = audioKey;
            result[@"wav"] = [self wavFilePathWithKey:audioKey format:audioFormat];
            
            if (0 == [VoiceConverter wavToAmr:result[@"wav"] amrSavePath:result[@"amr"]])
            {
                self.recorderBlock(YES, result);
            }
            else
            {
                result[@"error"] = @"wav to amr failed";
                self.recorderBlock(NO, result);
            }
        }
    }
}

- (void)cancelRecording
{
    [recorder stop];
    [recorder deleteRecording];
}

- (NSInteger)recordingAmp
{
    [recorder updateMeters];
    
    CGFloat meter = [recorder averagePowerForChannel:0];
    if (meter <= -40)
    {
        return 0;
    }
    else if (meter <= -35 &&  -40 < meter)
    {
        return  1;
    }
    else if (meter <= -10 && -35 < meter)
    {
        return 2;
    }
    else
    {
        return 3;
    }
}

- (AVAudioRecorder *)recorder
{
    if (!recorder)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        
        NSError *err = nil;
        [audioSession setCategory : AVAudioSessionCategoryPlayAndRecord error:&err];
        if(err)
        {
            return nil;
        }
        
        [audioSession setActive:YES error:&err];
        err = nil;
        if(err)
        {
            return nil;
        }
        
        NSDictionary *settings = @{
                                   AVSampleRateKey :  [NSNumber numberWithFloat: 8000.0],
                                   AVFormatIDKey :  [NSNumber numberWithInt: kAudioFormatLinearPCM],
                                   AVNumberOfChannelsKey : [NSNumber numberWithInt: 1]};
        
        NSError *error;
        recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:[self wavFilePathWithKey:self.audioKey format:self.audioFormat]]
                                               settings:settings error:&error];
        recorder.delegate = self;
        recorder.meteringEnabled = YES;
        
        if (error)
        {
            [EBAlert alertError:error.description];
            recorder = nil;
        }
    }
    
    return recorder;
}

- (AVAudioPlayer *)playerWithFilePath:(NSString *)path
{
    if (!player)
    {
        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                                sizeof(sessionCategory),
                                &sessionCategory);
        
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                                 sizeof (audioRouteOverride),
                                 &audioRouteOverride);
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        //默认情况下扬声器播放
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];
        
        NSError *error = nil;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
        if (error)
        {
            DDLogError(@"%@", error.description);
            return nil;
        }
        
        player.delegate = self;
    }
    
    return player;
}

- (NSString *)audioKey
{
    if (audioKey == nil)
    {
        audioKey = [NSString stringWithFormat:@"a_%ld", (NSInteger)[NSDate date].timeIntervalSince1970];
    }
    
    return audioKey;
}

- (NSString *)audioFormat
{
    if (audioFormat == nil)
    {
        audioFormat = @"wav";
    }
    
    return audioFormat;
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)aRecorder successfully:(BOOL)flag
{
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)aRecorder error:(NSError *)error
{
    DDLogDebug(@"%@", error);
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)aPlayer successfully:(BOOL)flag
{
    if (self.playerBlock)
    {
        self.playerBlock(EBPlayerStatusFinished, nil);
    }
}

+ (NSString *)urlToKey:(NSString *)url
{
    const char *str = [url UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
}

@end
