//
//  ERPSignViewController.h
//  chowRentAgent
//
//  Created by 凯文马 on 15/11/16.
//  Copyright © 2015年 eallcn. All rights reserved.
//

#import "BaseViewController.h"
#import "EBNavigationController.h"


typedef void(^commitAction)(NSString *url);

@interface ERPSignViewController : BaseViewController

@property (nonatomic, copy) commitAction commitAction;


@end
