//
//  WorkSelectClientCodeViewController.h
//  beaver
//
//  Created by mac on 18/1/19.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "BaseViewController.h"

@interface WorkSelectClientCodeViewController : BaseViewController

@property (nonatomic, copy) void(^returnBlock)(NSString *client_code ,NSString *client_name);

@end
