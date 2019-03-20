//
// Created by 何 义 on 14-7-23.
// Copyright (c) 2014 eall. All rights reserved.
//
#pragma mark -- 照片上传控制器

#import "HousePhotoPreUploadViewController.h"
#import "EBHouse.h"
#import "EBHousePhoto.h"
#import "EBViewFactory.h"
#import "EBBusinessConfig.h"
#import "EBCache.h"
#import "EBAlert.h"
#import "EBController.h"
#import "UIImage+Alpha.h"
#import "MHTextField.h"
#import "EBHousePhotoUploader.h"
#import "EBFilter.h"
#import "RIButtonItem.h"
#import "UIActionSheet+Blocks.h"
#import "UIImageView+AFNetworking.h"
#import "SKImageController.h"
#import "EBVideoUtil.h"
#import "EBVideoUpload.h"

typedef NS_ENUM(NSInteger , EMHTextFieldEndType)
{
    EMHTextFieldEndTypeEdit = 0,
    EMHTextFieldEndTypeDelete = 1,
};

@interface HousePhotoPreUploadViewController()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_uploadPhotos;
    EBHouse *_house;
    NSMutableArray *_textFields;
    NSMutableArray *_indexLocationSelect;
    BOOL _isLocationEmpty;
    EMHTextFieldEndType _endType;
    NSInteger _deleteRow;
    BOOL _modifyTag;
}

@end

@implementation HousePhotoPreUploadViewController

- (void)loadView
{
    [super loadView];
    
    NSArray *locations = [[EBCache sharedInstance] businessConfig].houseConfig.photoDescriptions;
    if (locations == nil)
        _isLocationEmpty = YES;
    else
    {
        if (locations.count < 1)
            _isLocationEmpty = YES;
        else
            _isLocationEmpty = NO;
    }

    _tableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 90;
    [self.view addSubview:_tableView];

    UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 72)];
    [tableHeader addSubview:[EBViewFactory blueButtonWithFrame:CGRectMake(15, 30, [EBStyle screenWidth] - 30, 36)
                                                         title:NSLocalizedString(@"house_photo_add_more", nil) target:self
                                                        action:@selector(addMorePhotos)]];
    _tableView.tableHeaderView = tableHeader;

    if (_publishTag)
    {
        [self addRightNavigationBtnWithTitle:NSLocalizedString(@"save", nil)
                                      target:self action:@selector(finishPhotoEditing)];
    }
    else
    {
        [self addRightNavigationBtnWithTitle:NSLocalizedString(@"toolbar_done", nil)
                                      target:self action:@selector(finishPhotoEditing)];
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_note_close"] style:UIBarButtonItemStyleDone target:self action:@selector(back:)];
    self.title = NSLocalizedString(@"photo_desc", nil);
    _endType = EMHTextFieldEndTypeEdit;
}

- (void)dealloc
{
}

#pragma mark - action
- (void)back:(id)sender
{
    if (_publishTag)
    {
        if (_modifyTag)
        {
            [EBAlert confirmWithTitle:nil message:NSLocalizedString(@"confirm_leave_photo_publish", nil)
                                  yes:NSLocalizedString(@"confirm", nil) action:^
             {
                 
                 [self.navigationController popViewControllerAnimated:YES];
             }];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        [EBAlert confirmWithTitle:nil message:NSLocalizedString(@"confirm_leave_photo_upload", nil)
                              yes:NSLocalizedString(@"confirm_leave_condition_give_up", nil) action:^
         {
             
             [self.navigationController popViewControllerAnimated:YES];
         }];
    }
}

- (void)finishPhotoEditing
{
    [EBTrack event:EVENT_CLICK_HOUSE_UPLOAD];
    for (EBHousePhoto *photo in _uploadPhotos) {
        if (photo.locationDesc == nil) {
            [EBAlert alertError:@"请选择图片类型" length:2.0f];
            return;
        }
    }
    if (_getUpLoadPhotoBlock)
    {
//        for (int i = 0; i < _uploadPhotos.count; i ++)
//        {
//            EBHousePhoto *photo = (EBHousePhoto*)_uploadPhotos[i];
//            if (photo.locationDesc && photo.locationDesc.length > 0)
//            {
//                photo.note = [NSString stringWithFormat:@"%@ %@",photo.locationDesc, photo.note];
//            }
//        }
        self.getUpLoadPhotoBlock(_uploadPhotos);
    }
//    [[EBHousePhotoUploader sharedInstance] addHousePhotos:_uploadPhotos];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)addMorePhotos
{
    //lwl
    NSString * imageCount = [EBPreferences sharedInstance].image_num_limit;
    _modifyTag = YES;//10
    //pictures.count img_num
    if (!_publishTag && _house.image_num + _uploadPhotos.count >= [imageCount integerValue])
    {
        NSString *title = nil;
        if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
            if (title == nil) {
                title = @"";
            }
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:NSLocalizedString(@"photo_uploading_limit_warn", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"anonymous_call_end_confirm", nil) otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        if (_publishTag && _uploadPhotos.count > 20) {
            [EBAlert alertError:@"最多选择20张"];
            return;
        }
        
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        NSString *format = nil;
        for (int i = 0; i < 2; i++)
        {
            format = [NSString stringWithFormat:@"upload_select_%d", i];
            [buttons addObject:[RIButtonItem itemWithLabel:NSLocalizedString(format, nil)
                                                    action:^
                                {
                                    if (i == 0)
                                    {
                                        [[EBController sharedInstance] pickImageWithUrlSourceTypeEx:UIImagePickerControllerSourceTypeCamera curentViewController:self handler:^(UIImage *image, NSURL *url)
                                         {
                                             [self dismissViewControllerAnimated:YES completion:nil];
                                             [self addCameraPhotosForUploading:image url:url];
                                             [_tableView reloadData];
                                         }];
                                    }
                                    else
                                    {
                                        NSUInteger maxNums = 0;
                                        if (_publishTag) {
                                            maxNums = 20 - _uploadPhotos.count;
                                        } else {
                                            maxNums = [imageCount integerValue] - _house.image_num - _uploadPhotos.count;
                                        }
                                        [SKImageController showMutlSelectPhotoFrom:self maxSelect:maxNums select:^(NSArray *info) {
                                            [self addPhotosForUploading:info];
                                            [_tableView reloadData];
                                        }];
                                        
//                                        AGImagePickerController *pickerController = [[AGImagePickerController alloc] initWithFailureBlock:^(NSError *error)
//                                                                                     {
//                                                                                         [self dismissViewControllerAnimated:YES completion:nil];
//                                                                                     } andSuccessBlock:^(NSArray *info)
//                                                                                     {
//                                                                                         [self dismissViewControllerAnimated:YES completion:nil];
//                                                                                         [self addPhotosForUploading:info];
//                                                                                         [_tableView reloadData];
//                                                                                     } maximumNumberOfPhotosToBeSelected:maxNums];
//                                        
//                                        [self presentViewController:pickerController animated:YES completion:nil];
                                    }
                                }]];
        }
        [[[UIActionSheet alloc] initWithTitle:nil buttons:buttons] showInView:self.view];
    }
}

- (void)uploadPhotos:(NSArray *)photos forHouse:(EBHouse *)house getUpLoadPhotoBlock:(id)retuenUpLoadPhotoBlock
{
    _house = house;
    _uploadPhotos = [[NSMutableArray alloc] init];
    _indexLocationSelect = [[NSMutableArray alloc] init];
    [self addPhotosForUploading:photos];
    self.getUpLoadPhotoBlock = retuenUpLoadPhotoBlock;
}

- (void)addPhotosForUploading:(NSArray *)photoInput
{
    if (!photoInput || photoInput.count == 0) {
        return;
    }
    
    if (!_publishTag)
    {
        for (ALAsset *asset in photoInput)
        {
            if (![self isAdded:[asset.defaultRepresentation url]])
            {
                EBHousePhoto *photo = [[EBHousePhoto alloc] init];
                photo.localUrl = [asset.defaultRepresentation url];
                photo.houseId = _house.id;
                photo.houseType = [EBFilter typeString:_house.rentalState];
                photo.thumbnail = CGImageRetain(asset.thumbnail);
                photo.status = EPhotoAddStatusWaiting;
                photo.publishTag = NO;
                [_uploadPhotos addObject:photo];
                [_indexLocationSelect addObject:@(-1)];
            }
        }
    }
    else
    {
        for (id url in photoInput)
        {
            EBHousePhoto *photo = [[EBHousePhoto alloc] init];
//            photo.localUrl = url;
            photo.houseId = _house.id;
            photo.houseType = [EBFilter typeString:_house.rentalState];
            photo.status = EPhotoAddStatusWaiting;
            photo.publishTag = YES;
            if ([url isKindOfClass:NSURL.class]) {
                photo.localUrl = url;
            } else if ([url isKindOfClass:ALAsset.class]) {
                if (![self isAdded:[[(ALAsset *)url defaultRepresentation] url]]) {
                    photo.localUrl = [[(ALAsset *)url defaultRepresentation] url];
                    photo.thumbnail = CGImageRetain([(ALAsset *)url thumbnail]);
                }
            }
            [_uploadPhotos addObject:photo];
            [_indexLocationSelect addObject:@(-1)];
        }
    }
}

- (void)uploadCameraPhotos:(UIImage *)cameraPhoto url:(NSURL *)url forHouse:(EBHouse *)house getUpLoadPhotoBlock:retuenUpLoadPhotoBlock
{
    _house = house;
    _uploadPhotos = [[NSMutableArray alloc] init];
    _indexLocationSelect = [[NSMutableArray alloc] init];
    [self addCameraPhotosForUploading:cameraPhoto url:url];
    self.getUpLoadPhotoBlock = retuenUpLoadPhotoBlock;
}

- (void)addCameraPhotosForUploading:(UIImage *)cameraPhoto url:(NSURL *)url
{
    EBHousePhoto *photo = [[EBHousePhoto alloc] init];
    photo.localUrl = url;
    photo.houseId = _house.id;
    photo.houseType = [EBFilter typeString:_house.rentalState];
    photo.thumbnail = CGImageRetain(cameraPhoto.CGImage);
    photo.status = EPhotoAddStatusWaiting;
    [_uploadPhotos addObject:photo];
    [_indexLocationSelect addObject:@(-1)];
}

- (BOOL)isAdded:(NSURL*)url
{
    NSString *strNew=[url absoluteString];
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

- (BOOL)shouldPopOnBack
{
    [EBAlert confirmWithTitle:nil message:NSLocalizedString(@"confirm_leave_photo_upload", nil)
                          yes:NSLocalizedString(@"confirm_leave_condition_give_up", nil) action:^
    {

        [self.navigationController popViewControllerAnimated:YES];
    }];

    return NO;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _uploadPhotos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    EBHousePhoto *photo = (EBHousePhoto*)_uploadPhotos[row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"uploadPhotoCell"];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"uploadPhotoCell"];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //图片的imageView
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 36, 64, 64)];
        imageView.tag = 600;
        [cell.contentView addSubview:imageView];

        UIImage *image = [UIImage imageNamed:@"red_delete"];
        UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(60, 16, 40, 40)];
        [deleteBtn setImage:image forState:UIControlStateNormal];
        [deleteBtn setImage:[image imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted];
        deleteBtn.tag = 700;
        [deleteBtn addTarget:self action:@selector(deletePhoto:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:deleteBtn];
        if (!_isLocationEmpty)
        {
            [self addLine:cell.contentView xOffset:94.0 yOffset:90];
//            [self addLine:cell.contentView xOffset:94.0 yOffset:55.5];
            
            UIButton *selectLocBtn = [self createIconBt:CGRectMake(94, 50, [EBStyle screenWidth] - 94, 26) title:NSLocalizedString(@"location", nil)
                                                   text:photo.locationDesc];
            selectLocBtn.tag = 800;
            [cell.contentView addSubview:selectLocBtn];
            
            MHTextField *noteView = [[MHTextField alloc] initWithFrame:CGRectMake(94, 70, 226, 20)];
            noteView.textColor = [EBStyle blackTextColor];
            noteView.tag = 900;
            noteView.returnKeyType = UIReturnKeyDone;
            noteView.font = [UIFont systemFontOfSize:14.0];
            noteView.scrollView = tableView;
            noteView.hideToolBar = YES;
            noteView.textColor = [EBStyle blackTextColor];
            noteView.placeholderColor = [EBStyle grayTextColor];
            noteView.placeholder = NSLocalizedString(@"note", nil);
            [cell.contentView addSubview:noteView];
            noteView.delegate = self;
            [self pushTextField:noteView];
        }
        
    }

    //图片
    UIImageView *imageView = (UIImageView*)[cell.contentView viewWithTag:600];
    if (imageView)
    {
//        if (photo.publishTag)
//        {
//            [imageView setImageWithURL:photo.localUrl placeholderImage:nil];
//        }
//        else
//        {
//            imageView.image = [UIImage imageWithCGImage:photo.thumbnail];
//        }
        if ([[photo.localUrl absoluteString] hasPrefix:@"assets"]) {
            if (!photo.thumbnail) {
                ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
                [assetsLibrary assetForURL:photo.localUrl resultBlock:^(ALAsset *asset) {
                    photo.thumbnail = asset.thumbnail;
                    imageView.image = [UIImage imageWithCGImage:photo.thumbnail];
                } failureBlock:^(NSError *error) {
                    
                }];
            } else {
                imageView.image = [UIImage imageWithCGImage:photo.thumbnail];
            }
        } else {
            [imageView setImageWithURL:photo.localUrl placeholderImage:nil];
        }
    }

    UILabel *locLabel = (UILabel*)[[cell.contentView viewWithTag:800] viewWithTag:901];
    if (locLabel)
    {
        if (photo.locationDesc == nil)
        {
            //house_photo_add_location 请选择图片位子
            locLabel.textColor = [EBStyle grayTextColor];
            locLabel.text = NSLocalizedString(@"house_photo_add_location", nil);
        }
        else
        {
            if (photo.locationDesc.length < 1)
            {
                locLabel.textColor = [EBStyle grayTextColor];
                locLabel.text = NSLocalizedString(@"house_photo_add_location", nil);
            }
            else
            {
                locLabel.textColor = [EBStyle blueTextColor];
                locLabel.text = photo.locationDesc;
            }
        }
    }
    
    MHTextField *noteView = (MHTextField *)[cell.contentView viewWithTag:900];
    if (noteView)
    {
        noteView.text = photo.note;
    }
    noteView.alpha = 0;
    cell.contentView.tag = row;

    return cell;
}

#pragma mark tool

- (void)addLine:(UIView *)parent xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset
{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(xOffset, yOffset, [EBStyle screenWidth] - xOffset, 0.5)];
    line.backgroundColor = [EBStyle grayClickLineColor];
    [parent addSubview:line];
}

- (UIButton*)createIconBt:(CGRect)frame title:(NSString*)title text:(NSString*)text
{
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    [btn addTarget:self action:@selector(selectLocation:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont systemFontOfSize:14.0];
    titleLabel.textColor = [EBStyle blackTextColor];
    titleLabel.text = title;
    [btn addSubview:titleLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blue_accessory"]];
    imageView.frame = CGRectOffset(imageView.frame, btn.frame.size.width - imageView.frame.size.width - 10, (btn.frame.size.height - imageView.frame.size.height) / 2);
    [btn addSubview:imageView];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btn.frame.size.width - imageView.frame.size.width - 15, btn.frame.size.height)];
    textLabel.tag = 901;
    textLabel.textAlignment = NSTextAlignmentRight;
    textLabel.font = [UIFont systemFontOfSize:14.0];
    textLabel.textColor = [EBStyle grayTextColor];
    textLabel.text = text;
    [btn addSubview:textLabel];
    
    return btn;
}

- (void)deletePhoto:(UIButton*)btn
{
    _modifyTag = YES;
    NSInteger row = btn.superview.tag;
    _deleteRow = row;
    NSInteger count = [_tableView numberOfRowsInSection:0];
    for (int i = 0; i < count; i ++)
    {
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (cell)
        {
            MHTextField *noteView = (MHTextField *)[cell.contentView viewWithTag:900];
            if (noteView)
            {
                if ([noteView isFirstResponder])
                {
                    _endType = EMHTextFieldEndTypeDelete;
                }
            }
        }
    }
    
    [_uploadPhotos removeObjectAtIndex:row];
    [_indexLocationSelect removeObjectAtIndex:row];
//    [_tableView reloadData];
    [_tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)selectLocation:(UIButton*)btn
{
    _modifyTag = YES;
    NSInteger row = btn.superview.tag;
    EBHousePhoto *photo = (EBHousePhoto*)_uploadPhotos[row];

    NSArray *locations = [[EBCache sharedInstance] businessConfig].houseConfig.photoDescriptions;
    [[EBController sharedInstance] promptChoices:locations
                                      withChoice:[_indexLocationSelect[row] integerValue] title:NSLocalizedString(@"house_photo_add_location", nil)
                                          header:nil
                                          footer:nil completion:^(NSInteger rightChoice)
     {
         photo.locationDesc = locations[rightChoice];
         NSNumber *num = [NSNumber numberWithInteger:rightChoice];
         _indexLocationSelect[row] = num;
//         if (photo.note)
//         {
//             if (photo.note.length < 1)
//             {
//                 photo.note = locations[rightChoice];
//             }
//         }
//         else
//         {
//             photo.note = locations[rightChoice];
//         }
         [_tableView reloadData];
     }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
   for (MHTextField *field in _textFields)
   {
       [field resignFirstResponder];
   }

   _tableView.contentOffset = CGPointMake(0, 0);
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSInteger index = textField.superview.tag;
    if (_endType == EMHTextFieldEndTypeEdit)
    {
        
        EBHousePhoto *photo = _uploadPhotos[index];
        photo.note = textField.text;
    }
    else
    {
        _endType = EMHTextFieldEndTypeEdit;
        if (_deleteRow < index)
        {
            if (index + 1 < _uploadPhotos.count)
            {
                EBHousePhoto *photo = _uploadPhotos[index + 1];
                photo.note = textField.text;
            }
        }
        else if (_deleteRow > index)
        {
            EBHousePhoto *photo = _uploadPhotos[index];
            photo.note = textField.text;
        }
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self.keyboardWillHideNotificationObserver];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _modifyTag = YES;
    [self setKeyboardWillHideNotificationObserver:[[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *notification){
        [self keyboardWillHide:notification];
    }]];
}

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    UITextField *textField;
//    [textField resignFirstResponder];
//}

- (void)pushTextField:(MHTextField *)textField
{
    if (_textFields == nil)
    {
        _textFields = [[NSMutableArray alloc] init];
    }

    [_textFields addObject:textField];
    textField.textFields = _textFields;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    //    CGRect currentFrame = [self convertRect:self.bounds toView:superScrollview];
//    CGRect originFrame = _tableView.frame;
//    CGFloat height;
//    CGFloat contenFloat;
//    if (_tableView.contentSize.height < originFrame.size.height) {
//        contenFloat = originFrame.size.height;
//    }
//    else
//    {
//        contenFloat = _tableView.contentSize.height;
//    }
//    
//    if (contenFloat - _tableView.contentOffset.y > originFrame.size.height)
//    {
//        height = _tableView.contentOffset.y;
//    }
//    else
//    {
//        height = contenFloat - originFrame.size.height;
//    }
//    [_tableView setContentOffset:CGPointMake(0, height) animated:YES];
}



@end
