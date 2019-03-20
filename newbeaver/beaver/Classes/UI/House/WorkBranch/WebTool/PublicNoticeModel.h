//
//  PublicNoticeModel.h
//  beaver
//
//  Created by mac on 17/8/14.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PublicNoticeModel : NSObject

@property (nonatomic, copy) NSString *document_id;//公告id
@property (nonatomic, copy) NSString *username;//发布人
@property (nonatomic, copy) NSString *title;//新房标题
@property (nonatomic, copy)NSString *create_time;
@property (nonatomic, copy)NSString *type;

- (instancetype)initWithDict:(NSDictionary *)dict;


@end
