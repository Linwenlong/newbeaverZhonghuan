//
// Created by 何 义 on 14-3-30.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBIMGroup.h"
#import "FMResultSet.h"
#import "EBPreferences.h"
#import "EBContact.h"


@implementation EBIMGroup

- (void)parseFromRs:(FMResultSet *)rs
{
    [super parseFromRs:rs];

    _name = [rs stringForColumn:@"Fname"];
    _id = [rs intForColumn:@"Fid"];
    _adminId = [rs stringForColumn:@"Fcreator_id"];
    _globalId = [rs stringForColumn:@"Fgroup_id"];
    _saved = [rs intForColumn:@"Fsaved"];
}

- (NSString *)groupTitle
{
    if (_name && _name.length > 0)
    {
        return _name;
    }
    else
    {
        return _placeholder;
    }
}
- (void)ensureGroupTitle
{
    if (!_name || _name.length == 0)
    {
        NSMutableArray *nameArray = [[NSMutableArray alloc] init];
        EBPreferences *pref = [EBPreferences sharedInstance];
        for (EBContact *contact in _members)
        {
            if ([pref.userId isEqualToString: contact.userId])
            {
                continue;
            }
            [nameArray addObject:contact.name];
        }

        _placeholder = [nameArray componentsJoinedByString:@"、"];
        if (!_placeholder || _placeholder.length == 0)
        {
            _placeholder = NSLocalizedString(@"im_group_chat", nil);
        }
    }
}

@end