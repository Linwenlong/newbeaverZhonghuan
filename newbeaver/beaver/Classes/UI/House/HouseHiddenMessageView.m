//
//  HouseHiddenMessageView.m
//  beaver
//
//  Created by 林文龙 on 2018/7/24.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "HouseHiddenMessageView.h"

@interface HouseHiddenMessageView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UIView * headerView;
@property (nonatomic, strong) UIImageView * icon;
@property (nonatomic, strong) UILabel * model_type_title;
@property (nonatomic, strong) UIButton * model_type;
@property (nonatomic, strong) UILabel * model_context_title;
@property (nonatomic, strong) UITextView * model_context;
@property (nonatomic, strong) UILabel * tip;
@property (nonatomic, strong) UIButton * submit;
@property (nonatomic, strong)ValuePickerView *pickerView;
@property (nonatomic, strong) UITableView * listTableView;

@property (nonatomic, strong) NSArray * dataArr;

@property (nonatomic, assign) CGFloat list_H;

@end

@implementation HouseHiddenMessageView

- (instancetype)initWithFrame:(CGRect)frame withTempate:(NSArray *)temPate{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5.0f;
        self.dataArr = temPate;
        self.pickerView = [[ValuePickerView alloc]initShowClear:NO];
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5.0f;
        self.pickerView = [[ValuePickerView alloc]initShowClear:NO];
        [self setUI];
    }
    return self;
}

- (void)imageClick:(UITapGestureRecognizer *)tap{
    self.imageClick();
}

- (void)modelClick:(UIButton *)btn{

    self.modelClick(btn,_listTableView,_list_H);
}
- (void)submitClick:(UIButton *)btn{
    self.submitClick(btn,_model_type,_model_context);
}

- (void)setUI{
    
    _headerView = [UIView new];
//    _headerView.backgroundColor = [UIColor redColor];
    
    UILabel *titleLable = [UILabel new];
    titleLable.font = [UIFont systemFontOfSize:16.0f];
    titleLable.textAlignment = NSTextAlignmentRight;
    titleLable.textColor = [UIColor colorWithRed:0.24 green:0.45 blue:0.75 alpha:1.00];
    titleLable.text = @"隐号发送短信";
    
    _icon = [UIImageView new];
    _icon.image = [UIImage imageNamed:@"hidden_chacha"];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClick:)];
    _icon.userInteractionEnabled = YES;
    [_icon addGestureRecognizer:tap];
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = [UIColor colorWithRed:0.24 green:0.45 blue:0.75 alpha:1.00];
//    _icon.backgroundColor = [UIColor redColor];
    
    _model_type_title = [UILabel new];
    _model_type_title.font = [UIFont systemFontOfSize:14.0f];
    _model_type_title.textAlignment = NSTextAlignmentRight;
    NSString *oldStr1 = @"*短信模版";
    
    NSMutableAttributedString * context_title1 = [[NSMutableAttributedString alloc]initWithString:oldStr1];
    [context_title1 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.99 green:0.29 blue:0.42 alpha:1.00] range:NSMakeRange(0, 1)];
    [context_title1 addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(1, oldStr1.length-1)];
    
    _model_type_title.attributedText = context_title1;
    
    _model_type = [UIButton new];
    _model_type.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [_model_type setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [_model_type setTitle:@"" forState:UIControlStateNormal];
    _model_type.layer.borderColor = [UIColor colorWithRed:0.87 green:0.89 blue:0.93 alpha:1.00].CGColor;
    _model_type.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _model_type.layer.borderWidth = 1.0f;
    _model_type.layer.cornerRadius = 2.0f;
    [_model_type addTarget:self action:@selector(modelClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _model_context_title = [UILabel new];
    _model_context_title.font = [UIFont systemFontOfSize:14.0f];
    _model_context_title.textAlignment = NSTextAlignmentRight;
    NSString *oldStr = @"*短信内容";
    NSMutableAttributedString * context_title = [[NSMutableAttributedString alloc]initWithString:oldStr];
    [context_title addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.99 green:0.29 blue:0.42 alpha:1.00] range:NSMakeRange(0, 1)];
    [context_title addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(1, oldStr.length-1)];
    _model_context_title.attributedText = context_title;
    
    
    _model_context = [UITextView new];
    _model_context.layer.borderColor = [UIColor colorWithRed:0.87 green:0.89 blue:0.93 alpha:1.00].CGColor;
    _model_context.layer.borderWidth = 1.0f;
    _model_context.layer.cornerRadius = 2.0f;
    _model_context.font = [UIFont systemFontOfSize:15.0f];

    
    _tip = [UILabel new];
    _tip.textColor = UIColorFromRGB(0xff3800);

    _tip.text = @"提醒：若手动输入短信内容，请不要包含“{ } \\ / [ ]”等特殊字符";
    _tip.numberOfLines = 0;
    _tip.font  =[UIFont systemFontOfSize:13.0f];
    _tip.textAlignment = NSTextAlignmentLeft;
    
    _submit = [UIButton new];
    [_submit setTitle:@"提交" forState:UIControlStateNormal];
    [_submit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _submit.backgroundColor = [UIColor colorWithRed:0.24 green:0.45 blue:0.75 alpha:1.00];
    _submit.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    _submit.layer.cornerRadius = 3.0f;
    [_submit addTarget:self action:@selector(submitClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _listTableView = [UITableView new];
    _listTableView.backgroundColor = [UIColor redColor];
    _listTableView.hidden = YES;
    _listTableView.dataSource = self;
    _listTableView.delegate = self;
    _listTableView.bounces = NO;
    _listTableView.layer.cornerRadius = 2.0f;
    _listTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [_listTableView setSeparatorInset:UIEdgeInsetsZero];
    [_listTableView setLayoutMargins:UIEdgeInsetsZero];
    _listTableView.separatorColor = UIColorFromRGB(0xe8e8e8);
    
    _listTableView.layer.shadowColor = [UIColor colorWithRed:0.71 green:0.71 blue:0.71 alpha:1.00].CGColor;
    _listTableView.layer.shadowOffset = CGSizeMake(6, 6);
    _listTableView.layer.shadowOpacity = 1.0f;
    _listTableView.clipsToBounds = false;
    
    [_listTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self sd_addSubviews:@[_headerView,_model_type_title,_model_type,_model_context_title,_model_context,_listTableView,_tip,_submit]];
    
    [_headerView sd_addSubviews:@[titleLable,_icon,lineView]];
    
    
    CGFloat x = 10;
    CGFloat y = 30;
    CGFloat spacing = 10;
    CGFloat h = 30;
    
    _headerView.sd_layout
    .leftSpaceToView(self, 0)
    .rightSpaceToView(self, 0)
    .topSpaceToView(self, 0)
    .heightIs(50);
    
    titleLable.sd_layout
    .leftSpaceToView(_headerView, 10)
    .topSpaceToView(_headerView, 10)
    .widthIs(100)
    .heightIs(30);
    
    _icon.sd_layout
    .topSpaceToView(_headerView, 10)
    .rightSpaceToView(_headerView, 10)
    .widthIs(20)
    .heightIs(20);
    
    lineView.sd_layout
    .leftSpaceToView(_headerView, 0)
    .rightSpaceToView(_headerView, 0)
    .bottomSpaceToView(_headerView, 0)
    .heightIs(2);
    
    _model_type_title.sd_layout
    .topSpaceToView(_headerView, y)
    .leftSpaceToView(self, 0)
    .widthIs(80)
    .heightIs(h);
    
    _model_type.sd_layout
    .topSpaceToView(_headerView, y)
    .leftSpaceToView(_model_type_title, 5)
    .rightSpaceToView(self, x)
    .heightIs(h);
    
//    _listTableView.sd_layout
//    .topSpaceToView(_model_type, 0)
//    .leftEqualToView(_model_type)
//    .rightSpaceToView(self, x)
//    .heightIs(200);
    
    _model_context_title.sd_layout
    .topSpaceToView(_model_type_title, spacing)
    .leftSpaceToView(self, 0)
    .widthIs(80)
    .heightIs(h);
    
    _model_context.sd_layout
    .topSpaceToView(_model_type_title, spacing)
    .leftSpaceToView(_model_context_title, 5)
    .rightSpaceToView(self, x)
    .heightIs(150);
    
    _tip.sd_layout
    .topSpaceToView(_model_context, 10)
    .leftSpaceToView(self, x)
    .rightSpaceToView(self, x)
    .heightIs(40);

    _submit.sd_layout
    .topSpaceToView(_tip, 20)
    .centerXEqualToView(self)
    .widthIs(100)
    .heightIs(30);
    
    //列表
    
    _listTableView.frame = CGRectMake(85, 110, self.width - 85 - 10, 160);
    if (_dataArr.count < 4) {
        _listTableView.height = _dataArr.count * 40;
    }else{
        _listTableView.height = 160;
    }
    
    _list_H = _listTableView.height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary *dic = _dataArr[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",dic[@"model_type"]];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _listTableView.hidden = YES;
    NSDictionary *dic = _dataArr[indexPath.row];
    
     [_model_type setTitle:dic[@"model_type"] forState:UIControlStateNormal];
    
    if ([dic[@"model_type"] isEqualToString:@"手动输入"]) {
        _model_context.userInteractionEnabled = YES;
        _model_context.text = @"";
        
        [_model_context becomeFirstResponder];//成为第一响应
    }else{
        _model_context.text = dic[@"model_context"];
        _model_context.userInteractionEnabled = NO;
        [_model_context resignFirstResponder];//放弃第一响应
    }
}

@end
