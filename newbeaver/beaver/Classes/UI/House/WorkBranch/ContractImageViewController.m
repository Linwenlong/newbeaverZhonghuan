//
//  ContractImageViewController.m
//  beaver
//
//  Created by mac on 17/12/19.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "ContractImageViewController.h"
#import "UIImageView+WebCache.h"
#import "FSBasicImageSource.h"
#import "FSImageViewerViewController.h"
#import "FSBasicImage.h"

@interface ContractImageViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong)UICollectionView * collectionView;
@property (nonatomic, strong)NSMutableArray *dataArray;//数据
@property (nonatomic, strong)DefaultView *defaultView;

@end

@implementation ContractImageViewController

- (DefaultView *)defaultView{
    if (!_defaultView) {
        _defaultView = [[DefaultView alloc]initWithFrame:CGRectMake(0, 0, 250, 110)];
        _defaultView.center = self.collectionView.center;
        _defaultView.top -= 40;
        _defaultView.placeView.image = [UIImage imageNamed:@"contract"];//需要更换
        _defaultView.placeText.text = @"暂无图片信息...";
    }
    return _defaultView;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 24);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH- 64 - 40) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
    }
    return _collectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataArray = [NSMutableArray array];
    [self.view addSubview:self.collectionView];
    [self requestData];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
}

- (void)requestData{
    
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"%@/zhpay/NewDealImg?token=%@&deal_code=%@",NewHttpBaseUrl,[EBPreferences sharedInstance].token,@"CTR173533971008"]);
    NSString *urlStr = @"zhpay/NewDealImg";//需要替换下
    [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
    //_dept_id
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       @"deal_code":_deal_code
       } success:^(id responseObject) {
           [EBAlert hideLoading];
        NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           NSLog(@"currentDic=%@",currentDic);
           NSArray *tmpArray = currentDic[@"data"][@"url"];//公告列表
           NSLog(@"tmpArray=%@",tmpArray);
           
           if (tmpArray.count == 0) {//如果没有数据
               [self.collectionView addSubview:self.defaultView];
           }else{
               if (self.defaultView) {
                   [self.defaultView  removeFromSuperview];
               }
           }
           
           if ([currentDic[@"code"] integerValue] == 0) {
               for (NSDictionary *dic in tmpArray) {
                   [_dataArray addObject:dic];
               }
           }else{
               [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
           }
           
           [self.collectionView reloadData];
       } failure:^(NSError *error) {
           [EBAlert hideLoading];
           [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
       }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark -- UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = _dataArray[indexPath.row];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:1.00];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:cell.contentView.bounds];
    NSLog(@"imgUrl=%@",dic[@"imgUrl"]);
    [imageView sd_setImageWithURL:[NSURL URLWithString:dic[@"imgUrl"]] placeholderImage:nil];
    [cell.contentView addSubview:imageView];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"点击了某个");
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    //进入新的图片控制器
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    for (NSDictionary *dic  in _dataArray)
    {
        [photos addObject:[[FSBasicImage alloc] initWithImageURL:[NSURL URLWithString:dic[@"imgUrl"]] name:nil]];
    }
    FSBasicImageSource *photoSource = [[FSBasicImageSource alloc] initWithImages:photos];
    FSImageViewerViewController *controller = [[FSImageViewerViewController alloc] initWithImageSource:photoSource imageIndex:indexPath.row];
    controller.fixTitle = @"图片详情";
    [self.parentViewController.navigationController pushViewController:controller animated:YES];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((kScreenW-60)/2.0f, (kScreenW-60)/2.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 15, 10, 15);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 24;
}

//进入图片控制器






@end
