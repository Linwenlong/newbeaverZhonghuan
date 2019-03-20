//
// Created by 何 义 on 14-5-22.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBAMapLocation.h"
#import "EBAlert.h"
#import "EBHttpClient.h"
#import "EBHttpClient+BMapAPI.h"
#import "EBMapPOI.h"
//#import <AMapSearchKit/AMapSearchAPI.h>
#import <MapKit/MapKit.h>
#import <objc/message.h>

@interface EBAMapLocation()<MKMapViewDelegate, CLLocationManagerDelegate>

//@property (nonatomic, copy) void(^reGeoBlock)(id request, NSString *name, NSString *address);
//@property (nonatomic, copy) void(^nearbyBlock)(id request, NSArray *nearbyPlaces);
//@property (nonatomic, copy) void(^searchBlock)(id request, NSArray *searchPlaces);
@property (nonatomic, copy) void(^locationBlock)(BOOL success, CGFloat lat, CGFloat lon);
//@property (nonatomic, readonly) AMapSearchAPI *searchAPI;
@property (nonatomic, readonly) MKMapView *mapView;
@property (nonatomic, readonly) CLLocationManager *locationManager;
@property (nonatomic, strong) EBMapPOI *currentPoi;

@end

@implementation EBAMapLocation

@synthesize
//searchAPI=_searchAPI,
mapView=_mapView, locationManager=_locationManager;

+ (EBAMapLocation *)sharedInstance
{
    static dispatch_once_t pred;
    static EBAMapLocation *_sharedInstance = nil;

    dispatch_once(&pred, ^{
        _sharedInstance = [[EBAMapLocation alloc] init];
    });

    return _sharedInstance;
}

- (void)requestLocationWithTimeout:(NSTimeInterval)timeout completion:(void(^)(BOOL, CGFloat, CGFloat))handler
{
    self.locationBlock = handler;
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        self.locationManager.delegate = self;
    }
    else
    {
        [self getLocationFromMapView:timeout];
    }
//    [self locationManager];
//    [_locationManager startUpdatingLocation];
}

- (void)getLocationFromMapView:(NSTimeInterval)timeout
{
    if ([self locationServicesAvailable])
    {
        self.mapView.showsUserLocation = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * (NSInteger)timeout), dispatch_get_main_queue(), ^
        {
            if (self.mapView.showsUserLocation)
            {
                MKUserLocation *userLocation = self.mapView.userLocation;
                if (userLocation)
                {
                    if (userLocation.coordinate.latitude == 0 && userLocation.coordinate.longitude == 0) {
//                        self.locationBlock(NO, userLocation.coordinate.latitude, userLocation.coordinate.longitude);
                        self.locationBlock(NO, 0, 0);
                    } else {
                        self.locationBlock(YES, userLocation.coordinate.latitude, userLocation.coordinate.longitude);
                    }
                }
                else
                {
                    self.locationBlock(NO, 0, 0);
                }
                self.mapView.showsUserLocation = NO;
            }
        });
    }
    else
    {
        [EBAlert hideLoading];
        [EBAlert alertWithTitle:nil message:NSLocalizedString(@"allow_location_service", nil)];
    }
}

- (BOOL)locationServicesAvailable
{
    if (![CLLocationManager locationServicesEnabled])
    {
        return NO;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        return NO;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        return NO;
    }
    return YES;
}


#pragma -mark MKMapView delegate

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    self.locationBlock(YES, userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    mapView.showsUserLocation = NO;
}

#pragma -mark CLLocationManager delegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status != kCLAuthorizationStatusNotDetermined)
    {
        [self getLocationFromMapView:2.0];
    } else {
        SEL methodSel = NSSelectorFromString(@"requestWhenInUseAuthorization");
        if ([_locationManager respondsToSelector:methodSel]) {
            objc_msgSend(_locationManager, methodSel);
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *loc = locations[0];
    self.locationBlock(YES, loc.coordinate.latitude, loc.coordinate.longitude);
    [manager stopUpdatingLocation];
}

- (MKMapView *)mapView
{
    if (!_mapView)
    {
        _mapView = [[MKMapView alloc] init];
        _mapView.delegate = self;
    }

    return _mapView;
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager)
    {
       _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
//        [_locationManager startUpdatingLocation];
        SEL methodSel = NSSelectorFromString(@"requestWhenInUseAuthorization");
        if ([_locationManager respondsToSelector:methodSel]) {
            objc_msgSend(_locationManager, methodSel);
        }
    }

    return _locationManager;
}

- (id)requestAddressWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                      completion:(void(^)(id request, NSString *name, NSString *address))handler
{
    return [[EBHttpClient sharedInstance] mapRequest:@{@"lat":@(latitude), @"lon":@(longitude)} reGeocode:^(id request, BOOL success, EBMapPOI *poi)
            {
                 if (success)
                 {
                     self.currentPoi = poi;
                     handler(request, poi.name, poi.address);
                 }
            }];
}

- (id)requestAddressAndPoiWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                            completion:(void(^)(id request, NSString *name, NSString *address))handler
{
    return [[EBHttpClient sharedInstance] mapRequest:@{@"lat":@(latitude), @"lon":@(longitude),@"pois":@(1)} reGeocode:^(id request, BOOL success, EBMapPOI *poi)
    {
        if (success)
        {
            self.currentPoi = poi;
            handler(request, poi.name, poi.address);
        }
    }];
}

- (id)requestNearByLocationsWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude page:(NSInteger)page
                              completion:(void(^)(id request, NSArray *locations))handler
{
    NSArray *pois = self.currentPoi.nearbyPois;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (pois)
    {
        NSInteger returnCount = 20;
        NSInteger offset = (page - 1) * 20;
        if (pois.count > offset)
        {
            returnCount = MIN(pois.count - offset, returnCount);
            result = [[pois subarrayWithRange:NSMakeRange(offset, returnCount)] mutableCopy];
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^
    {
       handler(nil, result);
    });

    return nil;
}

- (id)searchLocationsWithKeyword:(NSString *)keyword page:(NSInteger)page
                      completion:(void(^)(id request, NSArray *locations))handler
{
    NSInteger cityCode = 131;
    if (self.currentPoi && self.currentPoi.cityCode)
    {
        cityCode = self.currentPoi.cityCode;
    }
    return [[EBHttpClient sharedInstance] mapRequest:@{@"region":@(cityCode), @"q":keyword, @"page_num":@(page - 1)}
                                           poiSearch:^(id request, BOOL success, NSArray *pois)
                                           {
                                               handler(request, success ? pois : nil);
                                           }];
}
//
//- (id)requestAddressWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
//                      completion:(void(^)(id request, NSString *name, NSString *address))handler
//{
//    self.reGeoBlock = handler;
//    AMapReGeocodeSearchRequest *reGeocodeSearchRequest = [[AMapReGeocodeSearchRequest alloc] init];
//    reGeocodeSearchRequest.location = [AMapGeoPoint locationWithLatitude:latitude longitude:longitude];
//    reGeocodeSearchRequest.searchType = AMapSearchType_ReGeocode;
//    reGeocodeSearchRequest.requireExtension = YES;
//    [self.searchAPI AMapReGoecodeSearch:reGeocodeSearchRequest];
//
//    return reGeocodeSearchRequest;
//}
//
//- (id)requestNearByLocationsWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude page:(NSInteger)page
//                              completion:(void(^)(id request, NSArray *locations))handler
//{
//    self.nearbyBlock = handler;
//    AMapPlaceSearchRequest *nearbyPoiRequest = [[AMapPlaceSearchRequest alloc] init];
//    nearbyPoiRequest.searchType = AMapSearchType_PlaceAround;
//    nearbyPoiRequest.page = page;
//    nearbyPoiRequest.location = [AMapGeoPoint locationWithLatitude:latitude longitude:longitude];
//    nearbyPoiRequest.radius= 1000;
//    [self.searchAPI AMapPlaceSearch:nearbyPoiRequest];
//
//    return nearbyPoiRequest;
//}
//
//- (id)searchLocationsWithKeyword:(NSString *)keyword page:(NSInteger)page
//                      completion:(void(^)(id request, NSArray *locations))handler
//{
//    self.searchBlock = handler;
//
//    AMapPlaceSearchRequest *searchRequest = [[AMapPlaceSearchRequest alloc] init];
//    searchRequest.searchType = AMapSearchType_PlaceKeyword;
//    searchRequest.page = page;
//    searchRequest.city = @[@"beijing"];
//    searchRequest.requireExtension = YES;
//    searchRequest.keywords = [keyword copy];
//
//    [self.searchAPI AMapPlaceSearch:searchRequest];
//
//    return searchRequest;
//}
//
//- (AMapSearchAPI *)searchAPI
//{
//    if (!_searchAPI)
//    {
//        _searchAPI = [[AMapSearchAPI alloc] initWithSearchKey:@"eb62fec5e116eca1e079637614175304" Delegate:self];
//    }
//
//    return _searchAPI;
//}

//#pragma AMapSearch delegate
//- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
//{
//    if (response)
//    {
//        NSString *name = nil;
//        if (response.regeocode.roads && response.regeocode.roads.count)
//        {
//            AMapRoad *road = response.regeocode.roads[0];
//            name = [road.name copy];
//        }
//
//        self.reGeoBlock(request, name, response.regeocode.formattedAddress);
//    }
//}
//
//- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response
//{
//    if (response)
//    {
//        if (request.searchType == AMapSearchType_PlaceKeyword)
//        {
//            self.searchBlock(request, response.pois);
//        }
//        else
//        {
//           self.nearbyBlock(request, response.pois);
//        }
//    }
//}
@end