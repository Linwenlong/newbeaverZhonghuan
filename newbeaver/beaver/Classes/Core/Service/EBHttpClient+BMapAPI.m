//
// Created by 何 义 on 14-5-31.
// Copyright (c) 2014 eall. All rights reserved.
//


#import <CoreLocation/CoreLocation.h>
#import "EBHttpClient+BMapAPI.h"
#import "EBMapPOI.h"
#import "EBAlert.h"


@implementation EBHttpClient (BMapAPI)

- (void)handleRequest:(id)request withData:(NSDictionary *)data handler:(TMapHandlerBlock)handler
{
    NSInteger errorCode = [data[@"status"] integerValue];
    if (errorCode == 0)
    {
       if (data[@"result"])
       {
           handler(request, YES, data[@"result"]);
       }
       else if (data[@"results"])
       {
           handler(request, YES, data[@"results"]);
       }
    }
    else
    {
        handler(request, NO, data);
        [EBAlert alertWithTitle:nil message:data[@"message"] confirm:^
        {

        }];
    }
}

- (void)handleRequest:(id)request withError:(NSError *)error handler:(TMapHandlerBlock)handler
{
    handler(request, NO,  @{@"code":@-9487, @"desc": error.description});
    if (error && error.code == -1009)
    {
        [EBAlert alertWithTitle:nil message:NSLocalizedString(@"network_error", nil) confirm:^
        {

        }];
    }
    else
    {
        [EBAlert alertWithTitle:nil message:NSLocalizedString(@"server_error", nil) confirm:^
        {

        }];
    }
}

#define MAP_BASE_URL @"http://api.map.baidu.com/"
#define MAP_URI_SEARCH @"place/v2/search"
#define MAP_URI_GEO_CODER @"geocoder/v2/"

- (NSDictionary *)wrappedMapParameters:(NSDictionary *)parameters
{
    NSMutableDictionary *md = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    md[@"output"] = @"json";
    md[@"ak"] = @"09769Bdiv9HOhCEB56cbAGuA";

    if (parameters[@"lat"] && parameters[@"lon"])
    {
        md[@"location"] = [NSString stringWithFormat:@"%.10f,%.10f", [parameters[@"lat"] floatValue], [parameters[@"lon"] floatValue]];
        [md removeObjectForKey:@"lat"];
        [md removeObjectForKey:@"lon"];
    }

    return md;
}

- (id)mapRequest:(NSDictionary *)parameters poiSearch:(TMapHandlerBlock)handler
{
    if (self.reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        [self handleRequest:nil withError:[[NSError alloc] initWithDomain:@"network" code:-1009 userInfo:nil] handler:handler];
        return nil;
    }
    parameters = [self wrappedMapParameters:parameters];
    return [self GET:[NSString stringWithFormat:@"%@%@", MAP_BASE_URL, MAP_URI_SEARCH] parameters:parameters
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 [self handleRequest:operation withData:responseObject handler:^(id request, BOOL success, NSArray *result)
                 {
                     if (success)
                     {
                         NSMutableArray *pois = [[NSMutableArray alloc] init];
                         for (NSDictionary *poi in result)
                         {
                             EBMapPOI *mapPOI = [[EBMapPOI alloc] init];
                             mapPOI.address = poi[@"address"];
                             mapPOI.name = poi[@"name"];
                             mapPOI.location = CLLocationCoordinate2DMake([poi[@"location"][@"lat"] floatValue],
                                     [poi[@"location"][@"lng"] floatValue]);
                             [pois addObject:mapPOI];
                         }
                         handler(operation, YES, pois);
                     }
                 }];
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self handleRequest:operation withError:error handler:handler];
            }];
}

- (id)mapRequest:(NSDictionary *)parameters reGeocode:(TMapHandlerBlock)handler
{
    if (self.reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        [self handleRequest:nil withError:[[NSError alloc] initWithDomain:@"network" code:-1009 userInfo:nil] handler:handler];
        return nil;
    }
    parameters = [self wrappedMapParameters:parameters];
    return [self GET:[NSString stringWithFormat:@"%@%@", MAP_BASE_URL, MAP_URI_GEO_CODER] parameters:parameters
             success:^(AFHTTPRequestOperation *operation, id responseObject) {

                 [self handleRequest:operation withData:responseObject handler:^(id request, BOOL success, NSDictionary *poi)
                 {
                     if (success)
                     {
                         EBMapPOI *mapPOI = [[EBMapPOI alloc] init];
                         mapPOI.address = poi[@"formatted_address"];
                         mapPOI.name = poi[@"addressComponent"][@"street"];
                         if (!mapPOI.name)
                         {
                             mapPOI.name = mapPOI.address;
                         }
                         mapPOI.location = CLLocationCoordinate2DMake([poi[@"location"][@"lat"] floatValue],
                                 [poi[@"location"][@"lng"] floatValue]);
                         mapPOI.cityCode = [poi[@"cityCode"] integerValue];

                         if (poi[@"pois"])
                         {
                             NSMutableArray *pois = [[NSMutableArray alloc] init];
                             for (NSDictionary *poi0 in poi[@"pois"])
                             {
                                 EBMapPOI *mPOI = [[EBMapPOI alloc] init];
                                 mPOI.address = poi0[@"addr"];
                                 mPOI.name = poi0[@"name"];
                                 mPOI.location = CLLocationCoordinate2DMake([poi0[@"point"][@"y"] floatValue],
                                         [poi0[@"point"][@"x"] floatValue]);
                                 [pois addObject:mPOI];
                             }
                             mapPOI.nearbyPois = pois;
                         }

                         handler(operation, YES, mapPOI);
                     }
                 }];

             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self handleRequest:operation withError:error handler:handler];
            }];
}

@end