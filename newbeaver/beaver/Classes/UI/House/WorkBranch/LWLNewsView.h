//
//  LWLNewsView.h
//  beaver
//
//  Created by mac on 17/7/23.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LWLNewsViewDelegate <NSObject>

- (void)LWLNewsViewImageClick:(UIImageView *)imageView;

@end

@interface LWLNewsView : UIView

@property (nonatomic, strong)UILabel *countLable;//文字显示lable

@property (nonatomic, strong)UITableView *mainTableView;

@property (nonatomic, weak)id<LWLNewsViewDelegate> lwlShowViewDelegate;

@end
