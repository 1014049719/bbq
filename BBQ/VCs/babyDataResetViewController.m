//
//  babyDataResetViewController.m
//  BBQ
//
//  Created by wth on 15/7/29.
//  Copyright (c) 2015年 bbq. All rights reserved.
//

#import "babyDataResetViewController.h"
#import "DatePicker.h"
#import <DateTools.h>
#import "ResetPassKeyTableViewController.h"
#import "AppDelegate.h"

@interface babyDataResetViewController () <
    UITextFieldDelegate, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate, UIActionSheetDelegate>

@property(weak, nonatomic) IBOutlet UIButton *headBtn;

@property(weak, nonatomic) IBOutlet UILabel *babyNameLabel;

@property(weak, nonatomic) IBOutlet UILabel *schoolLabel;
@property(weak, nonatomic) IBOutlet UILabel *classLabel;
@property(assign, nonatomic) BOOL datePickerIsOn;

@property(weak, nonatomic) IBOutlet UIButton *birthdayButton;
@property(assign, nonatomic) int gender;

@property(strong, nonatomic) DatePicker *dp;
@property(weak, nonatomic) IBOutlet UIButton *boyButton;
@property(weak, nonatomic) IBOutlet UIButton *girlButton;

//相册
@property(strong, nonatomic) UIImagePickerController *imagePicker;
//图片转换的data对象
@property(strong, nonatomic) NSData *data;
//图片二进制路径
@property(strong, nonatomic) NSString *filePathStr;

@property(strong, nonatomic) NSMutableArray *imageAry;
@property(strong, nonatomic) UploadFileModel *uploadFileModel;

@end

@implementation babyDataResetViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  if (!self.baby)
    self.baby = TheCurBaoBao;

  [self initValues];

  if (self.type == BBQBabyDataResetTypeLogin) {
    [self.navigationController
        setViewControllers:
            @[ self.navigationController.viewControllers.firstObject, self ]
                  animated:NO];
  }

  //相册
  _imagePicker = [[UIImagePickerController alloc] init];
  _imagePicker.allowsEditing = YES;
  //要同时包含<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
  _imagePicker.delegate = self;

  self.headBtn.layer.masksToBounds = YES;
  self.headBtn.layer.cornerRadius = CGRectGetHeight(self.headBtn.frame) / 2.0;

  NSArray *ary =
      [[NSBundle mainBundle] loadNibNamed:@"DatePicker" owner:self options:nil];
  _dp = ary[0];

  self.schoolLabel.text = self.baby.curSchool.schoolname;
  self.classLabel.text = self.baby.curClass.classname;
  self.babyNameLabel.text = self.baby.realname;

  if (self.baby.birthyear == 0 && self.baby.birthmonth == 0 &&
      self.baby.birthday == 0) {
    [self.birthdayButton setTitle:@"请选择宝宝的出生日期"
                         forState:UIControlStateNormal];
  } else {
    NSDate *birthday = [NSDate dateWithYear:self.baby.birthyear.integerValue
                                      month:self.baby.birthmonth.integerValue
                                        day:self.baby.birthday.integerValue];
    [self.birthdayButton
        setTitle:[birthday formattedDateWithFormat:@"yyyy-MM-dd"]
        forState:UIControlStateNormal];
  }

  self.gender = self.baby.gender.intValue;
  if (self.gender == 1) {
    self.boyButton.selected = YES;
  } else if (self.gender == 2) {
    self.girlButton.selected = YES;
  }

    [self.headBtn setImageWithURL:[NSURL URLWithString:self.baby.avartar] forState:UIControlStateNormal placeholder:Placeholder_avatar];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)initValues {

  if (self.imageAry == nil) {
    self.imageAry = [NSMutableArray arrayWithCapacity:0];
  }
  if (self.uploadFileModel == nil) {
    self.uploadFileModel = [[UploadFileModel alloc] init];
  }
}

- (void)tapEvent:(UITapGestureRecognizer *)ges {
}

//设置上传宝宝头像按钮
- (IBAction)BabyHeaderIconBtnClick:(id)sender {

  //创建UIActionSheet
  UIActionSheet *actionSheet =
      [[UIActionSheet alloc] initWithTitle:@"选择照片"
                                  delegate:self
                         cancelButtonTitle:@"取消"
                    destructiveButtonTitle:@"来自相册"
                         otherButtonTitles:@"拍照", nil];
  [actionSheet showInView:self.view];
}

// UIActionSheet选择事件
- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {

  switch (buttonIndex) {
  case 0: {
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //跳转到相册
    [self presentViewController:_imagePicker animated:YES completion:nil];
    NSLog(@"点击相册0");
  } break;
  case 1: {
    _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:_imagePicker animated:YES completion:nil];
    NSLog(@"点击相机1");
  } break;
  default:
    break;
  }
}

// imagePickerView代理 照片选择完成
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {

  UIImage *image = info[UIImagePickerControllerEditedImage];

  NSString *filenameGuid = [NSString stringWithUUID];
  NSDictionary *dicFileInfo =
      [CommonFunc saveJYEXPic:image fileguid:filenameGuid mode:@"L"];

  if (!dicFileInfo) {
    [SVProgressHUD showErrorWithStatus:@"保存文件失败"];
    return;
  }

  NSString *filepath = dicFileInfo[@"slt"][@"filepath"];
  UIImage *imagefile = [UIImage imageWithContentsOfFile:filepath];

  self.uploadFileModel.fileData = UIImageJPEGRepresentation(imagefile, 1);
  self.uploadFileModel.fileName = filepath;
  [self.imageAry addObject:self.uploadFileModel];

  //刚换按钮图片
  [self.headBtn setBackgroundImage:imagefile forState:UIControlStateNormal];

  NSLog(@"开始上传头像请求");

  //保存后 上传图片请求
  [self
      UploadHeadIconWithUrlStr:[CS_URL_BASE
                                   stringByAppendingString:URL_UPLOAD_AVATAR]];

  //完成后返回界面
  [self dismissViewControllerAnimated:YES completion:nil];
}

// imagePickerView代理 照片选择取消
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

  //取消后返回界面
  [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark 上传头像请求
- (void)UploadHeadIconWithUrlStr:(NSString *)UrlStr {

  [SVProgressHUD showWithStatus:@"请稍候..."];
  //上传参数

  //是宝宝的头像
  NSDictionary *paramsDic = @{ @"uid" : self.baby.uid };
  [HttpTool multipartPostFileDataWithPath:UrlStr
      params:paramsDic
      dataAry:self.imageAry
      success:^(id JSON) {
        dispatch_async(
            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
              NSDictionary *dic = JSON;
              NSInteger res = [dic[@"res"] integerValue];
              if (res == 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                  [SVProgressHUD showSuccessWithStatus:@"上传成功"];

                  self.baby.avartar = self.uploadFileModel.fileName;
                  //更新刷新数
                  
                  //通知
                  [[NSNotificationCenter defaultCenter]
                      postNotificationName:
                          kSetNeedsRefreshEntireDataNotification
                                    object:nil
                                  userInfo:@{
                                    @"type" : @(BBQRefreshNotificationTypeAll)
                                  }];
                });

              } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                  NSString *message =
                      [NSString stringWithFormat:@"%@", dic[@"msg"]];
                  [SVProgressHUD showErrorWithStatus:message];
                });
              }
            });
      }
      failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        });
      }];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  [_dp removeFromSuperview];

  return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
}

//选择宝宝生日按钮
- (IBAction)BabyBirthdayBtnClick:(UIButton *)sender {
  NSDate *date = [NSDate date];
  NSString *now = [date formattedDateWithFormat:@"yyyy-MM-dd"];
  _dp.datePicker.datePickerMode = UIDatePickerModeDate;
  WS(weakSelf)
  _dp.datePickerCallBack = ^(NSString *time) {
    if ([time compare:now] == NSOrderedDescending) {
      [SVProgressHUD showErrorWithStatus:@"宝"
                                         @"宝生日有误，请重新选择"];
    } else {
      [weakSelf.birthdayButton setTitle:time forState:UIControlStateNormal];
    }
  };
  [self.view addSubview:_dp];
  if (_dp.datePickerIsOn == NO) {
  }

  _dp.datePickerIsOn = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [_dp removeFromSuperview];
//}
//选择性别
- (IBAction)SexBtnClick:(UIButton *)sender {

  for (int i = 0; i < 2; i++) {

    UIButton *button = (UIButton *)[self.view viewWithTag:10 + i];
    button.selected = NO;
  }
  sender.selected = YES;

  if ([sender.titleLabel.text isEqualToString:@"男孩"]) {
    self.gender = 1;
  } else {
    self.gender = 2;
  }
}

//完成按钮
- (IBAction)completeBtnClick:(id)sender {
  NSDate *date = [NSDate dateWithString:self.birthdayButton.titleLabel.text
                           formatString:@"yyyy-MM-dd"];
  NSInteger year = [date year];
  NSInteger month = [date month];
  NSInteger day = [date day];

  //    if ([self.baby.avartar rangeOfString:@"lasttime=0"].location !=
  //    NSNotFound) {
  //        [SVProgressHUD showErrorWithStatus:@"请上传宝宝头像"];
  //    }
  if ([self.birthdayButton.titleLabel.text
          isEqualToString:@"请选择宝宝的出生日期"]) {
    [SVProgressHUD showErrorWithStatus:@"请选择宝宝的出生日期"];
  }

  else if (year == 0 || month == 0 || day == 0) {
    [SVProgressHUD showErrorWithStatus:@"请选择正确的宝宝出生日期"];
  }

  else if (self.gender == 0) {
    [SVProgressHUD showErrorWithStatus:@"请选择宝宝性别"];
  } else {
    [SVProgressHUD showWithStatus:@"请稍候..."];
    NSDictionary *params = @{
      @"baobaouid" : self.baby.uid,
      @"realname" : self.babyNameLabel.text,
      @"birthday" : self.birthdayButton.titleLabel.text,
      @"gender" : @(self.gender),
      @"nickname" : self.baby.nickname
    };
    [BBQHTTPRequest
         queryWithType:BBQHTTPRequestTypeUpdateBabyInfo
                 param:params
        successHandler:^(AFHTTPRequestOperation *operation,
                         NSDictionary *responseObject, bool apiSuccess) {
          [SVProgressHUD showSuccessWithStatus:responseObject[@"msg"]];
          [self updateBaoBaoData];
          //更新刷新数
          

          if (self.type == BBQBabyDataResetTypeLogin) {
            if ([TheCurUser needResetPassword]) {
              UIStoryboard *storyBoard =
                  [UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil];
              ResetPassKeyTableViewController *ResetPassVcl = [storyBoard
                  instantiateViewControllerWithIdentifier:@"ResetPassVcl"];
              ResetPassVcl.type = BBQResetPasswordTypeLogin;
              [self.navigationController pushViewController:ResetPassVcl
                                                   animated:YES];
            } else {
              [((AppDelegate *)[UIApplication sharedApplication].delegate)
                      setupTabBarController];
            }
          } else if (self.type == BBQBabyDataResetTypeNormal) {
            [[NSNotificationCenter defaultCenter]
                postNotificationName:kSetNeedsRefreshEntireDataNotification
                              object:nil
                            userInfo:@{
                              @"type" : @(BBQRefreshNotificationTypeUserInfo)
                            }];
            [self.navigationController popViewControllerAnimated:YES];
          }
        } errorHandler:nil
        failureHandler:nil];
  }
}

/// 更新本地宝宝数据
- (void)updateBaoBaoData {

  self.baby.realname = self.babyNameLabel.text;
  self.baby.gender = @(self.gender);

  NSDate *date = [NSDate dateWithString:self.birthdayButton.titleLabel.text
                           formatString:@"yyyy-MM-dd"];

  self.baby.birthyear = @(date.year);

  self.baby.birthmonth = @(date.month);
  self.baby.birthday = @(date.day);
    [TheCurUser updateBaby:self.baby];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
