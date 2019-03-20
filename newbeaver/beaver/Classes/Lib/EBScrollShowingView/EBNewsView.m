//
//  EBNewsView.m
//  beaver
//
//  Created by 凯文马 on 15/12/15.
//  Copyright © 2015年 eall. All rights reserved.
//

#import "EBNewsView.h"
#import "EBViewFactory.h"
#import "EBStyle.h"

CGFloat const EBNewsCellHeight = 70;

@interface EBNewsView () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) CGFloat timeInterval;

@end

@implementation EBNewsView


# pragma mark - init


- (instancetype)initWithFrame:(CGRect)frame{
    if (frame.size.height < EBNewsCellHeight) {
        frame.size.height = EBNewsCellHeight;
    }
    frame.size.width = [UIScreen mainScreen].bounds.size.width;
    if (self = [super initWithFrame:frame]) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.bounces = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_tableView];
        _timeInterval = 3.f;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _tableView.frame = CGRectMake(0, 0, self.width, EBNewsCellHeight);
    _tableView.centerY = self.height * 0.5f;
}

+ (instancetype)newsViewWithNews:(NSArray *)news timeInterval:(CGFloat)timeInterval clickAction:(EBNewsViewClickNewsBlock)clickAction
{
    EBNewsView *view = [[EBNewsView alloc] initWithFrame:CGRectZero];
    if (timeInterval) {
        view.timeInterval = timeInterval;
    }
    view.news = news;
    view.clickAction = clickAction;
    return view;
}

+ (instancetype)newsViewWithNews:(NSArray *)news clickAction:(EBNewsViewClickNewsBlock)clickAction
{
    return [self newsViewWithNews:news timeInterval:0 clickAction:clickAction];
}

- (void)setNews:(NSArray *)news
{
    if (news.count) {
        _news = news;
        self.index = 0;
        [self stopTimer];
//        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        [self startTimer];
    }

}

# pragma mark - Timer

- (void)startTimer
{
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(timeActions) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimer
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)timeActions
{
    self.index = self.index >= self.news.count - 1 ? 0 : self.index + 1;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
}

# pragma mark - UIScrollViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.news.count) {
        return 1;

    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EBNewsCell *cell = [EBNewsCell cellWithTableView:tableView news:self.news[self.index]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EBNewsCell *cell = (EBNewsCell *)[tableView cellForRowAtIndexPath:indexPath];
    EBNews *news = cell.news;
    if (self.clickAction) {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.clickAction(news);
        });
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return EBNewsCellHeight;
}


@end

@implementation EBNews

+ (instancetype)newsWithId:(NSNumber *)ID title:(NSString *)title info:(NSString *)info url:(NSString *)url
{
    EBNews *news = [[EBNews alloc] init];
    news.ID = ID;
    news.title = title;
    news.info = info;
    news.urlStr = url;
    return news;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"EBNews:id = %@,title = %@,info = %@,url = %@",self.ID,self.title,self.info,self.urlStr];
}

@end

@interface EBNewsCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *infoLabel;

@end

@implementation EBNewsCell

+ (EBNewsCell *)cellWithTableView:(UITableView *)tableView news:(EBNews *)news
{
    static NSString *ID = @"NewCell";
    EBNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[EBNewsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell initCell];
    }
    cell.news = news;
    return cell;
}

- (void)initCell
{
    CGFloat width = EBNewsCellHeight - 2 * 15;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, width, width)];
    imageView.image = [UIImage imageNamed:@"work_home_news_icon"];
    [self.contentView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.right + 15, imageView.top, [UIScreen mainScreen].bounds.size.width - 4 * 15 - imageView.width, [EBViewFactory textSize:@"a" font:[UIFont boldSystemFontOfSize:14] bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)].height)];
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textColor = [EBStyle blackTextColor];
    [self.contentView addSubview:label];
    self.titleLabel = label;
    
    CGFloat infoLabelHeight = [EBViewFactory textSize:@"a" font:[UIFont systemFontOfSize:12] bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)].height;
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(label.left, imageView.bottom - infoLabelHeight, label.width, infoLabelHeight)];
    infoLabel.font = [UIFont systemFontOfSize:12];
    infoLabel.textColor = [EBStyle blackTextColor];
    [self.contentView addSubview:infoLabel];
    self.infoLabel = infoLabel;
}

- (void)setNews:(EBNews *)news
{
    _news = news;
    self.titleLabel.text = news.title;
    self.infoLabel.text = news.info;
}

@end