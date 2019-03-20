//
//  PublishPortAddViewController.h
//  beaver
//
//  Created by wangyuliang on 14-8-27.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"

@interface PublishPortAddViewController : BaseViewController

@end

@interface PublishPortAddViewCell : UIView

@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, copy) void (^addPort)(NSDictionary *port);

- (id)initWithData:(CGRect)frame port:(NSDictionary *)port;

@end
