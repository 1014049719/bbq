//
//  BBQDynamicDetailViewController.m
//  BBQ
//
//  Created by 朱琨 on 16/1/17.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQDynamicDetailViewController.h"
#import "BBQDynamicCell.h"
#import <KxMenu.h>
#import "ShareView.h"
#import "ReceivedGiftViewController.h"
#import "GiftViewController.h"
#import "AppMacro.h"
#import <QBPopupMenu.h>
#import "UserDataShowViewController.h"
#import "CheckTools.h"
#import <UINavigationBar+Awesome.h>
#import "UIMessageInputView.h"
#import <BlocksKit+UIKit.h>
#import "MJPhotoBrowser.h"
#import "BBQPublishManager.h"
#import "BBQMoviePlayerViewController.h"
#import "BBQDynamicEditViewController.h"
#import "BBQForwardDynamicApi.h"
#import "BBQFetchAppointedDynamicApi.h"

@interface BBQDynamicDetailViewController () <UITableViewDataSource, UIMessageInputViewDelegate>

@property (strong, nonatomic) Dynamic *dynamic;
@property (strong, nonatomic) BBQDynamicLayout *layout;
@property (strong, nonatomic) YYThreadSafeArray *commentLayouts;
@property (copy, nonatomic) NSString *guid;
@property (strong, nonatomic) BBQFetchAppointedDynamicApi *fetchApi;
@property (assign, nonatomic) NSInteger indexOfTargetComment;
@property (assign, nonatomic) BOOL isMenuShowing;
@property (strong, nonatomic) QBPopupMenu *popupMenu;
@property (strong, nonatomic) UIButton *rightMenuButton;
@property (strong, nonatomic) UIMessageInputView *inputView;
@property (strong, nonatomic) UIView *commentSender;
@property (assign, nonatomic) BOOL commentIsReply;
@property (assign, nonatomic) CGFloat oldPanOffsetY;
@property (assign, nonatomic) NSInteger deleteIndex;
@property (strong, nonatomic) Comment *curComment;

@end

@implementation BBQDynamicDetailViewController

#pragma mark - Init
- (instancetype)initWithDynamic:(Dynamic *)dynamic {
    if (self = [super init]) {
        _dynamic = dynamic;
        _guid = dynamic.guid;
        [self onInit];
    }
    return self;
}

- (instancetype)initWithDynamicGuid:(NSString *)guid {
    if (self = [super init]) {
        _guid = guid;
    }
    return self;
}

- (void)onInit {
    [super onInit];
    self.needLoadMore = NO;
    self.needPullToRefresh = NO;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self triggerInitialLoad];
    [self.tableView registerClass:[BBQDynamicCell class] forCellReuseIdentifier:kDynamicCellDetailIdentifier];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:kDynamicCellDetailIdentifier forIndexPath:indexPath];
    } else {
        
    }
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.layout.height;
    }
    return 0;
}

#pragma mark - Stateful Delegate
- (void)tableViewControllerWillBeginInitialLoad:(BBQTableViewController *)tvc completion:(void (^)(BOOL, BOOL))completion {
    if (self.dynamic) {
        dispatch_async_on_main_queue(^{
            [self.tableView reloadData];
            completion(NO, NO);
        });
    } else if ([self.guid isNotBlank]) {
        @weakify(self)
        [self.fetchApi startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest *request) {
            @strongify(self)
            dispatch_async_on_main_queue(^{
                self.dynamic = [Dynamic modelWithJSON:request.responseJSONObject[@"data"]];
                self.layout = [[BBQDynamicLayout alloc] initWithDynamic:self.dynamic style:BBQDynamicLayoutStyleDetail];
                [self.tableView reloadData];
                completion(NO, NO);
            });
        } failure:^(__kindof YTKBaseRequest *request) {
            completion(YES, YES);
        }];
    }
}

#pragma mark - UIMessageInputViewDelegate
- (void)messageInputView:(UIMessageInputView *)inputView
                sendText:(NSString *)text {
    CheckNetwork
    if (!_commentIsReply) {
        Comment *newComment = [Comment commentWithDynamic:self.dynamic comment:nil];
        self.curComment = newComment;
    }
    self.curComment.content = text;
//    [self addComment];
}

- (void)messageInputView:(UIMessageInputView *)inputView
   heightToBottomChanged:(CGFloat)heightToBottom {
    [UIView animateWithDuration:0.25
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromBottom
                     animations:^{
                         UIEdgeInsets contentInsets = UIEdgeInsetsMake(
                                                                       0.0, 0.0,
                                                                       MAX(CGRectGetHeight(inputView.frame), heightToBottom),
                                                                       0.0);
                         ;
                         CGFloat msgInputY = kScreenHeight - heightToBottom - 64;
                         
                         self.tableView.contentInset = contentInsets;
                         self.tableView.scrollIndicatorInsets = contentInsets;
                         
                         if ([_commentSender isKindOfClass:[UIView class]] &&
                             !self.tableView.isDragging && heightToBottom > 60) {
                             UIView *senderView = _commentSender;
                             CGFloat senderViewBottom =
                             [self.tableView convertPoint:CGPointZero
                                                 fromView:senderView]
                             .y +
                             CGRectGetMaxY(senderView.bounds);
                             CGFloat contentOffsetY =
                             MAX(0, senderViewBottom - msgInputY);
                             [self.tableView
                              setContentOffset:CGPointMake(0, contentOffsetY)
                              animated:YES];
                         }
                     }
                     completion:nil];
}

#pragma mark - Action
- (void)didClickEditButton {
    CheckNetwork
    UIStoryboard *sb =
    [UIStoryboard storyboardWithName:@"Dynamic" bundle:nil];
    BBQDynamicEditViewController *vc =
    [sb instantiateViewControllerWithIdentifier:@"DynamicEditVC"];
    vc.dynamic = self.dynamic;
    vc.dynamic.reedit = YES;
    vc.dynamic.setDate = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didClickShareButton {
    CheckNetwork
    ShareView *shareView = [ShareView sharedInstance];
    shareView.guid = self.guid;
    shareView.model = self.dynamic;
    shareView.shareType = BBQShareTypeDynamic;
    [shareView showShareView];
}

- (void)didClickDeleteButton {
    CheckNetwork
    UIAlertView *alert =
    [UIAlertView bk_showAlertViewWithTitle:@"警告"
                                   message:@"确定删除本条动态？"
                         cancelButtonTitle:@"取消"
                         otherButtonTitles:@[ @"确定" ]
                                   handler:^(UIAlertView *alertView,
                                             NSInteger buttonIndex) {
                                       if (buttonIndex == 1) {
                                           [self deleteCurrentDynamic];
                                       }
                                   }];
    [alert show];
}

- (void)didClickForwardButton {
    CheckNetwork
    [SVProgressHUD showWithStatus:@"请稍候"];
    BBQForwardDynamicApi *api = [[BBQForwardDynamicApi alloc] initWithDynamic:self.dynamic];
//    @weakify(self)
//    [api startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
//        @strongify(self)
//        BBQFetchAppointedDynamicApi *dynamicApi = [[BBQFetchAppointedDynamicApi alloc] initWithGuid:request.responseJSONObject[@"data"][@"guid"]];
//        [dynamicApi startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest *request) {
//            Dynamic *dynamic = [Dynamic modelWithJSON:request.responseJSONObject[@"data"]];
//            [dynamic insertUpdateSyncToDB:nil];
//            [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:kPublishDynamicNotification object:dynamic];
//            ShowInfoWithCompletion(BBQHUDTypeSuccess, @"动态转发成功！", ^{
//                [self.navigationController popToRootViewControllerAnimated:YES];
//            });
//        } failure:^(__kindof YTKBaseRequest *request) {
//            ShowApiError
//        }];
//    } failure:^(YTKBaseRequest *request) {
//        ShowApiError
//    }];
}

- (void)deleteCurrentDynamic {
    CheckNetwork
    [Dynamic deleteDynamic:self.dynamic];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Getter & Setter
- (BBQFetchAppointedDynamicApi *)fetchApi{
    if (!_fetchApi) {
//        _fetchApi = [[BBQFetchAppointedDynamicApi alloc] initWithGuid:_guid];
    }
    return _fetchApi;
}

- (YYThreadSafeArray *)commentLayouts {
    if (!_commentLayouts) {
        _commentLayouts = [YYThreadSafeArray array];
    }
    return _commentLayouts;
}

@end
