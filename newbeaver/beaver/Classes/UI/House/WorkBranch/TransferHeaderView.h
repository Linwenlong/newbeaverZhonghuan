//
//  TransferHeaderView.h
//  chow
//
//  Created by 刘海伟 on 2017/11/6.
//  Copyright © 2017年 eallcn. All rights reserved.
//
//  过户状态headerView

#import <UIKit/UIKit.h>

@interface TransferHeaderView : UIView
/** 左边的线 */
@property (weak, nonatomic) IBOutlet UIView *midLineLeft;
/** 右边的线 */
@property (weak, nonatomic) IBOutlet UIView *midLineRight;
/** normal小图 */
@property (weak, nonatomic) IBOutlet UIImageView *smallIcon;
/** 节点lbl */
@property (weak, nonatomic) IBOutlet UILabel *contentLbl;
/** 时间lbl */
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;


+ (instancetype)headerView;


@end
