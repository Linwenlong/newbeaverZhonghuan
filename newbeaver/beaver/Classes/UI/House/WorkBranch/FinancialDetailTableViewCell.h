//
//  FinancialDetailTableViewCell.h
//  beaver
//
//  Created by mac on 17/11/27.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FinancialDetailTableViewCell : UITableViewCell

- (void)setDic:(NSDictionary *)dic isEdit:(BOOL)edit;

@property (nonatomic, strong)UIButton *btn; //删除

@property (nonatomic, strong)UIImageView *qrcode; //二维码

@property (nonatomic, strong) UIPanGestureRecognizer *swipeGesture;

@end
