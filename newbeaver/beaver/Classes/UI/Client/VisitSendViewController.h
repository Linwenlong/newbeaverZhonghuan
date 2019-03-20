//
//  visitViewController.h
//  beaver
//
//  Created by wangyuliang on 14-5-30.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecommendViewController.h"

@class EBClientVisitLog;

@interface VisitSendViewController : RecommendViewController

@property (nonatomic, strong) EBClientVisitLog *clientVisitLog;

@end
