//
//  WorkSumListModel.h
//  beaver
//
//  Created by mac on 18/2/2.
//  Copyright © 2018年 eall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WorkSumListModel : NSObject

@property (nonatomic, strong)NSString *title;
@property (nonatomic, strong)NSString *tmp_type;
@property (nonatomic, strong)NSString *document_id;

@property (nonatomic, strong)NSString *date;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
