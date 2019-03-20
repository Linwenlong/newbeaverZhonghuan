//
//  workbenchBtn.h
//  chowRentAgent
//
//  Created by zhaoyao on 15/12/7.
//  Copyright (c) 2015年 eallcn. All rights reserved.
//

#import <UIKit/UIKit.h>

#define workBenchBtnPointBadge (-1)

typedef NS_ENUM(NSInteger , workbenchBtnBorderType) {
    workbenchBtnBorderTop = 1,
    workbenchBtnBorderLeft = 1 << 1,
    workbenchBtnBorderBottom = 1 << 2,
    workbenchBtnBorderRight = 1 << 3,
};

@interface workbenchBtn : UIButton

@property (nonatomic, assign) NSInteger badge;

- (void)addPointBadge;

- (void)removeBadge;

- (id)initWithTitle:(NSString *)title imageN:(UIImage *)imgN imageH:(UIImage *)imgH frame:(CGRect)frame;
- (instancetype)initWithTitle:(NSString *)title imageUrl:(NSString *)url frame:(CGRect)frame;

- (void)addBorderWithType:(workbenchBtnBorderType)type;

@end
