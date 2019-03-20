//
//  EBLocationPickerViewController.m
//  beaver
//
//  Created by LiuLian on 12/12/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "EBLocationPickerViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "EBMapService.h"
#import "EBListView.h"
#import "EBViewFactory.h"
#import "UIImage+Alpha.h"
#import "EBSearch.h"
#import "EBController.h"
@interface EBLocationPickerViewController ()<MAMapViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    UIButton *_sendButton;
    
    MAMapView *_mapView;
    EBListView *_nearbyPlaceListView;
    UIImageView *_mapCenterIcon;
    
    MAUserLocation *_userLocation;
    NSString *_userAddress;
    NSString *_userCity;
    
    CLLocationCoordinate2D _mapCenter;
    AMapPOI *_currentPOI;
    
    BOOL _isInitial;
    BOOL _isReloadNearby;
    BOOL _isInsertCurrent;
    
    EBSearch *_searchHelper;
    EBLocationDataSource *_searchDataSource;
    BOOL _searchingPlace;
}
@end

@implementation EBLocationPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"location_select_title", nil);
    
    if (self.withSend) {
        _sendButton = [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_send"] target:self action:@selector(locationSelected:)];
        _sendButton.enabled = NO;
    }
    [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_search"] target:self action:@selector(searchLocation:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"cancel", nil) style:UIBarButtonItemStylePlain
                                                                            target:self action:@selector(cancelPicker:)];
    
    [self initMapView];
    
    [self setupNearbyLocationsListView];
    
    [self setupSearchUIAndDataSource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    _userAddress = @"";
    _isReloadNearby = YES;
    
    CGRect frame = [EBStyle fullScrTableFrame:NO];
    UIView *mapContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, frame.size.height/2)];
    [self.view addSubview:mapContainer];
    
    _mapView = [[EBMapService sharedInstance] mapView];
    _mapView.frame = mapContainer.bounds;
    _mapView.showsCompass = YES;
    _mapView.compassOrigin = CGPointMake([EBStyle screenWidth] - 15 - _mapView.compassSize.width, 15);
    
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
//    [_mapView setUserTrackingMode:MAUserTrackingModeNone animated:YES];//定位图层不跟随用户位置
    
    [mapContainer addSubview:_mapView];
    
    _mapCenterIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_center_icon"]];
    _mapCenterIcon.center = mapContainer.center;
    _mapCenterIcon.frame = CGRectOffset(_mapCenterIcon.frame, 0, -15);
    [mapContainer addSubview:_mapCenterIcon];
    
    UIImage *locateIcon = [UIImage imageNamed:@"map_current_location"];
    UIButton *locateButton = [[UIButton alloc] initWithFrame:CGRectMake(20, mapContainer.height - 70, 50, 50)];
    [locateButton setImage:locateIcon forState:UIControlStateNormal];
    [locateButton setImage:[locateIcon imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted];
    [locateButton addTarget:self action:@selector(centerMapWithUserLocation:) forControlEvents:UIControlEventTouchUpInside];
    [mapContainer addSubview:locateButton];
}

- (void)setupNearbyLocationsListView
{
    CGRect fullFrame = [EBStyle fullScrTableFrame:NO];
    _nearbyPlaceListView = [[EBListView alloc] initWithFrame:CGRectMake(0, _mapView.bottom, self.view.width, fullFrame.size.height - _mapView.height)];
    _nearbyPlaceListView.withoutRefreshHeader = YES;
    
    __weak typeof(self) weakSelf = self;
    
    EBLocationDataSource *ds = [[EBLocationDataSource alloc] init];
    ds.pageSize = 20;
    ds.forNearby = YES;
    ds.withSend = _withSend;
    ds.selectedPoiChanged = ^(AMapPOI *newPoi) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf->_withSend) {
            strongSelf->_isReloadNearby = NO;
            strongSelf->_currentPOI = newPoi;
            CLLocationCoordinate2D center = CLLocationCoordinate2DMake(newPoi.location.latitude, newPoi.location.longitude);
            strongSelf->_mapView.centerCoordinate = center;
        } else {
            strongSelf->_currentPOI = newPoi;
            [strongSelf locationSelected:nil];
        }
    };
    
//    static id nearByRequest = nil;
    ds.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id)) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSInteger page = [params[@"page"] integerValue];
        if (page == 0) {
            page = 1;
        }
        
        if (strongSelf->_userLocation) {
            strongSelf->_sendButton.enabled = NO;
            [[EBMapService sharedInstance] searchPlaceByAround:strongSelf->_mapCenter.latitude longitude:strongSelf->_mapCenter.longitude page:page handler:^(id result, BOOL success) {
                strongSelf->_sendButton.enabled = YES;
                
                if (!success) {
                    done(NO, result);
                    return;
                }
                if (page == 1) {
                    NSMutableArray *ma = [NSMutableArray arrayWithArray:result];
                    if (!strongSelf->_isInsertCurrent) {
                        AMapPOI *apoi = [AMapPOI new];
                        apoi.name = @"[位置]";
                        apoi.address = _userAddress;
                        apoi.location = [AMapGeoPoint locationWithLatitude:strongSelf->_mapCenter.latitude longitude:strongSelf->_mapCenter.longitude];
                        
                        [ma insertObject:apoi atIndex:0];
                        strongSelf->_currentPOI = apoi;
                    } else {
                        [ma insertObject:strongSelf->_currentPOI atIndex:0];
                        strongSelf->_isInsertCurrent = NO;
                        [(EBLocationDataSource *)strongSelf->_nearbyPlaceListView.dataSource setCurrentCenterDelete:YES];
                    }
                    
                    done(YES, ma);
                    [strongSelf->_nearbyPlaceListView.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                } else {
                    done(YES, result);
                }
            }];
        } else {
            done(NO, nil);
        }
    };
    _nearbyPlaceListView.dataSource = ds;
    
    [self.view addSubview:_nearbyPlaceListView];
}

- (void)setupSearchUIAndDataSource
{
    _searchHelper = [[EBSearch alloc] init];
    [_searchHelper setupSearchBarForController:self];
    
    _searchHelper.displayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    __weak typeof(self) weakSelf = self;
    EBLocationDataSource *ds = [[EBLocationDataSource alloc] init];
    ds.selectedPoiChanged =  ^(AMapPOI *newPoi) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf->_isInsertCurrent = YES;
        
        [strongSelf->_searchHelper.displayController setActive:NO animated:YES];
        
        strongSelf->_currentPOI = newPoi;
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake(newPoi.location.latitude, newPoi.location.longitude);
        strongSelf->_mapView.centerCoordinate = center;
    };
    
    ds.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id)) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSInteger page = [params[@"page"] integerValue];
        if (page == 0) {
            page = 1;
        }
        [[EBMapService sharedInstance] searchPlaceByKey:strongSelf->_searchHelper.displayController.searchBar.text city:strongSelf->_userCity page:page handler:^(id result, BOOL sucess) {
            done(YES, result);
        }];
    };
    
    _searchDataSource = ds;
}

#pragma mark - mamapview delegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (updatingLocation) {
        _userLocation = userLocation;
        if (!_isInitial) {
            _mapView.region = MACoordinateRegionMake(CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude), MACoordinateSpanMake(0.006, 0.006));
            _mapView.centerCoordinate = userLocation.coordinate;
            
            _isInitial = YES;
        }
    }
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [UIView animateWithDuration:0.25 animations:^{
        _mapCenterIcon.frame = CGRectOffset(_mapCenterIcon.frame, 0, 15);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            _mapCenterIcon.frame = CGRectOffset(_mapCenterIcon.frame, 0, -15);
        } completion:^(BOOL finished) {
            [self setMapCenter:mapView.centerCoordinate];
        }];
    }];
}

#pragma mark - navi action
- (void)cancelPicker:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)locationSelected:(UIButton *)btn
{
    CLLocationCoordinate2D coor = [[EBController sharedInstance] BD09FromGCJ02:CLLocationCoordinate2DMake(_currentPOI.location.latitude, _currentPOI.location.longitude)];
    
    self.selectBlock(@{@"address":_currentPOI.address, @"name":_currentPOI.name,
                       @"lat":@(coor.latitude), @"lon":@(coor.longitude)});
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchLocation:(UIButton *)btn
{
    __weak typeof(self) weakSelf = self;
    
    _searchDataSource.currentChoice = 0;
    [_searchHelper searchLocations:self delegate:self keywordChange:^(NSString *keyword) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf->_searchDataSource clearData];
    } searchClick:^(NSString *keyword) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf->_searchingPlace = YES;
        [strongSelf->_searchDataSource refresh:YES handler:^(BOOL success, id result) {
            strongSelf->_searchingPlace = NO;
            if (success) {
                [strongSelf->_searchHelper.displayController.searchResultsTableView reloadData];
            }
        }];
         
        [strongSelf->_searchHelper.displayController.searchResultsTableView reloadData];
    }];
}

- (void)centerMapWithUserLocation:(id)sender
{
    _mapView.centerCoordinate = _userLocation.location.coordinate;
}

- (void)refreshNearbyPlace
{
    if (!_nearbyPlaceListView.loadInitialed) {
        [_nearbyPlaceListView startLoading];
    } else {
        [_nearbyPlaceListView refreshList:YES];
    }
}

- (void)setMapCenter:(CLLocationCoordinate2D)center
{
    _mapCenter = center;
    
    if (!_isReloadNearby) {
        _isReloadNearby = YES;
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[EBMapService sharedInstance] searchReGeocode:_mapCenter.latitude longitude:_mapCenter.longitude handler:^(id regeocode, BOOL success) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (success) {
            strongSelf->_userAddress = [(AMapReGeocode *)regeocode formattedAddress];
            AMapAddressComponent *com = [(AMapReGeocode *)regeocode addressComponent];
            if (com.city && ![com.city isEqualToString:@""]) {
                strongSelf->_userCity = com.city;
            } else {
                strongSelf->_userCity = com.province;
            }
            [(EBLocationDataSource *)strongSelf->_nearbyPlaceListView.dataSource setPage:1];
            [(EBLocationDataSource *)strongSelf->_nearbyPlaceListView.dataSource setCurrentChoice:0];
            [(EBLocationDataSource *)strongSelf->_nearbyPlaceListView.dataSource setCurrentCenterDelete:NO];
            [strongSelf refreshNearbyPlace];
            
        }
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_searchingPlace && [indexPath row] == [_searchDataSource numberOfRows]) {
        if ([_searchDataSource hasMore]) {
            UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)[cell viewWithTag:99];
            UILabel *label =  (UILabel *) [cell viewWithTag:100];
            [indicatorView startAnimating];
            
            [_searchDataSource loadMore:^(BOOL success, id result) {
                 [indicatorView stopAnimating];
                 if (success) {
                     label.hidden = YES;
                     [tableView reloadData];
                 } else {
                     label.hidden = NO;
                     label.text = NSLocalizedString(@"loading_fail", nil);
                 }
             }];
        } else {
            [cell viewWithTag:100].hidden = NO;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_searchingPlace || _searchDataSource.dataArray == nil) {
        return 1;
    }
    
    NSInteger numberOfRows = [_searchDataSource numberOfRows];
    if (_searchDataSource.dataArray.count && _searchDataSource.hasMore) {
        return numberOfRows + 1;
    } else {
        return numberOfRows;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_searchingPlace && [indexPath row] == 0) {
        UITableViewCell *cell = [EBViewFactory loadingMoreCellFor:tableView cellHeight:[_searchDataSource heightOfRow:0] cellIdentifier:@"loadingCell"];
        UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)[cell viewWithTag:99];
        [indicatorView startAnimating];
        return cell;
    } else if (_searchDataSource.dataArray == nil && [indexPath row] == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"emptyCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"emptyCell"];
        }
        
        return cell;
    } else if ([indexPath row] == [_searchDataSource numberOfRows]) {
        return [EBViewFactory loadingMoreCellFor:tableView cellHeight:[_searchDataSource heightOfRow:0] cellIdentifier:@"loadingMoreCell"];
    } else {
        return [_searchDataSource tableView:tableView cellForRow:[indexPath row]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_searchDataSource heightOfRow:[indexPath row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] < [_searchDataSource numberOfRows] && !_searchingPlace) {
        [_searchDataSource tableView:tableView didSelectRow:[indexPath row]];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end

#pragma mark - locationDataSource

@interface EBLocationDataSource()

@property (nonatomic) BOOL isUserLoction;

@end

@implementation EBLocationDataSource

- (CGFloat)heightOfRow:(NSInteger)row
{
    return 60.0;
}

- (void)tableView:(UITableView *)tableView didSelectRow:(NSInteger)row
{
    if (_withSend && _currentChoice == row) {
        return;
    }
//    if (_currentChoice != row) {
        AMapPOI *poi = self.dataArray[row];
        
        self.selectedPoiChanged(poi);
        _currentChoice = row;
        
        if (!_currentCenterDelete) {
            [self.dataArray removeObjectAtIndex:0];
            _currentCenterDelete = YES;
            _currentChoice -= 1;
        }
    
        [tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
//    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRow:(NSInteger)row
{
    NSString *identifier = @"locationNearbyIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        [cell addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:60.0 leftMargin:15.0]];
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
        cell.textLabel.backgroundColor = [UIColor redColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
    }
    
    AMapPOI *poi = self.dataArray[row];
    cell.textLabel.text = poi.name;
    cell.detailTextLabel.text = poi.address;
    
    if (row == _currentChoice) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return  cell;
}

@end
