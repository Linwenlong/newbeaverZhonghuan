//
// Created by 何 义 on 14-4-1.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBContentAudioView.h"
#import "EBIMMessage.h"
#import "EBRecorderPlayer.h"
#import "EBStyle.h"
#import "EBIMManager.h"

@interface EBContentAudioView()
{
    UIImageView *_imageView;
    UILabel *_timeView;
    UILabel *_markView;
    NSTimer *_animationTimer;
    NSInteger _animationCount;
}
@end

@implementation EBContentAudioView

- (id)init
{
    self = [super init];
    if (self)
    {
         _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [self addSubview:_imageView];

        _timeView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 25)];
        _timeView.textColor = [EBStyle blackTextColor];
        _timeView.font = [UIFont systemFontOfSize:12];
        [self addSubview:_timeView];

        _markView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 6, 6)];
        _markView.layer.cornerRadius = 3.0;
        _markView.layer.masksToBounds = YES;
        _markView.backgroundColor = [EBStyle redTextColor];
//        _markView.hidden = YES;
        [self addSubview:_markView];
    }
    return self;
}

- (BOOL)audioListened
{
   if (self.message.isIncoming)
   {
       id listened = self.message.content[@"listened"];
       return [listened boolValue];
   }

   return YES;
}

+ (CGSize)neededContentSize:(EBIMMessage *)message
{
    NSInteger length = [message.content[@"length"] integerValue];

    CGFloat currentWidth;
    if (length <= 2)
    {
       currentWidth = 30;
    }
    else if (length > 2 && length <= 10)
    {
        currentWidth = 30 + 125.0 / 8 * (length - 2);
    }
    else
    {
        currentWidth = 155 + 35.0 / 50 * (length - 10);
    }

    return CGSizeMake(currentWidth, 24);
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (self.message.isIncoming)
    {
        _imageView.center = CGPointMake(_imageView.frame.size.width / 2, self.frame.size.height / 2);
        _imageView.image = [UIImage imageNamed:@"im_audio_from"];
        _timeView.frame = CGRectOffset(_timeView.bounds, self.bounds.size.width + 20, 0);
        _markView.frame = CGRectOffset(_markView.bounds, self.bounds.size.width + 20, -10);
    }
    else
    {
        _imageView.center = CGPointMake(self.frame.size.width - _imageView.frame.size.width / 2, self.frame.size.height / 2);
        _imageView.image = [UIImage imageNamed:@"im_audio_to"];
        _timeView.frame = CGRectOffset(_timeView.bounds, -(20 + _timeView.bounds.size.width), 0);
        _markView.frame = CGRectOffset(_markView.bounds, -26, -10);
    }
    _timeView.backgroundColor = [UIColor clearColor];
}

- (void)updateContent:(EBIMMessage*)message
{
    [super updateContent:message];
    _timeView.text = [NSString stringWithFormat:@"%ld''", [self.message.content[@"length"] integerValue]];
    _timeView.textAlignment = message.isIncoming ? NSTextAlignmentLeft : NSTextAlignmentRight;

    _markView.hidden = [self audioListened];

    _timeView.hidden = !(message.status == EMessageStatusOK || message.status == EMessageStatusPlaying);

    [self stopAnimation];
    if (message.status == EMessageStatusPlaying)
    {
        [self startAnimationTimer];
    }
}

- (void)startAnimationTimer
{
    if (_animationTimer)
    {
        [_animationTimer invalidate];
        _animationTimer = nil;
    }

    _animationCount = 0;
    _animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(playingAnimation) userInfo:nil repeats:YES];
}

- (void)playingAnimation
{
    if (_animationCount >= 4)
    {
        _animationCount = 0;
    }

    NSString *format = self.message.isIncoming ? @"im_audio_from_%d" : @"im_audio_to_%d";
    _imageView.image = [UIImage imageNamed:[NSString stringWithFormat:format, _animationCount]];

    _animationCount++;
}

- (void)stopAnimation
{
    if (_animationTimer)
    {
        [_animationTimer invalidate];
        _animationTimer = nil;
    }

    NSString *image = self.message.isIncoming ? @"im_audio_from" : @"im_audio_to";
    _imageView.image = [UIImage imageNamed:image];
}

- (void)playAudio
{
    [[EBRecorderPlayer sharedInstance] playAudio:self.message.content withBlock:^(EBPlayerStatus status, NSDictionary *playerInfo)
    {
        switch (status)
        {
            case EBPlayerStatusDownloading:
            case EBPlayerStatusConverting:
                break;
            case EBPlayerStatusPlaying:
                self.bubbleImageView.highlighted = NO;
                self.message.status = EMessageStatusPlaying;
                [self startAnimationTimer];
                break;
            case EBPlayerStatusFinished:
            case EBPlayerStatusCanceled:
            case EBPlayerStatusError:
                [self stopAnimation];
                self.bubbleImageView.highlighted = NO;
                self.message.status = EMessageStatusOK;
                break;
            default:
                break;
        }
    }];
}

- (void)handleTapEvent
{
   self.bubbleImageView.highlighted = YES;

   if (self.message.status == EMessageStatusPlaying)
   {
       [[EBRecorderPlayer sharedInstance] stopPlaying];
   }
   else
   {
       if (![self audioListened])
       {
           _markView.hidden = YES;
           NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithDictionary:self.message.content];
           info[@"listened"] = @(YES);
           self.message.content = info;
           [[EBIMManager sharedInstance] updateMessage:self.message onlyStatus:NO needUpdateTime:NO];
       }
       [self playAudio];
   }
}

- (NSString *)toPasteboard
{
    return @"audio";
}
@end