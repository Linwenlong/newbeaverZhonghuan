//
//  HouseNewForceFollowupFooterView.h
//  beaver
//
//  Created by mac on 17/11/17.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PINTextView.h"

@interface HouseNewForceFollowupFooterView : UIView

@property (nonatomic, strong)PINTextView *followUpContent; //跟进文本
@property (nonatomic, strong)UILabel *countlable;   //字数lable
@property (nonatomic, strong)UIButton *confirmBtn;  //确认btn

@end
