//
//  UITableView+PlaceHolderView.m
//  PlaceHolderView
//
//  Created by yh on 17/5/16.
//  Copyright © 2017年 yh. All rights reserved.
//

#import "UITableView+PlaceHolderView.h"
#import "NSObject+MethodSwizzle.h"
#import "DefaultView.h"



@implementation UITableView (PlaceHolderView)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:@selector(reloadData) withMethod:@selector(yh_reloadData)];
    });
}

- (void)yh_reloadData
{
    if (self.enablePlaceHolderView) {
        NSInteger sectionCount = self.numberOfSections;
        NSInteger rowCount = 0;
        for (int i = 0; i < sectionCount; i++) {
            rowCount += [self.dataSource tableView:self numberOfRowsInSection:i];
        }
        if (rowCount == 0) {
            [self addSubview:self.yh_PlaceHolderView];
        }
        else
        {
            [self.yh_PlaceHolderView removeFromSuperview];
        }
    }
    [self yh_reloadData];
}


- (void)setEnablePlaceHolderView:(BOOL)enblePlaceHolderView
{
    objc_setAssociatedObject(self, @selector(enablePlaceHolderView), @(enblePlaceHolderView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)enablePlaceHolderView
{
    NSNumber *number = objc_getAssociatedObject(self, @selector(enablePlaceHolderView));
    return number.boolValue;
}

- (void)setYh_PlaceHolderView:(UIView *)yh_PlaceHolderView
{
    objc_setAssociatedObject(self, @selector(yh_PlaceHolderView), yh_PlaceHolderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)yh_PlaceHolderView
{
    UIView *placeHolder = objc_getAssociatedObject(self, @selector(yh_PlaceHolderView));
    
    if (!placeHolder) {
        if (self.tableHeaderView != nil) {
            CGRect frame = self.bounds;
            frame.origin.y = CGRectGetMaxY(self.tableHeaderView.frame);
            DefaultView *defaultView = [[DefaultView alloc] initWithFrame:frame];
            CGRect placeViewFrame = defaultView.placeView.frame;
         
            placeViewFrame.origin.y -= (defaultView.centerY-160);
            
            CGRect placeTextFrame = defaultView.placeText.frame;
            placeTextFrame.origin.y -= (defaultView.centerY-160);
            defaultView.placeView.frame = placeViewFrame;
            defaultView.placeText.frame = placeTextFrame;
            
            placeHolder  = defaultView;
            
        }else{
            placeHolder  = [[DefaultView alloc] initWithFrame:self.bounds];
        }
        self.yh_PlaceHolderView = placeHolder;
    }
    return placeHolder;
}

@end
