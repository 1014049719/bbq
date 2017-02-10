//
//  BBQDynamicViewModel.m
//  BBQ
//
//  Created by 朱琨 on 15/11/17.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import "BBQDynamicViewModel.h"
#import "BBQDynamicCell.h"
#import "BBQDynamicFactory.h"
#import "BBQFetchDynamicApi.h"
#import "BBQDeleteDynamicApi.h"
#import "BBQAddCommentApi.h"
#import "BBQDeleteCommentApi.h"
#import "BBQDynamicTableViewController.h"
#import <DateTools.h>
#import <BlocksKit.h>
#import "BBQPublishManager.h"
#import "BBQDynamicLikeApi.h"

static NSString * const kDynamicMenuCellIdentifier = @"kDynamicMenuCellIdentifier";

@interface BBQDynamicViewModel ()

@property (assign, readwrite, nonatomic) BBQDynamicGroupType groupType;
@property (strong, nonatomic) YYThreadSafeArray *dataSource;
@property (strong, nonatomic) YYThreadSafeArray *layouts;
@property (copy, readwrite, nonatomic) NSNumber *baobaouid;
@property (copy, readwrite, nonatomic) NSNumber *classuid;
@property (copy, readwrite, nonatomic) NSNumber *schoolid;
@property (copy, readwrite, nonatomic) NSString *navTitle;
@property (strong, nonatomic) BBQFetchDynamicApi *loadLatestApi;
@property (strong, nonatomic) BBQFetchDynamicApi *loadMoreApi;
@property (assign, nonatomic) BOOL showWelcome;

@end

@implementation BBQDynamicViewModel

@synthesize selectedDate = _selectedDate;

#pragma mark - Init
+ (instancetype)viewModelWithObject:(id)object {
    BBQDynamicViewModel *viewModel;
    viewModel.model = object;
    if ([object isKindOfClass:[BBQBabyModel class]]) {
        viewModel = [BBQDynamicViewModel viewModelForBaby:((BBQBabyModel *)object).uid];
        viewModel.navTitle = ((BBQBabyModel *)object).realname;
    } else if ([object isKindOfClass:[BBQClassDataModel class]]) {
        viewModel = [BBQDynamicViewModel viewModelForClass:((BBQClassDataModel *)object).classid inSchool:TheCurUser.curSchool.schoolid];
        viewModel.navTitle = ((BBQClassDataModel *)object).classname;
    } else if ([object isKindOfClass:[BBQSchoolDataModel class]]) {
        viewModel = [BBQDynamicViewModel viewModelForSchool:((BBQSchoolDataModel *)object).schoolid];
        viewModel.navTitle = ((BBQSchoolDataModel *)object).schoolname;
    } else if ([object isKindOfClass:[BBQTopicsModel class]]) {
        viewModel = [BBQDynamicViewModel viewModelForSquareWithTopic:object];
    }
    return viewModel;
}

+ (instancetype)viewModelForBaby:(NSNumber *)baobaouid {
    return [[BBQDynamicViewModel alloc] initWithGroupType:BBQDynamicGroupTypeBaby baobaouid:baobaouid classuid:nil schoolid:nil];
}

+ (instancetype)viewModelForBabiesInClass:(NSNumber *)classuid {
    BBQDynamicViewModel *vm = [[BBQDynamicViewModel alloc] initWithGroupType:BBQDynamicGroupTypeBaby baobaouid:nil classuid:classuid schoolid:TheCurUser.curSchool.schoolid];
    vm.needHeader = NO;
    vm.schoolid = @0;
    return vm;
}

+ (instancetype)viewModelForBabiesInSchool:(NSNumber *)schoolid {
    BBQDynamicViewModel *vm = [[BBQDynamicViewModel alloc] initWithGroupType:BBQDynamicGroupTypeBaby baobaouid:nil classuid:nil schoolid:schoolid];
    vm.needHeader = NO;
    return vm;
}

+ (instancetype)viewModelForClass:(NSNumber *)classuid inSchool:(NSNumber *)schoolid {
    return [[BBQDynamicViewModel alloc] initWithGroupType:BBQDynamicGroupTypeClass baobaouid:nil classuid:classuid schoolid:schoolid];
}

+ (instancetype)viewmodelForClassesInSchool:(NSNumber *)schoolid {
    return [[BBQDynamicViewModel alloc] initWithGroupType:BBQDynamicGroupTypeClass baobaouid:nil classuid:nil schoolid:schoolid];
}

+ (instancetype)viewModelForSchool:(NSNumber *)schoolid {
    BBQDynamicViewModel *vm = [[BBQDynamicViewModel alloc] initWithGroupType:BBQDynamicGroupTypeSchool baobaouid:nil classuid:nil schoolid:schoolid];
    vm.needHeader = NO;
    return vm;
}

+ (instancetype)viewModelForSquareWithTopic:(BBQTopicsModel *)topic {
    BBQDynamicViewModel *viewModel = [[BBQDynamicViewModel alloc] initWithGroupType:BBQDynamicGroupTypeSquare baobaouid:nil classuid:nil schoolid:nil];
    viewModel.needHeader = NO;
    viewModel.topic = topic;
    return viewModel;
}

- (instancetype)initWithGroupType:(BBQDynamicGroupType)groupType baobaouid:(NSNumber *)baobaouid classuid:(NSNumber *)classuid schoolid:(NSNumber *)schoolid {
    if (self = [super init]) {
        _needHeader = YES;
        _groupType = groupType;
        _baobaouid = baobaouid ?: @0;
        _classuid = classuid ?: TheCurBaoBao.curClass.classid;
        _schoolid = schoolid ?: TheCurBaoBao.curSchool.schoolid;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePublishDynamicNotification:) name:kPublishDynamicNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCancelPublishDynamicNotification:) name:kCancelPublishDynamicNotification object:nil];
    }
    return self;
}

#pragma mark - Stateful Delegate
- (void)tableViewControllerWillBeginInitialLoad:(BBQTableViewController *)tvc completion:(void (^)(BOOL, BOOL))completion {
    @weakify(self)
    void (^finishBlock)(NSArray *) = ^(NSArray *dynamics) {
        @strongify(self)
        self.showWelcome = dynamics.count ? NO : YES;
        BBQDynamicLayoutStyle style = self.groupType == BBQDynamicGroupTypeSquare ? BBQDynamicLayoutStyleSquareTimeline : BBQDynamicLayoutStyleTimeline;
        if (self.showWelcome) {
            dynamics = @[[Dynamic dynamicForWelcomeWithType:self.groupType date:_selectedDate]];
            style = BBQDynamicLayoutStyleWelcome;
        }
        NSArray *layouts = [dynamics bk_map:^id(Dynamic *dynamic) {
            return [BBQDynamicFactory layoutWithDynamic:dynamic style:style];
        }];
        dispatch_async_on_main_queue(^{
            [self.layouts removeAllObjects];
            [self.layouts addObjectsFromArray:layouts];
            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:dynamics];
            [self.viewController.tableView reloadData];
            completion(self.dataSource.count == 0, NO);
            [[BBQPublishManager sharedManager] startWorking];
        });
    };
    
    [self loadDynamicFromLocalWithParams:[self requestParamsWithRefreshType:BBQRefreshTypePullDown fromLocal:YES] completion:^(NSArray *array) {
        @strongify(self)
        if (array.count) {
            finishBlock(array);
        }
        self.loadLatestApi.params = [self requestParamsWithRefreshType:BBQRefreshTypePullDown fromLocal:NO];
        [self.loadLatestApi startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSArray *dynamics = [NSArray modelArrayWithClass:[Dynamic class] json:request.responseJSONObject[@"data"][@"dynaarr"]];
                self.viewController.canLoadMore = dynamics.count >= 10;
#ifndef TARGET_PARENT
                [Dynamic clearTableSync:nil];
#endif
                [dynamics bk_each:^(Dynamic *obj) {
                    [obj insertUpdateSyncToDB:nil];
                }];
                finishBlock(dynamics);
            });
        } failure:^(YTKBaseRequest *request) {
            @strongify(self)
            completion(self.dataSource.count == 0, request.requestOperation.error && !self.dataSource.count ? YES : NO);
        }];
    }];
}

- (void)tableViewControllerWillBeginLoadingFromPullToRefresh:(BBQTableViewController *)tvc completion:(void (^)(BOOL, BOOL))completion {
    @weakify(self)
    void (^finishBlock)(NSArray *) = ^(NSArray *dynamics) {
        @strongify(self)
        self.showWelcome = dynamics.count ? NO : YES;
        BBQDynamicLayoutStyle style = self.groupType == BBQDynamicGroupTypeSquare ? BBQDynamicLayoutStyleSquareTimeline : BBQDynamicLayoutStyleTimeline;
        if (self.showWelcome) {
            dynamics = @[[Dynamic dynamicForWelcomeWithType:self.groupType date:_selectedDate]];
            style = BBQDynamicLayoutStyleWelcome;
        }
        
        NSArray *layouts = [dynamics bk_map:^id(Dynamic *dynamic) {
            return [BBQDynamicFactory layoutWithDynamic:dynamic style:style];
        }];
        dispatch_async_on_main_queue(^{
            [self.layouts removeAllObjects];
            [self.layouts addObjectsFromArray:layouts];
            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:dynamics];
            [self.viewController.tableView reloadData];
            completion(NO, NO);
        });
    };
    
    if (kNetworkNotReachability) {
        [self loadDynamicFromLocalWithParams:[self requestParamsWithRefreshType:BBQRefreshTypePullDown fromLocal:YES] completion:finishBlock];
    } else {
        self.loadLatestApi.params = [self requestParamsWithRefreshType:BBQRefreshTypePullDown fromLocal:NO];
        [self.loadLatestApi startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSArray *dynamics = [NSArray modelArrayWithClass:[Dynamic class] json:request.responseJSONObject[@"data"][@"dynaarr"]];
                self.viewController.canLoadMore = dynamics.count >= 10;
#ifndef TARGET_PARENT
                [Dynamic clearTableSync:nil];
#endif
                [dynamics bk_each:^(Dynamic *obj) {
                    [obj insertUpdateSyncToDB:nil];
                }];
                finishBlock(dynamics);
            });
        } failure:^(YTKBaseRequest *request) {
            @strongify(self)
            completion(self.dataSource.count == 0, request.requestOperation.error ? YES : NO);
        }];
    }
}

- (void)tableViewControllerWillBeginLoadingMore:(BBQTableViewController *)tvc completion:(void (^)(BOOL, BOOL, BOOL))completion {
    @weakify(self)
    void (^finishBlock)(NSArray *) = ^(NSArray *dynamics) {
        @strongify(self)
        BBQDynamicLayoutStyle style = self.groupType == BBQDynamicGroupTypeSquare ? BBQDynamicLayoutStyleSquareTimeline : BBQDynamicLayoutStyleTimeline;
        NSArray *layouts = [dynamics bk_map:^id(Dynamic *dynamic) {
            return [BBQDynamicFactory layoutWithDynamic:dynamic style:style];
        }];
        NSMutableArray *tempDynamics = [NSMutableArray arrayWithArray:self.dataSource];
        [tempDynamics addObjectsFromArray:dynamics];
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (Dynamic *dynamic in dynamics) {
            NSInteger idx = [tempDynamics indexOfObject:dynamic];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            [indexPaths addObject:indexPath];
        }
        dispatch_async_on_main_queue(^{
            [self.viewController.tableView beginUpdates];
            [self.layouts addObjectsFromArray:layouts];
            [self.dataSource addObjectsFromArray:dynamics];
            [self.viewController.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [self.viewController.tableView endUpdates];
            completion(YES, NO, NO);
        });
    };
    
    if (kNetworkNotReachability) {
        [self loadDynamicFromLocalWithParams:[self requestParamsWithRefreshType:BBQRefreshTypePullUp fromLocal:YES] completion:finishBlock];
    } else {
        self.loadMoreApi.params = [self requestParamsWithRefreshType:BBQRefreshTypePullUp fromLocal:NO];
        [self.loadMoreApi startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSArray *dynamics = [NSArray modelArrayWithClass:[Dynamic class] json:request.responseJSONObject[@"data"][@"dynaarr"]];
#ifdef TARGET_PARENT
                [dynamics bk_each:^(Dynamic *obj) {
                    [obj insertUpdateSyncToDB:nil];
                }];
#endif
                finishBlock(dynamics);
            });
        } failure:^(YTKBaseRequest *request) {
            completion(YES, request.requestOperation.error ? YES : NO, YES);
        }];
    }
}

- (void)loadDynamicFromLocalWithParams:(NSDictionary *)params completion:(void (^)(NSArray *array))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [Dynamic dynamicsWithParams:params completion:^(NSArray *dynamics) {
            if (completion) completion(dynamics);
        }];
    });
}

#pragma mark - Public Method
- (NSInteger)indexOfDynamic:(Dynamic *)dynamic {
    if ([self.dataSource containsObject:dynamic]) {
        return [self.dataSource indexOfObject:dynamic];
    }
    
    __block NSInteger index = NSNotFound;
    [self.dataSource enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(Dynamic *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.localid isEqualToString:dynamic.localid] || [obj.guid isEqualToString:dynamic.guid]) {
            *stop = YES;
            index = idx;
        }
    }];
    
    return index;
}

- (void)handleDateViewForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    BBQDynamicCell *dynamicCell = (BBQDynamicCell *)cell;
    if (dynamicCell.layout.style != BBQDynamicLayoutStyleTimeline) return;
    
    if (indexPath.row == 0) {
        [dynamicCell.dynamicView showDateView:YES];
    } else {
        NSDate *curDate = [NSDate dateWithTimeIntervalSince1970:
                           [self.dataSource[indexPath.row] graphtime].integerValue];
        NSDate *preDate = [NSDate dateWithTimeIntervalSince1970:
                           [self.dataSource[indexPath.row - 1] graphtime].integerValue];
        [dynamicCell.dynamicView showDateView:![curDate isSameDay:preDate]];
    }
}

- (void)deleteDynamic:(Dynamic *)dynamic {
    self.curDynamic = dynamic;
    [Dynamic deleteDynamic:dynamic];
}

- (void)addComment:(Comment *)comment withDynamic:(Dynamic *)dynamic {
    self.curDynamic = dynamic;
    [dynamic addComment:comment];
}

- (void)deleteComment:(Comment *)comment withDynamic:(Dynamic *)dynamic {
    self.curDynamic = dynamic;
    [dynamic deleteComment:comment];
}

- (void)likeDynamic:(Dynamic *)dynamic {
    [dynamic like];
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ((BBQDynamicLayout *)self.layouts[indexPath.row]).height;
}

#pragma mark - Table View Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.layouts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier;
    if (self.groupType == BBQDynamicGroupTypeSquare) {
        identifier = kDynamicCellSquareTimelineIdentifier;
    } else {
        identifier = kDynamicCellTimelineIdentifier;
    }
    BBQDynamicCell *dynamicCell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    dynamicCell.delegate = self.viewController;
    dynamicCell.layout = self.layouts[indexPath.row];
    return dynamicCell;
}

#pragma mark - Action


#pragma mark - Private Method
- (BOOL)shouldHandlePublishDynamic:(Dynamic *)dynamic {
    BOOL should = NO;
    if ([dynamic.dtype isEqualToNumber:@(self.groupType)]) {
        switch (self.groupType) {
            case BBQDynamicGroupTypeBaby: {
#ifdef TARGET_PARENT
                if ([dynamic.baobaouid isEqualToNumber:self.baobaouid]) {
                    should = YES;
                }
#else
                if ([dynamic.baobaouid isEqualToNumber:self.baobaouid] || [dynamic.classuid isEqualToNumber:self.classuid]) {
                    should = YES;
                }
#endif
                break;
            }
            case BBQDynamicGroupTypeClass: {
                if ([dynamic.classuid isEqualToNumber:self.classuid]) {
                    should = YES;
                }
                break;
            }
            case BBQDynamicGroupTypeSchool: {
                if ([dynamic.schoolid isEqualToNumber:self.schoolid]) {
                    should = YES;
                }
                break;
            }
            case BBQDynamicGroupTypeSquare: {
                if ([[dynamic.ispajs stringValue] isEqualToString:self.topic.id]) {
                    should = YES;
                }
                break;
            }
        }
    }
    
    return should;
}

- (void)handlePublishDynamicNotification:(NSNotification *)notification {
    Dynamic *dynamic = notification.object;
    if ([self shouldHandlePublishDynamic:dynamic]) {
        //等待上传时添加动态
        if (dynamic.uploadState == BBQDynamicUploadStateWaiting) {
            BBQDynamicLayoutStyle style;
            if (self.groupType == BBQDynamicGroupTypeSquare) {
                style = BBQDynamicLayoutStyleSquareTimeline;
            } else {
                style = BBQDynamicLayoutStyleTimeline;
            }
            BBQDynamicLayout *layout = [BBQDynamicFactory layoutWithDynamic:dynamic style:style];
            NSInteger index = [self indexOfDynamic:dynamic];
            if (index != NSNotFound) {
                [self.layouts replaceObjectAtIndex:index withObject:layout];
                [self.dataSource replaceObjectAtIndex:index withObject:dynamic];
                [self.viewController.tableView reloadRow:[self.dataSource indexOfObject:dynamic] inSection:0 withRowAnimation:UITableViewRowAnimationNone];
            } else {
                if (self.showWelcome) {
                    [self.layouts replaceObjectAtIndex:0 withObject:layout];
                    [self.dataSource replaceObjectAtIndex:0 withObject:dynamic];
                    [self.viewController.tableView reloadRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
                    self.showWelcome = NO;
                }  else {
                    [self.layouts insertObject:layout atIndex:0];
                    [self.dataSource insertObject:dynamic atIndex:0];
                    [self.viewController.tableView insertRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
                    [self resetDateView];
                }
            }
        } else {
            [self reloadDynamic:dynamic];
        }
    }
}

- (void)handleCancelPublishDynamicNotification:(NSNotification *)notification {
    Dynamic *dynamic = notification.object;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([self shouldHandlePublishDynamic:dynamic]) {
            NSInteger index = [self indexOfDynamic:dynamic];
            if (index != NSNotFound) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.layouts removeObjectAtIndex:index];
                    [self.dataSource removeObjectAtIndex:index];
                    [self.viewController.tableView deleteRow:index inSection:0 withRowAnimation:UITableViewRowAnimationNone];
                });
            }
        }
    });
}

- (void)reloadDynamic:(Dynamic *)dynamic {
    if ([self.dataSource containsObject:dynamic]) {
        if (dynamic.uploadState == BBQDynamicUploadStateUploading) {
            return;
        }
        NSInteger idx = [self.dataSource indexOfObject:dynamic];
        BBQDynamicLayoutStyle style;
        if (self.groupType == BBQDynamicGroupTypeSquare) {
            style = BBQDynamicLayoutStyleSquareTimeline;
        } else {
            style = BBQDynamicLayoutStyleTimeline;
        }
        BBQDynamicLayout *layout = [BBQDynamicFactory layoutWithDynamic:dynamic style:style];
        dispatch_async_on_main_queue(^{
            [self.layouts replaceObjectAtIndex:idx withObject:layout];
            [self.viewController.tableView reloadRow:idx inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        });
    } else {
        BBQDynamicLayoutStyle style;
        if (self.groupType == BBQDynamicGroupTypeSquare) {
            style = BBQDynamicLayoutStyleSquareTimeline;
        } else {
            style = BBQDynamicLayoutStyleTimeline;
        }
        BBQDynamicLayout *layout = [BBQDynamicFactory layoutWithDynamic:dynamic style:style];
        dispatch_async_on_main_queue(^{
            [self.layouts insertObject:layout atIndex:0];
            [self.dataSource insertObject:dynamic atIndex:0];
            [self.viewController.tableView insertRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        });
    }
}

- (void)resetDateView {
    dispatch_async_on_main_queue(^{
        [self.viewController.tableView.indexPathsForVisibleRows enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
            BBQDynamicCell *cell = [self.viewController.tableView cellForRowAtIndexPath:indexPath];
            [self handleDateViewForCell:cell atIndexPath:indexPath];
            [self.viewController.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
        }];
    });
}

- (NSDictionary *)requestParamsWithRefreshType:(BBQRefreshType)type fromLocal:(BOOL)isLocal {
    NSNumber *dateline;
    NSString *guid;
    if (type == BBQRefreshTypePullDown) {
        dateline = @([self.selectedDate timeIntervalSince1970]);
        guid = @"0";
    } else {
        dateline = ((Dynamic *)self.dataSource.lastObject).graphtime;
        guid = ((Dynamic *)self.dataSource.lastObject).guid;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                  @"baobaouid" : self.baobaouid ?: @"",
                                                                                  @"classuid" : self.classuid ?: @"",
                                                                                  @"schoolid" : self.schoolid ?: @"",
                                                                                  @"dtype" : @(self.groupType),
                                                                                  @"type" : @2,
                                                                                  @"dateline" : dateline,
                                                                                  @"guid" : guid,
                                                                                  }];
    if (self.groupType == BBQDynamicGroupTypeSquare) {
        if (isLocal) {
            [params addEntriesFromDictionary:@{
                                               @"ispajs": self.topic.id
                                               }];
        } else {
            [params addEntriesFromDictionary:@{
                                               @"catid": self.topic.id
                                               }];
        }
    }
    return params;
}

#pragma mark - Getter & Setter
- (YYThreadSafeArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [YYThreadSafeArray array];
    }
    return _dataSource;
}

- (YYThreadSafeArray *)layouts {
    if (!_layouts) {
        _layouts = [YYThreadSafeArray array];
    }
    return _layouts;
}

- (BBQFetchDynamicApi *)loadLatestApi {
    if (!_loadLatestApi) {
        _loadLatestApi = [[BBQFetchDynamicApi alloc] initWithParams:[self requestParamsWithRefreshType:BBQRefreshTypePullDown fromLocal:NO]];
    }
    return _loadLatestApi;
}

- (BBQFetchDynamicApi *)loadMoreApi {
    if (!_loadMoreApi) {
        _loadMoreApi = [[BBQFetchDynamicApi alloc] initWithParams:[self requestParamsWithRefreshType:BBQRefreshTypePullUp fromLocal:NO]];
    }
    return _loadMoreApi;
}

- (void)setCurDynamic:(Dynamic *)curDynamic {
    if (_curDynamic != curDynamic) {
        [_curDynamic bk_removeAllBlockObservers];
        _curDynamic = curDynamic;
        @weakify(self)
        [curDynamic bk_addObserverForKeyPaths:@[@"content", @"attachinfo", @"giftdata", @"reply", @"flag", @"browsecount"] options:NSKeyValueObservingOptionNew task:^(Dynamic *dynamic, NSString *keyPath, NSDictionary *change) {
            @strongify(self)
            if ([keyPath isEqualToString:@"flag"]) {
                NSInteger index = [self.dataSource indexOfObject:dynamic];
                if (index != NSNotFound) {
                    dispatch_async_on_main_queue(^{
                        [self.dataSource removeObjectAtIndex:index];
                        [self.layouts removeObjectAtIndex:index];
                        [self.viewController.tableView deleteRow:index inSection:0 withRowAnimation:UITableViewRowAnimationFade];
                        if (!self.dataSource.count) {
                            Dynamic *dynamic = [Dynamic dynamicForWelcomeWithType:self.groupType date:_selectedDate];
                            BBQDynamicLayout *layout = [BBQDynamicFactory layoutWithDynamic:dynamic style:BBQDynamicLayoutStyleWelcome];
                            [self.dataSource addObject:dynamic];
                            [self.layouts addObject:layout];
                            [self.viewController.tableView reloadData];
                            self.showWelcome = YES;
                        }
                        [self resetDateView];
                    });
                }
            } else {
                [self reloadDynamic:dynamic];
            }
        }];
    }
}

- (NSDate *)selectedDate {
    if(!_selectedDate) {
        _selectedDate = [NSDate date];
    }
    return [[NSDate dateWithYear:[_selectedDate year] month:[_selectedDate month] day:[_selectedDate day] hour:0 minute:0 second:0] dateByAddingDays:1];
}

- (void)setSelectedDate:(NSDate *)selectedDate {
    _selectedDate = selectedDate;
    //    [self.viewController.refresh beginRefreshing];
    [self.viewController triggerPullToRefresh];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
