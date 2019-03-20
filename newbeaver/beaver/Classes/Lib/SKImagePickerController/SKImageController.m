//
//  SKImageController.m
//  chow
//
//  Created by wangyuliang on 14-12-1.
//  Copyright (c) 2014年 eallcn. All rights reserved.
//

#import "SKImageController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "EBNavigationController.h"
#import "SKAlbumViewController.h"
#import "SKAssetsViewController.h"
#import "EBAlert.h"

@implementation SKImageController

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

+ (void)showMutlSelectPhotoFrom:(UIViewController *)viewCtrl maxSelect:(NSInteger)maxSelectNum select:(assertSelect)photoSelect
{
    if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusRestricted || [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied) {
        [EBAlert alertWithTitle:nil message:NSLocalizedString(@"user_setavatar_album_restrict_tip", nil) yes:NSLocalizedString(@"confirm", nil) confirm:nil];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @autoreleasepool {
            NSMutableArray *groupArray = [[NSMutableArray alloc] init];
            __block ALAssetsGroup *groupMax;
            void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
            {
                if (group) {
                    if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos) {
                        [groupArray insertObject:group atIndex:0];
                        groupMax = group;
                    } else if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] > ALAssetsGroupSavedPhotos) {
                        if (group.numberOfAssets > 0) {
                            [groupArray insertObject:group atIndex:1];
                        }
                    } else {
                        if (group.numberOfAssets > 0) {
                            [groupArray addObject:group];
                        }
                    }
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SKAlbumViewController *albumViewCtrl = [[SKAlbumViewController alloc] init];
                        albumViewCtrl.groupArray = groupArray;
                        albumViewCtrl.maxSelect = maxSelectNum;
                        albumViewCtrl.photoSelect = photoSelect;
                        SKAssetsViewController *assetsViewCtrl = [[SKAssetsViewController alloc] init];
                        assetsViewCtrl.group = groupMax;
                        assetsViewCtrl.maxSelect = maxSelectNum;
                        assetsViewCtrl.photoSelect = photoSelect;
                        EBNavigationController *baseNav = [[EBNavigationController alloc] init];
                        baseNav.viewControllers = @[albumViewCtrl, assetsViewCtrl];
                        [viewCtrl presentViewController:baseNav animated:YES completion:nil];
                    });
                }
            };
            
            void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                NSLog(@"A problem occured. Error: %@", error.localizedDescription);
            };	
            
            [[SKImageController defaultAssetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupAll
                                                                          usingBlock:assetGroupEnumerator 
                                                                        failureBlock:assetGroupEnumberatorFailure];
        }
        
    });
}


@end
