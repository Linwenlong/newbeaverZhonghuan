//
// Created by 何 义 on 14-3-29.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "MTLJSONAdapter.h"
#import "EBContactManager.h"
#import "HanyuPinyinOutputFormat.h"
#import "PinyinHelper.h"
#import "EBContact.h"
#import "EBCache.h"
#import "EBPreferences.h"
#import "SearchCoreManager.h"
#import "EBHttpClient.h"

@implementation EBContactManager
{
    BOOL _searchIndexBuilt;
    NSMutableDictionary *_contactsLocalIdMap;
    NSArray *_allContactsArray;
}

+ (EBContactManager *)sharedInstance
{
    static EBContactManager *_sharedInstance = nil;
    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)contactsChanged:(NSArray *)contactIds
{
//    NSDictionary *contactsDictionary = [[EBCache sharedInstance] objectForKey:EB_CACHE_KEY_CONTACTS];
//    __block BOOL needSync = NO;
//    [contactIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
//    {
//        NSString *contactId = obj;
//        if (!contactsDictionary[contactId])
//        {
//            needSync = YES;
//            *stop = YES;
//        }
//    }];
//
//    if (needSync)
//    {
        [self synchronizeContacts:nil];
//    }
}

- (void)synchronizeContacts:(void (^)(BOOL success))completion
{
   NSString *currentVersion = [self contactsVersion];
   if (!currentVersion)
   {
       currentVersion = @"";
   }
   [[EBHttpClient sharedInstance] dataRequest:@{@"cont_ver":currentVersion} contacts:^(BOOL success, id result)
   {
       if (success){
           NSDictionary *data = result;
           NSString *newVersion =  data[@"contacts_version"];
           [self cacheContacts:data[@"contacts"] version:newVersion];
       }
       if (completion){
           completion(success);
       }
   }];
}

- (NSArray *)contactsByKeyword:(NSString *)keyword
{
//    SearchCoreManager *coreManager = [SearchCoreManager share];

    if (!_searchIndexBuilt)
    {
//        [coreManager Reset];
        _contactsLocalIdMap = [[NSMutableDictionary alloc] init];
        NSDictionary *contactsDictionary = [[EBCache sharedInstance] objectForKey:EB_CACHE_KEY_CONTACTS];
        _allContactsArray = [contactsDictionary allValues];
        [contactsDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
        {
            EBContact *contact = (EBContact *)obj;
//            [coreManager AddContact:@(contact.localId) name:contact.name phone:nil];
            _contactsLocalIdMap[@(contact.localId)] = contact;
        }];
    }
//    NSMutableArray *matchArray = [[NSMutableArray alloc] init];
//    [coreManager Search:keyword searchArray:nil nameMatch:matchArray phoneMatch:nil];

    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
//    for (NSNumber *localId in matchArray)
//    {
//        [resultArray addObject:_contactsLocalIdMap[localId]];
//    }
//    department contains %@",keyword];

    if (keyword && keyword.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains %@ or pinyin  contains %@ or shortName contains %@ or department contains %@ or deptTel contains %@ or phone contains %@",keyword.lowercaseString,keyword.lowercaseString,keyword.lowercaseString,keyword.lowercaseString,keyword.lowercaseString,keyword.lowercaseString];
        resultArray = [[_allContactsArray filteredArrayUsingPredicate:predicate] mutableCopy];
    }
    return resultArray;
}

//座机
- (NSArray *)contactsPhoneByKeyword:(NSString *)keyword
{
    //SearchCoreManager *coreManager = [SearchCoreManager share];
    
    if (!_searchIndexBuilt)
    {
        //        [coreManager Reset];
        _contactsLocalIdMap = [[NSMutableDictionary alloc] init];
        NSDictionary *contactsDictionary = [[EBCache sharedInstance] objectForKey:EB_CACHE_KEY_CONTACTS];
        _allContactsArray = [contactsDictionary allValues];
        [contactsDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             EBContact *contact = (EBContact *)obj;
             //            [coreManager AddContact:@(contact.localId) name:contact.name phone:nil];
             _contactsLocalIdMap[@(contact.localId)] = contact;
         }];
    }
    
    //    NSMutableArray *matchArray = [[NSMutableArray alloc] init];
    //    [coreManager Search:keyword searchArray:nil nameMatch:matchArray phoneMatch:nil];
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    //    for (NSNumber *localId in matchArray)
    //    {
    //        [resultArray addObject:_contactsLocalIdMap[localId]];
    //    }
    
    if (keyword && keyword.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptTel contains %@",keyword];
        resultArray = [[_allContactsArray filteredArrayUsingPredicate:predicate] mutableCopy];
    }
    
    return resultArray;
}


//门店
- (NSArray *)contactsLWLByKeyword:(NSString *)keyword
{
    //    SearchCoreManager *coreManager = [SearchCoreManager share];
    
    if (!_searchIndexBuilt)
    {
        //        [coreManager Reset];
        _contactsLocalIdMap = [[NSMutableDictionary alloc] init];
        NSDictionary *contactsDictionary = [[EBCache sharedInstance] objectForKey:EB_CACHE_KEY_CONTACTS];
        _allContactsArray = [contactsDictionary allValues];
        [contactsDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             EBContact *contact = (EBContact *)obj;
             //            [coreManager AddContact:@(contact.localId) name:contact.name phone:nil];
             _contactsLocalIdMap[@(contact.localId)] = contact;
         }];
    }
    
    //    NSMutableArray *matchArray = [[NSMutableArray alloc] init];
    //    [coreManager Search:keyword searchArray:nil nameMatch:matchArray phoneMatch:nil];
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    //    for (NSNumber *localId in matchArray)
    //    {
    //        [resultArray addObject:_contactsLocalIdMap[localId]];
    //    }

    if (keyword && keyword.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains %@ or department contains %@",keyword.lowercaseString,keyword.lowercaseString];
        resultArray = [[_allContactsArray filteredArrayUsingPredicate:predicate] mutableCopy];
    }
    
    return resultArray;
}

//除去了特殊的通讯录 lwl
- (NSArray *)nonAllContacts{
    return [[[EBCache sharedInstance] objectForKey:EB_CACHE_KEY_NON_SPECIAL_CONTACTS] allValues];
}


- (NSArray *)allContacts
{
   return [[[EBCache sharedInstance] objectForKey:EB_CACHE_KEY_CONTACTS] allValues];
}



- (EBContact *)contactById:(NSString *)id
{
    EBContact *contact = nil;
    NSRange range = [id rangeOfString:@"@"];
    if (range.location == NSNotFound)
    {
        NSDictionary *contactsDictionary = [[EBCache sharedInstance] objectForKey:EB_CACHE_KEY_CONTACTS];
        contact = contactsDictionary[id];
        if (contact)
        {
            contact.fromOtherPlatform = NO;
            return contact;
        }
        else
        {
            contact = [[EBContact alloc] init];
            contact.userId = id;
            contact.name = NSLocalizedString(@"deleted_contact", nil);
            
            if([id hasPrefix:@"c_"])
            {
                NSArray *nameArray = [id componentsSeparatedByString:@"_"];
                if(nameArray.count==3){
                    contact.name  =  [NSString stringWithFormat:@"客户[%@****]",[nameArray[2] substringToIndex:4]];
                }
            }
            
            contact.gender = @"m";
            contact.department = @"";
            contact.special = YES;
            contact.notFound = YES;
            contact.pinyin = @"unknown";
            contact.fromOtherPlatform = NO;
            
            return contact;
        }
    }
    else
    {
        contact = [[EBCache sharedInstance] objectForKey:id];
        if (contact)
        {
            return contact;
        }
        contact = [[EBContact alloc] init];
        contact.userId = id;
        contact.name = @"";
        contact.gender = @"m";
        contact.special = YES;
        contact.notFound =  NO;
        contact.pinyin = @"unknown";
        contact.fromOtherPlatform = YES;
        return contact;
    }
}

- (EBContact *)myContact
{
    return [self contactById:[EBPreferences sharedInstance].userId];
}

- (NSString *)contactsVersion
{
    return [[EBCache sharedInstance] objectForKey:EB_CACHE_KEY_CONTACT_VERSION];
}

- (void)cacheContacts:(NSArray *)contactArray  version:(NSString *)version
{
    
    NSString *oldVersion = [self contactsVersion];

    if ([oldVersion isEqualToString:version])
    {
        return;
    }

    NSMutableDictionary *contacts = [[NSMutableDictionary alloc] init];
    
    NSMutableSet *departmentSet = [NSMutableSet set];
    
    NSError *error;
    HanyuPinyinOutputFormat *outputFormat=[[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];
    [outputFormat setVCharType:VCharTypeWithV];
    [outputFormat setCaseType:CaseTypeLowercase];

    NSInteger localId = 998;
    for (NSDictionary *item in contactArray)
    {
        if (item[@"dept_name"] != nil && item[@"dept_id"] != nil) {
              [departmentSet addObject:[NSString stringWithFormat:@"%@-%@",item[@"dept_name"],item[@"dept_id"]]];
        }
        EBContact *contact = [MTLJSONAdapter modelOfClass:[EBContact class] fromJSONDictionary:item error:&error];
        contact.pinyin = [self getPinyinWithChinese:contact.name];
        contact.shortName = [self getShortWithChinese:contact.name];
        contact.firstLetter = [self getFirstCharWithChinese:contact.name];

        contact.localId = localId++;
        contacts[contact.userId] = contact;
    }
    [[EBCache sharedInstance] setObject:contacts forKey:EB_CACHE_KEY_NON_SPECIAL_CONTACTS];

    NSString *eallId = [EBPreferences systemIMIDEALL];
    NSString *companyId = [EBPreferences systemIMIDCompany];
    NSString *newHouseId = [EBPreferences systemIMIDNewHouse];

    contacts[eallId] = [self buildSpecialContact:eallId name:NSLocalizedString(@"special_msg_eall", nil) avatar:@"im_eall_logo" localId:localId++];
    contacts[companyId] = [self buildSpecialContact:companyId name:[EBPreferences sharedInstance].companyName avatar:@"im_company_logo" localId:localId++];
    contacts[newHouseId] = [self buildSpecialContact:newHouseId name:NSLocalizedString(@"special_msg_new_house", nil) avatar:@"im_client_follow_logo" localId:localId];


    
    [[EBCache sharedInstance] setObject:departmentSet forKey:EB_CACHE_KEY_DEPARMENTS];
    
    [[EBCache sharedInstance] setObject:contacts forKey:EB_CACHE_KEY_CONTACTS];
    [[EBCache sharedInstance] setObject:version forKey:EB_CACHE_KEY_CONTACT_VERSION];

    _searchIndexBuilt = NO;
}

- (EBContact *)buildSpecialContact:(NSString *)id name:(NSString *)name avatar:(NSString *)avatar localId:(NSInteger)localId
{
    EBContact *contact = [[EBContact alloc] init];
    contact.localId = localId;
    contact.name = name;
    contact.userId = id;
    contact.special = YES;
    contact.avatar = avatar;
    return contact;
}

#pragma mark pinyin

- (NSString *)getFirstCharWithChinese:(NSString *)chinese
{
    NSString *outputPinyin= [self getPinyinWithChinese:chinese];
    
    NSString *first = [outputPinyin substringWithRange:NSMakeRange(0, 1)];
    
    return first.uppercaseString;
}

- (NSString *)getPinyinWithChinese:(NSString *)chinese
{
    
    HanyuPinyinOutputFormat *outputFormat=[[HanyuPinyinOutputFormat alloc] init];
    
    [outputFormat setToneType:ToneTypeWithoutTone];
    
    [outputFormat setVCharType:VCharTypeWithV];
    
    [outputFormat setCaseType:CaseTypeLowercase];
    
    return [PinyinHelper toHanyuPinyinStringWithNSString:chinese withHanyuPinyinOutputFormat:outputFormat withNSString:@""];
    
}

- (NSString *)getShortWithChinese:(NSString *)chinese
{
    
    HanyuPinyinOutputFormat *outputFormat=[[HanyuPinyinOutputFormat alloc] init];
    
    [outputFormat setToneType:ToneTypeWithoutTone];
    
    [outputFormat setVCharType:VCharTypeWithV];
    
    [outputFormat setCaseType:CaseTypeLowercase];
    
    NSString *pinyin = [PinyinHelper toHanyuPinyinStringWithNSString:chinese withHanyuPinyinOutputFormat:outputFormat withNSString:@"-"];
    NSArray *shorts = [pinyin componentsSeparatedByString:@"-"];
    
    NSMutableString * shortName = [NSMutableString string];
    
    for (NSString *pin in shorts) {
        if (pin && pin.length > 0) {
            [shortName appendString:[pin substringWithRange:NSMakeRange(0, 1)]];
        }
    }
    
    return shortName;
    
}

@end
