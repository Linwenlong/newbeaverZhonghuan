//
//  ZHCheckController.m
//  财务收款项目
//
//  Created by 刘海伟 on 2017/11/26.
//  Copyright © 2017年 liuhaiwei. All rights reserved.
//
//  "查看"控制器

#import "ZHCheckController.h"
#import "ZHCheckOneCell.h"
#import "ZHCheckTwoCell.h"
#import "UIBarButtonItem+Extension.h"
#import "ZHCover.h"
#import "ZHPopMenu.h"
#import "ZHFundEditController.h"
#import "HWPopTool.h"


#define RGB(r,g,b) [UIColor colorWithRed:r/ 255.0 green:g/ 255.0 blue:b/ 255.0 alpha:1.0]
#define SCReenWidth [UIScreen mainScreen].bounds.size.width
#define SCReenHeirht [UIScreen mainScreen].bounds.size.height

@interface ZHCheckController ()<ZHCoverDelegate>

@property (nonatomic, strong) ZHCover *cover;
/** 实收列表及实收详情list */
@property (nonatomic, strong) NSMutableArray *recordArray;

@property (nonatomic, strong)UITableView *mainTableView;

@property (nonatomic, copy) NSString *token;

@property (nonatomic,strong) UIView *popView;
@property (nonatomic,strong) UIImageView *qrImageView;

@end

@implementation ZHCheckController


-(ZHCover *)cover {
    if (_cover == nil) {
        _cover = [[ZHCover alloc] init];
    }
    return _cover;
}
- (NSMutableArray *)recordArray {
    if (_recordArray == nil) {
        _recordArray = [NSMutableArray array];
    }
    return _recordArray;
}
- (NSDictionary *)checkDic {
    if (_checkDic == nil) {
        _checkDic = [NSDictionary dictionary];
    }
    return _checkDic;
}
- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH- 64) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _mainTableView.backgroundColor = RGB(244, 245, 246);
        //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        //解决tableview的分割线短一截
        if ([_mainTableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([_mainTableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
        }
    }
    return _mainTableView;
}


#pragma mark -- 初始化

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"查看";
    [self.view addSubview:self.mainTableView];
//    self.tableView.tableFooterView = [[UIView alloc] init];
//    self.tableView.rowHeight = 44;
//    self.tableView.backgroundColor = RGB(244, 245, 246);
//    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    
//    //解决tableview的分割线短一截
//    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
//        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
//    }
//    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
//        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
//    }
    
    //1.0 设置导航栏
    [self setUpNavgationBar];
    
}

#pragma mark -- 1.0 设置导航栏
- (void)setUpNavgationBar {    
    UIBarButtonItem *rightItemOne = [UIBarButtonItem itemWithImage:@"edit" highImage:nil target:self action:@selector(rightItemEdit)];
    rightItemOne.customView.width = 25;
    UIBarButtonItem *rightItemTwo = [UIBarButtonItem itemWithImage:@"garbage" highImage:nil target:self action:@selector(rightItemDelete)];
    rightItemTwo.customView.width = 20;
    UIBarButtonItem *rightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    rightSpace.width = -5;
    self.navigationItem.rightBarButtonItems = @[rightSpace,rightItemOne,rightItemTwo];

}
//导航栏上item事件的监听
- (void)leftItemBack {
    NSLog(@"点击了返回");
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark -- 编辑
- (void)rightItemEdit {
    
    if (![self.checkDic[@"order_no"] isEqualToString:@""]) {
        [[[UIAlertView alloc]initWithTitle:@"提示" message:@"该笔费用已生成订单,不允许编辑" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        return;
    }
    ZHFundEditController *editVC = [[ZHFundEditController alloc] init];
    editVC.hidesBottomBarWhenPushed = YES;
    editVC.checkDic = self.checkDic;
    editVC.deal_id = self.deal_id;
    editVC.deal_type = self.deal_type;
    editVC.vcTag = 1;
    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)rightItemDelete {
    
    if ([self.checkDic[@"order_no_status"] isEqualToString:@"已支付"]) {
        [[[UIAlertView alloc]initWithTitle:@"提示" message:@"该笔费用已支付,不允许删除" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确认删除这条实收信息" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //NSLog(@"点击了确定");
        //点击删除确认, 发起删除实收请求
        [self loadDeleteRequest];
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- 点击删除确认, 发起删除实收请求
- (void)loadDeleteRequest {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = [EBPreferences sharedInstance].token;
    params[@"document_id"] = self.checkDic[@"document_id"];  //实收数据主键ID
    params[@"user_id"] = [[EBPreferences sharedInstance].userId componentsSeparatedByString:@"_"].lastObject;  //当前操作人ID
    [HttpTool post:@"zhpay/collectPayDel" parameters:params success:^(id responseObject) {
        [EBAlert hideLoading];
        NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"currentDic=%@",currentDic);
        if ([currentDic[@"code"] integerValue] == 0) {
            [EBAlert alertSuccess:@"删除成功" length:2.0f];
            [self.navigationController popViewControllerAnimated:YES];
            self.returnBlock();
        }else{
            if ([currentDic.allKeys containsObject:@"desc"]) {
                [EBAlert alertError:currentDic[@"desc"] length:2.0f];
            }
        }
    } failure:^(NSError *error) {
        [EBAlert alertError:@"网络繁忙,请稍后再试" length:2.0f];
    }];
}

#pragma mark -- tableView的数据源和代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
        
    } else {
        return 9;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        ZHCheckOneCell *cell = [ZHCheckOneCell cellWithTableView:tableView];
        
        cell.titleLbl.text = [NSString stringWithFormat:@"%@",self.checkDic[@"order_no_status"]];
        
        //设置title的文字大小和颜色
        cell.titleLbl.font = [UIFont systemFontOfSize:14];
        
        if ([self.checkDic[@"order_no_status"] isEqualToString:@"未支付"]) {
            cell.titleLbl.textColor = RGB(46, 178, 239);
        }else{
            cell.titleLbl.textColor = RGB(128, 128, 128);
        }
        if ([self.checkDic[@"order_no"] isEqualToString:@""]) {
            cell.barCodeImgIcon.image = [UIImage imageNamed:@"ashcode"];
        } else {
            cell.barCodeImgIcon.image = [UIImage imageNamed:@"bulecode"];
        }
        
        cell.barCodeImgIcon.userInteractionEnabled = YES;
        //添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTap:)];
        [cell.barCodeImgIcon addGestureRecognizer:tap];
        
        //把单元格点击时状态 改为None
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
        
    } else {
        ZHCheckTwoCell *cell = [ZHCheckTwoCell cellWithTableView:tableView];
        
        //设置标题和内容的文字颜色大小
        cell.titleLbl.font = [UIFont systemFontOfSize:14];
        cell.titleLbl.textColor = RGB(64, 64, 64);
        cell.contentLbl.font = [UIFont systemFontOfSize:13];
        cell.contentLbl.textColor = RGB(128, 128, 128);
        
        if (indexPath.row == 0) {
            cell.titleLbl.text = @"收付类型";
            cell.contentLbl.text = [NSString stringWithFormat:@"%@",self.checkDic[@"price_charge"]];
            
        } else if (indexPath.row == 1) {
            cell.titleLbl.text = @"缴费方式";
            cell.contentLbl.text = [NSString stringWithFormat:@"%@",self.checkDic[@"price_way"]];
            
        } else if (indexPath.row == 2) {
            cell.titleLbl.text = @"刷卡手续费(元)";
            cell.contentLbl.text = [NSString stringWithFormat:@"%@",self.checkDic[@"credit_card_fees"]];
            cell.contentLbl.textColor = RGB(254, 56, 0);
            
        } else if (indexPath.row == 3) {
            cell.titleLbl.text = @"费用类型";
            cell.contentLbl.text = [NSString stringWithFormat:@"%@",self.checkDic[@"price_type"]];
            
        } else if (indexPath.row == 4) {
            cell.titleLbl.text = @"费用名称";
            cell.contentLbl.text = [NSString stringWithFormat:@"%@",self.checkDic[@"price_name"]];
            
        } else if (indexPath.row == 5) {
            cell.titleLbl.text = @"缴费人";
            cell.contentLbl.text = [NSString stringWithFormat:@"%@",self.checkDic[@"fee_user"]];
            
        } else if (indexPath.row == 6) {
            cell.titleLbl.text = @"收款金额(元)";
            cell.contentLbl.text = [NSString stringWithFormat:@"%@",self.checkDic[@"price_num"]];
            cell.contentLbl.textColor = RGB(254, 56, 0);
            
        } else if (indexPath.row == 7) {
            cell.titleLbl.text = @"收款日期";
            
            NSString *time = [NSString stringWithFormat:@"%@",self.checkDic[@"finance_date"]];
            cell.contentLbl.text = [self timeWithTimeIntervalString:time];
            
        } else if (indexPath.row == 8) {
            cell.titleLbl.text = @"备注";
            cell.contentLbl.text = [NSString stringWithFormat:@"%@",self.checkDic[@"memo"]];
        }
        
        //把单元格点击时状态 改为None
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
}

- (void)QRCode:(NSString *)order_no{
    //先生成视图
    _popView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW-60, 180)];;
    _popView.backgroundColor = [UIColor whiteColor];
    _popView.layer.cornerRadius = 7.0f;
    _qrImageView = [UIImageView new];
    [_popView addSubview:_qrImageView];
    UILabel *lable = [UILabel new];
    lable.text = order_no;
    lable.font = [UIFont systemFontOfSize:18.0f];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.textColor = UIColorFromRGB(0x404040);
    [_popView addSubview:lable];
    
    _qrImageView.sd_layout
    .topSpaceToView(_popView,20)
    .leftSpaceToView(_popView,20)
    .rightSpaceToView(_popView,20)
    .heightIs(100);
    
    lable.sd_layout
    .topSpaceToView(_qrImageView,10)
    .leftSpaceToView(_popView,0)
    .rightSpaceToView(_popView,0)
    .heightIs(40);
    
    //动画弹窗
    MyViewController *vc = [[HWPopTool sharedInstance] showWithPresentView:_popView animated:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closePop:)];
    vc.styleView.userInteractionEnabled = YES;
    [vc.styleView addGestureRecognizer:tap];
    
    CIImage *ciImage = [self generateBarCodeImage:order_no];
    UIImage *image = [self resizeCodeImage:ciImage withSize:CGSizeMake((self.view.frame.size.width - 100), 80)];
    
    if (image) {
        _qrImageView.image = image;
    }
    
}

- (void)closePop:(UITapGestureRecognizer *)tap{
    [[HWPopTool sharedInstance]closeWithBlcok:^{
        NSLog(@"已经关闭");
    }];
}


// 条形码点击手势的监听
- (void)imgTap:(UIGestureRecognizer *)recognizer {
    //NSLog(@"点击了条形码");
    if ([_checkDic[@"order_no"] isEqualToString:@""]) {
        [[[UIAlertView alloc]initWithTitle:@"提示" message:@"请先进行生成订单号操作" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        return;
    }else{
        if ([_checkDic[@"order_no_status"] isEqualToString:@"已支付"]) {
            [[[UIAlertView alloc]initWithTitle:@"提示" message:@"该笔费用已支付" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
            return;
        }else{
            NSString *order_no = _checkDic[@"order_no"];
            [self QRCode:order_no];
        }
    }
//    NSString *order_no = _checkDic[@"order_no"];
//    [self QRCode:order_no];
}



// 点击蒙板的时候调用
- (void)coverDidClickCover:(ZHCover *)cover {
    // 隐藏pop菜单
    [ZHPopMenu hide];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 8;
        
    } else {
        return 0.001;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headView = [[UIView alloc] init];
    headView.backgroundColor = RGB(244, 245, 246);
    
    return headView;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = RGB(244, 245, 246);
    
    return footerView;
}

//然后在重写willDisplayCell方法
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSString *)timeWithTimeIntervalString:(NSString *)timeString
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}



- (CIImage *) generateBarCodeImage:(NSString *)source
{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        NSData *data = [source dataUsingEncoding: NSASCIIStringEncoding];
        CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
        [filter setValue:data forKey:@"inputMessage"];
        
        [filter setValue:[NSNumber numberWithInteger:0] forKey:@"inputQuietSpace"];
        return filter.outputImage;
    }else{
        return nil;
    }
}

- (UIImage *) resizeCodeImage:(CIImage *)image withSize:(CGSize)size
{
    if (image) {
        CGRect extent = CGRectIntegral(image.extent);
        CGFloat scaleWidth = size.width/CGRectGetWidth(extent);
        CGFloat scaleHeight = size.height/CGRectGetHeight(extent);
        size_t width = CGRectGetWidth(extent) * scaleWidth;
        size_t height = CGRectGetHeight(extent) * scaleHeight;
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
        CGContextRef contentRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef imageRef = [context createCGImage:image fromRect:extent];
        CGContextSetInterpolationQuality(contentRef, kCGInterpolationNone);
        CGContextScaleCTM(contentRef, scaleWidth, scaleHeight);
        CGContextDrawImage(contentRef, extent, imageRef);
        CGImageRef imageRefResized = CGBitmapContextCreateImage(contentRef);
        CGContextRelease(contentRef);
        CGImageRelease(imageRef);
        return [UIImage imageWithCGImage:imageRefResized];
    }else{
        return nil;
    }
}


@end












