//
//  TransferProcdureView.h
//  beaver
//
//  Created by mac on 17/12/27.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TransferProcdureViewDelegate <NSObject>

- (void)ClickTransferProcdure:(NSInteger)tag;

@end

@interface TransferProcdureView : UIControl


- (instancetype)initWithFrame:(CGRect)frame;

/** 左边的线 */
@property (strong, nonatomic) UIView *midLineLeft;
/** 右边的线 */
@property (strong, nonatomic) UIView *midLineRight;
/** normal小图 */
@property (strong, nonatomic) UIImageView *smallIcon;
/** 节点lbl */
@property (strong, nonatomic) UILabel *contentLbl;


@property (nonatomic, weak)id<TransferProcdureViewDelegate> procdureViewDelegate;

@end
