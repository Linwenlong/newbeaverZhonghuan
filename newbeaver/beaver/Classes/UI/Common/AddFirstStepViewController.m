//
//  AddFirstStepViewController.m
//  beaver
//
//  Created by LiuLian on 7/31/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "AddFirstStepViewController.h"
#import "EBCache.h"
#import "EBBusinessConfig.h"
#import "EBInputElement.h"
#import "EBInputView.h"
#import "EBSelectElement.h"
#import "EBSelectView.h"
#import "EBCheckView.h"
#import "EBRadioGroup.h"
#import "EBElementStyle.h"
#import "UIActionSheet+Blocks.h"
#import "EBAlert.h"

@interface AddFirstStepViewController () <EBElementViewDelegate, EBSelectViewDelegate, EBInputViewDelegate, EBCheckViewDelegate>
{
    UIToolbar *_toolbar;
    UIBarButtonItem *_previousBarButton;
    UIBarButtonItem *_nextBarButton;
    EBElementView *_currentElementView;
    NSMutableArray *_inputViews;
    
    BOOL backAlert;
}
@end

@implementation AddFirstStepViewController
@synthesize addType, purpose, scrollView, wantNew, wantRadioGroup, accessoryRadioGroup, containerView, nameInputView, nameSelectView, telInputView, telSelectView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = purpose;
    if (_actionType == EBEditTypeAdd)
    {
        [self addRightNavigationBtnWithTitle:NSLocalizedString(@"btn_process_next_title", nil) target:self action:@selector(nextStep)];
    }
    else
    {
        [self addRightNavigationBtnWithTitle:NSLocalizedString(@"btn_process_done_title", nil) target:self action:@selector(endEdit)];
    }
    
    scrollView = [[UIScrollView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    [scrollView setContentOffset:CGPointMake(0, 0)];
//    UITapGestureRecognizer *scrollTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollTap:)];
//    [scrollView addGestureRecognizer:scrollTapGes];
    
    [self.view addSubview:scrollView];
    
    if (!addType) {
        NSMutableArray *tmparr =[NSMutableArray arrayWithArray:[[EBCache sharedInstance] businessConfig].houseConfig.wantNew];
//        wantNew = [[EBCache sharedInstance] businessConfig].houseConfig.wantNew;
        NSLog(@"wantNew = %@",tmparr);
        for (NSDictionary *dic in tmparr) {
            //存在移除
            if ([dic[@"value"] isEqualToString:@"sale_rent"]) {
                [tmparr removeObject:dic];
            }
        }
        wantNew = tmparr;
    } else {
        wantNew = [[EBCache sharedInstance] businessConfig].clientConfig.wantNew;
    }
    _inputViews = [NSMutableArray new];
    [self initToolbar];
    
    [self initViews];
    
    [self initInputViews];
}

//- (void)scrollTap:(UITapGestureRecognizer *)sender
//{
//    [nameInputView.inputTextField resignFirstResponder];
//    [telInputView.inputTextField resignFirstResponder];
//    [UIView animateWithDuration:0.5 animations:^{
//        [scrollView setContentOffset:CGPointMake(0, 0)];
//    }];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)initViews
{
    CGFloat dx = 30, dy = 20;
    
    if (wantNew.count > 0) {
        wantRadioGroup = [[EBRadioGroup alloc] initWithFrame:CGRectMake(dx, dy, scrollView.width-dx, 44.0)];
        NSMutableArray *radioNames = [NSMutableArray new];
        for (NSDictionary *dic in wantNew) {
            [radioNames addObject:@{@"title": dic[@"name"], @"value": dic[@"value"]}];
            
        }
        wantRadioGroup.radios = radioNames;
        __weak AddFirstStepViewController *weakSelf = self;
        wantRadioGroup.checkBlock = ^(NSInteger checkedIndex) {
            AddFirstStepViewController *strongSelf = weakSelf;
            [strongSelf resetAccessoryRadioGroup:checkedIndex];
            [strongSelf setBackAlert:YES];
        };
        [scrollView addSubview:wantRadioGroup];
        
        dy += wantRadioGroup.height + 4;
        
        [self resetAccessoryRadioGroup:0];
        if (accessoryRadioGroup) {
            dy += accessoryRadioGroup.height + 6;
        }
    }
    
    containerView = [[UIView alloc] initWithFrame:CGRectMake(dx, dy, scrollView.width-dx, 88.0)];
    [scrollView addSubview:containerView];
    
    dy += containerView.height + 6;
}

#pragma mark -
#pragma init views

- (void)initInputViews
{
    CGFloat dx = 30;
    
    EBElementStyle *style = [EBElementStyle defaultStyle];
    EBInputElement *nameInputElement = [EBInputElement new];
    nameInputElement.placeholder = !addType ? NSLocalizedString(@"search_house_5", nil): NSLocalizedString(@"search_client_2", nil);
    nameInputElement.star = EBElementViewStarVisible;
    nameInputView = [[EBInputView alloc] initWithStyle:CGRectMake(0, 0, (containerView.width-dx)*2/3, containerView.height/2) element:nameInputElement style:style];
//    nameInputView.inputTextField.delegate = self;
    [containerView addSubview:nameInputView];
    [nameInputView drawView];
    [nameInputView setToolbar:_toolbar];
    [nameInputView showInView:scrollView];
    nameInputView.delegate = self;
    [_inputViews addObject:nameInputView];
    
    NSArray *nameOptions = [[EBCache sharedInstance] businessConfig].houseConfig.appellations;
    if (!nameOptions || nameOptions.count == 0) {
        nameInputView.frame = CGRectMake(nameInputView.left, nameInputView.top, containerView.width, nameInputView.height);
        [nameInputView setNeedsLayout];
    } else {
        EBSelectElement *nameSelectElement = [EBSelectElement new];
        nameSelectElement.options = nameOptions;
        nameSelectElement.placeholder = NSLocalizedString(@"hint_select_appellation", nil);
        nameSelectView = [[EBSelectView alloc] initWithStyle:CGRectMake(nameInputView.left+nameInputView.width+dx, 0, containerView.width-(nameInputView.left+nameInputView.width+dx), containerView.height/2) element:nameSelectElement style:style];
        nameSelectView.delegate = self;
        [containerView addSubview:nameSelectView];
        [nameSelectView drawView];
    }
    
    EBInputElement *telInputElement = [EBInputElement new];
    telInputElement.placeholder = !addType ? NSLocalizedString(@"search_house_0", nil) : NSLocalizedString(@"search_client_0", nil);
    telInputElement.inputType = EBElementInputTypePhone;
    telInputElement.star = EBElementViewStarVisible;
    telInputElement.reg = @"((\\d{11})|^((\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1})|(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1}))$)";
    telInputView = [[EBInputView alloc] initWithStyle:CGRectMake(0, containerView.height/2, (containerView.width-dx)*2/3, containerView.height/2) element:telInputElement style:style];
//    telInputView.inputTextField.delegate = self;
    [containerView addSubview:telInputView];
    [telInputView drawView];
    [telInputView setToolbar:_toolbar];
    [telInputView showInView:scrollView];
    telInputView.delegate = self;
    [_inputViews addObject:telInputView];
    
    NSArray *telOptions = [[EBCache sharedInstance] businessConfig].houseConfig.telDescriptions;
    if (!telOptions || telOptions.count == 0) {
        telInputView.frame = CGRectMake(telInputView.left, telInputView.top, containerView.width, telInputView.height);
        [telInputView setNeedsLayout];
    } else {
        EBSelectElement *telSelectElement = [EBSelectElement new];
        telSelectElement.options = telOptions;
        telSelectElement.placeholder = NSLocalizedString(@"hint_select_tel_desc", nil);
        telSelectView = [[EBSelectView alloc] initWithStyle:CGRectMake(telInputView.left+telInputView.width+dx, containerView.height/2, containerView.width-(telInputView.left+telInputView.width+dx), containerView.height/2) element:telSelectElement style:style];
        telSelectView.delegate = self;
        [containerView addSubview:telSelectView];
        [telSelectView drawView];
    }
}

#pragma mark -
#pragma next step btn action
- (void)nextStep
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self doneButtonIsClicked:nil];
    
//    NSDictionary *params = @{@"purpose": purpose, @"type": wantNew[wantRadioGroup.selectedIndex][@"value"], @"public": [NSNumber numberWithBool:!accessoryRadioGroup.selectedIndex], @"appellation": [nameSelectView valueOfView], @"tel": [telInputView valueOfView], @"memo": [telSelectView valueOfView]};
//    [[EBHttpClient sharedInstance] houseRequest:params houseValidate:^(BOOL success, id result) {
//        self.navigationItem.rightBarButtonItem.enabled = YES;
//        
//        if (!success) {
//            return;
//        }
//        BOOL canContinue = (BOOL)result[@"can_continue"];
//        if (canContinue) {
//            HouseAddSecondStepViewController *controller = [HouseAddSecondStepViewController new];
//            controller.params = [NSDictionary dictionaryWithDictionary:params];
//            [self.navigationController pushViewController:controller animated:YES];
//        }
//    }];
}

- (void)inputviewresignFirstResponder
{
    [self doneButtonIsClicked:nil];
}

- (void)endEdit
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark - ebelementview delegate
- (void)viewDidSelect:(EBElementView *)elementView
{
    backAlert = YES;
}

- (void)checkViewDidChanged:(EBCheckView *)checkView
{
    backAlert = YES;
}

#pragma mark -  ebselectview delegate
- (void)selectViewShouldShowOptions:(EBSelectView *)selectView options:(NSArray *)options selectedIndex:(NSInteger)index
{
    
    NSArray *views = telInputView.subviews;
    for (id tf in views) {
        if ([tf isKindOfClass:[UITextField class]]) {
            UITextField *tt = (UITextField *)tf;
            [tt resignFirstResponder];
         }
    }
 
    NSArray *view1 = nameInputView.subviews;
    for (id tf in view1) {
        if ([tf isKindOfClass:[UITextField class]]) {
            UITextField *tt = (UITextField *)tf;
            [tt resignFirstResponder];
        }
    }
    
    backAlert = YES;
    
    NSMutableArray *buttons = [NSMutableArray new];
    NSUInteger optionIndex = 0;
    for (NSString *option in options) {
        [buttons addObject:[RIButtonItem itemWithLabel:option action:^{
            [selectView setValueOfView:[NSNumber numberWithInteger:optionIndex]];
        }]];
        optionIndex++;
    }
    [[[UIActionSheet alloc] initWithTitle:nil buttons:buttons] showInView:self.view];
    
}

#pragma mark - ebinputview delegate
- (void)inputViewDidBeginEditing:(EBInputView *)inputView
{
    backAlert = YES;
    
    _currentElementView = inputView;
    [self setBarButtonNeedsDisplayAtIndex:[_inputViews indexOfObject:inputView]];
}

#pragma mark - private method
- (void)resetAccessoryRadioGroup:(NSInteger)checkedIndex
{
    NSArray *access = wantNew[checkedIndex][@"access"];
    if (access > 0) {
        [accessoryRadioGroup removeFromSuperview];
        accessoryRadioGroup = nil;
        accessoryRadioGroup = [[EBRadioGroup alloc] initWithFrame:CGRectMake(wantRadioGroup.left, wantRadioGroup.top+wantRadioGroup.height+4, scrollView.width-wantRadioGroup.left, 44.0)];
        NSMutableArray *radioNames = [NSMutableArray new];
        for (int i = 0; i < access.count; i++) {
            [radioNames addObject:@{@"title": access[i][@"name"], @"value": access[i][@"value"]}];
        }
        accessoryRadioGroup.radios = radioNames;
        __weak AddFirstStepViewController *weakSelf = self;
        accessoryRadioGroup.checkBlock = ^(NSInteger checkedIndex) {
            AddFirstStepViewController *strongSelf = weakSelf;
            [strongSelf setBackAlert:YES];
        };
        [scrollView addSubview:accessoryRadioGroup];
    } else if (accessoryRadioGroup) {
        [accessoryRadioGroup removeFromSuperview];
        accessoryRadioGroup = nil;
    }
    
    [self frameView];
}

- (void)frameView
{
    
}

- (void)initToolbar
{
    _toolbar = [[UIToolbar alloc] init];
    _toolbar.frame = CGRectMake(0, 0, self.view.width, 44);
    // set style
    [_toolbar setBarStyle:UIBarStyleDefault];
    
    _previousBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"toolbar_previous", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(previousButtonIsClicked:)];
    _nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"toolbar_next", nil)
                                                      style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonIsClicked:)];
    
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"toolbar_done", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(doneButtonIsClicked:)];
    
    NSArray *barButtonItems = @[_previousBarButton, _nextBarButton, flexBarButton, doneBarButton];
    
    _toolbar.items = barButtonItems;
}

- (void)doneButtonIsClicked:(id)sender
{
    [_currentElementView deSelect:nil];
}

- (void)nextButtonIsClicked:(id)sender
{
    NSInteger tagIndex = [_inputViews indexOfObject:_currentElementView];
    EBElementView *textField =  [_inputViews objectAtIndex:++tagIndex];
    
    [textField onSelect:nil];
}

- (void)previousButtonIsClicked:(id)sender
{
    NSInteger tagIndex = [_inputViews indexOfObject:_currentElementView];
    EBElementView *textField =  [_inputViews objectAtIndex:--tagIndex];
    
    [textField onSelect:nil];
}

- (void)setBarButtonNeedsDisplayAtIndex:(NSInteger)index
{
    if (index == 0) {
        _previousBarButton.enabled = NO;
        _nextBarButton.enabled = YES;
    } else if (index == _inputViews.count-1) {
        _previousBarButton.enabled = YES;
        _nextBarButton.enabled = NO;
    } else {
        _previousBarButton.enabled = YES;
        _nextBarButton.enabled = YES;
    }
}

#pragma mark - back popup
- (BOOL)shouldPopOnBack
{
    if (backAlert) {
        [EBAlert confirmWithTitle:nil message:NSLocalizedString(@"edit_giveup_alert", nil) yes:NSLocalizedString(@"confirm_leave_condition_give_up", nil) action:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        return NO;
    }
    return YES;
}

- (void)setBackAlert:(BOOL)flag
{
    backAlert = flag;
}

@end
