//
//  ChongzhiImageViewController.h
//  beaver
//
//  Created by 林文龙 on 2018/7/20.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "BaseViewController.h"

@interface ChongzhiImageViewController : BaseViewController

@property (nonatomic, strong) NSString * payCount;//账号
@property (nonatomic, strong) NSString * payNum;//支付金额
@property (nonatomic, strong) NSString * payType;//支付类型 支付宝或者微信
@property (nonatomic, strong) NSString * type;//充值类型 1(账户充值)，2(月租充值)，3(短信充值)
@property (nonatomic, strong) NSString * imageStr;

@end
