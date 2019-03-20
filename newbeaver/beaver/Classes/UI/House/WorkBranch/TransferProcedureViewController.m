//
//  TransferProcedureViewController.m
//  beaver
//
//  Created by mac on 17/12/20.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "TransferProcedureViewController.h"
#import "ContractHeaderView.h"
#import "TransferStateController.h"
#import "TranferProcdureViewController.h"

@interface TransferProcedureViewController ()<ContractHeaderViewDelegate>


//过户
@property (nonatomic, strong)NSMutableArray *transferArr;

//贷款
@property (nonatomic, strong)NSMutableArray *loanArr;


@property (nonatomic, strong)ContractHeaderView *headerView;
@property (nonatomic, strong)UIScrollView *reafedScrollView;//下拉
@property (nonatomic, strong)UIScrollView *mainScrollView;//主滚动视图

@end

@implementation TransferProcedureViewController


- (UIScrollView *)reafedScrollView{
    if (!_reafedScrollView) {
        _reafedScrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
        //        _reafedScrollView.delegate = self;
    }
    return _reafedScrollView;
}

- (UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
        _mainScrollView.backgroundColor = [UIColor grayColor];
        //        _mainScrollView.delegate = self;
        _mainScrollView.pagingEnabled = YES;
        //        _mainScrollView.contentSize = CGSizeMake(kScreenW*2, 0);
    }
    return _mainScrollView;
}




- (void)viewDidLoad {
    [super viewDidLoad];

    
    _transferArr = [NSMutableArray array];
    _loanArr = [NSMutableArray array];
    
    //1.添加下拉视图
    [self.view addSubview:self.reafedScrollView];
    
    //1.添加主滚动视图
    [self.reafedScrollView addSubview:self.mainScrollView];

    //2.添加头部视图
    _headerView = [[ContractHeaderView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 52) leftTitle:@"过户详情" rightTitle:@"贷款详情"];
    _headerView.backgroundColor = [UIColor whiteColor];
    _headerView.contractDelegate = self;
    [self.reafedScrollView addSubview:_headerView];
    
    
    //发送请求
    [self requestData];
    
    
}

//收费详情
- (void)requestData{
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"%@/zhpay/NewDealTransfer?token=%@&deal_code=%@",NewHttpBaseUrl,[EBPreferences sharedInstance].token,_deal_code]);
    if (_deal_code == nil) {
        [EBAlert alertError:@"合同编号为空" length:2.0f];
        return;
    }
    NSString *urlStr = @"zhpay/NewDealTransfer";//需要替换下
    [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
    //    _dept_id
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       @"deal_code":_deal_code
       } success:^(id responseObject) {
           [EBAlert hideLoading];
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           
           NSArray *tmpArray = currentDic[@"data"][@"data"];
           NSLog(@"tmpArray=%@",tmpArray);
//           [self analysisData:tmpArray];
           if ([tmpArray isKindOfClass:[NSArray class]]) {//数组就解析数据
               [self analysisData:tmpArray];
           }else{
               [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
           }
           
       } failure:^(NSError *error) {
           [EBAlert hideLoading];
           [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
       }];
    
}

- (void)analysisData:(NSArray *)tmpArray{
    
    for (NSDictionary*dic in tmpArray) {
        if ([dic[@"group"] integerValue] == 1) {
            [_transferArr addObject:dic];
        }else{
            [_loanArr addObject:dic];
        }
    }
    
    //3.添加控制器
    for (int i=0; i < 2; i++) {
        TranferProcdureViewController *vc = [[TranferProcdureViewController alloc]init];
        vc.view.frame = CGRectMake(kScreenW*i, _headerView.height+1, kScreenW, kScreenH);
        if (i == 0) {
            vc.arr = _transferArr;
        }else{
            vc.arr = _loanArr;
        }
        [self addChildViewController:vc];
        
        [_mainScrollView addSubview:vc.view];
    }
    
}


#pragma mark -- ContractHeaderViewDelegate

-(void)currentBtn:(UIButton *)btn otherBtn:(UIButton *)otherBtn{
    CGPoint offset = self.mainScrollView.contentOffset;
    offset.x = self.mainScrollView.width * btn.tag;
    [self.mainScrollView setContentOffset:offset animated:YES];
    [UIView animateWithDuration:0.5 animations:^{
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        otherBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    }];
}

@end
