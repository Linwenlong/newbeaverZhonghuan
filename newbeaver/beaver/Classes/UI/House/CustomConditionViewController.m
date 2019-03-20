//
//  CustomConditionViewController.m
//  beaver
//
//  Created by 何 义 on 14-3-11.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "CustomConditionViewController.h"
#import "HouseViewController.h"
#import "EBFilterView.h"
#import "EBAlert.h"
#import "EBCondition.h"
#import "EBHttpClient.h"
#import "EBController.h"
#import "EBFilter.h"
#import <objc/runtime.h>

@interface CustomConditionViewController () <FilterViewDelegate>
{
    EBFilterView *_filterView;
    BOOL _saved;
}
@end

@implementation CustomConditionViewController

- (void)loadView
{
    [super loadView];

    self.title = _customType == ECustomConditionViewTypeGatherHouse ? NSLocalizedString(@"title_subscription", nil) : NSLocalizedString(@"title_custom_condition", nil);

    _filterView = [[EBFilterView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO] custom:YES];
    _filterView.delegate = self;
    _filterView.customCondition = _condition;
    _filterView.filterType = _customType == ECustomConditionViewTypeGatherHouse ? EFilterTypeGatherHouse : EFilterTypeHouse;
    [self.view addSubview:_filterView];

    [self addRightNavigationBtnWithTitle:NSLocalizedString(@"save", nil) target:self action:@selector(saveCondition)];
    _orgCondition = [[EBCondition alloc] init];
    _orgCondition.filter = [[EBFilter alloc] init];
    _orgCondition.id = _condition.id;
    _orgCondition.title = _condition.title;
    _orgCondition.communities = [_condition.communities mutableCopy];
    _orgCondition.filter = [_condition.filter copy];
}

- (void)saveCondition
{
    [_filterView syncCondition];
    if (_customType == ECustomConditionViewTypeGatherHouse)
    {
        [EBTrack event:EVENT_CLICK_COLLECT_POST_SUBSCRIBE_EDIT];
        if ([_condition.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
        {
            [EBAlert alertError:NSLocalizedString(@"alert_subscription_name", nil)];
            return;
        }
        else if ([_condition.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 10)
        {
            [EBAlert alertError:NSLocalizedString(@"alert_subscription_name_length", nil)];
            return;
        }
        [[EBHttpClient sharedInstance] gatherPublishRequest:[_condition currentArgs] subscriptionEdit:^(BOOL success, id result)
        {
            if (success)
            {
                [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_SUBSCRIPTION_UPDATE object:nil]];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                
            }
        }];
    }
    else if (_customType == ECustomConditionViewTypeHouse)
    {
        if ([_condition.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
        {
            [EBAlert alertError:NSLocalizedString(@"alert_condition_name", nil)];
            return;
        }
        else if ([_condition.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 10)
        {
            [EBAlert alertError:NSLocalizedString(@"alert_condition_name_length", nil)];
            return;
        }
        [[EBHttpClient sharedInstance] houseRequest:[_condition currentArgs] updateCondition:^(BOOL success, id result)
         {
             if (success)
             {
                 [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_CONDITION_UPDATE object:nil]];
                 [self.navigationController popViewControllerAnimated:YES];
             }
             else
             {
                 
             }
         }];
    }
}

- (BOOL)shouldPopOnBack
{
    [_filterView syncCondition];
    BOOL isSame = [self compareCondition:_condition orgCondition:_orgCondition];
//    isSame = NO;
    if(!isSame)
    {
        [EBAlert confirmWithTitle:nil message:NSLocalizedString(@"confirm_leave_condition", nil)
                              yes:NSLocalizedString(@"confirm_leave_condition_give_up", nil) action:^
         {
             _filterView.customCondition = _orgCondition;
             self.condition.id = _orgCondition.id;
             self.condition.title = _orgCondition.title;
             self.condition.communities = _orgCondition.communities;
             self.condition.filter = [_orgCondition.filter copy];
             [self.navigationController popViewControllerAnimated:YES];
         }];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }

    return NO;
}

#pragma mark - filterViewDelegate
-(void)filterView:(EBFilterView*)filterView filter:(EBFilter *)filter
{
    if (_customType == ECustomConditionViewTypeHouse)
    {
        [EBAlert confirmWithTitle:@"" message:NSLocalizedString(@"confirm_delete_condition", nil)
                              yes:NSLocalizedString(@"confirm_yes", nil) action:^
         {
             [[EBHttpClient sharedInstance] houseRequest:@{@"id":_condition.id} deleteCondition:^(BOOL success, id result)
              {
                  if (success)
                  {
                      //                [self.navigationController popViewControllerAnimated:YES];
                      NSArray *vcs = self.navigationController.viewControllers;
                      for (id vc in  vcs) {
                          if ([vc isKindOfClass:[HouseViewController class]]) {
                              HouseViewController *cc =(HouseViewController *)vc;
                               [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_CONDITION_UPDATE object:nil]];
                              [self.navigationController popToViewController:cc animated:YES];
                              return ;
                          }
                      }
                      [self.navigationController popToRootViewControllerAnimated:YES];
                      [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_CONDITION_DELETE object:nil]];
               
                  }
                  else
                  {
                      
                  }
              }];
         }];
    }
    else if (_customType == ECustomConditionViewTypeGatherHouse)
    {
        [EBAlert confirmWithTitle:@"" message:NSLocalizedString(@"confirm_delete_subscription", nil)
                              yes:NSLocalizedString(@"confirm_yes", nil) action:^
         {
             [[EBHttpClient sharedInstance] gatherPublishRequest:@{@"id":_condition.filter.subscriptionId} subscriptionDelete:^(BOOL success, id result)
              {
                  if (success)
                  {
                      NSArray *viewControllers = self.navigationController.viewControllers;
                      
                      [self.navigationController popToViewController:viewControllers[viewControllers.count - 3] animated:YES];
                      [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_SUBSCRIPTION_DELETE object:nil]];
                  }
                  else
                  {
                      
                  }
              }];
         }];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)compareProperty:(id)curProperty orgProperty:(id)orgProperty type:(NSString*)type
{
    if ([type compare:@"NSString"] == NSOrderedSame)
    {
        if((curProperty != nil) && (orgProperty != nil))
        {
            return [curProperty compare:orgProperty];
        }
        else
        {
            if((curProperty == nil) && (orgProperty == nil))
            {
                return YES;
            }
            else
                return NO;
        }
    }
    else if ([type compare:@"NSInteger"] == NSOrderedSame || [type compare:@"i"] == NSOrderedSame)
    {
        return curProperty == orgProperty;
    }
    else if ([type compare:@"NSDictionary"] == NSOrderedSame)
    {
        if((curProperty != nil) && (orgProperty != nil))
        {
            return [curProperty isEqualToDictionary:orgProperty];
        }
        else
        {
            if((curProperty == nil) && (orgProperty == nil))
            {
                return YES;
            }
            else
                return NO;
        }
    }
    else
        return NO;
}

//@property (nonatomic, strong) NSDictionary *reservedCondition;
- (BOOL)compareCondition:(EBCondition *)curCondition orgCondition:(EBCondition *)orgCondition
{
    if([curCondition.title compare:orgCondition.title] == NSOrderedDescending )
    {
        return NO;
    }
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self.condition.filter class], &outCount);
    objc_property_t *orgProperties = class_copyPropertyList([self.orgCondition.filter class], &outCount);
    for (i = 0 ; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        const char *attributes = property_getAttributes(property);
        char propertyType[32];
        char *state = strdup(attributes);
        char *attribute;
        while ((attribute = strsep(&state, ",")) != NULL)
        {
            if (attribute[0] == 'T' && attribute[1] != '@')
            {
                //!C primitive type
                memset(propertyType, 0, 32);
                memcpy(propertyType , (attribute + 1), strlen(attribute) - 1);
//                propertyType = "NSInteger";
                break;
            }
            else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
                // it's an ObjC id type:
                memset(propertyType, 0, 32);
                strcpy(propertyType , "id");
                break;
            }
            else if (attribute[0] == 'T' && attribute[1] == '@')
            {
                memset(propertyType, 0, 32);
                memcpy(propertyType , (attribute + 3), strlen(attribute) - 4);
                break;
            }
        }
        id propertyValue = [self.condition.filter valueForKey:[[NSString alloc] initWithCString:propName encoding:NSASCIIStringEncoding]];
        
        objc_property_t orgProperty = orgProperties[i];
        const char *orgPropName = property_getName(orgProperty);
        const char *orgAttributes = property_getAttributes(orgProperty);
        char orgPropertyType[32];
        char *orgState = strdup(orgAttributes);
        char *orgAttribute;
        while ((orgAttribute = strsep(&orgState, ",")) != NULL)
        {
            if (orgAttribute[0] == 'T' && orgAttribute[1] != '@')
            {
                //!C primitive type
                memset(orgPropertyType, 0, 32);
                memcpy(orgPropertyType, orgAttribute + 1, strlen(orgAttribute) - 1);
//                strcpy(orgPropertyType , (char *)[[NSData dataWithBytes:(orgAttribute + 1) length:strlen(orgAttribute) - 1] bytes]);
                //                propertyType = "NSInteger";
                break;
            }
            else if (orgAttribute[0] == 'T' && orgAttribute[1] == '@' && strlen(orgAttribute) == 2)
            {
                // it's an ObjC id type:
                memset(orgPropertyType, 0, 32);
                strcpy(orgPropertyType , "id");
                break;
            }
            else if (orgAttribute[0] == 'T' && orgAttribute[1] == '@')
            {
                memset(orgPropertyType, 0, 32);
                memcpy(orgPropertyType , orgAttribute + 3 , strlen(orgAttribute) - 4);
//                strcpy(orgPropertyType , (char *)[[NSData dataWithBytes:(orgAttribute + 3) length:strlen(orgAttribute) - 4] bytes]);
                break;
            }
        }
        id orgPropertyValue = [self.orgCondition.filter valueForKey:[[NSString alloc] initWithCString:orgPropName encoding:NSASCIIStringEncoding]];
        BOOL back = [self compareProperty:propertyValue orgProperty:orgPropertyValue type:[[NSString alloc] initWithCString:propertyType encoding:NSASCIIStringEncoding]];
        if(!back)
        {
            return NO;
        }
    }
    free(properties);
    return YES;
}

@end
