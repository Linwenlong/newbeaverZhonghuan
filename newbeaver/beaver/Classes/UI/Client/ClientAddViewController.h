//
//  ClientAddViewController.h
//  beaver
//
//  Created by LiuLian on 7/31/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "ParserContainerViewController.h"

@class EBClient;

@interface ClientAddViewController : ParserContainerViewController

@property (nonatomic, strong) NSDictionary *params;

@property (nonatomic) BOOL editFlag;
@property (nonatomic, weak) EBClient *client;
@end
