//
//  GatherHouseAddThirdViewController.m
//  beaver
//
//  Created by wangyuliang on 14-8-29.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "GatherHouseAddThirdViewController.h"
#import "EBGatherHouse.h"
#import "EBHttpClient.h"
#import "EBElementParser.h"
#import "EBElementStyle.h"
#import "EBElementView.h"
#import "EBInputView.h"
#import "EBSelectElement.h"
#import "EBSelectView.h"
#import "EBTextareaView.h"
#import "EBComponentView.h"
#import "EBIconLabel.h"
#import "EBSelectOptionsViewController.h"
#import "EBNavigationController.h"
#import "ExtraInfoViewController.h"
#import "RIButtonItem.h"
#import "AGImagePickerController.h"
#import "HousePhotoPreUploadViewController.h"
#import "EBHousePhotoUploader.h"
#import "EBController.h"
#import "UIActionSheet+Blocks.h"
#import "EBHousePhoto.h"
#import "EBParserContainerView.h"
#import "EBAlert.h"
#import "RegexKitLite.h"
#import "EBHouse.h"
#import "UIAlertView+Blocks.h"
#import "HousePhotoPreUploadViewController.h"
#import "EBFilter.h"
#import "GatherHouseAddFinishViewController.h"
#import "EBCache.h"
#import "HouseDetailViewController.h"
#import "SKImageController.h"

@interface GatherHouseAddThirdViewController ()
{
    UIView *footerView;
    NSMutableArray *_extra;
    EBHouse *_houseDetail;
    
    BOOL backAlert;
}

@end

@implementation GatherHouseAddThirdViewController

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
    self.navigationItem.title = NSLocalizedString(@"gather_house_add_erp_title", nil);
    [self addRightNavigationBtnWithTitle:@"提交" target:self action:@selector(doSubmit)];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [[EBHttpClient sharedInstance] houseRequest:@{@"relate_house_id":self.params[@"relate_house_id"], @"type": self.params[@"type"], @"purpose": self.params[@"purpose"]} houseParameter:^(BOOL success, id result)
    {
        if (!success)
            return;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        _extra = [NSMutableArray arrayWithArray:result[@"param"][@"extra"]];
        [self initParserContainer:result];
        
        [self initFooterView];
    }];
    _uploadPhotos = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetViews
{
    footerView.frame = CGRectMake(0, self.parserContainerView.bottom + 10, footerView.width, footerView.height);
    [self resizeContentSize];
}

- (void)initFooterView
{
    if (footerView) {
        footerView.frame = CGRectMake(0, self.parserContainerView.height + 10, footerView.width, footerView.height);
        [self resizeContentSize];
        
        return;
    }
    
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.parserContainerView.height + 10, self.scrollView.width, 80)];
    [self.scrollView addSubview:footerView];
    [self resizeContentSize];
    
    //    EBIconLabel *iconLabel = [[EBIconLabel alloc] initWithFrame:CGRectZero];
    //    iconLabel.iconPosition = EIconPositionTop;
    //    iconLabel.imageView.image = [UIImage imageNamed:@"im_more_0"];
    //    iconLabel.label.textColor = [EBStyle blackTextColor];
    //    iconLabel.label.font = [UIFont systemFontOfSize:14.0];
    //    iconLabel.label.text = NSLocalizedString(@"im_more_0", nil);
    //    iconLabel.gap = 2;
    //    iconLabel.tag = 10001;
    //    [footerView addSubview:iconLabel];
    //    CGRect frame = [iconLabel currentFrame];
    //    iconLabel.frame = CGRectMake(40.0, footerView.height-frame.size.height, frame.size.width, frame.size.height);
    //    UITapGestureRecognizer *iconTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(footerIconTap:)];
    //    [iconLabel addGestureRecognizer:iconTapGes];
    
    EBIconLabel *otherLabel = [[EBIconLabel alloc] initWithFrame:CGRectZero];
    otherLabel.iconPosition = EIconPositionTop;
    otherLabel.imageView.image = [UIImage imageNamed:@"im_chat_add"];
    otherLabel.label.textColor = [EBStyle blackTextColor];
    otherLabel.label.font = [UIFont systemFontOfSize:14.0];
    otherLabel.label.text = NSLocalizedString(@"other_info", nil);
    otherLabel.gap = 2;
    otherLabel.tag = 10002;
    [footerView addSubview:otherLabel];
    CGRect frame = [otherLabel currentFrame];
    //    otherLabel.frame = CGRectMake(footerView.width-frame.size.width-40.0, footerView.height-frame.size.height, frame.size.width, frame.size.height);
    otherLabel.frame = CGRectMake(footerView.width/2-frame.size.width/2, footerView.height/2-frame.size.height/2, frame.size.width, frame.size.height);
    UITapGestureRecognizer *otherTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(footerIconTap:)];
    [otherLabel addGestureRecognizer:otherTapGes];
}

#pragma mark - submit action
- (void)doSubmit
{
    [self.currentElementView deSelect:nil];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.params];
    params = [self setReqParams:params];
    if (!params) {
        return;
    }
    params[@"relate_house_id"] = self.params[@"relate_house_id"];
    params[@"media"] = _gatherHouse.port_name;
    [self.currentElementView deSelect:nil];
    [EBAlert showLoading:nil];
    //    __weak HouseAddViewController *weakSelf = self;
    [[EBHttpClient sharedInstance] houseRequest:params houseSave:^(BOOL success, id result) {
        [EBAlert hideLoading];
        if (success) {
            if (_gatherHouse.input_erp == 0)
            {
                _gatherHouse.input_erp = 1;
                _gatherHouse.to_erp_count ++;
            }
            
            NSString *houseId = result[@"id"];
            __block EBHouse *house = [[EBHouse alloc] init];
            house.id = houseId;
            NSString *type = params[@"type"];
            if ([type compare:@"sale"] == NSOrderedSame)
            {
                house.rentalState = EHouseRentalTypeSale;
            }
            else if ([type compare:@"rent"] == NSOrderedSame)
            {
                house.rentalState = EHouseRentalTypeRent;
            }
            else
            {
                house.rentalState = EHouseRentalTypeBoth;
            }
            [[EBHttpClient sharedInstance] houseRequest:@{@"id":house.id, @"force_refresh":@(YES),
                                                          @"type":[EBFilter typeString:house.rentalState]}
                                                 detail:^(BOOL success, id result)
             {
                 if (success)
                 {
                     house = result;
                     GatherHouseAddFinishViewController *viewController = [[GatherHouseAddFinishViewController alloc] init];
                     viewController.house = house;
                     [self.navigationController pushViewController:viewController animated:YES];
                 }
             }];
        } else {
            //            [EBAlert alertError:NSLocalizedString(@"house_add_alert_text_failed", nil)];
        }
    }];
}

- (void)getPhoto:(EBHouse*)house
{
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    NSString *format = nil;
    for (int i = 0; i < 2; i++)
    {
        format = [NSString stringWithFormat:@"upload_select_%d", i];
        [buttons addObject:[RIButtonItem itemWithLabel:NSLocalizedString(format, nil) action:^
                            {
                                if (i == 0)
                                {
                                    [[EBController sharedInstance] pickImageWithUrlSourceType:UIImagePickerControllerSourceTypeCamera handler:^(UIImage *image, NSURL *url)
                                     {
                                         [self dismissViewControllerAnimated:YES completion:nil];
                                         HousePhotoPreUploadViewController *preUploadViewController = [[HousePhotoPreUploadViewController alloc] init];
                                         [preUploadViewController uploadCameraPhotos:image url:url forHouse:house getUpLoadPhotoBlock:^(NSArray *array)
                                          {
                                              if (array && array.count > 0)
                                              {
                                                  [[EBHousePhotoUploader sharedInstance] addHousePhotos:array];
                                              }
                                          }];
                                         [self.navigationController pushViewController:preUploadViewController animated:YES];
                                     }];
                                }
                                else
                                {
                                    [SKImageController showMutlSelectPhotoFrom:self maxSelect:10 select:^(NSArray *info) {
                                        HousePhotoPreUploadViewController *preUploadViewController = [[HousePhotoPreUploadViewController alloc] init];
                                        [preUploadViewController uploadPhotos:info forHouse:house getUpLoadPhotoBlock:^(NSArray *array)
                                         {
                                             if (array && array.count > 0)
                                             {
                                                 [[EBHousePhotoUploader sharedInstance] addHousePhotos:array];
                                             }
                                         }];
                                        [self.navigationController pushViewController:preUploadViewController animated:YES];
                                    }];
                                    
//                                    AGImagePickerController *pickerController = [[AGImagePickerController alloc] initWithFailureBlock:^(NSError *error)
//                                                                                 {
//                                                                                     [self dismissViewControllerAnimated:YES completion:nil];
//                                                                                 } andSuccessBlock:^(NSArray *info)
//                                                                                 {
//                                                                                     [self dismissViewControllerAnimated:YES completion:nil];
//                                                                                     HousePhotoPreUploadViewController *preUploadViewController = [[HousePhotoPreUploadViewController alloc] init];
//                                                                                     [preUploadViewController uploadPhotos:info forHouse:house getUpLoadPhotoBlock:^(NSArray *array)
//                                                                                      {
//                                                                                          if (array && array.count > 0)
//                                                                                          {
//                                                                                              [[EBHousePhotoUploader sharedInstance] addHousePhotos:array];
//                                                                                          }
//                                                                                      }];
//                                                                                     [self.navigationController pushViewController:preUploadViewController animated:YES];
//                                                                                 } maximumNumberOfPhotosToBeSelected:10];
//                                    [self presentViewController:pickerController animated:YES completion:nil];
                                }
                            }]];
    }
    [[[UIActionSheet alloc] initWithTitle:nil buttons:buttons] showInView:self.view];
}

#pragma mark - ebelementview delegate
- (void)viewDidSelect:(EBElementView *)elementView
{
    backAlert = YES;
    
    [super viewDidSelect:elementView];
}

- (void)inputViewDidBeginEditing:(EBInputView *)inputView
{
    backAlert = YES;
    
    [super inputViewDidBeginEditing:inputView];
}

- (void)textareaViewDidBeginEditing:(EBTextareaView *)textareaView
{
    backAlert = YES;
    
    [super textareaViewDidBeginEditing:textareaView];
}

- (void)selectViewShouldShowOptions:(EBSelectView *)selectView options:(NSArray *)options selectedIndex:(NSInteger)index
{
    backAlert = YES;
    
    if (selectView) {
        CGRect curFrame = selectView.frame;
        CGRect scrollFrame = self.scrollView.frame;
        CGFloat height;
        if (self.scrollView.contentSize.height - curFrame.origin.y > scrollFrame.size.height)
        {
            height = curFrame.origin.y;
        }
        else
        {
            height = self.scrollView.contentSize.height - scrollFrame.size.height;
        }
        [self.scrollView setContentOffset:CGPointMake(0, height)];
    }
    
    [super selectViewShouldShowOptions:selectView options:options selectedIndex:index];
}

- (void)checkViewDidChanged:(EBCheckView *)checkView
{
    backAlert = YES;
    
    [super checkViewDidChanged:checkView];
}
#pragma mark -
#pragma footerview icon tap action
- (void)footerIconTap:(UITapGestureRecognizer *)sender
{
    EBIconLabel *view = (EBIconLabel *)sender.view;
    switch (view.tag) {
        case 10001:
        {
            NSMutableArray *buttons = [[NSMutableArray alloc] init];
            NSString *format = nil;
            for (int i = 0; i < 2; i++)
            {
                format = [NSString stringWithFormat:@"upload_select_%d", i];
                [buttons addObject:[RIButtonItem itemWithLabel:NSLocalizedString(format, nil) action:^
                                    {
                                        if (i == 0)
                                        {
                                            [[EBController sharedInstance] pickImageWithUrlSourceType:UIImagePickerControllerSourceTypeCamera handler:^(UIImage *image, NSURL *url)
                                             {
                                                 [self dismissViewControllerAnimated:YES completion:nil];
                                                 HousePhotoPreUploadViewController *preUploadViewController = [[HousePhotoPreUploadViewController alloc] init];
                                                 [preUploadViewController uploadCameraPhotos:image url:url forHouse:_houseDetail getUpLoadPhotoBlock:^(NSArray *array)
                                                  {
                                                      if (array && array.count > 0)
                                                      {
                                                          [[EBHousePhotoUploader sharedInstance] addHousePhotos:array];
                                                      }
                                                  }];
                                                 [self.navigationController pushViewController:preUploadViewController animated:YES];
                                             }];
                                        }
                                        else
                                        {
                                            [SKImageController showMutlSelectPhotoFrom:self maxSelect:0 select:^(NSArray *info) {
                                                [self dismissViewControllerAnimated:YES completion:nil];
                                                HousePhotoPreUploadViewController *preUploadViewController = [[HousePhotoPreUploadViewController alloc] init];
                                                [preUploadViewController uploadPhotos:info forHouse:_houseDetail getUpLoadPhotoBlock:^(NSArray *array)
                                                 {
                                                     if (array && array.count > 0)
                                                     {
                                                         [[EBHousePhotoUploader sharedInstance] addHousePhotos:array];
                                                     }
                                                 }];
                                                [self.navigationController pushViewController:preUploadViewController animated:YES];
                                            }];
                                            
//                                            AGImagePickerController *pickerController = [[AGImagePickerController alloc] initWithFailureBlock:^(NSError *error)
//                                                                                         {
//                                                                                             [self dismissViewControllerAnimated:YES completion:nil];
//                                                                                         } andSuccessBlock:^(NSArray *info)
//                                                                                         {
//                                                                                             [self dismissViewControllerAnimated:YES completion:nil];
//                                                                                             HousePhotoPreUploadViewController *preUploadViewController = [[HousePhotoPreUploadViewController alloc] init];
//                                                                                             [preUploadViewController uploadPhotos:info forHouse:_houseDetail getUpLoadPhotoBlock:^(NSArray *array)
//                                                                                              {
//                                                                                                  if (array && array.count > 0)
//                                                                                                  {
//                                                                                                      [[EBHousePhotoUploader sharedInstance] addHousePhotos:array];
//                                                                                                  }
//                                                                                              }];
//                                                                                             [self.navigationController pushViewController:preUploadViewController animated:YES];
//                                                                                         } maximumNumberOfPhotosToBeSelected:0];
//                                            [self presentViewController:pickerController animated:YES completion:nil];
                                        }
                                    }]];
            }
            [[[UIActionSheet alloc] initWithTitle:nil buttons:buttons] showInView:self.view];
        }
            break;
        case 10002:
        {
            ExtraInfoViewController *controller = [[ExtraInfoViewController alloc] initWithData:_extra title:NSLocalizedString(@"other_info_controller_title", nil)];
            EBNavigationController *naviController = [[EBNavigationController alloc] initWithRootViewController:controller];
            [self presentViewController:naviController animated:YES completion:^{
                
            }];
            
            __weak GatherHouseAddThirdViewController *weakSelf = self;
            __weak EBParserContainerView *weakParserContainerView = self.parserContainerView;
            __weak __block ExtraInfoViewController * weakController = controller;
            controller.onSelect = ^(NSIndexPath *indexPath, NSDictionary *data) {
                EBParserContainerView *strongParserContainerView = weakParserContainerView;
                
                NSMutableArray *arr = [NSMutableArray arrayWithArray:_extra[indexPath.section]];
                [arr removeObjectAtIndex:indexPath.row];
                _extra[indexPath.section] = [NSArray arrayWithArray:arr];
                if (arr.count == 0) {
                    [_extra removeObjectAtIndex:indexPath.section];
                }
                
                EBElementView *elementView = [strongParserContainerView showElementView:data[@"fields"]];
                [self initFooterView];
                
                if ([elementView isKindOfClass:EBInputView.class] || [elementView isKindOfClass:EBTextareaView.class]) {
                    [elementView onSelect:nil];
                }
                __weak EBSelectView *weakView = (EBSelectView*)elementView;
                if ([elementView isKindOfClass:EBSelectView.class]) {
                    EBSelectView *strongView = weakView;
                    weakController.onDisappear = ^{
                        
                        [self selectViewShouldShowOptions:strongView options:[(EBSelectElement *)strongView.element options] selectedIndex:[(EBSelectElement *)strongView.element selectedIndex]];
                    };
                }
            };
            
            controller.onCancel = ^{
                GatherHouseAddThirdViewController *strongSelf = weakSelf;
                [strongSelf dismissViewControllerAnimated:YES completion:^{
                    
                }];
            };
            break;
        }
        default:
            break;
    }
}

#pragma mark - private method
- (void)resizeContentSize
{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.parserContainerView.height+footerView.height+10);
}

- (BOOL)isPhotoAdded:(EBHousePhoto*)photo
{
    NSString *strNew=[photo.localUrl absoluteString];
    NSString *temp = nil;
    NSInteger count = [_uploadPhotos count];
    int i = 0;
    for (i = 0; i < count; i ++)
    {
        EBHousePhoto * photo = (EBHousePhoto*)_uploadPhotos[i];
        temp = [photo.localUrl absoluteString];
        if ([strNew compare:temp] == NSOrderedSame)
        {
            return YES;
        }
    }
    return  NO;
}

- (void)addPhoto:(NSArray *)array
{
    EBHousePhoto *photo = [[EBHousePhoto alloc] init];
    for (int i = 0; i < array.count; i ++) {
        photo = (EBHousePhoto *)array[i];
        if (![self isPhotoAdded:photo])
        {
            [_uploadPhotos addObject:photo];
        }
    }
}

#pragma mark - back popup
- (BOOL)shouldPopOnBack
{
//    if (backAlert) {
//        [EBAlert confirmWithTitle:nil message:NSLocalizedString(@"edit_giveup_alert", nil) yes:NSLocalizedString(@"confirm_leave_condition_give_up", nil) action:^{
//            [self.navigationController popViewControllerAnimated:YES];
//        }];
//        return NO;
//    }
    return YES;
}

@end
