//
//  BBQDynamicPageController.m
//  BBQ
//
//  Created by 朱琨 on 15/11/19.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import "BBQDynamicPageController.h"
#import "BBQDynamicTableViewController.h"
#import "BBQAttentionViewController.h"
#import "BBQNewCardViewController.h"
#import "BBQDynamicViewModel.h"
#import "SendInvitationViewController.h"
#import <WMPageConst.h>
#import <BlocksKit.h>
#import "BBQThemeManager.h"
#import <WMMenuItem.h>
#import <XHRealTimeBlur.h>
#import <PopMenu.h>
#import "QBImagePicker.h"
#import "BBQDynamicEditViewController.h"
#import "AuthorizationHelper.h"
#import "BBQPublishStatusBar.h"
#import "BBQPublishManager.h"
#import "BBQDualListViewController.h"
#import "User.h"
#import "CardPreviewController.h"
#import "MHBlurTutorialsViewController.h"
#import "IMYThemeConfig.h"
#import "UIColor+IMY_Theme.h"
#import "CEGuideArrow.h"

typedef enum {
    CEGuideArrowOfPopMenu,
    CEGuideArrowOfTabBar,
    
} CEGuideArrowViewType;
@interface BBQDynamicPageController () <IMY_ThemeChangeProtocol>

@property (copy, nonatomic) NSArray *navTitles;
@property (strong, nonatomic) PopMenu *popMenu;
@property (strong, nonatomic) BBQPublishStatusBar *statusBar;
@property (strong, nonatomic) BBQBabyModel *baby;
@property (strong, nonatomic) UIImageView *photoRemindView;
@property (strong, nonatomic) UIButton *switchBabyButton;
@property(nonatomic, strong) NSMutableArray *menuButtonFrames;
//@property (strong, nonatomic) UIImageView *czsPreview;
#ifndef TARGET_MASTER
@property (strong, nonatomic) UIButton *cameraButton;
#endif

@end

@implementation BBQDynamicPageController

+ (instancetype)pageControllerForTeacher {
    BBQDynamicPageController *pageController = [[BBQDynamicPageController alloc] initWithViewControllerClasses:@[[BBQDynamicTableViewController class], [BBQDynamicTableViewController class], [BBQDynamicTableViewController class], [BBQNewCardViewController class]] andTheirTitles:@[@"班级", @"宝宝", TheCurUser.curSchool.schoolTypeName, @"成长书"]];
    NSArray *keys = @[@"viewModel", @"viewModel", @"viewModel", @"model"];
    NSArray *values = @[[BBQDynamicViewModel viewModelForClass:TheCurUser.curClass.classid inSchool:TheCurUser.curSchool.schoolid], [BBQDynamicViewModel viewModelForBabiesInClass:TheCurUser.curClass.classid], [BBQDynamicViewModel viewModelForSchool:TheCurUser.curSchool.schoolid], TheCurUser.curClass];
    pageController.keys = [NSMutableArray arrayWithArray:keys];
    pageController.values = [NSMutableArray arrayWithArray:values];
    [pageController onInit];
    return pageController;
}

- (instancetype)initWithBaby:(BBQBabyModel *)baby {
    NSMutableArray *classes = [NSMutableArray array];
    NSMutableArray *labels = [NSMutableArray array];
    NSMutableArray *tempNavTitles = [NSMutableArray array];
    NSMutableArray *keys = [NSMutableArray array];
    NSMutableArray *values = [NSMutableArray array];
    [self.class setupClasses:classes labels:labels keys:keys values:values navTitles:tempNavTitles withBaby:baby];
    
    if (self = [super initWithViewControllerClasses:classes andTheirTitles:labels]) {
        _baby = baby;
        self.keys = keys;
        self.values = values;
        self.navTitles = tempNavTitles;
        [self onInit];
    }
    return self;
}

- (void)onInit {
    self.postNotification = YES;
    self.menuViewStyle = WMMenuViewStyleLine;
    self.menuHeight = 34;
    self.menuBGColor = [UIColor whiteColor];
    self.titleSizeNormal = 15;
    self.bounces = YES;
    self.titleSizeSelected = 15;
    self.titleColorNormal = UIColorHex(999999);
    [self addToThemeChangeObserver];
    self.titleColorSelected = [UIColor imy_colorForKey:@"SY_RED"];
    //    NSString *colorStr = [[BBQThemeManager sharedInstance] getTheCurThemeType];
    //    self.titleColorSelected = [UIColor colorWithHexString:colorStr];
}

#pragma mark - IMY_ThemeChangeProtocol
- (void)imy_themeChanged {
    
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.statusBar];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didMoveToViewController:) name:WMControllerDidFullyDisplayedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePublishDynamicNotification:) name:kPublishDynamicNotification object:nil];
#ifdef TARGET_PARENT
    @weakify(self)
    [[BBQLoginManager sharedManager] bk_addObserverForKeyPath:@"curUser.curBaby" options:NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
        @strongify(self)
        if (change[@"new"] && ![change[@"new"] isEqual:[NSNull null]]) {
            BBQBabyModel *baby = change[@"new"];
            self.baby = baby;
            [self reloadDataWithBaby:baby];
        }
    }];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.switchBabyButton];
#endif
    
#ifndef TARGET_MASTER
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.cameraButton];
    self.navigationItem.title = @"动态";
#endif
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //#ifdef TARGET_PARENT
    //    if (!_czsPreview) {
    //        [self.view addSubview:self.czsPreview];
    //    }
    //#endif
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view bringSubviewToFront:self.statusBar];
    
#ifdef TARGET_PARENT
    //    if (_czsPreview) {
    //        [self.view bringSubviewToFront:_czsPreview];
    //    }
    
#endif
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_popMenu) {
        [_popMenu dismissMenu];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
#ifdef TARGET_TEACHER
    if (TheCurUser.didFinishAD && [[NSUserDefaults standardUserDefaults] boolForKey:@"firstShowDynamic"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstShowDynamic"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self showTutorial];
    }
#endif
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Tutorial
#ifdef TARGET_TEACHER
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
- (void)showPopMenu {
    NSArray *menuItems = @[
                           [MenuItem itemWithTitle:@"照片" iconName:@"popmenu_photo" index:0],
                           [MenuItem itemWithTitle:@"视频" iconName:@"popmenu_video" index:1],
                           [MenuItem itemWithTitle:@"文字" iconName:@"popmenu_text" index:2],
                           [MenuItem itemWithTitle:@"批量导入照片" iconName:@"popmenu_batch" index:3],
                           //                           [MenuItem itemWithTitle:@"安全求助" iconName:@"popmenu_help" index:4]
                           ];
    if (_popMenu.isShowed) {
        [_popMenu dismissMenu];
        return;
    }
    if (!_popMenu) {
        _popMenu = [[PopMenu alloc] initWithFrame:kScreen_Bounds items:menuItems];
        if ([CEGuideArrow sharedGuideArrow].isDisplayed){
            @weakify(self)
            self.menuButtonFrames = [NSMutableArray array];
            _popMenu.returnFrameBlock =^(CGRect rect,BOOL isShow) {
                @strongify(self)
                if (isShow) {
                    [self.menuButtonFrames addObject:[NSValue valueWithCGRect:rect]];
                }else{
                    [[CEGuideArrow sharedGuideArrow] removeAnimated:YES];
                }
            };
        }
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
#ifdef TARGET_PARENT
                Dynamic *dynamic = [Dynamic dynamicWithMediaType:BBQDynamicMediaTypePhoto object:TheCurBaoBao];
                [self createNewDynamic:dynamic];
#else
                [self goToDualListWithMediaType:BBQDynamicMediaTypePhoto];
#endif
            } break;
            case 1: {
                //视频
                if (![AuthorizationHelper checkPhotoLibraryAuthorizationStatus]) {
                    return;
                }
#ifdef TARGET_PARENT
                Dynamic *dynamic = [Dynamic dynamicWithMediaType:BBQDynamicMediaTypeVideo object:TheCurBaoBao];
                [self createNewDynamic:dynamic];
#else
                [self goToDualListWithMediaType:BBQDynamicMediaTypeVideo];
#endif
            } break;
            case 2: {
                //文字
#ifdef TARGET_PARENT
                Dynamic *dynamic = [Dynamic dynamicWithMediaType:BBQDynamicMediaTypeNone object:TheCurBaoBao];
                [self createNewDynamic:dynamic];
#else
                [self goToDualListWithMediaType:BBQDynamicMediaTypeNone];
#endif
            } break;
            case 3: {
                //批量
                if (![AuthorizationHelper checkPhotoLibraryAuthorizationStatus]) {
                    return;
                }
#ifdef TARGET_PARENT
                Dynamic *dynamic = [Dynamic dynamicWithMediaType:BBQDynamicMediaTypeBatch object:TheCurBaoBao];
                [self createNewDynamic:dynamic];
#else
                [self goToDualListWithMediaType:BBQDynamicMediaTypeBatch];
#endif
            } break;
            case 4: {
                //TODO:安全求助
            } break;
            default:
                break;
        }
    };
    [_popMenu showMenuAtView:kKeyWindow.rootViewController.view];
    _popMenu.realTimeBlur.hasTapGestureEnable = YES;
    if ([CEGuideArrow sharedGuideArrow].isDisplayed) {
        [self showGuidArrow:CEGuideArrowOfPopMenu];
    }
}

- (void)previewClick {
    CardPreviewController *CardPreviewVcl =
    [[UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil]
     instantiateViewControllerWithIdentifier:@"CardPreviewVcl"];
    CardPreviewVcl.title = @"成长书";
    CardPreviewVcl.accessType = @"从动态进入";
    [self.navigationController pushViewController:CardPreviewVcl animated:YES];
}

- (void)goToDualListWithMediaType:(BBQDynamicMediaType)type {
    BBQDualListViewController *vc = [[UIStoryboard storyboardWithName:@"Common" bundle:nil] instantiateViewControllerWithIdentifier:@"DualListVC"];
    vc.dualListType = BBQDualListTypePublishDynamic;
    vc.mediaType = type;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)createNewDynamic:(Dynamic *)dynamic {
    BBQDynamicMediaType mediaType = dynamic.mediaType;
    if (mediaType == BBQDynamicMediaTypeVideo || mediaType == BBQDynamicMediaTypePhoto || mediaType == BBQDynamicMediaTypeBatch) {
        QBImagePickerController *imagePicker = [[QBImagePickerController alloc] initWithDynamic:dynamic];
        [self.navigationController
         pushViewController:imagePicker
         animated:YES];
    } else if (mediaType == BBQDynamicMediaTypeNone) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Dynamic" bundle:nil];
        BBQDynamicEditViewController *vc = [sb instantiateViewControllerWithIdentifier:@"DynamicEditVC"];
        vc.dynamic = dynamic;
        [self.navigationController
         pushViewController:vc
         animated:YES];
    }
}

- (void)babyList {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil];
    BBQAttentionViewController *vc = [sb instantiateViewControllerWithIdentifier:@"AttentionListBoard"];
    vc.type = BBQAttentionViewTypeNormal;
    @weakify(self)
    vc.didSelectClassBlock = ^(NSString *name) {
        @strongify(self)
        [self.titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([title isEqualToString:name]) {
                self.selectIndex = (int)idx;
                *stop = YES;
            }
        }];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)invite {
    SendInvitationViewController *vc = [[UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil]
                                        instantiateViewControllerWithIdentifier:@"sendInvitationVC"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)reloadDataWithBaby:(BBQBabyModel *)baby {
    dispatch_async_on_main_queue(^{
        self.selectIndex = 0;
        NSMutableArray *classes = [NSMutableArray array];
        NSMutableArray *labels = [NSMutableArray array];
        NSMutableArray *tempNavTitles = [NSMutableArray array];
        NSMutableArray *keys = [NSMutableArray array];
        NSMutableArray *values = [NSMutableArray array];
        [self.class setupClasses:classes labels:labels keys:keys values:values navTitles:tempNavTitles withBaby:baby];
        self.viewControllerClasses = classes;
        self.titles = labels;
        self.keys = keys;
        self.values = values;
        self.navTitles = tempNavTitles;
        [self onInit];
        [self reloadData];
    });
}

+ (void)setupClasses:(NSMutableArray *)classes labels:(NSMutableArray *)labels keys:(NSMutableArray *)keys values:(NSMutableArray *)values navTitles:(NSMutableArray *)navTitles withBaby:(BBQBabyModel *)baby {
    for (DynamicTag *tag in baby.dynamictags) {
        [classes addObject:[BBQDynamicTableViewController class]];
        [labels addObject:tag.label];
        [navTitles addObject:tag.title];
        [keys addObject:@"viewModel"];
        BBQDynamicViewModel *viewModel;
        if (tag.dtype.integerValue == BBQDynamicGroupTypeBaby) {
            viewModel = [BBQDynamicViewModel viewModelForBaby:baby.uid];
        } else if (tag.dtype.integerValue == BBQDynamicGroupTypeClass) {
            viewModel = [BBQDynamicViewModel viewModelForClass:tag.classid inSchool:tag.schoolid];
        } else {
            viewModel = [BBQDynamicViewModel viewModelForSchool:tag.schoolid];
        }
        viewModel.label = tag.label;
        [values addObject:viewModel];
    }
    //
    //    [classes addObjectsFromArray:@[[BBQNewCardViewController class], [GroupViewController class]]];
    //    [labels addObjectsFromArray:@[@"成长书", @"亲友团"]];
    //    [navTitles addObjectsFromArray:@[baby.realname ?: @"", baby.realname ?: @""]];
    //    [keys addObjectsFromArray:@[@"", @""]];
    //    [values addObjectsFromArray:@[@"", @""]];
    //    if (![baby.curSchool.schooltype isEqualToNumber:@3] && baby.baobaoschooldata.count) {
    //        [classes addObject:[BBQCalendarViewController class]];
    //        [labels addObject:@"成长报告"];
    //        [navTitles addObject:baby.realname ?: @""];
    //        [keys addObject:@""];
    //        [values addObject:@""];
    //    }
}

#pragma mark - Notification
- (void)didMoveToViewController:(NSNotification *)notification {
#ifdef TARGET_PARENT
    self.navigationItem.title = _navTitles[[notification.object[@"index"] integerValue]];
    //    _czsPreview.hidden = [notification.object[@"index"] integerValue] > TheCurBaoBao.dynamictags.count - 1;
    //    _czsPreview.userInteractionEnabled = [notification.object[@"index"] integerValue] <= TheCurBaoBao.dynamictags.count;
#else
    //    _czsPreview.hidden = [notification.object[@"index"] integerValue] > 2;
    //    _czsPreview.userInteractionEnabled = [notification.object[@"index"] integerValue] <= 2;
#endif
}

- (void)handlePublishDynamicNotification:(NSNotification *)notification {
    Dynamic *dynamic = notification.object;
#ifdef TARGET_PARENT
    switch ((BBQDynamicGroupType)dynamic.dtype.integerValue) {
        case BBQDynamicGroupTypeBaby: {
            self.selectIndex = 0;
            break;
        }
        case BBQDynamicGroupTypeClass:
        case BBQDynamicGroupTypeSchool: {
            [self.baby.dynamictags enumerateObjectsUsingBlock:^(DynamicTag *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (dynamic.dtype.integerValue == BBQDynamicGroupTypeClass) {
                    if ([obj.classid isEqualToNumber:dynamic.classuid]) {
                        *stop = YES;
                        self.selectIndex = (int)idx;
                    }
                } else {
                    if ([obj.schoolid isEqualToNumber:dynamic.schoolid]) {
                        *stop = YES;
                        self.selectIndex = (int)idx;
                    }
                }
            }];
            break;
        }
        case BBQDynamicGroupTypeSquare: {
            break;
        }
    }
#else
    switch ((BBQDynamicGroupType)dynamic.dtype.integerValue) {
        case BBQDynamicGroupTypeBaby: {
            self.selectIndex = 1;
            break;
        }
        case BBQDynamicGroupTypeClass: {
            self.selectIndex = 0;
            break;
        }
        case BBQDynamicGroupTypeSchool: {
            self.selectIndex = 2;
            break;
        }
    }
#endif
}

#pragma mark - Getter & Setter
- (NSArray *)itemsWidths {
    return [self.titles bk_map:^id(NSString *title) {
        CGFloat width = [title widthForFont:[UIFont systemFontOfSize:14]];
        return @(width + kScaleFrom_iPhone6_Desgin(25));
    }];
}

#ifndef TARGET_MASTER
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

- (BBQPublishStatusBar *)statusBar {
    if (!_statusBar) {
        _statusBar = [[BBQPublishStatusBar alloc] initWithFrame:CGRectZero];
        _statusBar.width = kScreenWidth;
        _statusBar.height = 34;
        _statusBar.top = self.menuHeight;
        _statusBar.vc = self;
    }
    return _statusBar;
}

- (UIButton *)switchBabyButton {
    if(!_switchBabyButton) {
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftButton setTitle:@" 切换宝宝" forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(babyList) forControlEvents:UIControlEventTouchUpInside];
        leftButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [leftButton setImage:[UIImage imageNamed:@"nav_baby_list"] forState:UIControlStateNormal];
        [leftButton sizeToFit];
        _switchBabyButton = leftButton;
    }
    return _switchBabyButton;
}
-(void)showGuidArrow:(CEGuideArrowViewType)type{
    NSInteger willShowTaskNo = 0;
    for (BBQTaskModel *model in TheCurUser.taskArr) {
        if (model.taskno !=0 && model.state==0) {
            willShowTaskNo = model.taskno;
            break;
        }
    }
    if (willShowTaskNo) {
        switch (type) {
            case CEGuideArrowOfTabBar:{
                if (willShowTaskNo != 3) {
                    CGPoint point = CGPointMake([UIScreen mainScreen].bounds.size.width- 60, 120);
                    [[CEGuideArrow sharedGuideArrow] showInWindow:kKeyWindow atPoint:point inView:self.view atAngle:90 length:0.0];
                    //                                        [[CEGuideArrow sharedGuideArrow] showInWindow:kKeyWindow atPosition:CEGuideArrowPositionTypeTopRight inView:self.rootTabBar
                    //                                         .middleButton atAngle:-90 length:0.0];
                }else{
                    CGPoint point = CGPointMake([UIScreen mainScreen].bounds.size.width- 60, 120);
                    [[CEGuideArrow sharedGuideArrow] showInWindow:kKeyWindow atPoint:point inView:self.view atAngle:90 length:0.0];
                }
                
            }break;
            case CEGuideArrowOfPopMenu:{
                if (willShowTaskNo != 3) {
                    CGRect rect = (willShowTaskNo ==1)?[self.menuButtonFrames[0] CGRectValue]:[self.menuButtonFrames[1] CGRectValue];
                    CGPoint point = CGPointMake(rect.origin.x+60, rect.origin.y-60);
                    [[CEGuideArrow sharedGuideArrow] showInWindow:kKeyWindow atPoint:point inView:self.popMenu atAngle:-90 length:0.0];
                }else{
                    if ([CEGuideArrow sharedGuideArrow].isDisplayed) {
                        [[CEGuideArrow sharedGuideArrow] removeAnimated:YES];
                    }
                }
            }break;
        }
    }
}
//
//- (UIImageView *)czsPreview {
//    if (!_czsPreview) {
//        _czsPreview = [[UIImageView alloc]
//                       initWithFrame:CGRectMake(3,  self.view.height - 60, self.view.width / 9,
//                                                (self.view.width / 9) * 53 / 50)];
//        _czsPreview.layer.cornerRadius =
//        ((self.view.width / 9) * 53 / 50) / (self.view.width / 9) / 2;
//        _czsPreview.image = [UIImage imageNamed:@"czspreview"];
//        _czsPreview.userInteractionEnabled = YES;
//        UITapGestureRecognizer *tapPreview =
//        [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                action:@selector(previewClick)];
//        [_czsPreview addGestureRecognizer:tapPreview];
//    }
//    return _czsPreview;
//}

@end