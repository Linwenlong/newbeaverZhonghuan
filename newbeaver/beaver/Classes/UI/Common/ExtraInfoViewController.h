//
//  ExtraInfoViewController.h
//  beaver
//
//  Created by LiuLian on 7/28/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ExtraInfoViewController : BaseViewController

@property (nonatomic, strong) NSArray *extraInfos;

@property (nonatomic, copy) void (^onCancel)(void);
@property (nonatomic, copy) void (^onSelect)(NSIndexPath *indexPath, NSDictionary *data);

@property (nonatomic, copy) void (^onDisappear)(void);

- (id)initWithData:(NSArray *)extraInfos title:(NSString *)title;
@end
