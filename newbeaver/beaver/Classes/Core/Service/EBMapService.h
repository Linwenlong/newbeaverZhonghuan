//
//  EBMapService.h
//  beaver
//
//  Created by LiuLian on 12/11/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class MAMapView, MAUserLocation;

@interface EBMapService : NSObject

+ (instancetype)sharedInstance;

- (MAMapView *)mapView;
- (void)requestUserLocation:(void (^)(id location))handler superview:(UIView *)view;
- (void)searchReGeocode:(CGFloat)lat longitude:(CGFloat)lon handler:(void (^)(NSString *regeocode, BOOL success))handler;
- (void)searchPlaceByAround:(CGFloat)lat longitude:(CGFloat)lon page:(NSInteger)page handler:(void (^)(id result, BOOL success))handler;
- (void)searchPlaceByKey:(NSString *)key city:(NSString *)city page:(NSInteger)page handler:(void (^)(id result, BOOL success))handler;
- (void)searchGeocode:(NSString *)address city:(NSString *)city handler:(void (^)(id result, BOOL sucess))handler;

@end
