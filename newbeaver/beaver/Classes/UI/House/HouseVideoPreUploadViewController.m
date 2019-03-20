//
//  HouseVideoPreUploadViewController.m
//  beaver
//
//  Created by LiuLian on 8/12/15.
//  Copyright (c) 2015 eall. All rights reserved.
//

#import "HouseVideoPreUploadViewController.h"
#import "EBAlert.h"
#import "EBVideoUtil.h"
#import "EBController.h"
#import "EBVideoUpload.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AFNetworkReachabilityManager.h"
#import "UIAlertView+Blocks.h"
#import "RIButtonItem.h"
#import <AVFoundation/AVFoundation.h>

@interface HouseVideoPreUploadViewController ()
{
    UIView *_myView;
    UILabel *_timeLabel;
    UILabel *_sizeLabel;
    
    NSInteger _videoDuaration;
}

@end

@implementation HouseVideoPreUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"视频上传";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_note_close"] style:UIBarButtonItemStyleDone target:self action:@selector(back:)];
    [self addRightNavigationBtnWithTitle:@"上传" target:self action:@selector(uploadAction:)];
    
    _myView = [EBVideoUtil getThumbViewWithURL:(_asset ? ([_asset defaultRepresentation].url) : _tmpURL) frame:CGRectMake(15, 15, self.view.width-30, 220) target:self];
    [self.view addSubview:_myView];
    
    CGFloat midW = _myView.width/2;
    NSURL  *url = [[_asset defaultRepresentation] url];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_myView.left, _myView.bottom + 15.0, midW, 17)];
    _timeLabel.textAlignment = NSTextAlignmentLeft;
    _timeLabel.textColor = [EBStyle blackTextColor];
    _timeLabel.font = [UIFont systemFontOfSize:14];
    
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];  // 初始化视频媒体文件
    NSInteger hour = 0, minute = 0, second = 0;
    second = urlAsset.duration.value / urlAsset.duration.timescale; // 获取视频总时长,单位秒
    _videoDuaration = second;
    //NSLog(@"movie duration : %d", second);
    if (second >= 3600){
        NSInteger index = second / 3600;
        hour = index;
        second = second - hour*3600;
        index = second / 60;
        minute = index;
        second = second - index * 60;
    }
    
    if (second >= 60) {
        NSInteger index = second / 60;
        minute = index;
        second = second - index * 60;
    }
    NSString *timerStr = @"";
    if (_videoDuaration >= 3600) {
        timerStr = [NSString stringWithFormat:@"%ld小时%ld分%ld秒",hour,minute,second];
    } else if (_videoDuaration >= 60){
        timerStr = [NSString stringWithFormat:@"%ld分%ld秒",minute,second];
    } else {
        timerStr = [NSString stringWithFormat:@"%ld秒",second];
    }
    
    if (second == 60) {
        timerStr = @"1分";
    }
    _timeLabel.text = [NSString stringWithFormat:@"时长：%@",timerStr];
    [self.view addSubview:_timeLabel];
    
    _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_timeLabel.right, _timeLabel.top, midW, 17)];
    _sizeLabel.textAlignment = NSTextAlignmentRight;
    _sizeLabel.font = [UIFont systemFontOfSize:14];
    _sizeLabel.textColor = [EBStyle blackTextColor];
    NSUInteger size = (UInt32)_asset.defaultRepresentation.size;
    _sizeLabel.text = [NSString stringWithFormat:@"大小：%.1fM",size/(1024.0*1024.0)];
    [self.view addSubview:_sizeLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)back:(id)sender
{
    [EBAlert confirmWithTitle:nil message:NSLocalizedString(@"confirm_leave_video_upload", nil) yes:NSLocalizedString(@"confirm_leave_condition_give_up", nil) action:^{
         [self dismissViewControllerAnimated:YES completion:nil];
     }];
}

- (void)uploadAction:(id)sender
{
    if (_videoDuaration > 60) {
        [EBAlert alertError:@"视频长度不能超过一分钟"];
        return;
    }
    NSUInteger size = (UInt32)_asset.defaultRepresentation.size;
    if ((size/(1024*1024)) > 100) {
        [EBAlert alertError:@"视频过大，视频大小不能超过100M"];
        return;
    }
    AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if (status == AFNetworkReachabilityStatusReachableViaWWAN)
    {
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:NSLocalizedString(@"confirm_giveup_video_upload", nil)
                           cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"cancel", nil) action:^{
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
            
        }]
                           otherButtonItems:[RIButtonItem itemWithLabel:@"上传" action:^{
            [self uploadVideo];
            
        }], nil] show];
    }
    else {
        [self uploadVideo];
    }
}

- (void)uploadVideo
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [EBAlert alertSuccess:NSLocalizedString(@"uploading_video_start", nil) allowUserInteraction:NO];
    
    EBVideoUpload *video = [[EBVideoUpload alloc] init];
    video.houseUid = _houseUid;
    //    video.assetURL = _assetURL;
    video.tmpURL = _tmpURL;
    video.asset = _asset;
    //    video.offset = 0;
    //    video.errorCounts = 0;
    video.status = VideoStatusUploading;
    [EBVideoUtil upload:video];
}

#pragma mark - private
-(long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}
@end
