//
//  PublishHouseViewController.h
//  beaver
//
//  Created by LiuLian on 9/1/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "ParserContainerViewController.h"

@interface PublishHouseViewController : ParserContainerViewController

@property (nonatomic, strong) NSMutableDictionary *params;
@property (nonatomic, strong) NSMutableArray *erp_photo_urls;
@property (nonatomic) BOOL showActionSheet;
@end
