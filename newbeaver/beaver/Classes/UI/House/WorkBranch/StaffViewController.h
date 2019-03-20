//
//  StaffViewController.h
//  beaver
//
//  Created by mac on 18/1/22.
//  Copyright © 2018年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StaffViewController : UIViewController

@property (nonatomic, copy) void(^returnBlock)(NSString *name ,NSString *userId);

@end
