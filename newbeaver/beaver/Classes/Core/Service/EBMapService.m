//
//  EBMapService.m
//  beaver
//
//  Created by LiuLian on 12/11/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "EBMapService.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>

@interface EBMapService()<MAMapViewDelegate, AMapSearchDelegate>

@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, copy) void (^locationHandler) (id result);
@property (nonatomic, copy) void (^geoHandler) (id result, BOOL success);
@property (nonatomic, copy) void (^regeoHandler) (id result, BOOL success);
@property (nonatomic, copy) void (^aroundHandler) (id result, BOOL success);

@end

@implementation EBMapService

+ (instancetype)sharedInstance
{
    static EBMapService *instance;
    static dispatch_once_t pre;
    dispatch_once(&pre, ^{
        instance = [EBMapService new];
        [instance configureAPIKey];
    });
    return instance;
}

- (void)configureAPIKey
{
    
    [MAMapServices sharedServices].apiKey = MAMapKey;
}

- (MAMapView *)mapView
{
    return [MAMapView new];
}

/**
 * 定位
 */
- (void)requestUserLocation:(void (^)(id))handler superview:(UIView *)view
{
    self.locationHandler = handler;
    
    
    NSArray *subviews = [view subviews];
    for (int i = 0; i < subviews.count; i++) {
        if ([subviews[i] isKindOfClass:[MAMapView class]]) {
            MAMapView*  mapview = (MAMapView *)subviews[i];
            mapview.showsUserLocation = YES;
            return;
        }
    }
    
    MAMapView *mapview = nil;

    if (!mapview) {
        mapview = [self mapView];
        mapview.frame = CGRectZero;
        [view addSubview:mapview];
        mapview.hidden = YES;
        
        mapview.delegate = self;
    }
    
    mapview.showsUserLocation = YES;
}

/**
 * 地理编码
 */
- (void)searchGeocode:(NSString *)address city:(NSString *)city handler:(void (^)(id, BOOL))handler
{
    self.geoHandler = handler;
    
    AMapGeocodeSearchRequest *geoRequest = [[AMapGeocodeSearchRequest alloc] init]; geoRequest.searchType = AMapSearchType_Geocode;
    geoRequest.address = address;
    if (city && ![city isEqualToString:@""]) {
        geoRequest.city = @[city];
    }
    [self.search AMapGeocodeSearch: geoRequest];
}

/**
 * 逆地理编码
 */
- (void)searchReGeocode:(CGFloat)lat longitude:(CGFloat)lon handler:(void (^)(NSString *, BOOL))handler
{
    self.regeoHandler = handler;
    
    AMapReGeocodeSearchRequest *regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
    regeoRequest.searchType = AMapSearchType_ReGeocode;
    regeoRequest.location = [AMapGeoPoint locationWithLatitude:lat longitude:lon];
    regeoRequest.radius = 100;
    regeoRequest.requireExtension = YES;
    [self.search AMapReGoecodeSearch: regeoRequest];
}

/**
 * 周边搜索
 */
- (void)searchPlaceByAround:(CGFloat)lat longitude:(CGFloat)lon page:(NSInteger)page handler:(void (^)(id, BOOL))handler
{
    self.aroundHandler = handler;
    
    AMapPlaceSearchRequest *poiRequest = [[AMapPlaceSearchRequest alloc] init];
    poiRequest.searchType = AMapSearchType_PlaceAround;
    poiRequest.location = [AMapGeoPoint locationWithLatitude:lat longitude:lon];
    poiRequest.radius= 1000;
    poiRequest.page = page;
    [self.search AMapPlaceSearch: poiRequest];
}

- (void)searchPlaceByKey:(NSString *)key city:(NSString *)city page:(NSInteger)page handler:(void (^)(id, BOOL))handler
{
    self.aroundHandler = handler;
    
    AMapPlaceSearchRequest *poiRequest = [[AMapPlaceSearchRequest alloc] init];
    poiRequest.searchType = AMapSearchType_PlaceKeyword;
    poiRequest.keywords = key;
    poiRequest.city = @[city];
    poiRequest.page = page;
    [self.search AMapPlaceSearch: poiRequest];
}

#pragma mark - 定位
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (!userLocation || !userLocation.location) {
        
    } else {
        //    if (updatingLocation) {
        self.locationHandler(userLocation);
        //    }
        mapView.showsUserLocation = NO;
        //    [mapView removeFromSuperview];
    }
}

- (void)mapView:(MAMapView*)mapView didFailToLocateUserWithError:(NSError*)error
{
    self.locationHandler(error);
    mapView.showsUserLocation = NO;
//    [mapView removeFromSuperview];
}

#pragma mark - 搜索
- (void)searchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"%s: searchRequest = %@, errInfo= %@", __func__, [request class], error);
    if ([request isKindOfClass:[AMapReGeocodeSearchRequest class]]) {
        self.regeoHandler(error.description, NO);
    } else if ([request isKindOfClass:[AMapPlaceSearchRequest class]]) {
        self.aroundHandler(error.description, NO);
    } else if ([request isKindOfClass:[AMapGeocodeSearchRequest class]]) {
        self.geoHandler(error.description, NO);
    }
}

- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest*)request response:(AMapGeocodeSearchResponse *)response
{
    if (response.count == 0) {
        self.geoHandler(nil, NO);
        return;
    }
    AMapGeocode *geocode = [response.geocodes firstObject];
    self.geoHandler(geocode, YES);
    
//    NSString *strCount = [NSString stringWithFormat:@"count: %d", response.count]; NSString *strGeocodes = @"";
//    for (AMapTip *p in response.geocodes) {
//        strGeocodes = [NSString stringWithFormat:@"%@\ngeocode: %@", strGeocodes,
//                       p.description]; }
//    NSString *result = [NSString stringWithFormat:@"%@ \n %@", strCount, strGeocodes];
//    NSLog(@"Geocode: %@", result);
}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    self.regeoHandler(response.regeocode, YES);
}

- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response
{
//    NSString *strCount = [NSString stringWithFormat:@"count: %d",response.count];
//    NSString *strSuggestion = [NSString stringWithFormat:@"Suggestion: %@", response.suggestion];
//    NSString *strPoi = @"";
//    for (AMapPOI *p in response.pois) {
//        strPoi = [NSString stringWithFormat:@"%@\nPOI: %@", strPoi, p.description]; }
//    NSString *result = [NSString stringWithFormat:@"%@ \n %@ \n %@", strCount, strSuggestion, strPoi];
//    NSLog(@"Place: %@", result);
    self.aroundHandler(response.pois, YES);
}

#pragma mark - getters
- (AMapSearchAPI *)search
{
    if (!_search) {
        _search = [[AMapSearchAPI alloc] initWithSearchKey:MAMapKey Delegate:self];
    }
    return _search;
}

@end
