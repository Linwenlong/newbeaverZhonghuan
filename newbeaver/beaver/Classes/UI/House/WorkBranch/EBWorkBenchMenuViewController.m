//
//  EBShopViewController.m
//  beaver
//
//  Created by 凯文马 on 15/12/16.
//  Copyright © 2015年 eall. All rights reserved.
//

/**
 *  工作台里面的界面
 */
#import "EBWorkBenchMenuViewController.h"
#import "workbenchBtn.h"
#import "ERPWebViewController.h"
#import "EBPreferences.h"
#import "EBAppAnalyzer.h"
#import "ZHDCNewHouseViewController.h"
#import "VedioTeachViewController.h"

@interface EBWorkBenchMenuViewController ()

@property (nonatomic, strong) UIScrollView *innerView;

@property (nonatomic, strong) NSDictionary *app;
@end

@implementation EBWorkBenchMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self buildView];
}

- (void)buildView
{
    NSMutableArray *temp = [@[] mutableCopy];
    for (NSInteger i = 0; i < self.items.count; i++) {
        EBWorkBenchItem *item = self.items[i];
        NSString *url = [NSString stringWithFormat:@"%@%@",BEAVER_WAP_URL,item.image];
        NSLog(@"url = %@",url);
        workbenchBtn *btn = [[workbenchBtn alloc] initWithTitle:item.name imageUrl:url frame:CGRectZero];
        btn.tag = i;
        [btn addTarget:self action:@selector(itemDidClick:) forControlEvents:UIControlEventTouchUpInside];
        if (item.tips) {
            [btn addPointBadge];
        }
        [temp addObject:btn];
    }
    [self buildButtonsInInnerView:[temp copy]];
}

/**
 *  在innerView上面创建按钮
 *
 *  @param buttons workbenchBtn数组
 */
- (void)buildButtonsInInnerView:(NSArray *)buttons
{
    if (!_innerView) {
        _innerView = [[UIScrollView alloc] init];
        _innerView.width = self.view.width;
        _innerView.showsHorizontalScrollIndicator = NO;
        _innerView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_innerView];
    }
    CGFloat margin = 15.f;
    NSInteger cols = MIN(4, buttons.count);
    NSInteger rows = 1;
    if (buttons.count < 4) {
        rows = 1;
    } else {
        if (buttons.count % 4) {
            rows = buttons.count / cols + 1;
        } else {
            rows = buttons.count / cols;
        }
    }
    CGFloat width = (self.view.width - 2 * margin) / cols;
    CGFloat height = 92.5;
    for (NSInteger i = 0; i < buttons.count; i++) {
        workbenchBtn *btn = buttons[i];
        if (![btn isKindOfClass:[workbenchBtn class]]) return;
        NSInteger col = i % cols;
        NSInteger row = i / cols;
        btn.frame = CGRectMake(margin + col * width, row * height, width, height);
        [_innerView addSubview:btn];
    }
    _innerView.height = rows * height;
    _innerView.centerY = self.view.height * 0.4f;
}

#pragma mark -- 工作台里面的点击按钮

- (void)itemDidClick:(UIButton *)sender
{
    EBWorkBenchItem *item = self.items[sender.tag];
    BOOL isWap = item.isWap;
    if ([item.name isEqualToString:@"新房客户跟进"]) {
        VedioTeachViewController *followup = [[VedioTeachViewController alloc]init];
            [self.navigationController pushViewController:followup animated:YES];
        return;
    } 
    
    if ([item.name isEqualToString:@"新房"]) {
        //新房界面
        ZHDCNewHouseViewController *newHouse = [[ZHDCNewHouseViewController alloc]init];
         [self.navigationController pushViewController:newHouse animated:YES];
        return;
    }
    
    if (isWap) {
            ERPWebViewController *webVc = [ERPWebViewController     sharedInstance];
        [webVc openWebPage:@{@"title":item.name,@"url":item.url}];
            [self.navigationController pushViewController:webVc animated:YES];
        } else {
            // 打开的是本地的控制器,根据 item.url 判断
            EBAppAnalyzer *analyzer = [[EBAppAnalyzer alloc] initWithJSON:item.url];
            UIViewController *vc = [analyzer toViewController];
            NSLog(@"vc=%@",vc);
            if (vc) {
                vc.title = item.name;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    
}

@end

@implementation EBWorkBenchItem

+ (instancetype)itemWithDict:(NSDictionary *)dict{
    EBWorkBenchItem *item = [[EBWorkBenchItem alloc] init];
    item.name = dict[@"name"];
    item.url = dict[@"url"];
    item.image = dict[@"image"];
    item.tips = [dict[@"tips"] boolValue];
    item.isWap = [dict[@"is_wap"] boolValue];
    return item;
}

+ (NSArray *)itemsWithDicts:(NSArray *)dicts{
    NSMutableArray *temp = [@[] mutableCopy];
    for (NSDictionary *dict in dicts) {
        EBWorkBenchItem *item = [self itemWithDict:dict];
        [temp addObject:item];
    }
    return [temp copy];
}

@end
