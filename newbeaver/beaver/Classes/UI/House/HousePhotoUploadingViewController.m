//
// Created by 何 义 on 14-7-23.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "HousePhotoUploadingViewController.h"
#import "EBProgressBar.h"
#import "EBHousePhoto.h"
#import "EBHousePhotoUploader.h"
#import "EBController.h"
#import "EBVideoUtil.h"
#import "EBVideoUpload.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface HousePhotoUploadingViewController()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_tableView;
}

@end

@implementation HousePhotoUploadingViewController

- (void)loadView
{
    [super loadView];

    _tableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 80;
    [self.view addSubview:_tableView];

    UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 86)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 290, 60)];
    label.textColor = [EBStyle blackTextColor];
    label.font = [UIFont systemFontOfSize:14.0];
    label.numberOfLines = 3;
    label.text = NSLocalizedString(@"uploading_desc", nil);
    [tableHeader addSubview:label];
    _tableView.tableHeaderView = tableHeader;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [EBController observeNotification:NOTIFICATION_UPLOADING_PHOTO from:self selector:@selector(uploadingPhotoNotify:)];
    [EBController observeNotification:NOTIFICATION_UPLOADING_PHOTO_FINISHED from:self selector:@selector(uploadingPhotoNotify:)];
    [EBController observeNotification:NOTIFICATION_UPLOADING_PHOTO_PROGRESS from:self selector:@selector(uploadingPhotoNotify:)];
    [EBController observeNotification:NOTIFICATION_UPLOADING_VIDEO from:self selector:@selector(uploadingPhotoNotify:)];
    [EBController observeNotification:NOTIFICATION_UPLOADING_VIDEO_FINISHED from:self selector:@selector(uploadingPhotoNotify:)];
    [EBController observeNotification:NOTIFICATION_UPLOADING_VIDEO_PROGRESS from:self selector:@selector(uploadingPhotoNotify:)];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)uploadingPhotoNotify:(NSNotification *)notification
{
    [_tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [EBHousePhotoUploader sharedInstance].uploadingPhotos.count + [[EBVideoUtil sharedInstance] uploadingVideos].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:70];
    UIImageView *playIconImgView = (UIImageView *)[cell.contentView viewWithTag:1000];
    EBProgressBar *progressBar = (EBProgressBar *)[cell.contentView viewWithTag:80];
    UILabel *descLabel = (UILabel *)[cell.contentView viewWithTag:90];
    UIButton *retryBtn = (UIButton *)[cell.contentView viewWithTag:777];
    UIButton *cancelBtn = (UIButton *)[cell.contentView viewWithTag:999];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, 64, 64)];
        imgView.tag = 70;
        
        playIconImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_video_play"]];
        playIconImgView.width = imgView.width * 0.3;
        playIconImgView.height = imgView.height * 0.3;
        playIconImgView.tag = 1000;
        playIconImgView.center = CGPointMake(imgView.width * 0.5, imgView.height * 0.5);
        [imgView addSubview:playIconImgView];
        playIconImgView.hidden = YES;
        
        [cell.contentView addSubview:imgView];

        progressBar = [[EBProgressBar alloc] initWithFrame:CGRectMake(90, 15, 215, 15)];
        progressBar.tag = 80;
        [cell.contentView addSubview:progressBar];

        descLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 40, 60, 16)];
        descLabel.tag = 90;
        descLabel.textColor = [EBStyle blackTextColor];
        descLabel.font = [UIFont systemFontOfSize:14.0];
        [cell.contentView addSubview:descLabel];

        retryBtn = [[UIButton alloc] initWithFrame:CGRectMake(150, 28, 40, 44)];
        retryBtn.tag = 777;
        retryBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [retryBtn setTitle:NSLocalizedString(@"retry", nil) forState:UIControlStateNormal];
        [retryBtn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
        [retryBtn setTitleColor:[EBStyle darkBlueTextColor] forState:UIControlStateHighlighted];
        [retryBtn addTarget:self action:@selector(retryUploading:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:retryBtn];

        cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(265, 28, 50, 44)];
        cancelBtn.tag = 999;
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [cancelBtn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[EBStyle darkBlueTextColor] forState:UIControlStateHighlighted];
        [cancelBtn addTarget:self action:@selector(cancelUploading:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:cancelBtn];
    }

    NSInteger index = [indexPath row];
    
    cell.contentView.tag = index;
    retryBtn.hidden = YES;
    cancelBtn.hidden = NO;
    
    progressBar.progress = 0.0;
    
    if (index < [EBHousePhotoUploader sharedInstance].uploadingPhotos.count) {
        playIconImgView.hidden = YES;
        EBHousePhoto *photo = [EBHousePhotoUploader sharedInstance].uploadingPhotos[index];
        
        imgView.image = [UIImage imageWithCGImage:photo.thumbnail];
        if (photo.status == EPhotoAddStatusAddSuccess)
        {
            progressBar.progress = 1.0;
            cancelBtn.hidden = YES;
            descLabel.text = NSLocalizedString(@"upload_finished", nil);
        }
        else if (photo.status < 0)
        {
            retryBtn.hidden = NO;
            descLabel.text = NSLocalizedString(@"upload_failure", nil);
        }
        else if (photo.status == EPhotoAddStatusWaiting)
        {
            descLabel.text = NSLocalizedString(@"upload_queueing", nil);
        }
        else
        {
            progressBar.progress = photo.progress;
            CGFloat progress;
            if (photo.progress == 1.0)
            {
                progress = 0.99;
            }
            else
            {
                progress =photo.progress;
            }
            descLabel.text = [NSString stringWithFormat:@"%.0f%%", progress * 100];
        }
    } else {
        playIconImgView.hidden = NO;
        EBVideoUpload *video = [[EBVideoUtil sharedInstance] uploadingVideos][index - [EBHousePhotoUploader sharedInstance].uploadingPhotos.count];
        
        imgView.image = [EBVideoUtil getThumbnailWithURL:(video.asset ? video.asset.defaultRepresentation.url : video.tmpURL)];
        if (video.status == VideoStatusFinish) {
            progressBar.progress = 1.0;
            cancelBtn.hidden = YES;
            descLabel.text = NSLocalizedString(@"upload_finished", nil);
        } else if (video.status == VideoStatusError) {
            retryBtn.hidden = NO;
            descLabel.text = NSLocalizedString(@"upload_failure", nil);
        } else {
            CGFloat progress = video.progress;
            progressBar.progress = progress;
            descLabel.text = [NSString stringWithFormat:@"%.0f%%", progress * 100];
        }
    }

    return cell;
}

- (void)retryUploading:(UIButton *)btn
{
    NSUInteger index = btn.superview.tag;
    if (index < [EBHousePhotoUploader sharedInstance].uploadingPhotos.count) {
        [[EBHousePhotoUploader sharedInstance] retry:index];
    } else {
        [EBVideoUtil retry:index-[EBHousePhotoUploader sharedInstance].uploadingPhotos.count];
    }
    
    [_tableView reloadData];
}

- (void)cancelUploading:(UIButton *)btn
{
    NSUInteger index = btn.superview.tag;
    if (index < [EBHousePhotoUploader sharedInstance].uploadingPhotos.count) {
        [[EBHousePhotoUploader sharedInstance] cancel:index];
    } else {
        [EBVideoUtil cancel:index-[EBHousePhotoUploader sharedInstance].uploadingPhotos.count];
    }
    
    [_tableView reloadData];
}

@end