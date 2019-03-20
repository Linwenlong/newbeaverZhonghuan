//
//  HouseCallRecordViewController.m
//  beaver
//
//  Created by 林文龙 on 2018/7/5.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "HouseCallRecordViewController.h"
#import "EBHouse.h"
#import "HouseCallRecordTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import "EBRecorderPlayer.h"

@interface HouseCallRecordViewController ()<UITableViewDelegate,UITableViewDataSource,AVAudioPlayerDelegate>

{
    int page;
    BOOL loadingHeader;
    NSTimer *_animationTimer;
}

@property (nonatomic, strong) UITableView * mainTableView;
@property (nonatomic, strong)NSMutableArray *dataArray;//数据
@property (nonatomic, strong)DefaultView *defaultView;


@property (nonatomic, weak) UIView * currentDurationTmp;
@property (nonatomic, assign) CGFloat  current_W;
@property (nonatomic, strong) AVAudioPlayer * audioPlayer;

@property (nonatomic, assign) NSInteger current_totle_time;//当前录音的总时间


@end

@implementation HouseCallRecordViewController


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
//    NSLog(@"duration1 = %f",_audioPlayer.duration);
//    NSLog(@"duration2 = %f",(_audioPlayer.currentTime/_audioPlayer.duration));
//    NSLog(@"duration3 = %f",(_audioPlayer.currentTime/_audioPlayer.duration)*_current_W);
//    [_currentDurationTmp setWidth_sd:((_audioPlayer.currentTime/_audioPlayer.duration)*_current_W)];
    [_currentDurationTmp setWidth_sd:((_audioPlayer.currentTime/_current_totle_time)*_current_W)];
//    _currentDurationTmp.width = ((_audioPlayer.currentTime/_audioPlayer.duration)*_current_W);
}

#pragma mark -- UITableViewDelegate UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HouseCallRecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *dic = _dataArray[indexPath.row];
    [cell setDic:dic];
    
    
    
    cell.playRecord = ^(UIView * currentDuration,UILabel *durationLable,UIImageView *icon){

        NSString *urlStr = @"call/getOnTape";
        __weak typeof(self) weakSelf = self;
        [EBAlert showLoading:@"加载中" allowUserInteraction:NO];

       NSLog(@"httpUrl = %@",[NSString stringWithFormat:@"%@/%@?token=%@&record_flag=%@",NewHttpBaseUrl,urlStr,[EBPreferences sharedInstance].token,[NSString stringWithFormat:@"%@",dic[@"record_flag"]]]);
        
        NSDictionary *parm = @{@"token":[EBPreferences sharedInstance].token,
                              @"record_flag":[NSString stringWithFormat:@"%@",dic[@"record_flag"]]
                               };
        NSLog(@"parm=%@",parm);
        [HttpTool post:urlStr parameters:parm
         
          success:^(id responseObject) {
               [EBAlert hideLoading];
            
               NSLog(@"class = %@",[responseObject class]);
//               NSLog(@"responseObject=%@",responseObject);
              
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
                                
                                _current_totle_time = [dic[@"play_time"] integerValue];
                                
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
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[EBRecorderPlayer sharedInstance]stopPlaying];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -- Lasy

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    return _mainTableView;
}

- (DefaultView *)defaultView{
    if (!_defaultView) {
        _defaultView = [[DefaultView alloc]initWithFrame:CGRectMake(0, 0, 250, 110)];
        _defaultView.center = self.mainTableView.center;
        _defaultView.top -= 40;
        _defaultView.placeView.image = [UIImage imageNamed:@"contract"];
        _defaultView.placeText.text = @"暂未获取到录音信息";
    }
    return _defaultView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
     _dataArray = [NSMutableArray array];
    self.title = [NSString stringWithFormat:@"通话录音-%@",self.houseDetail.contractCode];
    NSLog(@"houseDetail = %@",self.houseDetail);
    [self.view addSubview:self.mainTableView];
    
    [self refreshHeader];
    [self footerLoading];
    
    [_mainTableView registerClass:[HouseCallRecordTableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)requestData:(int)pageindex{
    
    
    NSString *urlStr = @"call/getDetailRecord";
    
    NSLog(@"urlData = %@",[NSString stringWithFormat:@"%@/call/getDetailRecord?token=%@&fk_id=%@&type=%@&page=%@&page_size=%@",NewHttpBaseUrl,[EBPreferences sharedInstance].token,_houseDetail.id,@"房源",[NSNumber numberWithInt:pageindex],[NSNumber numberWithInt:12]]);
    
    [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
    //    _dept_id
    __weak typeof(self) weakSelf = self;
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       @"fk_id":_houseDetail.id,
       @"type":@"房源",
       @"page":[NSNumber numberWithInt:pageindex],
       @"page_size":[NSNumber numberWithInt:12],

       } success:^(id responseObject) {
           [EBAlert hideLoading];
           
           if (  loadingHeader ==  YES) {
               [weakSelf.dataArray removeAllObjects];
              
           }
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"currentDic=%@",currentDic);
           NSArray *tmpArray = currentDic[@"data"][@"data"];//公告列表
           
           if ([currentDic[@"code"] integerValue] == 0) {
               for (NSDictionary *dic in tmpArray) {
                   [_dataArray addObject:dic];
               }
           }else{
               [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
           }
           
           if (_dataArray.count == 0) {//如果没有数据
               [weakSelf.mainTableView addSubview:self.defaultView];
           }else{
               if (weakSelf.defaultView) {
                   [weakSelf.defaultView  removeFromSuperview];
               }
           }
           
           [weakSelf.mainTableView.mj_header endRefreshing];
           
           if (tmpArray.count == 0) {
               [weakSelf.mainTableView.mj_footer endRefreshingWithNoMoreData];
               [weakSelf.mainTableView reloadData];
               return ;
           }else{
               [weakSelf.mainTableView.mj_footer endRefreshing];
           }
           [weakSelf.mainTableView reloadData];
           
       } failure:^(NSError *error) {
           [EBAlert hideLoading];
           [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
           [weakSelf.mainTableView.mj_footer endRefreshing];
           [weakSelf.mainTableView.mj_header endRefreshing];
       }];
    
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

@end
