//
//  ContractHeaderView.h
//  beaver
//
//  Created by mac on 17/12/19.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ContractHeaderViewDelegate <NSObject>

- (void)currentBtn:(UIButton *)btn otherBtn:(UIButton *)otherBtn;

@end

@interface ContractHeaderView : UIView

@property (nonatomic, weak)id<ContractHeaderViewDelegate> contractDelegate;//代理

- (instancetype)initWithFrame:(CGRect)frame leftTitle:(NSString *)left rightTitle:(NSString *)right;

@end
