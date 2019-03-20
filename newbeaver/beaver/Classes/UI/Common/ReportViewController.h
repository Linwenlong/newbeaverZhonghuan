//
//  ReportViewController.h
//  beaver
//
//  Created by ChenYing on 14-7-25.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBHouse.h"

@interface ReportViewController : BaseViewController<UITextViewDelegate>

@property(nonatomic, strong)EBHouse *house;
@property(nonatomic, strong)NSString *reportType;

@end
