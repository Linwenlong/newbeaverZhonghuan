//
//  ClientVisitLogViewController.m
//  beaver
//
//  Created by wangyuliang on 14-5-28.
//  Copyright (c) 2014年 eall. All rights reserved.
//
#import "ClientVisitLogViewController.h"
#import "EBListView.h"
#import "EBViewFactory.h"
#import "EBHttpClient.h"
#import "HouseListViewController.h"
#import "EBListView.h"
#import "HouseDataSource.h"
#import "EBFilter.h"
#import "EBHttpClient.h"
#import "CustomConditionViewController.h"
#import "EBCondition.h"
#import "EBHouse.h"
#import "EBClient.h"
#import "InputOrScanViewController.h"
#import "EBAlert.h"
#import "SnsViewController.h"
#import "EBClientVisitLog.h"
#import "HouseDataSource.h"
#import "ClientVisitLogDataSource.h"
#import "ClientVisitLogAddViewController.h"
#import "ERPWebViewController.h"
#import "FSBasicImageSource.h"
#import "FSBasicImage.h"
#import "FSImageViewerViewController.h"
@interface ClientVisitLogViewController ()<ClientVisitLogAddViewControllerDelegate>{
    EBListView *_listView;
}

@end

@implementation ClientVisitLogViewController

- (void)loadView
{
    [super loadView];
    NSString *title = [NSString stringWithFormat:@"%@-%@",NSLocalizedString(@"btn_view_record", nil) , _clientDetail.contractCode];
    self.navigationItem.title = title;
    
    [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_new_msg2"]target:self action:@selector(addVisitLog:)];
    
    _listView = [[EBListView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    NSString *user = [NSString stringWithFormat:@"%@%@" , NSLocalizedString(@"visit_send", nil) , _clientDetail.name];
    [_listView enableFooterButtonForLog:user target:self action:@selector(recommend:)];
    _listView.isSelecting = YES;
    
    ClientVisitLogDataSource *ds = [[ClientVisitLogDataSource alloc] init];
    EBFilter *filter = [[EBFilter alloc] init];
    [filter parseFromClient:_clientDetail withDetail:NO];
    ds.filter = filter;
//    383 10 1 sale 1
    ds.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
    {
        [[EBHttpClient sharedInstance] clientRequest:params visitLogs:^(BOOL success, NSArray *result)
         {
             done(success, result);
         }];
    };
    ds.imageBlock = ^(EBClientVisitLog *log){
        
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        
        for (NSDictionary *photoInfo  in log.images)
        {
            [photos addObject:[[FSBasicImage alloc] initWithImageURL:[NSURL URLWithString:photoInfo[@"url"]] name:@""]];
        }

        FSBasicImageSource *photoSource = [[FSBasicImageSource alloc] initWithImages:photos];
        FSImageViewerViewController *controller = [[FSImageViewerViewController alloc] initWithImageSource:photoSource imageIndex:0];
        controller.fixTitle = @"图片预览";
        
        [self.navigationController pushViewController:controller animated:YES];
    };
    _listView.dataSource = ds;
    _listView.emptyText = NSLocalizedString(@"empty_visit_log", nil);
    [self.view addSubview:_listView];
    [_listView startLoading];
}

#pragma mark - Selector

- (void)recommend:(UIButton *)btn
{
    [[EBController sharedInstance] recommendVisit:[_listView.dataSource.selectedSet sortedArrayUsingDescriptors:nil]
                                          toClient:_clientDetail  completion:^(BOOL success, NSDictionary *info)
     {
         
     }];
}

- (void)addVisitLog:(id)sender
{
    [EBTrack event:EVENT_CLICK_CLIENT_TAKE_LOOK_ADD];
    ClientVisitLogAddViewController *desViewController = [[ClientVisitLogAddViewController alloc] init];
    desViewController.clientDetail = _clientDetail;
    desViewController.delegate = self;
    desViewController.addVisitLogcompletion = ^{
        [_listView refreshList:YES];
    };
    [self.navigationController pushViewController:desViewController animated:YES];
}
- (void)openPage:(NSDictionary *)paramer
{
    self.isOpenpage = YES;
    self.openDict = paramer;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_listView refreshList:YES];
    
    if([self.openDict[@"open_page_url"] length]<1){
        return;
    }
    
    if (self.isOpenpage) {
        ERPWebViewController *erpVc = [ERPWebViewController sharedInstance];
        [erpVc openWebPage:@{@"title":@"",@"url":self.openDict[@"open_page_url"]}];
        self.isOpenpage = NO;
        [self.navigationController pushViewController:erpVc animated:YES];
    }

}
@end
