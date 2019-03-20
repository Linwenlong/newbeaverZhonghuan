//
//  ChargeDetailViewController.m
//  beaver
//
//  Created by mac on 17/12/20.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "ChargeDetailViewController.h"
#import "CKSlideMenu.h"
#import "ChargeSellAndBugViewController.h"

@interface ChargeDetailViewController ()<CKSlideMenuDelegate>

@property (nonatomic, strong)CKSlideMenu *slideMenu;
@property (nonatomic, strong)NSMutableArray *arr;

//甲方
@property (nonatomic, strong)NSMutableArray *arrSell;
@property (nonatomic, assign)CGFloat sell_totel_fee;//总费用
@property (nonatomic, assign)CGFloat sell_totel_other;//欠费

//乙方
@property (nonatomic, strong)NSMutableArray *arrBuy;
@property (nonatomic, assign)CGFloat buy_totel_fee;//总费用
@property (nonatomic, assign)CGFloat buy_totel_other;//欠费

@end

@implementation ChargeDetailViewController

- (void)changeTitle:(NSInteger)index{
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
    
    _arrSell = [NSMutableArray array];
    _arrBuy = [NSMutableArray array];
    
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
    lable.textColor = [UIColor whiteColor];
    lable.text= @"收费详情";
    lable.textAlignment = NSTextAlignmentCenter;
    lable.font = [UIFont systemFontOfSize:20.0f];
    self.navigationItem.titleView = lable;
    //发送请求
    [self requestData];
    
}

//收费详情
- (void)requestData{
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"%@/zhpay/NewDealFeesDetail?token=%@&deal_code=%@",NewHttpBaseUrl,[EBPreferences sharedInstance].token,_deal_code]);
    if (_deal_code == nil) {
        [EBAlert alertError:@"合同编号为空" length:2.0f];
        return;
    }
    NSString *urlStr = @"zhpay/NewDealFeesDetail";//需要替换下
    [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
    //    _dept_id
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       @"deal_code":_deal_code
       } success:^(id responseObject) {
           [EBAlert hideLoading];
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           
           NSArray *tmpArray = currentDic[@"data"][@"data"];//公告列表
           NSLog(@"tmpArray=%@",tmpArray);
           
           [self analysisData:tmpArray];
           
       } failure:^(NSError *error) {
           [EBAlert hideLoading];
           [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
       }];

}

- (void)analysisData:(NSArray *)tmpArray{
    
    for (NSDictionary *dic in tmpArray) {
        if ([dic.allKeys containsObject:@"holder"] && [dic[@"holder"] isEqualToString:@"1"]) {
            [_arrSell addObject:dic];
            //欠费
            NSLog(@"received = %d",[NSString StringIsNullOrEmpty:dic[@"received"]]);
            NSLog(@"receivable = %d",[NSString StringIsNullOrEmpty:dic[@"receivable"]]);
            
            if (![NSString StringIsNullOrEmpty:dic[@"receivable"]]) {
               _sell_totel_fee += [dic[@"receivable"] floatValue];
                //欠费
                NSLog(@"null = %d",[NSString StringIsNullOrEmpty:dic[@"received"]]);
                if (![NSString StringIsNullOrEmpty:dic[@"received"]]) {
                    _sell_totel_other += [dic[@"receivable"] floatValue] - [dic[@"received"] floatValue];
                }else{
                    _sell_totel_other += [dic[@"receivable"] floatValue] - 0;
                }
            }
        }else{
            [_arrBuy addObject:dic];
            if (dic[@"receivable"] != nil) {
                _buy_totel_fee += [dic[@"receivable"] floatValue];
                //欠费
                if (dic[@"received"] != nil) {
                    _buy_totel_other += [dic[@"receivable"] floatValue] - [dic[@"received"] floatValue];
                }else{
                    _buy_totel_other += [dic[@"receivable"] floatValue] - 0;
                }
            }
        }
    }
    
    [self setTest];
}

- (void)setTest{
    NSArray *titleArr = @[@"甲方（卖家）",@"乙方（买家）"];
    _arr = [NSMutableArray array];
    
    for (int i=0; i<titleArr.count; i++) {
//        UIViewController *vc = nil;
       
       ChargeSellAndBugViewController*  vc = [[ChargeSellAndBugViewController alloc]init];
        vc.title = titleArr[i];
        if (i == 0) {
            NSLog(@"_arrSell = %@",_arrSell);
            vc.arr = _arrSell;
            vc.totel_fee = _sell_totel_fee;
            vc.totel_other = _sell_totel_other;
        }else{
            vc.arr = _arrBuy;
            vc.totel_fee = _buy_totel_fee;
            vc.totel_other = _buy_totel_other;
        }
        [_arr addObject:vc];
    }
    
    _slideMenu = [[CKSlideMenu alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40) titles:titleArr controllers:_arr];
    _slideMenu.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"nav_bground"]];
    
    _slideMenu.bodyFrame = CGRectMake(0,  CGRectGetMaxY(_slideMenu.frame), self.view.frame.size.width, self.view.frame.size.height- CGRectGetMaxY(_slideMenu.frame));
    _slideMenu.ckslideMenuDelegate = self;
    _slideMenu.bodySuperView = self.view;
    _slideMenu.indicatorOffsety = 0;
    _slideMenu.indicatorWidth = 25;
    _slideMenu.indicatorHeight = 3.0f;
    _slideMenu.lazyLoad = YES;
    _slideMenu.isFixed = YES;
    _slideMenu.font = [UIFont systemFontOfSize:16.0f];
    _slideMenu.indicatorStyle = SlideMenuIndicatorStyleStretch;
    _slideMenu.titleStyle = SlideMenuTitleStyleGradient;
    _slideMenu.selectedColor = [UIColor whiteColor];
    _slideMenu.unselectedColor = [UIColor whiteColor];
    _slideMenu.indicatorColor = UIColorFromRGB(0xFFF100);
    [self.view addSubview:_slideMenu];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
