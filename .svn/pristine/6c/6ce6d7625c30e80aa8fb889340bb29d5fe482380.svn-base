//
//  DetailViewController.m
//  BBQ
//
//  Created by anymuse on 15/8/5.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import "DetailViewController.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "Comment.h"
#import <KxMenu.h>
#import "ShareView.h"
#import "ReceivedGiftViewController.h"
#import "GiftViewController.h"
#import "AppMacro.h"
#import "LoadingView.h"
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
#import "BBQDynamicCommentCell.h"
#import "BBQVisitsViewController.h"

@interface DetailViewController () <
UITableViewDataSource, UITableViewDelegate,
UIMessageInputViewDelegate, BBQDynamicCellDelegate>

@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(assign, nonatomic) NSInteger indexOfTargetComment;
@property(assign, nonatomic) BOOL isMenuShowing;
@property(strong, nonatomic) LoadingView *loadingView;
@property(strong, nonatomic) QBPopupMenu *popupMenu;
@property(weak, nonatomic) IBOutlet UIButton *rightMenuButton;
@property(strong, nonatomic) UIMessageInputView *inputView;
@property(strong, nonatomic) UIView *commentSender;
@property(assign, nonatomic) BOOL commentIsReply;
@property(assign, nonatomic) CGFloat oldPanOffsetY;
@property(assign, nonatomic) NSInteger deleteIndex;
@property (strong, nonatomic) Comment *curComment;
@property (strong, nonatomic) YYThreadSafeArray *commentLayouts;
@property (strong, nonatomic) BBQDynamicLayout *layout;

@end

@implementation DetailViewController

#pragma mark - Lift Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    //    [self.view setNeedsLayout];
    //    [self.view layoutIfNeeded];
    
    [self.tableView registerClass:[BBQDynamicCommentCell class] forCellReuseIdentifier:kDynamicCommentCellIdentifier];
    [self.tableView registerClass:[BBQDynamicCell class] forCellReuseIdentifier:kDynamicCellDetailIdentifier];
    [self.tableView registerClass:[BBQDynamicCell class] forCellReuseIdentifier:kDynamicCellSquareDetailIdentifier];
    
    if (self.dynamic) {
        self.guid = self.dynamic.guid;
        [self addDynamicObservers];
        if (self.dynamic.uploadState == BBQDynamicUploadStateSuccess) {
            [self getSpecifyDynamicComment:self.dynamic.guid];
        } else if (self.dynamic.uploadState == BBQDynamicUploadStateUploading) {
            self.rightMenuButton.enabled = NO;
        }
        
        if (self.dynamic.dtype.integerValue == BBQDynamicGroupTypeSquare) {
            self.layout = [BBQDynamicFactory layoutWithDynamic:self.dynamic style:BBQDynamicLayoutStyleSquareDetail];
        } else {
            self.layout = [BBQDynamicFactory layoutWithDynamic:self.dynamic style:BBQDynamicLayoutStyleDetail];
        }
        
        NSArray *commentLayouts = [self.dynamic.reply bk_map:^id(Comment *obj) {
            return [[BBQDynamicCommentLayout alloc] initWithComment:obj style:self.dynamic.dtype.integerValue];
        }];
        [self.commentLayouts removeAllObjects];
        [self.commentLayouts addObjectsFromArray:commentLayouts];
        [self.tableView reloadData];
        [self downloadData];
    } else if ([self.guid isNotBlank]) {
        [self downloadData];
        self.loadingView = [[NSBundle mainBundle] loadNibNamed:@"LoadingView"
                                                         owner:self
                                                       options:nil]
        .firstObject;
        @weakify(self)
        self.loadingView.buttonBlock = ^{
            @strongify(self)
            [self getDynamicDataAndPost:NO];
        };
        [self.view addSubview:self.loadingView];
        [self.view bringSubviewToFront:self.loadingView];
    }
    
    QBPopupMenuItem *deleteItem =
    [QBPopupMenuItem itemWithTitle:@"删除"
                            target:self
                            action:@selector(deleteComment)];
    
    self.popupMenu = [[QBPopupMenu alloc] initWithItems:@[ deleteItem ]];
    self.popupMenu.highlightedColor = [UIColor colorWithHexString:@"ff6440"];
    
    self.inputView = [UIMessageInputView
                      messageInputViewWithType:UIMessageInputViewContentTypeTweet];
    self.inputView.isAlwaysShow = YES;
    self.inputView.delegate = self;
    self.inputView.placeHolder = @"添加评论";
    
    UIEdgeInsets contentInsets =
    UIEdgeInsetsMake(0.0, 0.0, CGRectGetHeight(self.inputView.frame), 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    self.tableView.tableFooterView = [UIView new];
}

- (void)deleteComment {
    CheckNetwork
    if ([self.inputView isAndResignFirstResponder]) {
        return;
    }
    [self.dynamic deleteComment:_curComment];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.dynamic.uploadState == BBQDynamicUploadStateSuccess) {
        if (!self.inputView.toUser) {
            self.inputView.toUser = nil;
        }
        [self.inputView prepareToShow];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[ShareView sharedInstance] dismiss];
    if (self.inputView) {
        [self.inputView prepareToDismiss];
    }
    [[ShareView sharedInstance] dismiss];
    [self.popupMenu dismissAnimated:YES];
    [KxMenu dismissMenu];
}

- (void)addDynamicObservers {
    [self.dynamic bk_addObserverForKeyPaths:@[@"reply", @"giftdata", @"content", @"graphtime", @"attachinfo"] options:NSKeyValueObservingOptionNew task:^(id obj, NSString *keyPath, NSDictionary *change) {
        if ([keyPath isEqualToString:@"reply"]) {
            NSArray *layouts = [self.dynamic.reply bk_map:^id(Comment *obj) {
                return [[BBQDynamicCommentLayout alloc] initWithComment:obj style:self.dynamic.dtype.integerValue];
            }];
            [self.commentLayouts removeAllObjects];
            [self.commentLayouts addObjectsFromArray:layouts];
            [self.tableView reloadSection:1 withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            if (self.dynamic.dtype.integerValue == BBQDynamicGroupTypeSquare) {
                self.layout = [BBQDynamicFactory layoutWithDynamic:self.dynamic style:BBQDynamicLayoutStyleSquareDetail];
            } else {
                self.layout = [BBQDynamicFactory layoutWithDynamic:self.dynamic style:BBQDynamicLayoutStyleDetail];
            }
            [self.tableView reloadSection:0 withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
}

#pragma mark - Pop Menu
- (IBAction)didClickMenuButton:(UIButton *)sender {
    [self.inputView isAndResignFirstResponder];
    if (self.isMenuShowing) {
        [KxMenu dismissMenu];
        self.isMenuShowing = NO;
    } else {
        self.isMenuShowing = YES;
        CGRect frame = sender.frame;
        frame.origin.y += 20;
        
        switch (self.dynamic.uploadState) {
            case BBQDynamicUploadStateSuccess: {
                NSMutableArray *menuItems = [NSMutableArray array];
                KxMenuItem *shareItem = [KxMenuItem menuItem:@"分享" image:[UIImage imageNamed:@"detail_menu_share"] target:self action:@selector(didClickShareButton)];
                BOOL authority = [TheCurUser checkAuthorityWithDynamicModel:self.dynamic];
                if (self.dynamic.dtype.integerValue == BBQDynamicGroupTypeSquare) {
                    authority = TheCurUser.member.ismanage || authority;
                }
                if (authority) {
                    if ([self.dynamic.ispajs isEqualToNumber:@0] || self.dynamic.dtype.integerValue == BBQDynamicGroupTypeSquare) {
                        KxMenuItem *editItem = [KxMenuItem menuItem:@"编辑" image:[UIImage imageNamed:@"dynamic_edit"] target:self action:@selector(didClickEditButton)];
                        [menuItems addObject:editItem];
                    }
                    [menuItems addObject:shareItem];
                    KxMenuItem *deleteItem = [KxMenuItem menuItem:@"删除" image:[UIImage imageNamed:@"detail_menu_delete"] target:self action:@selector(didClickDeleteButton)];
                    [menuItems addObject:deleteItem];
                } else {
                    [menuItems addObject:shareItem];
                }
#ifdef TARGET_PARENT
                if (self.dynamic.dtype.integerValue != BBQDynamicGroupTypeBaby && self.dynamic.dtype.integerValue != BBQDynamicGroupTypeSquare) {
                    [menuItems addObject:[KxMenuItem menuItem:@"转发到宝宝" image:[UIImage imageNamed:@"detail_menu_zhuanfa"] target:self action:@selector(didClickForwardButton)]];
                }
#endif
                [KxMenu showMenuInView:self.navigationController.view fromRect:frame menuItems:menuItems];
                break;
            }
            case BBQDynamicUploadStateWaiting:
            case BBQDynamicUploadStateFail: {
                KxMenuItem *deleteItem = [KxMenuItem menuItem:@"删除" image:[UIImage imageNamed:@"detail_menu_delete"] target:self action:@selector(didClickDeleteButton)];
                [KxMenu showMenuInView:self.navigationController.view fromRect:frame menuItems:@[deleteItem]];
                break;
            }
            case BBQDynamicUploadStateUploading: {
                break;
            }
        }
    }
}

#pragma mark - PopupMenu
- (void)dismissPopupMenu {
    if (self.popupMenu.isVisible) {
        [self.popupMenu dismissAnimated:YES];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        [self.inputView isAndResignFirstResponder];
    }
}

- (void)scrollViewDidScroll:(nonnull UIScrollView *)scrollView {
    [self dismissPopupMenu];
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
    @weakify(self)
    [api startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        @strongify(self)
        BBQFetchAppointedDynamicApi *dynamicApi = [[BBQFetchAppointedDynamicApi alloc] initWithGuid:request.responseJSONObject[@"data"][@"guid"] dtype:self.dynamic ? self.dynamic.dtype.integerValue : 0];
        [dynamicApi startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest *request) {
            Dynamic *dynamic = [Dynamic modelWithJSON:request.responseJSONObject[@"data"]];
            [dynamic insertUpdateSyncToDB:nil];
            [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:kPublishDynamicNotification object:dynamic];
            NSString *str = @"动态转发成功！";
            [SVProgressHUD showSuccessWithStatus:str];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(HUD_DURATION(str) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        } failure:^(__kindof YTKBaseRequest *request) {
            ShowApiError
        }];
    } failure:^(YTKBaseRequest *request) {
        ShowApiError
    }];
}

- (void)deleteCurrentDynamic {
    CheckNetwork
    [Dynamic deleteDynamic:self.dynamic];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(nonnull UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return self.dynamic.reply.count ?: 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        BBQDynamicCell *aCell;
        if (self.dynamic.dtype.integerValue == BBQDynamicGroupTypeSquare) {
            aCell = [tableView dequeueReusableCellWithIdentifier:kDynamicCellSquareDetailIdentifier
                                              forIndexPath:indexPath];
        } else {
            aCell = [tableView dequeueReusableCellWithIdentifier:kDynamicCellDetailIdentifier forIndexPath:indexPath];
        }

        aCell.delegate = self;
        aCell.layout = self.layout;
        cell = aCell;
    } else {
        if (self.dynamic.reply.count) {
            BBQDynamicCommentCell *aCell = [tableView dequeueReusableCellWithIdentifier:kDynamicCommentCellIdentifier forIndexPath:indexPath];
            aCell.delegate = self;
            aCell.layout = self.commentLayouts[indexPath.row];
            cell = aCell;
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"NoCommentCell"
                                                   forIndexPath:indexPath];
        }
    }
    return cell;
}

- (CGFloat)tableView:(nonnull UITableView *)tableView
heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.layout.height;
    }
    if (self.dynamic.reply.count) {
        BBQDynamicCommentLayout *layout = self.commentLayouts[indexPath.row];
        if (!layout) {
            return 0;
        }
        return layout.height;
    }
    return [tableView fd_heightForCellWithIdentifier:@"NoCommentCell"
                                       configuration:nil];
}

#pragma mark - TabelView Delegate
- (void)tableView:(nonnull UITableView *)tableView
didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        CheckNetwork
        if ([self.inputView isAndResignFirstResponder]) {
            return;
        }
        self.indexOfTargetComment = indexPath.row;
        self.commentIsReply = YES;
        BBQDynamicCommentCell *cell =
        (BBQDynamicCommentCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        self.commentSender = [self.tableView cellForRowAtIndexPath:indexPath];
        Comment *newComment =
        [Comment commentWithDynamic:self.dynamic comment:self.dynamic.reply
         [indexPath.row]];
        self.curComment = newComment;
        self.inputView.placeHolder = [NSString
                                      stringWithFormat:@"回复：%@", cell.layout.username];
        [self.inputView notAndBecomeFirstResponder];
    }
}

- (UIView *)tableView:(UITableView *)tableView
viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForFooterInSection:(NSInteger)section {
    return 3;
}
#pragma mark -
#pragma mark 网络请求

/// 网络请求数据
- (void)downloadData {
    //离线状态
    if (kNetworkNotReachability) {
        [Dynamic dynamicWithGuid:self.guid completion:^(NSArray *dynamics) {
            if (dynamics.count) {
                self.dynamic = dynamics.firstObject;
            } else {
                return;
            }
        }];
    } else {
        [self getDynamicDataAndPost:NO];
    }
}

- (void)getDynamicDataAndPost:(BOOL)post {
    if (self.dynamic.uploadState == BBQDynamicUploadStateSuccess) {
        BBQFetchAppointedDynamicApi *api = [[BBQFetchAppointedDynamicApi alloc] initWithGuid:self.guid dtype:self.dynamic ? self.dynamic.dtype.integerValue : 0];
        [api startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest *request) {
            dispatch_async(
                           dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                               if (request.responseJSONObject[@"data"]) {
                                   self.dynamic = [Dynamic modelWithJSON:request.responseJSONObject[@"data"]];
                                   [self addDynamicObservers];
                                   [self.dynamic insertUpdateSyncToDB:nil];
                                   NSArray *layouts = [self.dynamic.reply bk_map:^id(Comment *obj) {
                                       return [[BBQDynamicCommentLayout alloc] initWithComment:obj style:self.dynamic.dtype.integerValue];
                                   }];
                                   
                                   BBQDynamicLayout *layout;
                                   if (self.dynamic.dtype.integerValue == BBQDynamicGroupTypeSquare) {
                                       layout = [BBQDynamicFactory layoutWithDynamic:self.dynamic style:BBQDynamicLayoutStyleSquareDetail];
                                   } else {
                                       layout = [BBQDynamicFactory layoutWithDynamic:self.dynamic style:BBQDynamicLayoutStyleDetail];
                                   }
                                   
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       self.rightMenuButton.enabled = YES;
                                       [self.commentLayouts removeAllObjects];
                                       [self.commentLayouts addObjectsFromArray:layouts];
                                       self.layout = layout;
                                       [self.tableView reloadData];
                                       if (self.loadingView.isShowing) {
                                           [self.loadingView dismiss];
                                       }
                                   });
                               } else {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       NSString *str = @"该动态不存在";
                                       [SVProgressHUD showErrorWithStatus:str];
                                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(HUD_DURATION(str) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                           [self.navigationController popViewControllerAnimated:YES];
                                       });
                                   });
                               }
                           });
        } failure:^(__kindof YTKBaseRequest *request) {
            if (self.loadingView.isShowing) {
                self.loadingView.status = BBQLoadingViewStatusError;
            }
        }];
    } else {
        [self.tableView reloadData];
        self.rightMenuButton.enabled = YES;
        [self.loadingView dismiss];
    }
}

- (void)addComment {
    CheckNetwork
    [self.dynamic addComment:_curComment];
    _commentIsReply = NO;
    _commentSender = nil;
    self.inputView.toUser = nil;
    [self.inputView isAndResignFirstResponder];
}

- (void)getSpecifyDynamicComment:(NSString *)guid {
    [BBQHTTPRequest
     queryWithType:BBQHTTPRequestTypeGetSpecifyDynamicComment
     param:@{
             @"guid" : guid
             }
     successHandler:^(AFHTTPRequestOperation *operation,
                      NSDictionary *responseObject, bool apiSuccess) {
         dispatch_async(dispatch_get_main_queue(), ^{
             if (self.loadingView.isShowing) {
                 [self.loadingView dismiss];
             }
             self.dynamic.reply = [NSArray modelArrayWithClass:[Comment class] json:responseObject[@"data"][@"commentarr"]];
             //             self.commentLayouts = [self.dynamic.reply bk_map:^id(Comment *obj) {
             //                 return [[BBQDynamicCommentLayout alloc] initWithComment:obj style:self.dynamic.dtype.integerValue];
             //             }];
             self.rightMenuButton.enabled = YES;
         });
     } errorHandler:nil
     failureHandler:nil];
}

#pragma mark - Cell Delegate
- (void)didClickGiftViewWithCell:(BBQDynamicCell *)cell {
    ReceivedGiftViewController *vc = [[UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil] instantiateViewControllerWithIdentifier:@"ReceivedGiftVC"];
    vc.dynamic = cell.dynamic;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)cell:(BBQDynamicCell *)cell didClickMediaAtIndex:(NSInteger)index {
    Dynamic *dynamic = self.dynamic;
    if (index == 0 &&
        ((Attachment *)dynamic.attachinfo.firstObject).itype.integerValue ==
        BBQAttachmentTypeVideo) {
        Attachment *attachment = dynamic.attachinfo.firstObject;
        
        if ([[UIApplication sharedApplication] canOpenURL:attachment.filepathURL]) {
            BBQMoviePlayerViewController *vc = [BBQMoviePlayerViewController new];
            vc.movieURL = attachment.filepathURL;
            [vc readyPlayer];
            [self.navigationController presentViewController:vc
                                                    animated:YES
                                                  completion:nil];
        } else {
            [SVProgressHUD showErrorWithStatus:@"视频数据错误"];
        }
    } else {
        NSMutableArray *photos = [NSMutableArray array];
        for (Attachment *model in dynamic.attachinfo) {
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.url = [model filepathURL];
            [photos addObject:photo];
        }
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        browser.currentPhotoIndex = index;
        browser.photos = photos;
        [browser show];
    }
}

- (void)didClickGiftButtonWithCell:(BBQDynamicCell *)cell {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil];
    GiftViewController *vc =
    [sb instantiateViewControllerWithIdentifier:@"GiftViewController"];
    vc.dynamic = cell.dynamic;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didClickVisitsButtonWithCell:(BBQDynamicCell *)cell {
    Dynamic *dynamic = cell.dynamic;
    BBQVisitsViewController *vc = [[BBQVisitsViewController alloc] initWithDynamic:dynamic];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didLongPressCommentCell:(BBQDynamicCommentCell *)commentCell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:commentCell];
    Comment *comment = self.dynamic.reply[indexPath.row];
    if (![comment.cguid isNotBlank]) {
        return;
    }
    
    if ([TheCurUser checkAuthorityWithDynamicModel:self.dynamic] ||
        [comment.uid isEqualToNumber:TheCurUser.member.uid]) {
        self.curComment = self.dynamic.reply[indexPath.row];
        CGRect popoverRect = [self.tableView
                              convertRect:[self.tableView rectForRowAtIndexPath:indexPath]
                              toView:self.tableView.superview];
        [self.popupMenu showInView:self.view targetRect:popoverRect animated:YES];
    }
}

- (void)didClickUserWithID:(NSNumber *)uid {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil];
    UserDataShowViewController *vc =
    [sb instantiateViewControllerWithIdentifier:@"UserInfo"];
    vc.uid = uid;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didClickMediaAtIndex:(NSInteger)index {
    if (index == 0 &&
        ((Attachment *)self.dynamic.attachinfo.firstObject).itype.integerValue ==
        BBQAttachmentTypeVideo) {
        Attachment *attachment = self.dynamic.attachinfo.firstObject;
        
        if ([[UIApplication sharedApplication] canOpenURL:attachment.filepathURL]) {
            BBQMoviePlayerViewController *vc = [BBQMoviePlayerViewController new];
            vc.movieURL = attachment.filepathURL;
            [vc readyPlayer];
            [self.navigationController presentViewController:vc
                                                    animated:YES
                                                  completion:nil];
        }else{
            [SVProgressHUD showErrorWithStatus:@"视频数据错误"];
        }
    } else {
        NSMutableArray *photos = [NSMutableArray array];
        for (Attachment *model in self.dynamic.attachinfo) {
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.url = [model filepathURL];
            [photos addObject:photo];
        }
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        browser.currentPhotoIndex = index;
        browser.photos = photos;
        [browser show];
    }
}

- (void)didLongPressCommentLabelAtIndexPath:(NSIndexPath *)indexPath {
    Comment *comment = self.dynamic.reply[indexPath.row];
    if ([TheCurUser checkAuthorityWithDynamicModel:self.dynamic] ||
        [comment.uid isEqualToNumber:TheCurUser.member.uid]) {
        self.curComment = self.dynamic.reply[indexPath.row];
        CGRect popoverRect = [self.tableView
                              convertRect:[self.tableView rectForRowAtIndexPath:indexPath]
                              toView:self.tableView.superview];
        [self.popupMenu showInView:self.view targetRect:popoverRect animated:YES];
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
    [self addComment];
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

#pragma mark - Getters & Setters
- (YYThreadSafeArray *)commentLayouts {
    if (!_commentLayouts) {
        _commentLayouts = [YYThreadSafeArray array];
    }
    return _commentLayouts;
}

@end
