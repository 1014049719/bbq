//
//  BBQDynamicEditViewController.m
//  BBQ
//
//  Created by 朱琨 on 15/12/4.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import "BBQDynamicEditViewController.h"
#import "BBQDynamicEditMediaCell.h"
#import "QBImagePickerController.h"
#import <CNPPopupController.h>
#import "BBQMoviePlayerViewController.h"
#import "MJPhotoBrowser.h"
#import <UINavigationController+FDFullscreenPopGesture.h>
#import "Dynamic.h"
#import <DateTools.h>
#import "BBQPublishManager.h"
#import "SetTableViewController.h"
#import "AGEmojiKeyBoardView.h"
#import "BBQDualListViewController.h"
#import "BBQPopupControllerFactory.h"
#import "BBQDynamicTableViewController.h"
#import "BBQDynamicPageController.h"

@interface BBQDynamicEditViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, YYTextViewDelegate, QBImagePickerControllerDelegate, BBQPopupControllerDelegate, AGEmojiKeyboardViewDelegate, AGEmojiKeyboardViewDataSource>

@property (strong, nonatomic) BBQPopupController *datePickerController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *publishButton;
@property (weak, nonatomic) IBOutlet UIButton *emojiButton;
//@property (weak, nonatomic) IBOutlet UIButton *firstTimeButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property(strong, nonatomic) AGEmojiKeyboardView *emojiKeyboardView;
@property (weak, nonatomic) IBOutlet UILabel *recordTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sendToLabel;
@property (weak, nonatomic) IBOutlet YYTextView *textView;

@end

@implementation BBQDynamicEditViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    self.navigationItem.title = ({
        NSString *title;
        switch ((BBQDynamicGroupType)_dynamic.dtype.integerValue) {
            case BBQDynamicGroupTypeBaby: {
                title = _dynamic.baobaoname;
                break;
            }
            case BBQDynamicGroupTypeClass: {
                title = _dynamic.classname;
                break;
            }
            case BBQDynamicGroupTypeSchool: {
                title = _dynamic.schoolname;
                break;
            }
            case BBQDynamicGroupTypeSquare: {
                title = _navTitle;
                break;
            }
        }
        self.sendToLabel.text = title;
        title;
    });
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    _textView.textContainerInset = UIEdgeInsetsMake(10, 15, 10, 15);
    _textView.textColor = UIColorHex(333333);
    _textView.font = [UIFont systemFontOfSize:14];
    _textView.placeholderText = @"宝宝正在干嘛呢？";
    _textView.placeholderTextColor = UIColorHex(999999);
    _textView.placeholderFont = [UIFont systemFontOfSize:14];
    if ([_dynamic.content isNotBlank]) {
        _textView.text= _dynamic.content;
    }
    if (!_dynamic.attachinfo.count && !_dynamic.setDate) {
        _dynamic.graphtime = @([[NSDate date] timeIntervalSince1970]);
    }
    
    //更新记录时间Label
    @weakify(self)
    if (_dynamic.dtype.integerValue != BBQDynamicGroupTypeSquare) {
        [self.dynamic bk_addObserverForKeyPath:@"graphtime" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
            @strongify(self)
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.dynamic.graphtime.doubleValue];
            dispatch_async_on_main_queue(^{
                self.recordTimeLabel.text = [NSString stringWithFormat:@"拍摄于 %@", [date formattedDateWithFormat:@"yyyy年MM月dd日"]];
            });
        }];
    } else {
        self.recordTimeLabel.text = [[NSDate date] formattedDateWithFormat:@"yyyy年MM月dd日"];
    }
    
    [self.dynamic bk_addObserverForKeyPath:@"attachinfo" task:^(id target) {
        @strongify(self)
        if (!self.dynamic.setDate) {
            if (self.dynamic.attachinfo.count) {
                __block NSInteger max = 0;
                [self.dynamic.attachinfo bk_each:^(Attachment *obj) {
                    max = MAX(max, obj.graphtime.integerValue);
                }];
                self.dynamic.graphtime = @(max);
            } else {
                self.dynamic.graphtime = @([[NSDate date] timeIntervalSince1970]);
            }
        }
    }];
}

#pragma mark - Action
- (void)updateTimeLabel {
    if (_dynamic.dtype.integerValue == BBQDynamicGroupTypeSquare) return;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_dynamic.graphtime.doubleValue];
    _recordTimeLabel.text = [NSString stringWithFormat:@"拍摄于 %@", [date formattedDateWithFormat:@"yyyy年MM月dd日"]];
}

- (IBAction)didClickFaceButton:(UIButton *)button {
    self.emojiButton.selected = !self.emojiButton.selected;
    [self.textView resignFirstResponder];
    if (button.selected) {
        self.textView.inputView = self.emojiKeyboardView;
        
    } else {
        self.textView.inputView = nil;
    }
    [self.textView becomeFirstResponder];
}

- (IBAction)cancelEdit:(id)sender {
    if (_dynamic.attachinfo.count || [_dynamic.content isNotBlank]) {
        @weakify(self)
        [UIAlertView bk_showAlertViewWithTitle:@"提示" message:@"确认取消发表吗？" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            @strongify(self)
            if (buttonIndex == 1) {
                [self.dynamic.attachinfo bk_each:^(Attachment *obj) {
                    [obj deleteLocalFile];
                    [obj deleteLocalThumb];
                }];
                
                [self popVC];
            }
        }];
    } else {
        [self popVC];
    }
}

- (void)popVC {
    if (_dynamic.dtype.integerValue == BBQDynamicGroupTypeSquare) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
//    [self.navigationController.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([obj isKindOfClass:[BBQDynamicTableViewController class]] || [obj isKindOfClass:[BBQDynamicPageController class]]) {
//            *stop = YES;
//            if (_dynamic.dtype.integerValue != BBQDynamicGroupTypeSquare) {
//                self.tabBarController.selectedIndex = 0;
//            }
//            [self.navigationController popToViewController:obj animated:YES];
//        }
//    }];
}

- (IBAction)didClickPublish:(id)sender {
    if (_dynamic.attachinfo.count && _dynamic.mediaType == BBQDynamicMediaTypeVideo) {
        Attachment *attachment = _dynamic.attachinfo.firstObject;
        if (![[attachment videoLocalPath] isNotBlank]) {
            ShowInfoWithCompletion(BBQHUDTypeInfo, @"正在处理视频，请稍候...", nil);
            return;
        }
    }
    if (kNetworkStatus == AFNetworkReachabilityStatusReachableViaWiFi) {
        [self publish];
        return;
    }
    
    if (kNetworkStatus == AFNetworkReachabilityStatusReachableViaWWAN && TheCurUser.needWarnWifi) {
        TheCurUser.netAlertCount++;
        @weakify(self)
        [UIAlertView bk_showAlertViewWithTitle:@"提示" message:@"您当前为移动数据传输，继续发表将消耗流量，是否需要设置仅在Wi-Fi环境下上传？" cancelButtonTitle:@"取消" otherButtonTitles:@[@"继续发表", @"去设置"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            @strongify(self)
            switch (buttonIndex) {
                case 1: {
                    [self publish];
                } break;
                case 2: {
                    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil];
                    SetTableViewController *vc = [sb instantiateViewControllerWithIdentifier:@"settingup"];
                    [self.navigationController pushViewController:vc animated:YES];
                } break;
                default:
                    break;
            }
        }];
        return;
    }
    
    [self publish];
}

- (void)publish {
    self.publishButton.enabled = NO;
    [[BBQPublishManager sharedManager] addDynamic:_dynamic];
    [self popVC];
    
    //    if (_dynamic.dtype.integerValue == BBQDynamicGroupTypeSquare) {
    //
    //    } else {
    //        self.tabBarController.selectedIndex = 0;
    //        [self.navigationController popToRootViewControllerAnimated:YES];
    //    }
}

- (IBAction)goToSet:(id)sender {
    
}

- (void)addItem {
    QBImagePickerController *imagePicker = [[QBImagePickerController alloc] initWithDynamic:_dynamic];
    imagePicker.navTitle = self.navTitle;
    imagePicker.delegate = self;
    [self.navigationController pushViewController:imagePicker animated:YES];
}

- (void)previewAtIndex:(NSIndexPath *)indexPath {
    if (_dynamic.mediaType == BBQDynamicMediaTypeVideo) {
        BBQMoviePlayerViewController *vc = [BBQMoviePlayerViewController new];
        Attachment *attachment = _dynamic.attachinfo.firstObject;
        if (attachment.assetURL) {
            vc.movieURL = attachment.assetURL;
        } else {
            vc.movieURL = [NSURL URLWithString:((Attachment *)_dynamic.attachinfo.firstObject).filepath];
        }
        [vc readyPlayer];
        [self.navigationController presentViewController:vc animated:YES completion:nil];
    } else {
        NSMutableArray *photos = [NSMutableArray array];
        for (Attachment *model in _dynamic.attachinfo) {
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.url = model.assetURL ?: [NSURL URLWithString:model.filepath];
            [photos addObject:photo];
        }
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        browser.currentPhotoIndex = indexPath.row;
        browser.photos = photos;
        [browser show];
    }
}


#pragma mark - Text view delegate
- (void)textViewDidChange:(YYTextView *)textView {
    _dynamic.content = textView.text;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 2) {
        return 2;
    }
    return 1;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return kScreenHeight * 0.35;
    } else if (indexPath.section == 1) {
        CGFloat height = (_dynamic.attachinfo.count / 4 + 1) * ([BBQDynamicEditMediaCell cellWidth] + 10) + 10;
        return height;
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 2.5;
    } else if (section == 2) {
        return 1.5;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 2.5;
    } else if (section == 1) {
        return 1;
    }
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (_dynamic.dtype.integerValue == BBQDynamicGroupTypeSquare) return;
        if (indexPath.row == 0) {
            [self.datePickerController presentPopupControllerAnimated:YES];
        } else if (indexPath.row == 1) {
#ifndef TARGET_PARENT
            BBQDualListViewController *vc = [[UIStoryboard storyboardWithName:@"Common" bundle:nil] instantiateViewControllerWithIdentifier:@"DualListVC"];
            vc.dualListType = BBQDualListTypePublishDynamic;
            vc.dynamic = _dynamic;
            [self.navigationController pushViewController:vc animated:YES];
#endif
        }
    }
}

#pragma mark - Scroll view delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - UICollection View Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == _dynamic.attachinfo.count) {
        [self addItem];
    } else {
        [self previewAtIndex:indexPath];
    }
}

#pragma mark - UICollection View Data Source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_dynamic.mediaType == BBQDynamicMediaTypeVideo) {
        return 1;
    }
    return MIN(9, _dynamic.attachinfo.count + 1);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BBQDynamicEditMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kDynamicEditMediaIdentifier forIndexPath:indexPath];
    
    if (indexPath.item == _dynamic.attachinfo.count) {
        cell.deselectButton.hidden = YES;
        cell.layer.contents = (__bridge id)[UIImage imageNamed:@"dynamic_edit_add"].CGImage;
    } else {
        cell.deselectButton.hidden = NO;
        cell.attach = _dynamic.attachinfo[indexPath.item];
    }
    
    @weakify(self)
    cell.deselectMedia = ^(Attachment *attach) {
        @strongify(self)
        [attach deleteLocalFile];
        if (self.dynamic.mediaType == BBQDynamicMediaTypeVideo) {
            [attach deleteLocalThumb];
        }
        [self.dynamic deleteAAttach:attach];
        [self updateTimeLabel];
        [self.collectionView reloadData];
        [self.tableView reloadSection:1 withRowAnimation:UITableViewRowAnimationNone];
    };
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (kScreenWidth - 5 * 15) / 4.0 ;
    return CGSizeMake(width, width);
}

#pragma mark - QBImagePicker Delegate
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets {
    NSMutableOrderedSet *selectedAssetURLs = [NSMutableOrderedSet orderedSet];
    [imagePickerController.selectedAssetURLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [selectedAssetURLs addObject:obj];
    }];
    @weakify(self)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self)
        [self.dynamic addSelectedAssetURLs:selectedAssetURLs];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadSection:1 withRowAnimation:UITableViewRowAnimationNone];
        });
    });
}

#pragma mark - BBQPopupController Delegate
- (NSDate *)selectedDateForPopupController:(BBQPopupController *)controller {
    return [NSDate dateWithTimeIntervalSince1970:_dynamic.graphtime.doubleValue];
}

- (void)popupController:(BBQPopupController *)popupController didSelectDate:(NSDate *)date {
    _dynamic.graphtime = @([date timeIntervalSince1970]);
    _dynamic.setDate = YES;
}

#pragma mark - Emoji Keyboard Delegate
- (AGEmojiKeyboardViewCategoryImage)defaultCategoryForEmojiKeyboardView:
(AGEmojiKeyboardView *)emojiKeyboardView {
    return AGEmojiKeyboardViewCategoryImageEmoji;
}

- (void)emojiKeyBoardViewDidPressSendButton:
(AGEmojiKeyboardView *)emojiKeyBoardView {
    [self didClickPublish:nil];
}

- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView
              didUseEmoji:(NSString *)emoji {
    [self.textView insertText:emoji];
}

- (void)emojiKeyBoardViewDidPressBackSpace:
(AGEmojiKeyboardView *)emojiKeyBoardView {
    if (self.textView.text.length > 0) {
        [self.textView deleteBackward];
    }
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView
      imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img;
    if (category == AGEmojiKeyboardViewCategoryImageEmoji) {
        img = [UIImage imageNamed:@"keyboard_emotion_emoji"];
    } else if (category == AGEmojiKeyboardViewCategoryImageMonkey) {
        img = [UIImage imageNamed:@"keyboard_emotion_monkey"];
    } else {
        img = [UIImage imageNamed:@"keyboard_emotion_monkey_gif"];
    }
    return img;
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView
   imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    return [self emojiKeyboardView:emojiKeyboardView
          imageForSelectedCategory:category];
}

- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:
(AGEmojiKeyboardView *)emojiKeyboardView {
    UIImage *img = [UIImage imageNamed:@"emoji_delete"];
    [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return img;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (!self.emojiButton.selected) {
        textView.inputView = nil;
    }
    return YES;
}

#pragma mark - Getter & Setter
- (BBQPopupController *)datePickerController {
    if (!_datePickerController) {
        _datePickerController = [BBQPopupControllerFactory popupControllerWithType:BBQPopupControllerTypeDatePicker];
        _datePickerController.delegate = self;
    }
    return _datePickerController;
}

- (AGEmojiKeyboardView *)emojiKeyboardView {
    if (!_emojiKeyboardView) {
        _emojiKeyboardView = [[AGEmojiKeyboardView alloc]
                              initWithFrame:CGRectMake(
                                                       0, 0, kScreenWidth, 216)
                              dataSource:self
                              showBigEmotion:NO];
        _emojiKeyboardView.delegate = self;
    }
    return _emojiKeyboardView;
}

- (BOOL)fd_interactivePopDisabled {
    return YES;
}

@end
