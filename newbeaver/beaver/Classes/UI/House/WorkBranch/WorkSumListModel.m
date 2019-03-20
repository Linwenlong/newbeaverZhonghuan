//
//  WorkSumListModel.m
//  beaver
//
//  Created by mac on 18/2/2.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "WorkSumListModel.h"

@implementation WorkSumListModel

- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        _title = dict[@"title"];
        _date = dict[@"type"];
        _tmp_type = dict[@"tmp_type"];
        _document_id = dict[@"document_id"];
    }
    return self;
}

@end
