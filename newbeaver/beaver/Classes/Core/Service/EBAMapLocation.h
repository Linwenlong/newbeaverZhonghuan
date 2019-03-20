//
// Created by 何 义 on 14-5-22.
// Copyright (c) 2014 eall. All rights reserved.
//


@interface EBAMapLocation : NSObject

+ (EBAMapLocation *)sharedInstance;

- (void)requestLocationWithTimeout:(NSTimeInterval)timeout completion:(void(^)(BOOL, CGFloat, CGFloat))handler;

- (id)requestAddressWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                      completion:(void(^)(id request, NSString *name, NSString *address))handler;

- (id)requestAddressAndPoiWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                      completion:(void(^)(id request, NSString *name, NSString *address))handler;
- (id)requestNearByLocationsWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude page:(NSInteger)page
                              completion:(void(^)(id request, NSArray *locations))handler;
- (id)searchLocationsWithKeyword:(NSString *)keyword page:(NSInteger)page completion:(void(^)(id request, NSArray *locations))handler;

@end