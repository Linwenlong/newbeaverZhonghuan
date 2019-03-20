//
//  NearByMapViewController.m
//  beaver
//
//  Created by linger on 16/2/1.
//  Copyright © 2016年 eall. All rights reserved.
//
/**
 *  地图找房
 *
 *  @return
 */
#import "NearByMapViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import <MapKit/MapKit.h>
#import "EBMapService.h"
#import "EBAlert.h"
#import "EBViewFactory.h"
#import "EBHttpClient.h"
#import "EBAlert.h"
#import "EBAppAnalyzer.h"
#import "EBListView.h"
#import "EBFilterHeader.h"
#import "HouseDataSource.h"
#import "CustomAnnotationView.h"
#import "NearByMapFilterHeaderView.h"
#import "ERPWebViewController.h"

#define DetailTAG 100

@interface NearByMapViewController ()<MAMapViewDelegate, UIActionSheetDelegate,NearByMapFilterHeaderViewDelegate>
{
    MAMapView *_mapView;
    NSArray * _listArray;
    BOOL isShow;
    CLLocationCoordinate2D _currentCoordinate;
}

@property (nonatomic, strong) NearByMapFilterHeaderView * headerFiler;
@property (nonatomic, strong) NearByMapFilterHeaderView * headerFiler2;

@property (nonatomic, strong) id<EBListDataSource> dataSource;
@end

@implementation NearByMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initMapView];
    [self createNavigationTitleView];
    [self createHeaderView];
    [self beaverStatistics:@"NewbyHouse"];
}

- (void)createNavigationTitleView{
    UIView *nvView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 40)];
    self.navigationItem.titleView = nvView;
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"二手",@"新房",@"租房",nil];
    UISegmentedControl *sc = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    [sc addTarget:self action:@selector(SegmentValueChange:) forControlEvents:UIControlEventValueChanged];
    sc.tintColor = [UIColor whiteColor];
    [nvView addSubview:sc];
    sc.frame= CGRectMake(25, 7.5, 150, 25);
    sc.selectedSegmentIndex = 0;
}

- (void)SegmentValueChange:(UISegmentedControl *)sc
{
    NSLog(@"%ld",sc.selectedSegmentIndex);
    [_headerFiler  dismissPopUpView];
    [_headerFiler2  dismissPopUpView];
    _headerFiler.alpha = 0;
    _headerFiler2.alpha = 0;

    switch (sc.selectedSegmentIndex) {
        case 0:
            _headerFiler.alpha = 1;
            _headerFiler.houseType = 0;//售
            _headerFiler.filter.requireOrRentalType = 0;
            [self filterToSeleted:[_headerFiler.filter currentArgs]];
            break;
        case 1:

            _headerFiler.alpha = 0;
            _headerFiler2.alpha = 0;
            [self filterToSeleted:@{@"type":@"new"}];
            
            break;
        case 2:

            _headerFiler2.alpha = 1;
            _headerFiler2.houseType = 1;// 租
            _headerFiler2.filter.requireOrRentalType = 1;
            [self filterToSeleted:[_headerFiler2.filter currentArgs]];
            break;
            
        default:
            break;
    }
}

- (void)createHeaderView
{
    _headerFiler = [[NearByMapFilterHeaderView alloc]initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 40)];
    _headerFiler.delegate = self;
      EBFilter*  filter =[[EBFilter alloc]init];
     _headerFiler.filter =filter;
    [self.view addSubview:_headerFiler];
    _headerFiler.alpha = 1;
    _headerFiler.houseType = 0;//售
    _headerFiler.filter.requireOrRentalType = 0;

    _headerFiler2 = [[NearByMapFilterHeaderView alloc]initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 40)];
    _headerFiler2.delegate = self;
     EBFilter*  filter2 =[[EBFilter alloc]init];
    _headerFiler2.filter =filter2;
    [self.view addSubview:_headerFiler2];
    _headerFiler2.alpha = 0;
//    _headerFiler2.houseType = 1;//租
//    _headerFiler2.filter.requireOrRentalType = 1;
    
}

#pragma mark -- 过滤地图找房
- (void)filterToSeleted:(NSDictionary *)agrs
{

    NSMutableDictionary *paramter = [[NSMutableDictionary  alloc]initWithDictionary:agrs];
    [paramter setObject:[NSNumber numberWithFloat:[[EBController sharedInstance] BD09FromGCJ02:_currentCoordinate].latitude] forKey:@"lat"];
    [paramter setObject:[NSNumber numberWithFloat:[[EBController sharedInstance] BD09FromGCJ02:_currentCoordinate].longitude] forKey:@"lng"];
    NSLog(@"%@",paramter);
    
    [_mapView setCenterCoordinate:_mapView.userLocation.coordinate animated:YES];
    [[EBHttpClient wapInstance] wapRequest:paramter nearbyList:^(BOOL success, id result) {
        [EBAlert hideLoading];
        
        if(success){
            _listArray = result[@"data"];
            if ([paramter[@"type"] isEqualToString:@"new"]) {
                [self addAnnotationsWithArray:_listArray withIsWap:YES withType:paramter[@"type"]];

            }else{
                [self addAnnotationsWithArray:_listArray withIsWap:NO withType:paramter[@"type"]];
            }
        }
        NSLog(@"%@",result);
    }];

 
}

- (void)filterChoiceChanged:(NSInteger)filterIndex
{

}
- (void)popupViewWillShow
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    if (isShow) {
        return;
    }else{
        isShow = YES;
    }
    NSLog(@"%f",_mapView.userLocation.coordinate.latitude);
    if (_mapView.userLocation.coordinate.latitude != 0 ) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.poiInfo];
        
        dic[@"lat"] = @([[EBController sharedInstance] BD09FromGCJ02:_mapView.userLocation.coordinate].latitude);
        dic[@"lng"] = @([[EBController sharedInstance] BD09FromGCJ02:_mapView.userLocation.coordinate].longitude);
        
        _currentCoordinate.latitude = _mapView.userLocation.coordinate.latitude;
        _currentCoordinate.longitude = _mapView.userLocation.coordinate.longitude;
        
        [EBAlert showLoading:nil];
        [_mapView setCenterCoordinate:_mapView.userLocation.coordinate animated:YES];
        [[EBHttpClient wapInstance] wapRequest:dic nearbyList:^(BOOL success, id result) {
            [EBAlert hideLoading];
            if(success){
                _listArray = result[@"data"];
                [self addAnnotationsWithArray:_listArray withIsWap:NO withType:@"sale"];
            }
            NSLog(@"%@",result);
        }];
    }
}

#pragma mark -- mapView
- (void)initMapView
{
    _mapView = [[EBMapService sharedInstance] mapView];
    _mapView.frame = self.view.bounds;
    _mapView.showsCompass = NO;
    _mapView.compassOrigin = CGPointMake([EBStyle screenWidth] - 15 - _mapView.compassSize.width, 15);
    _mapView.zoomLevel = 17.1;
    _mapView.delegate = self;
    
    [self.view addSubview:_mapView];
    
    _mapView.showsUserLocation = YES;
    
}

-(void)addAnnotationsWithArray:(NSArray*)annotations withIsWap:(BOOL)isWap withType:(NSString *)type
{

    NSArray *MapAnnotations = _mapView.annotations;
    for (NSInteger i =0 ; i<MapAnnotations.count; i++) {
        if ([MapAnnotations[i] isKindOfClass:[customerPointAnnotation class]]) {
            customerPointAnnotation *an  = (customerPointAnnotation *)MapAnnotations[i];
            [_mapView removeAnnotation:an];
        }
    }
    
    CLLocationCoordinate2D point[annotations.count];
    for (NSInteger i =0 ; i<annotations.count; i++) {
        NSDictionary*annotation=annotations[i];
        customerPointAnnotation *pointAnnotation1 = [[customerPointAnnotation alloc] init];
        CLLocationCoordinate2D coor = [[EBController sharedInstance] GCJ02FromBD09:CLLocationCoordinate2DMake([annotation[@"latitude"] floatValue], [annotation[@"longitude"] floatValue])];
        pointAnnotation1.coordinate = coor;
        if([annotation[@"num"] integerValue]){
            pointAnnotation1.title = [NSString stringWithFormat:@"%@ %@",annotation[@"community_name"],annotation[@"num"]];
        }else{
            pointAnnotation1.title = [NSString stringWithFormat:@"%@",annotation[@"community_name"]];
        }
        
        pointAnnotation1.subtitle = [NSString stringWithFormat:@"%@",annotation[@"community_name"]];
        pointAnnotation1.Mid = annotation[@"ids"];
        pointAnnotation1.community_id = [NSString stringWithFormat:@"%@",annotation[@"document_id"]];
        pointAnnotation1.type = type;
        pointAnnotation1.isWap = isWap;
        if (annotation[@"url"]) {
            pointAnnotation1.url= annotation[@"url"];
        }
        point[i]=CLLocationCoordinate2DMake(pointAnnotation1.coordinate.latitude, pointAnnotation1.coordinate.longitude);
        [_mapView addAnnotation:pointAnnotation1];

    }
    
}

/**
 *  标注选择
 *
 *  @param mapView
 *  @param view
 */
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    
    if ([view isKindOfClass:[CustomAnnotationView class]]) {
        CustomAnnotationView *cusView = (CustomAnnotationView *)view;
        cusView.selected = YES;
        
        customerPointAnnotation *cusAnnotation = cusView.annotation;
        NSLog(@"%@ %@ %@",cusAnnotation.Mid,cusAnnotation.subtitle,cusAnnotation.type);
        NSLog(@"community_id=%@",cusAnnotation.community_id);
        
        if (cusAnnotation.isWap) {
            ERPWebViewController *webVc = [ERPWebViewController sharedInstance];
            [webVc openWebPage:@{@"title":@"",@"url":cusAnnotation.url}];
            [self.navigationController pushViewController:webVc animated:YES];
        }else{
            NSDictionary *param =@{@"status":@"",
                                   @"type":cusAnnotation.type,
                                   @"id":cusAnnotation.Mid,
                                   @"community_id":cusAnnotation.community_id};
            
            NSDictionary *dict =@{@"app":@"HouseList",
                                  @"title":cusAnnotation.subtitle,
                                  @"param":param};
            
            EBAppAnalyzer *analyzer = [[EBAppAnalyzer alloc] initWithDict:dict];
            UIViewController *vc = [analyzer toViewController];
            if (vc) {
                vc.title = dict[@"title"];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
}

#pragma mark - mamapview delegate
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *customReuseIndetifier = @"customReuseIndetifier";
        CustomAnnotationView *annotationView = (CustomAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:customReuseIndetifier];
        if (annotationView == nil){
            annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation
                                                              reuseIdentifier:customReuseIndetifier];
        }
        // must set to NO, so we can show the custom callout view.
        customerPointAnnotation *sannotation = (customerPointAnnotation *)annotation;
        annotationView.canShowCallout   = NO;
        annotationView.name             = sannotation.title;
        annotationView.annotation       = sannotation;
        return annotationView;
    }
    return nil;
}


- (void)dealloc
{
    _mapView.delegate = nil;
}

@end

@implementation customerPointAnnotation



@end

