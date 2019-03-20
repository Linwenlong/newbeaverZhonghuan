//
//  ClientFollowLogDataSource.m
//  beaver
//
//  Created by wangyuliang on 14-6-22.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "ClientFollowLogDataSource.h"
#import "EBStyle.h"
#import "EBHttpClient.h"
#import "EBHouse.h"
#import "EBViewFactory.h"
#import "EBIconLabel.h"
#import "EBContact.h"
#import "EBPrice.h"
#import "EBController.h"
#import "EBFilter.h"
#import "UIImageView+AFNetworking.h"
#import "EBClientFollowLog.h"
#import "EBAudioPlayer.h"
#import "EBProgressView.h"

@implementation ClientFollowLogDataSource
{
    NSMutableDictionary *_loadDic;
    NSMutableDictionary *_playDic;
    NSMutableDictionary *_stopDic;
    NSMutableDictionary *_loadingDic;
    UIButton *_loadBtn;
    UIButton *_playBtn;
    UIButton *_stopBtn;
    EBProgressView *_progressView;
}

- (CGFloat)heightOfRow:(NSInteger)row
{
    CGFloat height;
    if(row < [self.dataArray count])
    {
        EBClientFollowLog *log = self.dataArray[row];
        if (log.is_tel_record)
        {
            if (log.content && (log.content.length > 0))
            {
                height = 112 + [EBViewFactory textSize:log.content font:[UIFont systemFontOfSize:14] bounding:CGSizeMake(290, 640)].height;
            }
            else
            {
                height = 80;
            }
//            NSString *url = log.record[@"record_url"];
//            if (url && (url.length > 0))
//            {
//                if (log.content && (log.content.length > 0))
//                {
//                    height = 112 + [EBViewFactory textSize:log.content font:[UIFont systemFontOfSize:14] bounding:CGSizeMake(290, 640)].height;
//                }
//                else
//                {
//                    height = 80;
//                }
//            }
//            else
//                height = 80;
        }
        else
        {
            CGSize contentSize = [EBViewFactory textSize:log.content font:[UIFont systemFontOfSize:14] bounding:CGSizeMake(300, 640)];
            height = 56 + contentSize.height;
        }
    }
    else
    {
        height = 73;
    }
    return height;
}

- (UILabel*)createLabel:(CGRect)frame color:(UIColor*)color font:(UIFont*)font text:(NSString*)text alignment:(NSTextAlignment)textAlignment
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.numberOfLines = 0;
    label.textColor = color;
    label.font = font;
    label.textAlignment = textAlignment;
    label.text = text;
    return label;
}

- (void)addImage:(UIView*)view name:(NSString*)name xfloat:(CGFloat)x yfloat:(CGFloat)y
{
    if (view)
    {
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
        CGRect frame = icon.frame;
        icon.frame = CGRectOffset(frame, x, y);
        [view addSubview:icon];
    }
}

- (NSString*)transformAudioLong:(NSInteger)voiceLong
{
    NSString *retLong = nil;
    if (voiceLong < 60)
    {
        retLong = [NSString stringWithFormat:@"%ld\"",voiceLong];
    }
    else
    {
        NSInteger min = voiceLong / 60;
        NSInteger sec = voiceLong % 60;
        retLong = [NSString stringWithFormat:@"%ld\'%ld\"",min,sec];
    }
    return retLong;
}

- (NSString*)transformAudioSize:(NSInteger)voiceSize
{
    NSString *retSize = nil;
    if (voiceSize < 1024)
    {
        retSize = [NSString stringWithFormat:@"%ldB",voiceSize];
    }
    else if ((voiceSize >= 1024) && (voiceSize < 1024 * 1024))
    {
        NSInteger kSize = voiceSize / 1024;
        NSInteger bSize = (voiceSize % 1024) / 102;
        if ((voiceSize % 1024) % 102 >= 51)
        {
            bSize = bSize + 1;
        }
        retSize = [NSString stringWithFormat:@"%ld.%ldK",kSize,bSize];
    }
    else
    {
        NSInteger mSize = voiceSize / (1024 * 1024);
        NSInteger kSize = (voiceSize % (1024 * 1024)) / (102 * 1024);
        if ((voiceSize % (1024 * 1024)) % (102 * 1024) >= (51 * 1024))
        {
            kSize = kSize + 1;
        }
        retSize = [NSString stringWithFormat:@"%ld.%ldM",mSize,kSize];
    }
    return retSize;
}

- (NSString*)transformDate:(NSInteger)timeDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timeDate];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    NSArray *array = [confromTimespStr componentsSeparatedByString:@" "];
    NSString *text = nil;
    if([array count] > 1)
    {
        NSArray *dateArray = [array[0] componentsSeparatedByString:@"-"];
        NSArray *timeArray = [array[1] componentsSeparatedByString:@":"];
        NSInteger hour = [timeArray[0] intValue];
        NSInteger minute = [timeArray[1] intValue];
        text = [NSString stringWithFormat:@"%@-%@-%@ %ld:%ld", dateArray[0],dateArray[1],dateArray[2],hour,minute];
    }
    else
    {
        text = [NSString stringWithFormat:@"%ld", timeDate];
    }
    return text;
}

- (UIButton*)createBtn:(NSString*)imageName tag:(NSInteger)tag action:(SEL)action
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    CGRect frame = imageView.frame;
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    btn.frame = CGRectMake([EBStyle screenWidth] - 54, 12, frame.size.width + 20, frame.size.height + 20);
    btn.tag = tag;
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)createBtnDic:(NSInteger)row
{
    if (!_loadDic)
    {
        _loadDic = [[NSMutableDictionary alloc] init];
        [_loadDic setObject:_loadBtn forKey:[NSString stringWithFormat:@"%ld",row]];
    }
    else
    {
        [_loadDic setObject:_loadBtn forKey:[NSString stringWithFormat:@"%ld",row]];
    }
    if (!_playDic)
    {
        _playDic = [[NSMutableDictionary alloc] init];
        [_playDic setObject:_playBtn forKey:[NSString stringWithFormat:@"%ld",row]];
    }
    else
    {
        [_playDic setObject:_playBtn forKey:[NSString stringWithFormat:@"%ld",row]];
    }
    if (!_stopDic)
    {
        _stopDic = [[NSMutableDictionary alloc] init];
        [_stopDic setObject:_stopBtn forKey:[NSString stringWithFormat:@"%ld",row]];
    }
    else
    {
        [_stopDic setObject:_stopBtn forKey:[NSString stringWithFormat:@"%ld",row]];
    }
    
    if (!_loadingDic)
    {
        _loadingDic = [[NSMutableDictionary alloc] init];
        [_loadingDic setObject:_progressView forKey:[NSString stringWithFormat:@"%ld",row]];
    }
    else
    {
        [_loadingDic setObject:_progressView forKey:[NSString stringWithFormat:@"%ld",row]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRow:(NSInteger)row
{
    CGFloat height = [self heightOfRow:row];
    EBClientFollowLog *log = self.dataArray[row];
    CGSize contentSize = [EBViewFactory textSize:log.content font:[UIFont systemFontOfSize:14] bounding:CGSizeMake(300, 640)];
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], height)];
        CGSize userSize = [EBViewFactory textSize:log.user font:[UIFont systemFontOfSize:14] bounding:CGSizeMake(150, 18)];
        UILabel *user = [self createLabel:CGRectMake(14, 10, userSize.width, userSize.height) color:[EBStyle blackTextColor] font:[UIFont systemFontOfSize:14.0] text:log.user alignment:NSTextAlignmentLeft];
        [view addSubview:user];
        
        CGSize departSize = [EBViewFactory textSize:log.department font:[UIFont systemFontOfSize:14] bounding:CGSizeMake(306 - userSize.width - 12, 18)];
        UILabel *department = [self createLabel:CGRectMake(26 + userSize.width, 10, departSize.width, departSize.height) color:[EBStyle grayTextColor] font:[UIFont systemFontOfSize:14.0] text:log.department alignment:NSTextAlignmentLeft];
        [view addSubview:department];
        
        CGFloat timeHeight = 50;
        NSInteger verticalGap = 3;
        if (log.is_tel_record)
        {
            timeHeight = 54;
        }
        else
        {
            timeHeight = 10 + userSize.height + 2 * verticalGap + contentSize.height;
        }
        NSString *timeText = [self transformDate:log.date];
        CGSize timeSize = [EBViewFactory textSize:timeText font:[UIFont systemFontOfSize:12] bounding:CGSizeMake(150, 640)];
        UILabel *time = [self createLabel:CGRectMake(14, timeHeight, timeSize.width, timeSize.height) color:[EBStyle grayTextColor] font:[UIFont systemFontOfSize:12.0] text:timeText alignment:NSTextAlignmentLeft];
        [view addSubview:time];
        
        
        CGSize waySize = [EBViewFactory textSize:timeText font:[UIFont systemFontOfSize:12] bounding:CGSizeMake(150, 640)];
        UILabel *way = [self createLabel:CGRectMake(14 + timeSize.width + 10, timeHeight, waySize.width, waySize.height) color:[EBStyle grayTextColor] font:[UIFont systemFontOfSize:12.0] text:log.way alignment:NSTextAlignmentLeft];
        [view addSubview:way];
        
        if (log.is_tel_record)
        {
            NSString *url = log.record[@"record_url"];
            if (url && (url.length > 0))
            {
                [self addImage:view name:@"follow_audio_icon" xfloat:14 yfloat:34];
                
                
                NSInteger voiceLong = [log.record[@"last_time"] intValue];
                UILabel *audioLong = [self createLabel:CGRectMake(38, 32, 100, 18) color:[EBStyle blackTextColor] font:[UIFont systemFontOfSize:14] text:[self transformAudioLong:voiceLong] alignment:NSTextAlignmentLeft];
                [view addSubview:audioLong];
                
                NSInteger voiceSize = [log.record[@"file_size"] intValue];
                UILabel *audioSize =[self createLabel:CGRectMake(170, 32, 100, 18) color:[EBStyle blackTextColor] font:[UIFont systemFontOfSize:14] text:[self transformAudioSize:voiceSize] alignment:NSTextAlignmentRight];
                [view addSubview:audioSize];
                
                _loadBtn = [self createBtn:@"follow_audio_load" tag:100 + row action:@selector(audioLoad:)];
                [view addSubview:_loadBtn];
                
                _playBtn = [self createBtn:@"follow_audio_play" tag:100 + row action:@selector(audioPlay:)];
                [view addSubview:_playBtn];
                
                _stopBtn = [self createBtn:@"follow_audio_stop" tag:100 + row action:@selector(audioStop:)];
                [view addSubview:_stopBtn];
                
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"follow_audio_stop"]];
                CGRect frame = imageView.frame;
                
                _progressView = [[EBProgressView alloc] initWithFrame:CGRectMake([EBStyle screenWidth] - 44, 24, frame.size.width, frame.size.height) backColor:[UIColor whiteColor] progressColor:[UIColor greenColor] lineWidth:frame.size.width / 2];
                [view addSubview:_progressView];
                
                [self createBtnDic:row];
                
                if ([[EBAudioPlayer sharedInstance] isAudioLocalExist:[log.record objectForKey:@"record_url"] format:log.record[@"file_format"]])
                {
                    _playBtn.hidden = NO;
                    _loadBtn.hidden = YES;
                    _stopBtn.hidden = YES;
                    _progressView.hidden = YES;
                }
                else
                {
                    _playBtn.hidden = YES;
                    _loadBtn.hidden = NO;
                    _stopBtn.hidden = YES;
                    _progressView.hidden = YES;
                }
                if (log.content && (log.content.length > 0))
                {
                    UIView *audioNoteView = [[UIView alloc] initWithFrame:CGRectMake(15, 78, 290, 22 + [EBViewFactory textSize:log.content font:[UIFont systemFontOfSize:14] bounding:CGSizeMake(290, 640)].height)];
                    audioNoteView.backgroundColor = [UIColor colorWithRed:252.0/255.0 green:242.0 / 255.0 blue:187.0 / 255.0 alpha:1.0];
                    UILabel *audioNoteText = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 270, 22 + [EBViewFactory textSize:log.content font:[UIFont systemFontOfSize:14] bounding:CGSizeMake(290, 640)].height)];
                    audioNoteText.numberOfLines = 0;
                    audioNoteText.textAlignment = NSTextAlignmentLeft;
                    audioNoteText.textColor = [EBStyle blackTextColor];
                    audioNoteText.font = [UIFont systemFontOfSize:14.0];
                    audioNoteText.text = log.content;
                    [audioNoteView addSubview:audioNoteText];
                    [view addSubview:audioNoteView];
                }
            }
            else
            {
                NSInteger byetype = [log.record[@"byetype"] integerValue];
                if (byetype == 0)
                {
                    [self addImage:view name:@"follow_audio_wait" xfloat:14 yfloat:34];
                }
                else if (byetype < 0)
                {
                    [self addImage:view name:@"follow_audio_break" xfloat:14 yfloat:34];
                }
                UILabel *msgLabel = [self createLabel:CGRectMake(46, 10 + userSize.height + 6, 268, userSize.height) color:[EBStyle blackTextColor] font:[UIFont systemFontOfSize:14.0] text:log.record[@"msg"] alignment:NSTextAlignmentLeft];
                [view addSubview:msgLabel];
                if (log.content && (log.content.length > 0))
                {
                    UIView *audioNoteView = [[UIView alloc] initWithFrame:CGRectMake(15, 78, 290, 22 + [EBViewFactory textSize:log.content font:[UIFont systemFontOfSize:14] bounding:CGSizeMake(290, 640)].height)];
                    audioNoteView.backgroundColor = [UIColor colorWithRed:252.0/255.0 green:242.0 / 255.0 blue:187.0 / 255.0 alpha:1.0];
                    UILabel *audioNoteText = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 270, 22 + [EBViewFactory textSize:log.content font:[UIFont systemFontOfSize:14] bounding:CGSizeMake(290, 640)].height)];
                    audioNoteText.numberOfLines = 0;
                    audioNoteText.textAlignment = NSTextAlignmentLeft;
                    audioNoteText.textColor = [EBStyle blackTextColor];
                    audioNoteText.font = [UIFont systemFontOfSize:14.0];
                    audioNoteText.text = log.content;
                    [audioNoteView addSubview:audioNoteText];
                    [view addSubview:audioNoteView];
                }
            }
        }
        else
        {
            CGSize contentSize = [EBViewFactory textSize:log.content font:[UIFont systemFontOfSize:14] bounding:CGSizeMake(300, 640)];
            UILabel *content = [self createLabel:CGRectMake(14, 10 + userSize.height + verticalGap, 300, contentSize.height) color:[EBStyle blackTextColor] font:[UIFont systemFontOfSize:14.0] text:log.content alignment:NSTextAlignmentLeft];
            [view addSubview:content];
        }
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        [cell.contentView addSubview:view];
        [cell.contentView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:height - 0.5 leftMargin:14.0]];
    }
    
    return cell;
}

- (void)audioLoad:(UIButton *)btn
{
    NSInteger row = btn.tag - 100;
    EBProgressView *progressView = [_loadingDic objectForKey:[NSString stringWithFormat:@"%ld",row]];
    EBClientFollowLog *log = self.dataArray[row];
    NSString *url = [log.record objectForKey:@"record_url"];
    NSString *newKey = [EBAudioPlayer urlToKey:url];
    [[EBHttpClient sharedInstance] downloadFile:url to:[[EBAudioPlayer sharedInstance] wavFilePathWithKey:newKey format:log.record[@"file_format"]]
                                   withProgress:^(id operation, CGFloat progress)
     {
         btn.hidden = YES;
         progressView.hidden = NO;
         [progressView updateProgress:progress];
     }
                                        handler:^(BOOL success, id result)
     {
         progressView.hidden = YES;
         if (success)
         {
             btn.hidden = YES;
             UIButton *temp = [_playDic objectForKey:[NSString stringWithFormat:@"%ld",row]];
             temp.hidden = NO;
             //                 [self playByKey:newKey];
         }
         else
         {
             //                 self.playerBlock(EBPlayerStatusError, @{@"desc":@"downloading"});
         }
     }];
}

- (void)audioPlay:(UIButton *)btn
{
    if (_curPlayingRow != -1)
    {
        UIButton *tempStop = [_stopDic objectForKey:[NSString stringWithFormat:@"%ld",_curPlayingRow]];
        UIButton *tempPlay = [_playDic objectForKey:[NSString stringWithFormat:@"%ld",_curPlayingRow]];
        tempStop.hidden = YES;
        tempPlay.hidden = NO;
    }
    
    NSInteger row = btn.tag - 100;
    _curPlayingRow = row;
    EBClientFollowLog *log = self.dataArray[row];
    
    [[EBAudioPlayer sharedInstance] playAudio:log.record[@"record_url"] format:log.record[@"file_format"] withBlock:^(EBPlayerStatus status, NSDictionary *playerInfo){
        if (status == EBPlayerStatusPlaying)
        {
            btn.hidden = YES;
            UIButton *temp = [_stopDic objectForKey:[NSString stringWithFormat:@"%ld",row]];
            temp.hidden = NO;
        }
        if (status == EBPlayerStatusFinished)
        {
            btn.hidden = NO;
            UIButton *temp = [_stopDic objectForKey:[NSString stringWithFormat:@"%ld",row]];
            temp.hidden = YES;
        }
    }];
}

- (void)audioStop:(UIButton *)btn
{
    NSInteger row = btn.tag - 100;
    [[EBAudioPlayer sharedInstance] stopPlaying];
    btn.hidden = YES;
    UIButton *temp = [_playDic objectForKey:[NSString stringWithFormat:@"%ld",row]];
    temp.hidden = NO;
}

@end
