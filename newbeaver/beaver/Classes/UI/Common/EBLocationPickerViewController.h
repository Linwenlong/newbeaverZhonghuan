//
//  EBLocationPickerViewController.h
//  beaver
//
//  Created by LiuLian on 12/12/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBPagedDataSource.h"

@class AMapPOI;

@interface EBLocationPickerViewController : BaseViewController

@property (nonatomic, copy) void(^selectBlock)(NSDictionary *poi);
@property (nonatomic) BOOL withSend;

@end

@interface EBLocationDataSource : EBPagedDataSource

@property (nonatomic) NSInteger currentChoice;
@property (nonatomic) BOOL currentCenterDelete;

@property (nonatomic) BOOL forNearby;
@property (nonatomic) BOOL withSend;
@property (nonatomic, copy) void(^selectedPoiChanged)(AMapPOI *);

@end
