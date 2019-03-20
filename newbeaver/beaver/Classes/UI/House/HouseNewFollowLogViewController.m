//
//  HouseNewFollowLogViewController.m
//  beaver
//
//  Created by 林文龙 on 2018/8/22.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "HouseNewFollowLogViewController.h"
#import "HouseNewFollowLogRecordTableViewCell.h"
#import "HouseNewFollowLogRecordModel.h"
#import "HouseNewFollowLogTableViewCell.h"
#import "HouseNewFollowLogModel.h"
#import "EBRecorderPlayer.h"
#import "AddFollowLogViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface HouseNewFollowLogViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    int page;
    BOOL loadingHeader;
    NSTimer *_animationTimer;
}
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)UITableView *mainTableView;

@property (nonatomic, weak) UIView * currentDurationTmp;
@property (nonatomic, assign) CGFloat  current_W;
@property (nonatomic, strong) AVAudioPlayer * audioPlayer;

@property (nonatomic, assign) NSInteger current_totle_time;//当前录音的总时间

@end

@implementation HouseNewFollowLogViewController

- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH)];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        
        _mainTableView.estimatedRowHeight = 70.0f;
        
        _mainTableView.rowHeight = UITableViewAutomaticDimension;
    }
    return _mainTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"跟进记录";
    _dataArray = [NSMutableArray array];
    
    [self.view addSubview:self.mainTableView];
    
    [_mainTableView registerClass:[HouseNewFollowLogRecordTableViewCell class] forCellReuseIdentifier:@"recordcell"];
    [_mainTableView registerClass:[HouseNewFollowLogTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    [self refreshHeader];
    [self footerLoading];
    
    if (_houseDetail.follow)
    {
        [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_add"] target:self action:@selector(addFollowLog:)];
    }
    
}

- (void)addFollowLog:(UIButton*)btn
{
    [EBTrack event:EVENT_CLICK_HOUSE_MARKED_GJ_LIST_ADD];
    AddFollowLogViewController *viewController = [[AddFollowLogViewController alloc] init];
    viewController.isHouse = YES;
    viewController.house = _houseDetail;
    
    __weak typeof(self) wealself = self;
    
    viewController.complete = ^(){
        [wealself refreshHeader];
    };
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)footerLoading{
    self.mainTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        page += 1;
        loadingHeader = NO;
        [self requestData:page];
    }];
}
//刷新头部、、MJ
-(void)refreshHeader{
    self.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 1;
        loadingHeader = YES;
        [self requestData:page];//加载数据
    }];
    [self.mainTableView.mj_header beginRefreshing];
}

#pragma mark -- RequestData
- (void)requestData:(int)pageindex{
    [self.view endEditing:YES];
    
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"%@/house/follow?token=%@&page=%d&page_size=12&house_id=%@&type=sale",NewHttpBaseUrl,[EBPreferences sharedInstance].token,pageindex,_houseDetail.id]);
    NSString *urlStr = @"house/follow";
    [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
    
    NSString *type = @"";
    if (_houseDetail.rentalState == 1) {
        type = @"rent";
    }else if (_houseDetail.rentalState == 2){
        type = @"sale";
    }else{
        type = @"both";
    }
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       @"page":[NSNumber numberWithInt:pageindex],
       @"page_size":[NSNumber numberWithInt:12],
       @"house_id":_houseDetail.id,
       @"type":type
       }success:^(id responseObject) {
           [EBAlert hideLoading];
           //是否启用占位图
           _mainTableView.enablePlaceHolderView = YES;
           DefaultView *defaultView = (DefaultView *)_mainTableView.yh_PlaceHolderView;
           defaultView.placeView.image = [UIImage imageNamed:@"无详情"];
           defaultView.placeText.text = @"暂无详情数据";
           if (  loadingHeader ==  YES) {
               [self.dataArray removeAllObjects];
           }
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           NSLog(@"currentDic=%@",currentDic);
           NSDictionary *dic = currentDic[@"data"];
           
           NSArray *tmpArray = dic[@"follow"];

           
           for (NSDictionary *dic in tmpArray) {
  
               [_dataArray addObject:dic];
           }
           NSLog(@"tmpArray=%@",tmpArray);
           [self.mainTableView.mj_header endRefreshing];
           
           if (tmpArray.count == 0) {
               [self.mainTableView.mj_footer endRefreshingWithNoMoreData];
               [self.mainTableView reloadData];
               return ;
           }else{
               [self.mainTableView.mj_footer endRefreshing];
           }
           [self.mainTableView reloadData];
           
       } failure:^(NSError *error) {
           [EBAlert hideLoading];
           if (_dataArray.count == 0) {
               //是否启用占位图
               _mainTableView.enablePlaceHolderView = YES;
               DefaultView *defaultView = (DefaultView *)_mainTableView.yh_PlaceHolderView;
               defaultView.placeView.image = [UIImage imageNamed:@"数据获取失败"];
               defaultView.placeText.text = @"数据获取失败";
               [self.mainTableView reloadData];
           }
           [EBAlert alertError:@"请检查网络" length:2.0f];
           [self.mainTableView.mj_header endRefreshing];
           [self.mainTableView.mj_footer endRefreshing];
       }];
}

#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    
    NSDictionary *dic = _dataArray[indexPath.row];
    if ([dic[@"is_tel_record" ] integerValue] == 1) {
        HouseNewFollowLogRecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recordcell" forIndexPath:indexPath];
        [cell setDic:dic];
         cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.playRecord = ^(UIView * currentDuration,UILabel *durationLable,UIImageView *icon){
            
            NSString *urlStr = @"call/getOnTape";
            __weak typeof(self) weakSelf = self;
            [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
            
            NSLog(@"httpUrl = %@",[NSString stringWithFormat:@"%@/%@?token=%@&record_flag=%@",NewHttpBaseUrl,urlStr,[EBPreferences sharedInstance].token,[NSString stringWithFormat:@"%@",dic[@"c_record"][@"record_flag"]]]);
            
            NSDictionary *parm = @{@"token":[EBPreferences sharedInstance].token,
                                   @"record_flag":[NSString stringWithFormat:@"%@",dic[@"c_record"][@"record_flag"]]
                                   };
            NSLog(@"parm=%@",parm);
            [HttpTool post:urlStr parameters:parm
             
                   success:^(id responseObject) {
                       [EBAlert hideLoading];
                       
                       NSLog(@"class = %@",[responseObject class]);
//                       NSLog(@"responseObject=%@",responseObject);
                       
                       [[EBRecorderPlayer sharedInstance]playAudioData:responseObject withBlock:^(EBPlayerStatus status, NSDictionary *playerInfo) {
                           NSLog(@"status=%ld",status);
                           NSLog(@"playerInfo=%@",playerInfo);
                           
                           switch (status)
                           {
                               case EBPlayerStatusDownloading://正在下载
                               case EBPlayerStatusConverting:
                                   break;
                               case EBPlayerStatusPlaying://正在播放
                                   //播放获取播放器
                               {
                                   NSLog(@"current = %ld",[dic[@"play_time"] integerValue]);
                                   
                                   AVAudioPlayer *audioPlayer = playerInfo[@"player"];
                                   _audioPlayer = audioPlayer;
                                   _currentDurationTmp = currentDuration;
                                   icon.image = [UIImage imageNamed:@"hidden_player"];
                                   _current_W = kScreenW - 2*15- 60 - 5;
                                   
                                   _current_totle_time = [dic[@"c_record"][@"play_time"] integerValue];
                                   
                                   //                                durationLable.text = [NSString stringWithFormat:@"%0.02fs",audioPlayer.duration];
                                   [weakSelf startAnimationTimer];
                               }
                                   break;
                               case EBPlayerStatusFinished://播放完成
                               case EBPlayerStatusCanceled:
                               case EBPlayerStatusError://播放错误
                               {
                                   _currentDurationTmp.width = 0;
                                   icon.image = [UIImage imageNamed:@"hidden_noplayer"];
                                   [self stopAnimation];
                               }
                                   break;
                               default:
                                   break;
                           }
                       }];
                       
                   } failure:^(NSError *error) {
                       
                       NSLog(@"error=%@",error.userInfo);
                       NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
                       
                       NSLog(@"错误 = %@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
                       [EBAlert hideLoading];
                       [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
                   }];
        };
        
        return cell;
    }else{
        HouseNewFollowLogTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setDic:dic];
        return cell;
    }
}


- (void)stopAnimation
{
    if (_animationTimer)
    {
        [_animationTimer invalidate];
        _animationTimer = nil;
    }
    
    
}

- (void)startAnimationTimer
{
    if (_animationTimer)
    {
        [_animationTimer invalidate];
        _animationTimer = nil;
    }
    
    //    _animationCount = 0;
    _animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(playingAnimation) userInfo:nil repeats:YES];
    
}

- (void)playingAnimation
{
    //    NSLog(@"current = %f",_audioPlayer.currentTime);
//        NSLog(@"duration1 = %f",_audioPlayer.duration);
//        NSLog(@"duration2 = %f",(_audioPlayer.currentTime/_audioPlayer.duration));
//        NSLog(@"duration3 = %f",(_audioPlayer.currentTime/_audioPlayer.duration)*_current_W);
    //    [_currentDurationTmp setWidth_sd:((_audioPlayer.currentTime/_audioPlayer.duration)*_current_W)];
    
    [_currentDurationTmp setWidth_sd:((_audioPlayer.currentTime/_current_totle_time)*_current_W)];
    
    //    _currentDurationTmp.width = ((_audioPlayer.currentTime/_audioPlayer.duration)*_current_W);
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dic = _dataArray[indexPath.row];
    if ([dic[@"is_tel_record" ] integerValue] == 1) {
        return 160;
    }else{
        return 110;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}


@end
