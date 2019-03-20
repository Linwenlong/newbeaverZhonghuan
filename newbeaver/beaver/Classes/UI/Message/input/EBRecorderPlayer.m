//
// Created by 何 义 on 14-4-5.
// Copyright (c) 2014 eall. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import <CommonCrypto/CommonDigest.h>
#import "EBRecorderPlayer.h"
#import "EBAlert.h"
#import "VoiceConverter.h"
#import "EBHttpClient.h"

@interface EBRecorderPlayer() <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (copy, nonatomic)   void(^playerBlock)(EBPlayerStatus status, NSDictionary *playerInfo);
@property (copy, nonatomic)   void(^recorderBlock)(BOOL success, NSDictionary *result);
@property (strong, nonatomic) NSString *audioKey;
@property (strong, nonatomic) NSString *audioDir;

@end

@implementation EBRecorderPlayer

@synthesize recorder,player,audioKey,audioDir;

+ (EBRecorderPlayer *)sharedInstance
{
    static EBRecorderPlayer *_sharedInstance = nil;
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
       audioDir = [[[cachesDirectory stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]] stringByAppendingPathComponent:@"im_audio"] copy];
       if (![[NSFileManager defaultManager] fileExistsAtPath:audioDir])
       {
           NSError *error;
           [[NSFileManager defaultManager] createDirectoryAtPath:audioDir withIntermediateDirectories:YES attributes:nil error:&error];
       }
    }
    return self;
}

- (NSString *)wavFilePathWithKey:(NSString *)key
{
   NSString *path =[NSString stringWithFormat:@"%@/%@.wav", audioDir, key];
    return path;
}

- (NSString *)amrFilePathWithKey:(NSString *)key
{
    return [NSString stringWithFormat:@"%@/%@.amr", audioDir, key];
}

- (void)stopPlaying
{
    if (player && player.isPlaying)
    {
        [player stop];
        [self removeMonitor];
        if (_playerBlock)
        {
            _playerBlock(EBPlayerStatusCanceled, nil);
        }
    }

    player = nil;
}

//lwl
- (void)palyByData:(NSData *)data{
    player = [self playerWithData:data];
    if (player)
    {
        [self beginMonitor];
        NSDictionary *playerInfo = @{
                                     @"player":player};
        self.playerBlock(EBPlayerStatusPlaying, playerInfo);
        [player play];
    }
}

- (void)playAudioData:(NSData *)data withBlock:(void(^)(EBPlayerStatus status, NSDictionary *playerInfo))playBlock{
//    NSLog(@"data=%@",data);
    [self stopPlaying];
    self.playerBlock = playBlock;
    if (data.length != 0) {
        [self palyByData:data];
    }
}

- (void)playAudio:(NSDictionary *)audioInfo withBlock:(void(^)(EBPlayerStatus status, NSDictionary *playerInfo))playBlock
{
    NSLog(@"audioInfo=%@",audioInfo);
    [self stopPlaying];
    self.playerBlock = playBlock;
//
    NSString *key = audioInfo[@"local"];

    if ((key && key.length > 0) && ([[NSFileManager defaultManager] fileExistsAtPath:[self wavFilePathWithKey:key]] ||
            [[NSFileManager defaultManager] fileExistsAtPath:[self amrFilePathWithKey:key]]))
    {
        [self playByKey:key];
    }
    else
    {
        NSString *url = audioInfo[@"url"];
        NSString *newKey = [EBRecorderPlayer urlToKey:url];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self wavFilePathWithKey:newKey]] ||
                [[NSFileManager defaultManager] fileExistsAtPath:[self amrFilePathWithKey:newKey]])
        {
            [self playByKey:newKey];
        }
        else
        {
            self.playerBlock(EBPlayerStatusDownloading, nil);
            [[EBHttpClient sharedInstance] downloadFile:url to:[self amrFilePathWithKey:newKey] withHandler:^(BOOL success, id result)
            {
                if (success)
                {
                    [self playByKey:newKey];
                }
                else
                {
                    self.playerBlock(EBPlayerStatusError, @{@"desc":@"downloading"});
                }
            }];
        }
    }
}

- (BOOL)isFollowRecordLocal:(NSString *)url
{
    BOOL ret = NO;
    NSString *newKey = [EBRecorderPlayer urlToKey:url];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self wavFilePathWithKey:newKey]])
    {
        ret = YES;
    }
    else
    {
        ret = NO;
    }
    return ret;
}



- (void)playFollowRecord:(NSString *)url withBlock:(void(^)(EBPlayerStatus status, NSDictionary *playerInfo))playBlock
{
    [self stopPlaying];
    self.playerBlock = playBlock;
    //
//    NSString *url = audioInfo[@"url"];
    NSString *newKey = [EBRecorderPlayer urlToKey:url];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self wavFilePathWithKey:newKey]] ||
        [[NSFileManager defaultManager] fileExistsAtPath:[self amrFilePathWithKey:newKey]])
    {
        [self playByKey:newKey];
    }
    else
    {
        self.playerBlock(EBPlayerStatusDownloading, nil);
        [[EBHttpClient sharedInstance] downloadFile:url to:[self amrFilePathWithKey:newKey] withProgress:^(id operation, CGFloat progress)
         {
             ;
         }
        handler:^(BOOL success, id result)
         {
             if (success)
             {
                 [self playByKey:newKey];
             }
             else
             {
                 self.playerBlock(EBPlayerStatusError, @{@"desc":@"downloading"});
             }
         }];
    }
}




- (void)playByKey:(NSString *)key
{
   if ([[NSFileManager defaultManager] fileExistsAtPath:[self wavFilePathWithKey:key]])
   {
       player = [self playerWithFilePath:[self wavFilePathWithKey:key]];
       
       if (player)
       {
           [self beginMonitor];
           self.playerBlock(EBPlayerStatusPlaying, nil);
           [player play];
       }
   }
   else if ([[NSFileManager defaultManager] fileExistsAtPath:[self amrFilePathWithKey:key]])
   {
       self.playerBlock(EBPlayerStatusConverting, nil);
       if (0 == [VoiceConverter amrToWav:[self amrFilePathWithKey:key] wavSavePath:[self wavFilePathWithKey:key]])
       {
           [self playByKey:key];
       }
       else
       {
           self.playerBlock(EBPlayerStatusError, nil);
       }

   }
}

//lwl
- (AVAudioPlayer *)playerWithData:(NSData *)data{

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
        player = [[AVAudioPlayer alloc] initWithData:data error:&error];
        if (error)
        {
            DDLogError(@"%@", error.description);
            return nil;
        }
        
        player.delegate = self;
    }
    
    return player;

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
            result[@"wav"] = [self wavFilePathWithKey:audioKey];
            result[@"amr"] = [self amrFilePathWithKey:audioKey];

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
        recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:[self wavFilePathWithKey:self.audioKey]]
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
    [self removeMonitor];
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

- (void)beginMonitor
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    
    //添加监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sensorStateChange:)
                                                 name:@"UIDeviceProximityStateDidChangeNotification"
                                               object:nil];
}

- (void)removeMonitor
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}

//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES){
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else{
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

@end
