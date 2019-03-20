//
//  SKAlbumViewController.h
//  chow
//
//  Created by wangyuliang on 14-12-1.
//  Copyright (c) 2014年 eallcn. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "BaseViewController.h"
#import "SKImageController.h"

@interface SKAlbumViewController : BaseViewController

@property (nonatomic, assign) NSInteger maxSelect;
@property (nonatomic, strong) NSArray *groupArray;
@property (nonatomic, copy) assertSelect photoSelect;

@end
