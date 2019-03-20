//
//  HouseVideoPreUploadViewController.h
//  beaver
//
//  Created by LiuLian on 8/12/15.
//  Copyright (c) 2015 eall. All rights reserved.
//

#import "BaseViewController.h"

@class ALAsset;

@interface HouseVideoPreUploadViewController : BaseViewController

@property (nonatomic, strong) NSURL *tmpURL;
@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, strong) NSString *houseUid;

@end
