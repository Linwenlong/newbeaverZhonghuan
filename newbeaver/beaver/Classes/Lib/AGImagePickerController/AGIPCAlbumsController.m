//
//  AGIPCAlbumsController.m
//  AGImagePickerController
//
//  Created by Artur Grigor on 2/16/12.
//  Copyright (c) 2012 - 2013 Artur Grigor. All rights reserved.
//  
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//  

#import "AGIPCAlbumsController.h"

#import "AGImagePickerController.h"
#import "AGIPCAssetsController.h"
#import "EBViewFactory.h"

@interface AGIPCAlbumsController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *_assetsGroups;
    __weak AGImagePickerController *_imagePickerController;
}

@property (ag_weak, nonatomic, readonly) NSMutableArray *assetsGroups;
@property (nonatomic, strong) UITableView *tableView;

@end

@interface AGIPCAlbumsController ()

- (void)registerForNotifications;
- (void)unregisterFromNotifications;

- (void)didChangeLibrary:(NSNotification *)notification;

- (void)loadAssetsGroups;
- (void)reloadData;

- (void)cancelAction:(id)sender;

@end

@implementation AGIPCAlbumsController

#pragma mark - Properties

@synthesize imagePickerController = _imagePickerController;

- (NSMutableArray *)assetsGroups
{
    if (_assetsGroups == nil)
    {
        _assetsGroups = [[NSMutableArray alloc] init];
        [self loadAssetsGroups];
    }
    
    return _assetsGroups;
}

#pragma mark - Object Lifecycle

- (id)initWithImagePickerController:(AGImagePickerController *)imagePickerController
{
    self = [super init];
    if (self)
    {
        self.imagePickerController = imagePickerController;
    }
    
    return self;
}

- (void)loadAssetsGroup:(ALAssetsGroup *)group animated:(BOOL)animated
{
    AGIPCAssetsController *controller = [[AGIPCAssetsController alloc] initWithImagePickerController:self.imagePickerController andAssetsGroup:group];
    controller.navigationController.hidesBottomBarWhenPushed = YES;
    controller.navigationController.toolbarHidden = YES;
    [self.navigationController pushViewController:controller animated:animated];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)loadView
{
    [super loadView];

    _tableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Fullscreen
    if (self.imagePickerController.shouldChangeStatusBarStyle) {
        self.wantsFullScreenLayout = YES;
    }
    
    // Setup Notifications
    [self registerForNotifications];
    
    // Navigation Bar Items
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                     style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];

	self.navigationItem.leftBarButtonItem = cancelButton;

    self.title = NSLocalizedString(@"photos", nil);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Destroy Notifications
    [self unregisterFromNotifications];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.assetsGroups) {
        return self.assetsGroups.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:98];
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:99];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        [cell addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:70 width:310 leftMargin:10]];

        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        [cell.contentView addSubview:imageView];
        imageView.tag = 98;

        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, 200, 70)];
        titleLabel.textColor = [EBStyle blackTextColor];
        titleLabel.font = [UIFont systemFontOfSize:14.0];
        titleLabel.tag = 99;
        [cell.contentView addSubview:titleLabel];
    }
    
    ALAssetsGroup *group = (self.assetsGroups)[indexPath.row];
    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
    NSUInteger numberOfAssets = group.numberOfAssets;
    
    titleLabel.text = [NSString stringWithFormat:@"%@", [group valueForProperty:ALAssetsGroupPropertyName]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", numberOfAssets];
    [imageView setImage:[UIImage imageWithCGImage:[(ALAssetsGroup *)self.assetsGroups[indexPath.row] posterImage]]];
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
	[self loadAssetsGroup:self.assetsGroups[[indexPath row]] animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	return 70;
}

#pragma mark - Private

- (void)loadAssetsGroups
{
    __ag_weak AGIPCAlbumsController *weakSelf = self;
    
    [self.assetsGroups removeAllObjects];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        @autoreleasepool {
            
            void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) 
            {
                if (group == nil) 
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (![weakSelf.navigationController.topViewController isKindOfClass:[AGIPCAssetsController class]]) {
                            ALAssetsGroup *groupMax = nil;
                            for (int i = 0; i < weakSelf.assetsGroups.count; i ++)
                            {
                                ALAssetsGroup *group = (ALAssetsGroup*)weakSelf.assetsGroups[i];
                                if (groupMax)
                                {
                                    if (group.numberOfAssets > groupMax.numberOfAssets)
                                    {
                                        groupMax = group;
                                    }
                                }
                                else
                                {
                                    groupMax = group;
                                }
                            }
                            if (groupMax)
                            {
                                [weakSelf loadAssetsGroup:groupMax animated:NO];
                            }
                        }
                    });
                    return;
                }
                
                if (weakSelf.imagePickerController.shouldShowSavedPhotosOnTop) {
                    if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos) {
                        [weakSelf.assetsGroups insertObject:group atIndex:0];
                    } else if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] > ALAssetsGroupSavedPhotos) {
                        [weakSelf.assetsGroups insertObject:group atIndex:1];
                    } else {
                        [weakSelf.assetsGroups addObject:group];
                    }
                } else {
                    [weakSelf.assetsGroups addObject:group];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf reloadData];
//                    if (![self.navigationController.topViewController isKindOfClass:[AGIPCAssetsController class]]) {
//                        ALAssetsGroup *groupMax = nil;
//                        for (int i = 0; i < self.assetsGroups.count; i ++)
//                        {
//                            ALAssetsGroup *group = (ALAssetsGroup*)self.assetsGroups[i];
//                            if (groupMax)
//                            {
//                                if (group.numberOfAssets > groupMax.numberOfAssets)
//                                {
//                                    groupMax = group;
//                                }
//                            }
//                            else
//                            {
//                                groupMax = group;
//                            }
//                        }
//                        if (groupMax)
//                        {
//                            [self loadAssetsGroup:groupMax animated:NO];
//                        }
//                    }
                });
            };
            
            void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                NSLog(@"A problem occured. Error: %@", error.localizedDescription);
                [weakSelf.imagePickerController performSelector:@selector(didFail:) withObject:error];
            };	
            
            [[AGImagePickerController defaultAssetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupAll
                                   usingBlock:assetGroupEnumerator 
                                 failureBlock:assetGroupEnumberatorFailure];
            
        }
        
    });
}

- (void)reloadData
{
    [self.tableView reloadData];
    self.title = NSLocalizedStringWithDefaultValue(@"AGIPC.Albums", nil, [NSBundle mainBundle], @"返回", nil);
}

- (void)cancelAction:(id)sender
{
    [self.imagePickerController performSelector:@selector(didCancelPickingAssets)];
}

#pragma mark - Notifications

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didChangeLibrary:) 
                                                 name:ALAssetsLibraryChangedNotification 
                                               object:[AGImagePickerController defaultAssetsLibrary]];
}

- (void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:ALAssetsLibraryChangedNotification 
                                                  object:[AGImagePickerController defaultAssetsLibrary]];
}

- (void)didChangeLibrary:(NSNotification *)notification
{
    [self loadAssetsGroups];
}

- (void)dealloc
{
    [self unregisterFromNotifications];
}

@end
