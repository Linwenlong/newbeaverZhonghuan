//
//  EBAppAnalyzer.m
//  beaver
//
//  Created by 凯文马 on 15/12/22.
//  Copyright © 2015年 eall. All rights reserved.
//

#import "EBAppAnalyzer.h"
#import "JSONKit.h"
#import "EBController.h"
#import "EBFilter.h"

NSString *const EBAppHouseList = @"HouseList";
NSString *const EBAppClientList= @"ClientList";
NSString *const EBAppHouse     = @"House";
NSString *const EBAppClient    = @"Client";
NSString *const EBAPPContracts = @"Contracts";
NSString *const EBAPPCalculator= @"Calculator";
NSString *const EBAPPQrCode    = @"QrCode";
NSString *const EBAPPPubHouse  = @"PubHouse";
NSString *const EBAPPNearByMap = @"NearByMap";
NSString *const EBAPPHouseDetail = @"HouseDetail";


@interface EBAppAnalyzer ()
@property (nonatomic, strong) NSDictionary *viewControllerNames;

@end

@implementation EBAppAnalyzer

- (instancetype)initWithJSON:(NSString *)JSON
{
    return [self initWithDict:[JSON objectFromJSONString]];
}

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [self init]) {
        _viewControllerKey = dict[@"app"];
        _param = dict[@"param"];
    }
    return self;
}

- (UIViewController *)toViewController
{
    NSLog(@"%@",self.viewControllerNames[self.viewControllerKey]);
    UIViewController *vc = [[NSClassFromString(self.viewControllerNames[self.viewControllerKey]) alloc] init];
    SEL selector = NSSelectorFromString(@"setAppParam:");
    if ([vc respondsToSelector:selector]) {
        IMP imp = [vc methodForSelector:selector];
        void (*func)(id,SEL,NSDictionary *) = (void *)imp;
        func(vc,selector,_param);
    }
    [self setBaseParam:vc];
    return vc;
}

# pragma mark - gettget

- (NSDictionary *)viewControllerNames
{
    if (!_viewControllerNames) {
        _viewControllerNames = @{
                                 EBAPPPubHouse  : @"GatherAndPublishViewController",
                                 EBAPPCalculator: @"CalculatorViewController",
                                 EBAPPQrCode    : @"QRScannerViewController",
                                 EBAppClient    : @"ClientViewController",
                                 EBAppHouse     : @"HouseViewController",
                                 EBAppHouseList : @"HouseListViewController",
                                 EBAppClientList: @"ClientListViewController",
                                 EBAPPContracts : @"ContactsViewController",
                                 EBAPPNearByMap : @"NearByMapViewController",
                                 EBAPPHouseDetail:@"HouseDetailViewController",
                                 };
    }
    return _viewControllerNames;
}


# pragma mark - private

- (UIViewController *)setBaseParam:(UIViewController *)vc
{
    NSString *vcName = NSStringFromClass([vc class]);
    if (vcName) {
        if ([vcName isEqualToString:self.viewControllerNames[EBAppHouseList]]) {
            [vc setValue:@(EHouseListTypeSearch) forKeyPath:@"listType"];
            [vc setValue:[[EBFilter alloc] init] forKeyPath:@"filter"];
        } else if ([vcName isEqualToString:self.viewControllerNames[EBAppClientList]]) {
            [vc setValue:@(EHouseListTypeSearch) forKeyPath:@"listType"];
            [vc setValue:[[EBFilter alloc] init] forKeyPath:@"filter"];
        }
    }
    return vc;
}

@end

