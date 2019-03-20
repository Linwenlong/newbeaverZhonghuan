//
//  VideoListViewController.m
//  beaver
//
//  Created by LiuLian on 8/27/15.
//  Copyright (c) 2015 eall. All rights reserved.
//

#import "VideoListViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "EBAlert.h"
#import "EBStyle.h"
#import "EBVideoUtil.h"
#import "HouseVideoPreUploadViewController.h"

@interface VideoListViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray *videoAssets;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic) NSIndexPath *selectVideoPath;

@end

@implementation VideoListViewController

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static ALAssetsLibrary *assetsLibrary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        // Workaround for triggering ALAssetsLibraryChangedNotification
        [assetsLibrary writeImageToSavedPhotosAlbum:nil metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) { }];
    });
    
    return assetsLibrary;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"选择视频";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_note_close"] style:UIBarButtonItemStyleDone target:self action:@selector(back:)];
    
    [self addRightNavigationBtnWithTitle:@"下一步" target:self action:@selector(nextAction:)];

    
    [self getVideoAssets];
}

- (void)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getVideoAssets
{
    if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusRestricted || [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied) {
        [EBAlert alertWithTitle:nil message:NSLocalizedString(@"user_setavatar_album_restrict_tip", nil) yes:NSLocalizedString(@"confirm", nil) confirm:nil];
        return;
    }
    
    [EBAlert showLoading:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @autoreleasepool {
            [self.videoAssets removeAllObjects];
            
            void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
                if (group) {
                    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        NSString *type = [result valueForProperty:ALAssetPropertyType];
                        if ([type isEqualToString:ALAssetTypeVideo]) {
                            [self.videoAssets addObject:result];
                        }
                    }];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [EBAlert hideLoading];
                        [self.collectionView reloadData];
                    });
                }
            };
            
            void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
//                NSLog(@"A problem occured. Error: %@", error.localizedDescription);
                [EBAlert hideLoading];
                [self.collectionView reloadData];
            };
            
            [[VideoListViewController defaultAssetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:assetGroupEnumerator failureBlock:assetGroupEnumberatorFailure];
        }
        
    });
}

#pragma mark - collectionview delegate and datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.videoAssets.count == 0) {
        [EBAlert alertError:@"相册没有视频"];
    }
    
    return self.videoAssets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VideoCell" forIndexPath:indexPath];
    if (!cell) {
        CGFloat w = collectionView.width / 4.0;
        cell = [[UICollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, w, w)];
    }
    
    NSUInteger row = [indexPath row];
    ALAsset *asset = [self.videoAssets objectAtIndex:row];
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1000];
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2.5, 2.5, cell.width-5, cell.height-5)];
        imageView.tag = 1000;
        UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_video_play"]];
        iconImageView.width = imageView.width * 0.3;
        iconImageView.height = imageView.height * 0.3;
        iconImageView.center = CGPointMake(imageView.width * 0.5, imageView.height * 0.5);
        [imageView addSubview:iconImageView];
        [cell.contentView addSubview:imageView];
    }
    imageView.image = [EBVideoUtil getThumbnailWithURL:[asset defaultRepresentation].url];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *selectCell = [collectionView cellForItemAtIndexPath:_selectVideoPath];
    UIView *oldImageView = (UIView *)[selectCell viewWithTag:888];
    if (oldImageView) {
        [oldImageView removeFromSuperview];
        if (_selectVideoPath != indexPath) {
            _selectVideoPath = indexPath;
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            
            
            UIView *coverView = [[UIView alloc] init];
            coverView.frame = cell.contentView.frame;
            coverView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
            coverView.alpha = 1.0f;
            coverView.tag = 888;
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image_select_icon"]];
            imageView.frame = CGRectMake(coverView.width - 22 - 5, coverView.height - 22 - 5, 22, 22);
            [coverView addSubview:imageView];
            [cell.contentView addSubview:coverView];
        }
    }else{
        _selectVideoPath = indexPath;
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        UIView *coverView = [[UIView alloc] init];
        coverView.frame = cell.contentView.frame;
        coverView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        coverView.tag = 888;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image_select_icon"]];
        imageView.frame = CGRectMake(coverView.width - 22 - 5, coverView.height - 22 - 5, 22, 22);
        [coverView addSubview:imageView];
        [cell.contentView addSubview:coverView];
    }
   
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat w = collectionView.width/4.0;
    return CGSizeMake(w, w);
}

#pragma mark - getter and setter
- (NSMutableArray *)videoAssets
{
    if (!_videoAssets) {
        _videoAssets = [[NSMutableArray alloc] init];
    }
    return _videoAssets;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO] collectionViewLayout:layout];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"VideoCell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.alwaysBounceVertical = YES;
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

#pragma mark - private method
- (void)nextAction:(id)sender
{
    UICollectionViewCell *selectCell = [_collectionView cellForItemAtIndexPath:_selectVideoPath];
    UIView *oldImageView = (UIView *)[selectCell viewWithTag:888];
    if (!oldImageView) {
        [EBAlert alertError:@"请选择一个视频"];
        return;
    }
    
    ALAsset *asset = [self.videoAssets objectAtIndex:_selectVideoPath.row];

    HouseVideoPreUploadViewController *vc = [[HouseVideoPreUploadViewController alloc] init];
    vc.asset = asset;
    vc.houseUid = _houseUid;

    [self.navigationController pushViewController:vc animated:YES];
}

@end
