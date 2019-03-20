//
//  MapTrackViewController.m
//  beaver
//
//  Created by mac on 17/5/25.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "MapTrackViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapTrackViewController ()<MKMapViewDelegate>
{
    MKMapView*mapView;//地图view
}
@property (nonatomic, strong)CLLocationManager *mg;

@end

@implementation MapTrackViewController

- (CLLocationManager *)mg{
    if (!_mg) {
        _mg = [[CLLocationManager alloc]init];
        
        if ([_mg respondsToSelector:@selector(requestAlwaysAuthorization)]) {
              [_mg requestAlwaysAuthorization];
        }
    }
    return _mg;
}

- (void)initMapView{
    mapView = [[MKMapView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH)];
    mapView.delegate = self;
    [self.view addSubview:mapView];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"行程数据";
    [self initMapView];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self mg];
    mapView.showsUserLocation = YES;
}

#pragma mark -- MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    userLocation.title = @"林文龙";
    userLocation.subtitle = @"你好";
    //设置地图显示中心(大头针移动调整显示中心)
    [mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    //设置地图显示的跨度
    MKCoordinateSpan span = MKCoordinateSpanMake(0.001, 0.001);
    
    MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.location.coordinate, span);
    [mapView setRegion:region animated:YES];
    
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    NSLog(@"%f----%f",mapView.region.span.latitudeDelta,mapView.region.span.longitudeDelta);
}

@end
