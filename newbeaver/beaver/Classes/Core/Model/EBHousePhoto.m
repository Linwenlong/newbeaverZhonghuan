//
// Created by 何 义 on 14-7-23.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBHousePhoto.h"
#import "EBHouse.h"


@implementation EBHousePhoto

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

    dictionary[@"house_id"] = _houseId;
    dictionary[@"house_type"] = _houseType;
    dictionary[@"status"] = @(_status);
    dictionary[@"local_url"] = [_localUrl absoluteString];

    if (_remoteUrl)
    {
        dictionary[@"remote_url"] = _remoteUrl;
    }
    if (_note)
    {
        dictionary[@"note"] = _note;
    }

    if (_locationDesc)
    {
        dictionary[@"location"] = _locationDesc;
    }

    return  dictionary;
}

- (NSDictionary *)toAddParams
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

    dictionary[@"house_id"] = _houseId;
    dictionary[@"type"] = _houseType;

    if (_remoteUrl)
    {
        dictionary[@"uri"] = _remoteUrl;
    }
    if (_note)
    {
        dictionary[@"memo"] = _note;
    }
    else
    {
        dictionary[@"memo"] = @"";
    }

    if (_locationDesc)
    {
        dictionary[@"position"] = _locationDesc;
    }
    else
    {
        dictionary[@"position"] = @"";
    }

    return  dictionary;
}

+ (EBHousePhoto *)fromDictionary:(NSDictionary *)dictionary
{
    EBHousePhoto *photo = [[EBHousePhoto alloc] init];
    photo.houseId = dictionary[@"house_id"];
    photo.houseType = dictionary[@"house_type"];
    photo.note = dictionary[@"note"];
    photo.locationDesc = dictionary[@"location"];
    photo.localUrl = [[NSURL alloc] initWithString:dictionary[@"local_url"]];
    photo.remoteUrl = dictionary[@"remote_url"];
    photo.status = [dictionary[@"status"] integerValue];

    return photo;
}

@end