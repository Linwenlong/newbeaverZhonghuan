//
//  ClientVisitLogDataSource.h
//  beaver
//
//  Created by wangyuliang on 14-5-28.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBPagedDataSource.h"
#import "HouseItemView.h"
#import "EBClientVisitLog.h"
@class EBHouse;
@class EBClient;
typedef void(^TClickOnHouse)(EBHouse *);
typedef void(^TClickOnImage)(EBClientVisitLog *);

@interface ClientVisitLogDataSource : EBPagedDataSource

@property(nonatomic, assign) BOOL marking;
@property(nonatomic, copy) TClickOnHouse clickBlock;
@property(nonatomic, copy) TClickOnImage imageBlock;

@end


@interface ClientVisitLogDataSourceTableViewCell: UITableViewCell

@property (nonatomic, strong)UILabel *timeLabel;
@property (nonatomic, strong)UIButton *imageBtn;
@property (nonatomic, strong)UILabel *titleLabel;
@property (nonatomic, strong)HouseItemView *itemView;
@end