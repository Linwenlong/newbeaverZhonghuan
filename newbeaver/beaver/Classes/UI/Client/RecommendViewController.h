//
//  RecommendViewController.h
//  beaver
//
//  Created by 何 义 on 14-3-18.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EBHouse;
@class EBClient;

@interface RecommendViewController : UIViewController

@property (nonatomic, strong) NSArray *sendDataArray;
@property (nonatomic, strong) EBClient *client;
@property (nonatomic, copy) void(^completionHandler)(BOOL success, NSDictionary *info);
@property (nonatomic) NSInteger tagHouseOrVisit;

@end
