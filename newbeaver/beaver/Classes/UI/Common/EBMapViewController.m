//
//  EBMapViewController.m
//  beaver
//
//  Created by LiuLian on 12/11/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "EBMapViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import <MapKit/MapKit.h>
#import "EBMapService.h"
#import "EBAlert.h"
#import "EBViewFactory.h"
#import "EBController.h"
@interface EBMapViewController ()<MAMapViewDelegate, UIActionSheetDelegate>
{
    MAMapView *_mapView;
}

@property (nonatomic, strong) NSMutableArray *availableMaps;

@end

@implementation EBMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"location", nil);
    
    [self initMapView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_mapType == EMMapViewTypeByCoordinate) {
        [self setLocation];
    } else {
        NSString *keyword = [NSString stringWithFormat:@"%@ %@",_poiInfo[@"address"],_poiInfo[@"name"]];
        __weak typeof(self) weakSelf = self;
        [[EBMapService sharedInstance] searchGeocode:keyword city:nil handler:^(id result, BOOL sucess) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!sucess) {
                [EBAlert alertError:@"定位失败"];
                return;
            }
            AMapGeocode *geocode = (AMapGeocode *)result;
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:strongSelf.poiInfo];
            dic[@"lat"] = @(geocode.location.latitude);
            dic[@"lon"] = @(geocode.location.longitude);
            strongSelf.poiInfo = [NSDictionary dictionaryWithDictionary:dic];
            [strongSelf setLocation];
        }];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)initMapView
{
    _mapView = [[EBMapService sharedInstance] mapView];
    _mapView.frame = self.view.bounds;
    _mapView.showsCompass = YES;
    _mapView.compassOrigin = CGPointMake([EBStyle screenWidth] - 15 - _mapView.compassSize.width, 15);
    
    _mapView.delegate = self;
    
    [self.view addSubview:_mapView];
    
    _mapView.showsUserLocation = YES;
}

- (void)setLocation
{
    _mapView.region = MACoordinateRegionMake(CLLocationCoordinate2DMake([self.poiInfo[@"lat"] floatValue], [self.poiInfo[@"lon"] floatValue]), MACoordinateSpanMake(0.006, 0.006));

    CLLocationCoordinate2D coor = [[EBController sharedInstance] GCJ02FromBD09:CLLocationCoordinate2DMake([self.poiInfo[@"lat"] floatValue], [self.poiInfo[@"lon"] floatValue])];
    _mapView.centerCoordinate = coor;
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = coor;
    pointAnnotation.title = self.poiInfo[@"name"] ? : NSLocalizedString(@"location", nil);
    pointAnnotation.subtitle = self.poiInfo[@"address"];
    
    [_mapView addAnnotation:pointAnnotation];
    [_mapView selectAnnotation:pointAnnotation animated:NO];
    

}
-(void)addAnnotationsWithArray:(NSArray*)annotations
{
    CLLocationCoordinate2D point[annotations.count];
    for (NSInteger i =0 ; i<annotations.count; i++) {
        NSDictionary*annotation=annotations[i];
        MAPointAnnotation *pointAnnotation1 = [[MAPointAnnotation alloc] init];
        pointAnnotation1.coordinate = CLLocationCoordinate2DMake([annotation[@"lat"] floatValue], [annotation[@"lon"] floatValue]);
        pointAnnotation1.title = annotation[@"name"] ? : NSLocalizedString(@"location", nil);
        pointAnnotation1.subtitle = annotation[@"address"];
        if (i!=0) {
            //第一个大头针跳过 第一个大头针设置为self.pointInfo 创建视图，定位第一个坐标，所有已经创建，就不用在创建。
            [_mapView addAnnotation:pointAnnotation1];
            [_mapView selectAnnotation:pointAnnotation1 animated:NO];
        }
        point[i]=CLLocationCoordinate2DMake(pointAnnotation1.coordinate.latitude, pointAnnotation1.coordinate.longitude);
        
    }
    
    MAPolyline *polygon=[MAPolyline polylineWithCoordinates:point count:annotations.count];
    [_mapView addOverlay:polygon];
}
-(MAOverlayView*)mapView:(MAMapView *)mapView viewForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineView *polylineView = [[MAPolylineView alloc] initWithPolyline:overlay];
        polylineView.lineWidth = 5.f;
        polylineView.strokeColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.6];
        
        return polylineView;
    }
    return nil;
}
#pragma mark - mamapview delegate
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        annotationView.canShowCallout= NO;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
//        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorPurple;
        
        annotationView.rightCalloutAccessoryView = [EBViewFactory blueButtonWithFrame:CGRectMake(0, annotationView.height/2-14, 40, 28)
                                                                                title:NSLocalizedString(@"go_there", nil)
                                                                               target:self action:@selector(goThere:)];
        
        
        [self customAnnotation:annotationView withPointAnnotation:(MAPointAnnotation*)annotation];//自定义显示
        
        return annotationView;
    }
    return nil;
}

- (void)customAnnotation:(MAPinAnnotationView *)view withPointAnnotation:(MAPointAnnotation *)annotation
{

    if (self.AnnotationType==EBAnnotationTypeByIcon) {

        view.image=[UIImage imageNamed:@"stroke_mark"];
        
        CGFloat factor = 122 / 504.f;
        CGFloat width = 113.f / 162 * view.width;
        
        UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0,factor * view.height - 0.5 * width, width,width)];
        imageview.centerX = view.width * 0.5f;
        imageview.image = [UIImage imageNamed:@"red_delete"];
        imageview.contentMode = UIViewContentModeScaleAspectFill;
        [view addSubview:imageview];

    }
}

- (void)goThere:(UIButton *)btn
{
    [self availableMapsApps];
    UIActionSheet *action = [[UIActionSheet alloc] init];
    
    [action addButtonWithTitle:NSLocalizedString(@"map_system", nil)];
    for (NSDictionary *dic in self.availableMaps)
    {
        [action addButtonWithTitle:dic[@"name"]];
    }
    [action addButtonWithTitle:NSLocalizedString(@"cancel", nil)];
    action.cancelButtonIndex = self.availableMaps.count + 1;
    action.delegate = self;
    [action showInView:self.view];
}

- (void)availableMapsApps
{
    self.availableMaps = [[NSMutableArray alloc] init];
    
    CLLocationCoordinate2D startCoor = _mapView.userLocation.location.coordinate;
    CLLocationCoordinate2D endCoor = CLLocationCoordinate2DMake([self.poiInfo[@"lat"] floatValue], [self.poiInfo[@"lon"] floatValue]);
    NSString *toName = self.poiInfo[@"address"];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://map/"]])
    {
        NSString *urlString = [NSString stringWithFormat:@"baidumap://map/direction?origin=latlng:%f,%f|name:%@&destination=latlng:%f,%f|name:%@&mode=transit",
                               startCoor.latitude, startCoor.longitude, NSLocalizedString(@"my_location", nil), endCoor.latitude, endCoor.longitude, toName];
        
        NSDictionary *dic = @{@"name": NSLocalizedString(@"map_baidu", nil), @"url": urlString};
        [self.availableMaps addObject:dic];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]])
    {
        NSString *urlString = [NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=applicationScheme&poiname=%@&poiid=BGVIS&lat=%f&lon=%f&dev=0&style=3",
                               NSLocalizedString(@"product_title", nil), self.poiInfo[@"address"], endCoor.latitude, endCoor.longitude];
        
        NSDictionary *dic = @{@"name": NSLocalizedString(@"map_amap", nil), @"url": urlString};
        [self.availableMaps addObject:dic];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]])
    {
        NSString *urlString = [NSString stringWithFormat:@"comgooglemaps://?daddr=%f,%f&saddr=%f,%f&directionsmode=transit", endCoor.latitude, endCoor.longitude, startCoor.latitude, startCoor.longitude];
        
        NSDictionary *dic = @{@"name": NSLocalizedString(@"map_google", nil), @"url": urlString};
        [self.availableMaps addObject:dic];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        CLLocationCoordinate2D startCoor = _mapView.userLocation.location.coordinate;
        CLLocationCoordinate2D endCoor = CLLocationCoordinate2DMake([self.poiInfo[@"lat"] floatValue], [self.poiInfo[@"lon"] floatValue]);
        
        MKPlacemark *currentMark = [[MKPlacemark alloc] initWithCoordinate:startCoor addressDictionary:nil];
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:endCoor addressDictionary:nil];
        MKMapItem *currentLocation = [[MKMapItem alloc] initWithPlacemark:currentMark];
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:placemark];
        toLocation.name = self.poiInfo[@"address"];
        
        [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                       launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
        
    }
    else if (buttonIndex < self.availableMaps.count + 1)
    {
        NSDictionary *mapDic = self.availableMaps[buttonIndex-1];
        NSString *urlString = mapDic[@"url"];
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)dealloc
{
    _mapView.delegate = nil;
}

@end
