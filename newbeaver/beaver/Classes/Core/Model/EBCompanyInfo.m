//
//  EBCompanyInfo.m
//  beaver
//
//  Created by ChenYing on 14-8-12.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBCompanyInfo.h"
#import "HanyuPinyinOutputFormat.h"
#import "PinyinHelper.h"

@implementation EBCompanyInfo

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"cityName": @"city_name",
             @"companyId": @"company_id",
             @"version": @"version",
    };
}


- (NSString *)cityNamePinYin
{
    HanyuPinyinOutputFormat *outputFormat=[[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];
    [outputFormat setVCharType:VCharTypeWithV];
    [outputFormat setCaseType:CaseTypeLowercase];
    
    return [PinyinHelper toHanyuPinyinStringWithNSString:self.cityName
                                       withHanyuPinyinOutputFormat:outputFormat
                                                      withNSString:@""];
}
@end
