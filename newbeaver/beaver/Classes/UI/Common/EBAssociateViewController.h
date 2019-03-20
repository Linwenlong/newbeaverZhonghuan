//
//  EBAssociateViewController.h
//  beaver
//
//  Created by wangyuliang on 14-7-30.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBCommunity.h"

@class EBCommunity;

@interface EBAssociateViewController : BaseViewController

@property (nonatomic, copy) void(^handleSelection)(NSString *district, NSString *region, EBCommunity *community);

@property (nonatomic, strong) NSString *district;

@property (nonatomic, strong) NSString *region;

@end
