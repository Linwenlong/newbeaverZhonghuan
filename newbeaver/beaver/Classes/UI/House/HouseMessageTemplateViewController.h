//
//  HouseMessageTemplateViewController.h
//  beaver
//
//  Created by 林文龙 on 2018/7/23.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "BaseViewController.h"

@interface HouseMessageTemplateViewController : BaseViewController

@property (nonatomic, strong) void(^returnBlock)(NSString *template,NSString *message);

@end
