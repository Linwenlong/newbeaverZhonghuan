//
//  SKAsset.h
//  chow
//
//  Created by wangyuliang on 14-12-1.
//  Copyright (c) 2014年 eallcn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface SKAsset : NSObject

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, assign) BOOL select;

@end
