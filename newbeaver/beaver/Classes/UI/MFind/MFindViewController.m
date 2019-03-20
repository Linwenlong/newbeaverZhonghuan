//
//  MFindViewController.m
//  beaver
//  发现
//  Created by zhaoyao on 15/12/16.
//  Copyright © 2015年 eall. All rights reserved.
//

#import "MFindViewController.h"
#import "EBViewFactory.h"
#import "EBHttpClient.h"
#import "EBAlert.h"
#import "UIImageView+WebCache.h"
#import "EBPreferences.h"
#import "ERPWebViewController.h"
#import "UITabBar+badge.h"
#import "EBController.h"
CGFloat const EBFindCellHeight = 70;

@interface MFindViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *foundTableView;
@property (nonatomic, strong) NSArray *cellArray;

@end

@implementation MFindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发现";
    [self hiddenleftNVItem];
    [self createTableView];
    [self createData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.foundTableView) {
        [self createData];
    }
    [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_GATHER_FIND object:@{@"show":@"0"}]];
}
//隐藏左箭头
- (void)hiddenleftNVItem
{
    self.navigationItem.leftBarButtonItem=nil;
}
- (void)createTableView
{
    self.foundTableView = [[UITableView alloc]initWithFrame:[EBStyle fullScrTableFrame:YES] style:UITableViewStylePlain];
    self.foundTableView.delegate = self;
    self.foundTableView.dataSource = self;
    UIImageView *headerView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 1, 150)];
    [headerView sd_setImageWithURL:[NSURL URLWithString:[EBPreferences sharedInstance].foundListDatas[@"top_image"]] placeholderImage:nil];
    self.foundTableView.tableHeaderView = headerView;
    self.foundTableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:self.foundTableView];
}

- (void)createData
{
    __weak UITableView*tv=self.foundTableView;
    __weak typeof(self) weakSelf = self;
    [[EBHttpClient wapInstance] wapRequest:nil foundList:^(BOOL success, id result) {
        if (success) {
            weakSelf.cellArray = nil;
            [EBPreferences sharedInstance].foundListDatas = result;
            [[EBPreferences sharedInstance ] writePreferences];
            [tv reloadData];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.cellArray) {
        return self.cellArray.count;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    EBFindCell *cell = [EBFindCell cellWithTableview:tableView withItem:[self toItenWithDict:self.cellArray[indexPath.row]]];
    return cell;
}

- (foundItem *)toItenWithDict:(NSDictionary *)dict
{
    foundItem *item = [[foundItem alloc]init];
    item.image = dict[@"image"];
    item.des   = dict[@"des"];
    item.type  = dict[@"type"];
    item.tips  = dict[@"tips"];
    item.url   = dict[@"url"];
    return item;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return EBFindCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        EBFindCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.selected = NO;
        foundItem *item = [weakSelf toItenWithDict:weakSelf.cellArray[indexPath.row]];
        ERPWebViewController *erpVc = [ERPWebViewController sharedInstance];
        [erpVc openWebPage:@{@"title":item.type,@"url":item.url}];
        erpVc.hidesBottomBarWhenPushed = YES;
        [weakSelf.navigationController pushViewController:erpVc animated:YES];
    });
}

# pragma mark - getter

- (NSArray *)cellArray
{
    if (!_cellArray) {
        _cellArray = [EBPreferences sharedInstance].foundListDatas[@"data"];
        [(UIImageView *)_foundTableView.tableHeaderView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BEAVER_WAP_URL,[EBPreferences sharedInstance].foundListDatas[@"top_image"]]] placeholderImage:nil];
    }
    return _cellArray;
}

@end

@interface foundItem ()

@end

@implementation foundItem

+ (instancetype)itemWithImg:(NSString *)img title:(NSString *)title subInfo:(NSString *)info
{
    foundItem *item=[[foundItem alloc]init];
    item.image=img;
    item.type=title;
    item.des=info;
    return item;
}
@end

@interface EBFindCell ()
@property (nonatomic, strong) UIImageView*leftImageView;
@property (nonatomic, strong) UIView *tipsView;
@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UILabel *subInfoLabel;
@end
@implementation EBFindCell

+ (EBFindCell*)cellWithTableview:(UITableView*)tableview withItem:(foundItem*)item
{
    static NSString *ID = @"FindCell";
    EBFindCell *cell=[tableview dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell=[[EBFindCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        [cell initCell];
    }
    cell.items=item;
    return cell;
}
- (void)initCell
{
    CGFloat width = EBFindCellHeight - 2 * 15;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, width, width)];
    imageView.image = [UIImage imageNamed:@"work_home_news_icon"];
    [self.contentView addSubview:imageView];
    self.leftImageView = imageView;
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.right + 15, imageView.top, [UIScreen mainScreen].bounds.size.width - 4 * 15 - imageView.width, [EBViewFactory textSize:@"a" font:[UIFont boldSystemFontOfSize:14] bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)].height)];
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textColor = [EBStyle blackTextColor];
    [self.contentView addSubview:label];
    self.topLabel = label;
    
    UIView * labelRed = [[UIView alloc]initWithFrame:CGRectMake(label.frame.size.width, 0, 10, 10)];
    labelRed.centerY = label.top;
    labelRed.backgroundColor = [EBStyle redTextColor];
    labelRed.layer.cornerRadius = labelRed.frame.size.width/2;
    labelRed.layer.masksToBounds = YES;
    [self.contentView addSubview:labelRed];
    self.tipsView = labelRed;
    
    CGFloat infoLabelHeight = [EBViewFactory textSize:@"a" font:[UIFont systemFontOfSize:12] bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)].height;
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(label.left, imageView.bottom - infoLabelHeight, label.width, infoLabelHeight)];
    infoLabel.font = [UIFont systemFontOfSize:12];
    infoLabel.textColor = [EBStyle blackTextColor];
    [self.contentView addSubview:infoLabel];
    self.subInfoLabel = infoLabel;
}

- (void)setItems:(foundItem *)item
{
    _items = item;
    self.topLabel.width = [EBViewFactory textSize:item.type font:self.topLabel.font bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)].width;
    
    self.tipsView.left = self.topLabel.right+5;
    
    NSString *imageUrl = [NSString stringWithFormat:@"%@%@",BEAVER_WAP_URL,item.image];
    [self.leftImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil];
    self.topLabel.text = item.type;
    self.subInfoLabel.text = item.des;
    self.tipsView.alpha = [item.tips integerValue];
}
@end
