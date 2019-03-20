//
//  HouseDetailViewController.h
//  beaver
//
//  Created by 何 义 on 14-3-10.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBAppointment.h"
#import "EBNumberStatus.h"
#import "NIAttributedLabel.h"

@class EBClient;

typedef NS_ENUM(NSInteger , EClientDetailOpenType)
{
    EClientDetailOpenTypeCommon = 1,
    EClientDetailOpenTypeAdd = 2
};

@interface ClientDetailViewController : BaseViewController <NIAttributedLabelDelegate>

@property (nonatomic, strong) EBClient *clientDetail;
@property (nonatomic, strong) NSMutableArray *appointArray;
@property (nonatomic, strong) EBNumberStatus *numStatus;
@property (nonatomic, assign) EClientDetailOpenType pageOpenType;

- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize;

@end
