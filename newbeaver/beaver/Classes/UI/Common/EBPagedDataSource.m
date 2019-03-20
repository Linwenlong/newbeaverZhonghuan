//
// Created by 何 义 on 14-3-20.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBPagedDataSource.h"
#import "EBFilter.h"
#import "EBHouse.h"


@implementation EBPagedDataSource
{
    BOOL _hasMore;
}

- (BOOL)itemExist:(id)item
{
    for (id obj in self.dataArray)
    {
        if ([[obj performSelector:@selector(id)] isEqualToString:[item performSelector:@selector(id)] ])
        {
            return YES;
        }
    }
    return NO;
}

- (CGFloat)heightOfRow:(NSInteger)row
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRow:(NSInteger)row
{
   if (tableView.isEditing)
   {
       [_selectedSet addObject:_dataArray[row]];
   }
}

- (void)tableView:(UITableView *)tableView didDeselectRow:(NSInteger)row
{
    if (tableView.isEditing)
    {
        [_selectedSet removeObject:_dataArray[row]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRow:(NSInteger)row
{
    return nil;
}

- (NSInteger)numberOfRows
{
    return _dataArray.count;
}

- (NSMutableDictionary *)pageArgs
{
    NSMutableDictionary *args = [_filter currentArgs];
    if (!args)
    {
        args = [[NSMutableDictionary alloc] init];
    }
    args[@"page"] = @(_page);
    args[@"page_size"] = @(_pageSize);

    return args;
}

- (void)refresh:(BOOL)force handler:(void (^)(BOOL success, id result))done
{
    _page = 1;
    if (_pageSize <= 0)
    {
        _pageSize = 10;
    }

    NSMutableDictionary *params = [self pageArgs];
    params[@"force_refresh"] = @(force);

    _requestBlock(params, ^(BOOL success, id result)
    {
        if (success)
        {
            _dataArray = result;
            if (_dataArray == nil)
            {
                _dataArray = [[NSMutableArray alloc] init];
            }
            _selectedSet = [[NSMutableSet alloc] init];
            _hasMore = _dataArray.count >= _pageSize;
        }

        done(success, result);
    });
}

- (void)loadMore:(void (^)(BOOL success, id result))done
{
    _page += 1;

    _requestBlock([self pageArgs], ^(BOOL success, id result)
    {
        if (success)
        {
            NSMutableArray *newArray = (NSMutableArray *)result;
            NSInteger count = newArray.count;
            for (NSInteger i = count - 1; i >= 0; i--)
            {
                id item = newArray[i];
                if ([item isKindOfClass:[EBHouse class]])
                {
                   EBHouse *newHouse = (EBHouse *)item;
                   for (EBHouse *house in _dataArray)
                   {
                      if ([newHouse.id isEqualToString:house.id])
                      {
                          [newArray removeObject:newHouse];
                          break;
                      }
                   }
                } else {
                    break;
                }
            }

            count = newArray.count;
            [_dataArray addObjectsFromArray:newArray];
            _hasMore =  count >= _pageSize;
        }

        done(success, result);
    });
}

- (BOOL)hasMore
{
    return _hasMore;
}

- (void)clearData
{
    _dataArray = nil;
    _selectedSet = [[NSMutableSet alloc] init];
    _hasMore = NO;
}

@end