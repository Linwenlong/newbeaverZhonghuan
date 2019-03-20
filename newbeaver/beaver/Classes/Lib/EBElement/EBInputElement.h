//
//  EBInputElement.h
//  MyQuickDialog
//
//  Created by LiuLian on 7/22/14.
//  Copyright (c) 2014 eallcn. All rights reserved.
//

#define EBElementInputTypeNumber @"number"
#define EBElementInputTypePhone @"phone"
#define EBElementInputTypeText @"text"
#define EBElementInputTypeDate @"date"
#define EBElementInputTypeContact @"contact"
#define EBElementInputTypeEmail @"email"
#define EBElementInputTypePassword @"password"

#import "EBPrefixElement.h"

//typedef enum {
//    kInputTypeText = 0,
//    kInputTypeNumber,
//    kInputTypeDecimal,
//    kInputTypePhone,
//    kInputTypeEmail
//} EBInputType;

@interface EBInputElement : EBPrefixElement

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *inputType;
@property (nonatomic, strong) NSString *placeholder;
@end
