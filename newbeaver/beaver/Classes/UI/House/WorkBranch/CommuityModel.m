//
//  CommuityModel.m
//  beaver
//
//  Created by mac on 17/8/16.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "CommuityModel.h"

@implementation CommuityModel

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.commuity_id forKey:@"id"];
    [aCoder encodeObject:self.commuity_name forKey:@"name"];
    [aCoder encodeObject:self.pname forKey:@"pname"];
    [aCoder encodeObject:self.ppname forKey:@"ppname"];
    [aCoder encodeObject:self.spell forKey:@"spell"];
     [aCoder encodeObject:self.address forKey:@"address"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.commuity_id = [aDecoder decodeObjectForKey:@"id"];
        self.commuity_name = [aDecoder decodeObjectForKey:@"name"];
        self.pname = [aDecoder decodeObjectForKey:@"pname"];
        self.ppname = [aDecoder decodeObjectForKey:@"ppname"];
        self.spell = [aDecoder decodeObjectForKey:@"spell"];
        self.address = [aDecoder decodeObjectForKey:@"address"];
    }
    return self;
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.commuity_id = dict[@"id"];
        self.commuity_name = dict[@"name"];
        self.pname = dict[@"pname"];
        self.ppname = dict[@"ppname"];
        self.spell = dict[@"spell"];
        self.address = dict[@"address"];
    }
    return self;
}

@end
