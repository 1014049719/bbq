//
//  BBQDynamicTableViewController.m
//  BBQ
//
//  Created by 朱琨 on 15/11/23.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import "BBQDynamicTableViewController.h"
#import "DetailViewController.h"
#import "BBQBabyHeaderView.h"
#import "BBQBabyMaterialViewController.h"
#import "BBQDynamicCell.h"
#import "BBQDynamicEditViewController.h"
#import "ReceivedGiftViewController.h"
#import "BBQMoviePlayerViewController.h"
#import "CheckTools.h"
#import "GiftViewController.h"
#import "MJPhotoBrowser.h"
#import "NSString+Common.h"
#import "ShareView.h"
#import "UIMessageInputView.h"
#import "UserDataShowViewController.h"
#import <Masonry.h>
#import <QBPopupMenu.h>
#import "CEGuideArrow.h"
#import <UIScrollView+APParallaxHeader.h>
#import <PopMenu.h>
#import "AuthorizationHelper.h"
#import "BBQDualListViewController.h"
#import "WebViewController.h"
#import "BBQPublishStatusBar.h"
#import "BBQPublishManager.h"
#import "MHBlurTutorialsViewController.h"
#import "BBQPopupControllerFactory.h"
#import "SendInvitationViewController.h"
#import "BBQDynamicMenuCell.h"
#import "UITableView+BBQTableViewCategory.h"
#import "BBQNewCardViewController.h"
#import "GroupViewController.h"
#import "BBQCalendarViewController.h"
#import "QBImagePicker.h"
#import "BBQVisitsViewController.h"
#import "BBQAttentionClassBaoBaoViewController.h"
#import "DateTools.h"
#import "BBQAttentionManagerViewController.h"
#import "BBQAttentionListApi.h"
#import "UIView+WZLBadge.h"

@interface BBQDynamicTableViewController () <BBQDynamicCellDelegate,
UIMessageInputViewDelegate, YYTextKeyboardObserver, BBQPopupControllerDelegate>

@property (strong, nonatomic) NSNumber *groupType;
@property (strong, nonatomic) BBQBabyHeaderView *headerView;
@property (strong, nonatomic) UIMessageInputView *inputView;
@property (strong, nonatomic) BBQDynamicViewModel *viewModel;
@property (strong, nonatomic) QBPopupMenu *funcMenu;
@property (strong, nonatomic) QBPopupMenu *deleteMenu;
@property (strong, nonatomic) BBQDynamicCell *commentSender;
@property (strong, nonatomic) Comment *curComment;
@property (strong, nonatomic) Comment *deleteComment;
@property (strong, nonatomic) PopMenu *popMenu;
@property (strong, nonatomic) BBQPopupController *datePickerController;         // Date Picker

#ifdef TARGET_PARENT
@property (strong, nonatomic) UIButton *bookButton;         // 成长书按钮
@property (strong, nonatomic) UIButton *groupButton;         // 亲友团按钮
@property (strong, nonatomic) UIButton *reportButton;         // 每日报告按钮
@property (strong, nonatomic) UIButton *classBabyButton;         // 班级宝宝
#endif

@property (strong, nonatomic) BBQPublishStatusBar *statusBar;
#ifdef TARGET_MASTER
@property (strong, nonatomic) UIButton *cameraButton;
#endif

@end

@implementation BBQDynamicTableViewController

#pragma mark - Life Cycle
#ifdef TARGET_MASTER
+ (instancetype)viewControllerForMasterTab {
    BBQDynamicTableViewController *vc = [[BBQDynamicTableViewController alloc] initWithViewModel:[BBQDynamicViewModel viewModelWithObject:TheCurUser.curSchool]];
    return vc;
}
#endif

- (instancetype)initWithViewModel:(BBQDynamicViewModel *)viewModel {
    if (self = [super init]) {
        _viewModel = viewModel;
        _viewModel.viewController = self;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    if (self.viewModel.baobaouid && ![self.viewModel.baobaouid isEqualToNumber:@0] && self.viewModel.groupType == BBQDynamicGroupTypeBaby) {
        [self.tableView addParallaxWithView:self.headerView
                                  andHeight:CGRectGetHeight(self.headerView.frame)];
        [self.tableView.parallaxView.shadowView removeFromSuperview];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.floatHeaderView = NO;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.view.backgroundColor = UIColorHex(f5f5f5);
    self.tableView.dataSource = self.viewModel;
    self.tableView.delegate = self;
    self.viewModel.viewController = self;
    self.tableView.backgroundColor = UIColorHex(f5f5f5);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.statefulDelegate = self.viewModel;
    self.inputView.delegate = self;
    self.canLoadMore = NO;
    
    NSString *identifier;
    if (self.viewModel.groupType == BBQDynamicGroupTypeSquare) {
        identifier = kDynamicCellSquareTimelineIdentifier;
    } else {
        identifier = kDynamicCellTimelineIdentifier;
    }
    [self.tableView registerClass:[BBQDynamicCell class]
           forCellReuseIdentifier:identifier];
    
    if (_headerView) {
        [_headerView updateView];
    }
    
    if (self.viewModel.topic.allowpublish) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mine_edit"] style:UIBarButtonItemStylePlain target:self action:@selector(showPopMenu)];
    }
    
    if (_viewModel.groupType == BBQDynamicGroupTypeSquare) {
        [self.view addSubview:self.statusBar];
    }
    
#ifdef TARGET_MASTER
    if (self.viewModel.groupType != BBQDynamicGroupTypeSquare) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_baby_list"] style:UIBarButtonItemStylePlain target:self action:@selector(selectDynamic)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.cameraButton];
    }
    @weakify(self)
    [[BBQLoginManager sharedManager] bk_addObserverForKeyPath:@"curUser.curSelection" options:NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
        @strongify(self)
        if (change[@"new"] && ![change[@"new"] isEqual:[NSNull null]]) {
            BBQDynamicViewModel *viewModel = [BBQDynamicViewModel viewModelWithObject:change[@"new"]];
            self.viewModel = viewModel;
        }
    }];
    
    [self bk_addObserverForKeyPath:@"viewModel" options:NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
        @strongify(self)
        self.tableView.dataSource = self.viewModel;
        [self.tableView reloadData];
        self.viewModel.viewController = self;
        self.statefulDelegate = self.viewModel;
        [self triggerInitialLoad];
    }];
    
    [self.view addSubview:self.statusBar];
#endif
    [self triggerInitialLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
#ifdef TARGET_MASTER
    if (self.viewModel.groupType != BBQDynamicGroupTypeSquare) {
        self.navigationItem.title = self.viewModel.navTitle;
    }
#endif
    if (_headerView) {
        if ([TheCurBaoBao.qx isEqualToNumber:@1] || [TheCurBaoBao.qx isEqualToNumber:@2] ) {
            _headerView.inviteButton.hidden = NO;
            _headerView.inviteButton.enabled = YES;
        } else {
            _headerView.inviteButton.hidden = YES;
            _headerView.inviteButton.enabled = NO;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.tableView.showsVerticalScrollIndicator = YES;
    if (self.inputView) {
        [self.inputView prepareToShow];
    }
    if (_headerView) {
        BBQAttentionListApi *api = [BBQAttentionListApi new];
        @weakify(self)
        [api startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest *request) {
            NSNumber *num = request.responseJSONObject[@"data"][@"agreenum"];
            @strongify(self)
            if (num.integerValue) {
                [self.headerView.attentionButton showBadgeWithStyle:WBadgeStyleNumber value:num.integerValue animationType:WBadgeAnimTypeNone];
            } else {
                [self.headerView.attentionButton clearBadge];
            }
        } failure:nil];
    }
#ifdef TARGET_MASTER
    if (TheCurUser.didFinishAD && [[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self showTutorial];
    }
#endif
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[ShareView sharedInstance] dismiss];
    if ([CEGuideArrow sharedGuideArrow].isDisplayed) {
        [[CEGuideArrow sharedGuideArrow] removeAnimated:YES];
    }
    self.tableView.showsVerticalScrollIndicator = NO;
    if (_inputView) {
        [_inputView prepareToDismiss];
    }
    [_funcMenu dismissAnimated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Tabel View Delegate
#ifdef TARGET_PARENT
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!self.viewModel.needHeader) {
        return nil;
    }
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    view.size = CGSizeMake(kScreenWidth, 80);
    
    if (self.viewModel.groupType == BBQDynamicGroupTypeBaby) {
        if ([TheCurBaoBao hasDailyReport]) {
            [view addSubview:self.bookButton];
            [view addSubview:self.groupButton];
            [view addSubview:self.reportButton];
            
            self.bookButton.centerY = self.groupButton.centerY = self.reportButton.centerY = view.height / 2;
            self.groupButton.left = self.bookButton.right;
            self.reportButton.left = self.groupButton.right;
        } else {
            [view addSubview:self.bookButton];
            [view addSubview:self.groupButton];
            
            self.bookButton.centerY = self.groupButton.centerY = view.height / 2;
            self.bookButton.width = self.groupButton.width = kScreenWidth / 2.0;
            
            self.groupButton.left = self.bookButton.right;
        }
    } else {
        [view addSubview:self.bookButton];
        [view addSubview:self.classBabyButton];
        
        self.bookButton.width = self.classBabyButton.width = kScreenWidth / 2.0;
        
        self.bookButton.centerY = self.classBabyButton.centerY = view.height / 2;
        self.classBabyButton.left = self.bookButton.right;
    }
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //    if (self.viewModel.groupType == BBQDynamicGroupTypeSquare) {
    //        return 0;
    //    }
    if (!self.viewModel.needHeader) {
        return 0;
    }
    return 80;
}
#endif

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.viewModel heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel handleDateViewForCell:cell atIndexPath:indexPath];
}

#pragma mark - Scroll view delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        [_inputView isAndResignFirstResponder];
        [_funcMenu dismissAnimated:YES];
    }
}

#pragma mark - Dynamic Cell Delegate
- (void)didClickDateView {
    [self.datePickerController presentPopupControllerAnimated:YES];
}

- (void)didClickUserWithID:(NSNumber *)uid {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil];
    UserDataShowViewController *vc =
    [sb instantiateViewControllerWithIdentifier:@"UserInfo"];
    vc.uid = uid;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)cell:(BBQDynamicCell *)cell didClickMediaAtIndex:(NSInteger)index {
    Dynamic *dynamic = cell.dynamic;
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
        }else{
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

- (void)didClickShareButtonWithCell:(BBQDynamicCell *)cell {
    Dynamic *dynamic = cell.dynamic;
    if (!dynamic || !dynamic.guid)
        return;
    ShareView *shareView = [ShareView sharedInstance];
    shareView.model = cell.dynamic;
    shareView.guid = cell.dynamic.guid;
    shareView.shareType = BBQShareTypeDynamic;
    [shareView showShareView];
}

- (void)cell:(BBQDynamicCell *)cell
didClickCommentCell:(BBQDynamicCommentCell *)commentCell {
    CheckNetwork
    if (![commentCell.layout.comment.cguid isNotBlank]) return;
    _commentSender = cell;
    Dynamic *dynamic = cell.dynamic;
    Comment *comment = commentCell.layout.comment;
    Comment *newComment =
    [Comment commentWithDynamic:dynamic comment:comment];
    self.curComment = newComment;
    NSString *regxname = @"";
    if (comment.groupkey.integerValue == BBQGroupkeyTypeParent) { //家长
        regxname = [comment.baobaoname
                    stringByAppendingString:[NSString relationshipWithID:comment.gxid gxname:comment.gxname]];
    } else {
        regxname = comment.regxname;
    }
    self.inputView.placeHolder = [NSString stringWithFormat:@"回复 %@", regxname];
    [self.inputView notAndBecomeFirstResponder];
}

- (void)cell:(BBQDynamicCell *)cell
didLongPressCommentCell:(BBQDynamicCommentCell *)commentCell {
    if (![TheCurUser checkAuthorityWithDynamicModel:cell.dynamic] ||
        ![commentCell.layout.comment.cguid isNotBlank])
        return;
    _commentSender = cell;
    CGRect rect = [self.parentViewController.view convertRect:commentCell.frame
                                             fromViewOrWindow:commentCell.superview];
    _deleteComment = commentCell.layout.comment;
    QBPopupMenuItem *deleteItem =
    [QBPopupMenuItem itemWithTitle:@"删除"
                            target:self
                            action:@selector(deleteComment:)];
    _funcMenu = [[QBPopupMenu alloc] initWithItems:@[ deleteItem ]];
    [_funcMenu showInView:self.parentViewController.view targetRect:rect animated:YES];
}

- (void)didClickGiftButtonWithCell:(BBQDynamicCell *)cell {
    self.viewModel.curDynamic = cell.dynamic;
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil];
    GiftViewController *vc =
    [sb instantiateViewControllerWithIdentifier:@"GiftViewController"];
    vc.dynamic = cell.dynamic;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didClickEditButtonWithCell:(BBQDynamicCell *)cell {
    CheckNetwork
    self.viewModel.curDynamic = cell.dynamic;
    UIStoryboard *sb =
    [UIStoryboard storyboardWithName:@"Dynamic" bundle:nil];
    BBQDynamicEditViewController *vc =
    [sb instantiateViewControllerWithIdentifier:@"DynamicEditVC"];
    vc.dynamic = cell.dynamic;
    vc.dynamic.reedit = YES;
    vc.dynamic.setDate = YES;
    if (cell.dynamic.dtype.integerValue == BBQDynamicGroupTypeSquare) {
        vc.navTitle = self.viewModel.topic.name;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didClickDeleteButtonWithCell:(BBQDynamicCell *)cell {
    CheckNetwork
    @weakify(self)
    UIAlertView *alert =
    [UIAlertView bk_showAlertViewWithTitle:@"警告"
                                   message:@"确定删除本条动态？"
                         cancelButtonTitle:@"取消"
                         otherButtonTitles:@[@"确定"]
                                   handler:^(UIAlertView *alertView,
                                             NSInteger buttonIndex) {
                                       @strongify(self)
                                       if (buttonIndex == 1) {
                                           [self.viewModel deleteDynamic:cell.dynamic];
                                       }
                                   }];
    [alert show];
}

- (void)didClickWhiteSpaceWithCell:(BBQDynamicCell *)cell {
    self.viewModel.curDynamic = cell.dynamic;
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil];
    DetailViewController *vc = [sb instantiateViewControllerWithIdentifier:@"DetailViewVC"];
    vc.dynamic = cell.dynamic;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didClickGiftViewWithCell:(BBQDynamicCell *)cell {
    self.viewModel.curDynamic = cell.dynamic;
    ReceivedGiftViewController *vc = [[UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil] instantiateViewControllerWithIdentifier:@"ReceivedGiftVC"];
    vc.dynamic = cell.dynamic;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didClickCommentButtonWithCell:(BBQDynamicCell *)cell {
    CheckNetwork
    Dynamic *dynamic = cell.dynamic;
    self.viewModel.curDynamic = cell.dynamic;
    if (dynamic.dtype.integerValue == BBQDynamicGroupTypeSquare) {
        if (dynamic.uploadState != BBQDynamicUploadStateSuccess) return;
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil];
        DetailViewController *vc = [sb instantiateViewControllerWithIdentifier:@"DetailViewVC"];
        vc.dynamic = cell.dynamic;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        switch (dynamic.uploadState) {
            case BBQDynamicUploadStateSuccess: {
                Comment *newComment =
                [Comment commentWithDynamic:dynamic comment:nil];
                _curComment = newComment;
                _commentSender = cell;
                self.inputView.placeHolder = @"添加评论";
                [_inputView notAndBecomeFirstResponder];
                break;
            }
            case BBQDynamicUploadStateWaiting:
            case BBQDynamicUploadStateFail: {
                break;
            }
            case BBQDynamicUploadStateUploading: {
                [SVProgressHUD showInfoWithStatus:@"动态正在上传中，请稍候..."];
                break;
            }
        }
    }
}

- (void)didClickLikeButtonWithCell:(BBQDynamicCell *)cell {
    [self.viewModel likeDynamic:cell.dynamic];
}

- (void)didClickVisitsButtonWithCell:(BBQDynamicCell *)cell {
    Dynamic *dynamic = cell.dynamic;
    BBQVisitsViewController *vc = [[BBQVisitsViewController alloc] initWithDynamic:dynamic];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UIMessageInputView Delegate
- (void)messageInputView:(UIMessageInputView *)inputView
                sendText:(NSString *)text {
    _curComment.content = text;
    [self.viewModel addComment:_curComment withDynamic:_commentSender.dynamic];
    [self.inputView isAndResignFirstResponder];
}

- (void)messageInputView:(UIMessageInputView *)inputView
   heightToBottomChanged:(CGFloat)heightToBottom {
    if (heightToBottom) {
        CGFloat originalOffsetY = self.tableView.contentOffset.y;
        CGFloat viewBottom =
        CGRectGetMaxY([kKeyWindow convertRect:_commentSender.frame
                             fromViewOrWindow:_commentSender.superview]);
        CGFloat difference = kScreenHeight - heightToBottom - viewBottom;
        CGFloat newOffsetY = MAX(originalOffsetY - difference,
                                 _headerView ? -_headerView.height : 0);
        [self.tableView setContentOffset:CGPointMake(0, newOffsetY) animated:YES];
    }
}

#pragma mark - BBQPopupController Delegate
- (NSDate *)selectedDateForPopupController:(BBQPopupController *)controller {
    return [self.viewModel.selectedDate dateBySubtractingDays:1];
}
- (void)popupController:(BBQPopupController *)popupController didSelectDate:(NSDate *)date {
    self.viewModel.selectedDate = date;
    if (![self.tableView.visibleCells containsObject:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]]) {
        [self.tableView scrollToRow:0 inSection:0 atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (NSDate *)minimumDateForPopupController:(BBQPopupController *)controller {
    return [NSDate dateWithTimeIntervalSince1970:0];
}

- (NSDate *)maximumDateForPopupController:(BBQPopupController *)controller {
    return [NSDate date];
}

#pragma mark - Tutorial
#ifdef TARGET_MASTER
- (void)showTutorial {
    MHBlurTutorialsViewController *tutorialsVC =
    [[MHBlurTutorialsViewController alloc] init];
    tutorialsVC.tutorialsType = BBQTutorialsTypeDynamic;
    @weakify(self)
    tutorialsVC.block = ^{
        @strongify(self)
        [self goToDualListWithMediaType:BBQDynamicMediaTypePhoto];
    };
    
    if (kiOS8Later) {
        tutorialsVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        tutorialsVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self
         presentViewController:tutorialsVC
         animated:YES
         completion:^{
             [tutorialsVC setAnimations:@[
                                          @{
                                              @"holeRadius" : @(
                                                  self.cameraButton.width / 2.0 + 5),
                                              @"holeCenter" : [NSValue
                                                               valueWithCGPoint:
                                                               CGPointMake(
                                                                           self.cameraButton.centerX,
                                                                           self.cameraButton.centerY +
                                                                           20)]
                                              },
                                          @{
                                              @"holeRadius" : @0,
                                              @"holeCenter" : [NSValue valueWithCGPoint:CGPointZero]
                                              }
                                          ]];
             [tutorialsVC
              setBackgroundColor:[UIColor colorWithWhite:0
                                                   alpha:0.7]];
             [tutorialsVC displayTutorial];
         }];
    } else {
        [self presentViewController:tutorialsVC
                           animated:NO
                         completion:^{
                             [tutorialsVC dismissViewControllerAnimated:
                              NO completion:^{
                                  kKeyWindow.rootViewController
                                  .modalPresentationStyle =
                                  UIModalPresentationCurrentContext;
                                  [self
                                   presentViewController:tutorialsVC
                                   animated:NO
                                   completion:^{
                                       [tutorialsVC setAnimations:@[
                                                                    @{
                                                                        @"holeRadius" : @(
                                                                            self.cameraButton.width /
                                                                            2.0 +
                                                                            5),
                                                                        @"holeCenter" : [NSValue
                                                                                         valueWithCGPoint:
                                                                                         CGPointMake(
                                                                                                     self.cameraButton.centerX,
                                                                                                     self.cameraButton.centerY +
                                                                                                     20)]
                                                                        },
                                                                    @{
                                                                        @"holeRadius" : @(0),
                                                                        @"holeCenter" : [NSValue
                                                                                         valueWithCGPoint:CGPointZero]
                                                                        }
                                                                    ]];
                                       [tutorialsVC
                                        setBackgroundColor:
                                        [UIColor colorWithWhite:0
                                                          alpha:0.7]];
                                       [tutorialsVC displayTutorial];
                                   }];
                                  kKeyWindow.rootViewController
                                  .modalPresentationStyle =
                                  UIModalPresentationFullScreen;
                              }];
                         }];
    }
}
#endif

#pragma mark - Action
- (void)didTapadvertisementImageView{
    WebViewController *WebVcl =
    [[UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil]
     instantiateViewControllerWithIdentifier:@"WebViewController"];
    WebVcl.url = _headerView.advUrlStr;
    [self.navigationController pushViewController:WebVcl animated:YES];
    
}

- (void)didTapBabyAvatarView {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil];
    BBQBabyMaterialViewController *vc =
    [sb instantiateViewControllerWithIdentifier:@"babyMaterialVC"];
    @weakify(self)
    vc.returnCoverImageBlock=^(NSString *urlstr){
        @strongify(self)
        [self.headerView setImageWithURL:[NSURL URLWithString:urlstr] placeholder:[UIImage
                                                                                   imageNamed:@"coverImage.jpg"] options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)invite {
    SendInvitationViewController *vc = [[UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil]
                                        instantiateViewControllerWithIdentifier:@"sendInvitationVC"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showPopMenu {
    NSMutableArray *menuItems = [NSMutableArray arrayWithArray:@[
                                                                 [MenuItem itemWithTitle:@"照片" iconName:@"popmenu_photo" index:0],
                                                                 [MenuItem itemWithTitle:@"视频" iconName:@"popmenu_video" index:1],
                                                                 [MenuItem itemWithTitle:@"文字" iconName:@"popmenu_text" index:2],
                                                                 ]];
#ifdef TARGET_MASTER
    if (self.viewModel.groupType != BBQDynamicGroupTypeSquare) {
        [menuItems addObject:[MenuItem itemWithTitle:@"批量导入照片" iconName:@"popmenu_batch" index:3]];
    }
#endif
    
    if (_popMenu.isShowed) {
        [_popMenu dismissMenu];
        return;
    }
    if (!_popMenu) {
        _popMenu = [[PopMenu alloc] initWithFrame:kScreen_Bounds items:menuItems];
        _popMenu.perRowItemCount = 3;
        _popMenu.menuAnimationType = kPopMenuAnimationTypeSina;
    }
    
    @weakify(self)
    _popMenu.didSelectedItemCompletion = ^(MenuItem *selectedItem){
        @strongify(self)
        switch (selectedItem.index) {
            case 0: {
                //照片
                if (![AuthorizationHelper checkPhotoLibraryAuthorizationStatus]) {
                    return;
                }
                [self didSelectPopMenuWithMediaType:BBQDynamicMediaTypePhoto];
            } break;
            case 1: {
                //视频
                if (![AuthorizationHelper checkPhotoLibraryAuthorizationStatus]) {
                    return;
                }
                [self didSelectPopMenuWithMediaType:BBQDynamicMediaTypeVideo];
            } break;
            case 2: {
                //文字
                [self didSelectPopMenuWithMediaType:BBQDynamicMediaTypeNone];
            } break;
            case 3: {
                //批量
                if (![AuthorizationHelper checkPhotoLibraryAuthorizationStatus]) {
                    return;
                }
                [self didSelectPopMenuWithMediaType:BBQDynamicMediaTypeBatch];
            } break;
            case 4: {
                //TODO:安全求助
            } break;
            default:
                break;
        }
    };
    [_popMenu showMenuAtView:kKeyWindow.rootViewController.view];
}

- (void)pickDate {
    [self.datePickerController presentPopupControllerAnimated:YES];
}

- (void)didSelectPopMenuWithMediaType:(BBQDynamicMediaType)type {
#ifdef TARGET_MASTER
    if (self.viewModel.groupType == BBQDynamicGroupTypeSquare) {
        Dynamic *dynamic = [Dynamic dynamicWithMediaType:type object:self.viewModel.topic];
        [self createNewDynamic:dynamic];
    } else {
        [self goToDualListWithMediaType:type];
    }
#else
    Dynamic *dynamic = [Dynamic dynamicWithMediaType:type object:self.viewModel.topic];
    [self createNewDynamic:dynamic];
#endif
}

- (void)createNewDynamic:(Dynamic *)dynamic {
    BBQDynamicMediaType mediaType = dynamic.mediaType;
    if (mediaType == BBQDynamicMediaTypeVideo || mediaType == BBQDynamicMediaTypePhoto || mediaType == BBQDynamicMediaTypeBatch) {
        QBImagePickerController *imagePicker = [[QBImagePickerController alloc] initWithDynamic:dynamic];
        imagePicker.navTitle = self.viewModel.topic.name;
        [self.navigationController
         pushViewController:imagePicker
         animated:YES];
    } else if (mediaType == BBQDynamicMediaTypeNone) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Dynamic" bundle:nil];
        BBQDynamicEditViewController *vc = [sb instantiateViewControllerWithIdentifier:@"DynamicEditVC"];
        vc.navTitle = self.viewModel.topic.name;
        vc.dynamic = dynamic;
        [self.navigationController
         pushViewController:vc
         animated:YES];
    }
}

- (void)goToDualListWithMediaType:(BBQDynamicMediaType)type {
    BBQDualListViewController *vc = [[UIStoryboard storyboardWithName:@"Common" bundle:nil] instantiateViewControllerWithIdentifier:@"DualListVC"];
    vc.dualListType = BBQDualListTypePublishDynamic;
    vc.mediaType = type;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)navigateToBook {
    id model;
    NSString *title;
    if (self.viewModel.groupType == BBQDynamicGroupTypeBaby) {
        BBQBabyModel *baby = [BBQBabyModel new];
        baby.uid = self.viewModel.baobaouid;
        title = @"宝宝成长书";
        model = baby;
    } else {
        BBQClassDataModel *class = [BBQClassDataModel new];
        class.classid = self.viewModel.classuid;
        title = @"班级成长书";
        model = class;
    }
    BBQNewCardViewController *BBQNewCardVcl=[[BBQNewCardViewController alloc] initWithModel:model];
    BBQNewCardVcl.title = title;
    BBQNewCardVcl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:BBQNewCardVcl animated:YES];
}

- (void)navigateToGroup {
    UIStoryboard *sb =
    [UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil];
    GroupViewController *vc =
    [sb instantiateViewControllerWithIdentifier:@"GroupVC"];
    vc.title = @"亲友团";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)navigateToReport {
    BBQCalendarViewController *vc = [[BBQCalendarViewController alloc] initWithBaby:TheCurBaoBao];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)navigateToClassBaby {
    BBQAttentionClassBaoBaoViewController *vc = [[BBQAttentionClassBaoBaoViewController alloc]init];
    vc.paramID = self.viewModel.classuid;
    vc.hidesBottomBarWhenPushed = YES;
    vc.navigationItem.title = self.viewModel.label;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)navigateToAttentionRequest {
    BBQAttentionManagerViewController *vc = [[BBQAttentionManagerViewController alloc]init];
    vc.paramID= TheCurBaoBao.uid;
    vc.hidesBottomBarWhenPushed = YES;
    vc.navigationItem.title = @"哪些人关注我的宝宝";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)selectDynamic {
    BBQDualListViewController *vc = [[UIStoryboard storyboardWithName:@"Common" bundle:nil] instantiateViewControllerWithIdentifier:@"DualListVC"];
    vc.dualListType = BBQDualListTypeCheckDynamic;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)deleteComment:(Comment *)comment {
    CheckNetwork [self.viewModel deleteComment:_deleteComment
                                   withDynamic:_commentSender.dynamic];
}

#pragma mark - Getter & Setter
- (UIMessageInputView *)inputView {
    if (!_inputView) {
        _inputView = [UIMessageInputView
                      messageInputViewWithType:UIMessageInputViewContentTypeTweet];
    }
    return _inputView;
}

- (BBQPopupController *)datePickerController {
    if (!_datePickerController) {
        _datePickerController = [BBQPopupControllerFactory popupControllerWithType:BBQPopupControllerTypeDatePicker];
        _datePickerController.delegate = self;
    }
    return _datePickerController;
}

- (BBQBabyHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[BBQBabyHeaderView alloc] initWithBaby:TheCurBaoBao];
        [_headerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBabyAvatarView)]];
        @weakify(self) _headerView.avatarViewClicked = ^{
            @strongify(self)
            [self didTapBabyAvatarView];
        };
        
        _headerView.advertisementImageViewClick = ^{
            @strongify(self)
            [self didTapadvertisementImageView];
        };
        
        _headerView.inviteButtonClicked = ^{
            @strongify(self)
            [self invite];
        };
        
        _headerView.attentionButtonClicked = ^{
            @strongify(self)
            [self navigateToAttentionRequest];
        };
    }
    return _headerView;
}

#ifdef TARGET_PARENT
- (UIButton *)bookButton {
    if(!_bookButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        button.size = CGSizeMake(kScreenWidth / 3.0, 60);
        [button addTarget:self action:@selector(navigateToBook) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        [button setTitleColor:UIColorHex(999999) forState:UIControlStateNormal];
        if (self.viewModel.groupType == BBQDynamicGroupTypeBaby) {
            [button setTitle:@"宝宝成长书" forState:UIControlStateNormal];
        } else {
            [button setTitle:@"班级成长书" forState:UIControlStateNormal];
        }
        
        [button setImage:[UIImage imageNamed:@"czs"] forState:UIControlStateNormal];
        
        CGFloat spacing = 6.0;
        
        CGSize imageSize = button.imageView.image.size;
        button.titleEdgeInsets = UIEdgeInsetsMake(
                                                  0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
        
        CGSize titleSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
        button.imageEdgeInsets = UIEdgeInsetsMake(
                                                  - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
        _bookButton = button;
    }
    return _bookButton;
}

- (UIButton *)groupButton {
    if(!_groupButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.size = CGSizeMake(kScreenWidth / 3.0, 60);
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        [button addTarget:self action:@selector(navigateToGroup) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:UIColorHex(999999) forState:UIControlStateNormal];
        [button setTitle:@"亲友团" forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"qy"] forState:UIControlStateNormal];
        CGFloat spacing = 6.0;
        
        CGSize imageSize = button.imageView.image.size;
        button.titleEdgeInsets = UIEdgeInsetsMake(
                                                  0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
        
        CGSize titleSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
        button.imageEdgeInsets = UIEdgeInsetsMake(
                                                  - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
        _groupButton = button;
    }
    return _groupButton;
}

- (UIButton *)reportButton {
    if(!_reportButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        button.size = CGSizeMake(kScreenWidth / 3.0, 60);
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        [button addTarget:self action:@selector(navigateToReport) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:UIColorHex(999999) forState:UIControlStateNormal];
        [button setTitle:@"成长报告" forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"czj"] forState:UIControlStateNormal];
        
        CGFloat spacing = 6.0;
        
        CGSize imageSize = button.imageView.image.size;
        button.titleEdgeInsets = UIEdgeInsetsMake(
                                                  0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
        
        CGSize titleSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
        button.imageEdgeInsets = UIEdgeInsetsMake(
                                                  - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
        _reportButton = button;
    }
    return _reportButton;
}

- (UIButton *)classBabyButton {
    if(!_classBabyButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        button.size = CGSizeMake(kScreenWidth / 3.0, 60);
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button addTarget:self action:@selector(navigateToClassBaby) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:UIColorHex(999999) forState:UIControlStateNormal];
        [button setTitle:@"同班宝宝" forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"tb_baby"] forState:UIControlStateNormal];
        
        CGFloat spacing = 6.0;
        
        CGSize imageSize = button.imageView.image.size;
        button.titleEdgeInsets = UIEdgeInsetsMake(
                                                  0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
        
        CGSize titleSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
        button.imageEdgeInsets = UIEdgeInsetsMake(
                                                  - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
        _classBabyButton = button;
    }
    return _classBabyButton;
}
#endif

- (BBQPublishStatusBar *)statusBar {
    if (!_statusBar) {
        _statusBar = [[BBQPublishStatusBar alloc] initWithFrame:CGRectZero];
        _statusBar.width = kScreenWidth;
        _statusBar.height = 34;
        _statusBar.vc = self;
    }
    return _statusBar;
}

#ifdef TARGET_MASTER
- (UIButton *)cameraButton {
    if (!_cameraButton) {
        _cameraButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _cameraButton.size = CGSizeMake(29, 29);
        [_cameraButton setImage:[UIImage imageNamed:@"nav_take_photo"] forState:UIControlStateNormal];
        [_cameraButton addTarget:self action:@selector(showPopMenu) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraButton;
}
#endif

@end
