//
//  NameAndDepermentViewController.h
//  beaver
//
//  Created by mac on 17/9/7.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "BaseViewController.h"



@interface NameAndDepermentViewController : UIViewController


@property (nonatomic, copy) void(^returnBlock)(NSString *dept_id,NSString *dept_name);
@property (nonatomic, strong) NSString *type;
@property (nonatomic, copy) void(^contactsSelected)(NSArray *contacts);
@property (nonatomic, strong) NSArray *filterContacts;

@end
