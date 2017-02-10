//
//  BBQBabyModifyViewController.m
//  BBQ
//
//  Created by anymuse on 15/12/2.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import "BBQBabyModifyViewController.h"
#import "DatePicker.h"
#import <DateTools.h>
#import "ResetPassKeyTableViewController.h"
#import "AppDelegate.h"
#import "BBQSetNameViewController.h"
#import "BBQSetClassViewController.h"
#import "BBQSetSchoolViewController.h"
#import "BBQSchoolDataModel.h"
#import "BBQClassDataModel.h"
#import "RelationshipModel.h"
#import "RelationshipViewController.h"
#import "UIBarButtonItem+Extention.h"
#import "UIButton+Extension.h"
#import "ResetPasswordViewController.h"

@interface BBQBabyModifyViewController ()<
UITextFieldDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UIActionSheetDelegate>

@property(weak, nonatomic) IBOutlet UIButton *headBtn;

@property(weak, nonatomic) IBOutlet UILabel *babyNameLabel;

@property(assign, nonatomic) BOOL datePickerIsOn;

@property(weak, nonatomic) IBOutlet UIButton *birthdayButton;
@property(assign, nonatomic) int gender;

@property(strong, nonatomic) DatePicker *dp;
@property(weak, nonatomic) IBOutlet UIButton *boyButton;
@property(weak, nonatomic) IBOutlet UIButton *girlButton;
@property (weak, nonatomic) IBOutlet UIButton *relatButton;
@property (weak, nonatomic) IBOutlet UILabel *placelabel;
@property (weak, nonatomic) IBOutlet UILabel *schoolLabel;
@property (weak, nonatomic) IBOutlet UILabel *classlabel;
@property (weak, nonatomic) IBOutlet UILabel *headLabel;
@property (weak, nonatomic) IBOutlet UIImageView *nameNext;
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (nonatomic, strong) BBQSchoolDataModel *selectedSchool;
@property (nonatomic, strong) BBQClassDataModel *selectedClass;
//相册
@property(strong, nonatomic) UIImagePickerController *imagePicker;
//图片转换的data对象
@property(strong, nonatomic) NSData *data;
//图片二进制路径
@property(strong, nonatomic) NSString *filePathStr;

@property(strong, nonatomic) NSMutableArray *imageAry;
@property(strong, nonatomic) UploadFileModel *uploadFileModel;
@property (nonatomic, strong) RelationshipModel *relation;
@end

@implementation BBQBabyModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.baby)
        self.baby = TheCurBaoBao;
    
    [self initValues];
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
    __block BBQSchoolDataModel *school = [self.baby.baobaoschooldata firstObject];
    [self.baby.baobaoschooldata enumerateObjectsUsingBlock:^(BBQSchoolDataModel*  _Nonnull schoolmodel, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([schoolmodel.schooltype isEqualToNumber:@0]) {
            school = schoolmodel;
            *stop = YES;
        }
    }];
    BBQClassDataModel *classmodel = [school.classdata firstObject];
    if (school.schoolname.length) {
        self.schoolLabel.text=school.schoolname;
        if (school.resideprovince.length) {
            NSString *placeStr =[NSString stringWithFormat:@"%@%@%@",school.resideprovince,school.residecity,school.residedist];
            self.placelabel.text = placeStr;
        }
    }
    if (classmodel.classname.length) {
        self.classlabel.text= classmodel.classname;
    }
    if (self.baby.gxname.length) {
        [self.relatButton setTitle:self.baby.gxname forState:UIControlStateNormal];
        [self.relatButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    self.babyNameLabel.text = self.baby.realname;
    
    if ([self.baby.birthyear isEqual: @0] || [self.baby.birthmonth isEqual:@0] ||
        [self.baby.birthday isEqual: @0]) {
        [self.birthdayButton setTitle:@"请选择宝宝的出生日期"
                             forState:UIControlStateNormal];
    } else {
        NSDate *birthday = [NSDate dateWithYear:self.baby.birthyear.integerValue
                                          month:self.baby.birthmonth.integerValue
                                            day:self.baby.birthday.integerValue];
        [self.birthdayButton
         setTitle:[birthday formattedDateWithFormat:@"yyyy-MM-dd"]
         forState:UIControlStateNormal];
        [self.birthdayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    self.gender = self.baby.gender.intValue;
    if (self.gender == 1) {
        self.boyButton.selected = YES;
    } else if (self.gender == 2) {
        self.girlButton.selected = YES;
    }
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithtTarget:self anction:@selector(back) image:@"nav_back_arrow" title:@"返回"];
    [self.headBtn buttonDispNetorLocalImg:self.baby.avartar];
}
-(void)back{
    if (self.baby.realname.length ==0) {
        NSString *message = @"请填写宝宝的姓名并提交完成";
        [self showAlertWithName:message];
    }else if (self.baby.gxid.integerValue < 1) {
        NSString *message =@"请选择与宝宝的关系并提交完成";
        [self showAlertWithName:message];
    }else
        [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)showAlertWithName:(NSString *)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil, nil];
    [alert show];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
-(void)setBaobaoName{
    BBQSetNameViewController *NameVC= [[BBQSetNameViewController alloc] init];
    NameVC.nameStr = self.babyNameLabel.text;
    NameVC.title = @"填写姓名";
    WS(weakSelf);
    [NameVC returnText:^(NSString *showText) {
        weakSelf.babyNameLabel.text =showText;
    }];
    [self.navigationController pushViewController:NameVC animated:NO];
}
- (void)initValues {
    
    if (self.imageAry == nil) {
        self.imageAry = [NSMutableArray arrayWithCapacity:0];
    }
    if (self.uploadFileModel == nil) {
        self.uploadFileModel = [[UploadFileModel alloc] init];
    }
    if (TheCurBaoBao.qx.integerValue == BBQAuthorityTypeAdmin || TheCurBaoBao.qx.integerValue ==BBQAuthorityTypeManager) {
        self.headLabel.hidden = NO;
        self.nameNext.hidden = NO;
        self.birthdayButton.userInteractionEnabled = YES;
        self.girlButton.userInteractionEnabled = YES;
        self.headBtn.userInteractionEnabled = YES;
        self.boyButton.userInteractionEnabled = YES;
        [self.nameView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setBaobaoName)]];
    }else{
        self.headLabel.hidden = YES;
        self.nameNext.hidden = YES;
        self.birthdayButton.userInteractionEnabled = NO;
        self.girlButton.userInteractionEnabled = NO;
        self.headBtn.userInteractionEnabled = NO;
        self.boyButton.userInteractionEnabled = NO;
        
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
                                                                   
                                                                   self.baby.avartar = dic[@"data"][@"url_middle"];
                                                                   //通知刷新当前宝宝数据
                                                                   [[NSNotificationCenter defaultCenter]
                                                                    postNotificationName:
                                                                    kSetNeedsRefreshBaobaoHeadNotification
                                                                    object:nil
                                                                    userInfo:nil];
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
    _dp.datePicker.date = date;
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
    if (self.babyNameLabel.text.length ==0) {
        [SVProgressHUD showErrorWithStatus:@"请填写宝宝的姓名"];
    }else if ([self.relatButton.titleLabel.text
               hasPrefix:@"请选择"] || self.relatButton.titleLabel.text.length ==0) {
        [SVProgressHUD showErrorWithStatus:@"请选择与宝宝的关系"];
    }else{
        [SVProgressHUD showWithStatus:@"请稍候..."];
        NSString *birthdayStr = [self.babyNameLabel.text hasPrefix:@"请选择"]?@"":self.birthdayButton.titleLabel.text;
        NSNumber *classuid = self.classlabel.text?@0:self.selectedClass.classid;
        NSInteger gxid = self.relation ? ([self.relation.relationshipTag intValue] -200):self.baby.gxid.integerValue;
        NSString *gxname = self.relation ? self.relation.relaName:self.baby.gxname;
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"baobaouid"] = self.baby.uid;
        params[@"realname"] = self.babyNameLabel.text;
        params[@"birthday"] = birthdayStr;
        params[@"gender"] = @(self.gender);
        params[@"nickname"] = self.baby.nickname;
        params[@"classuid"] = classuid;
        params[@"gxid"] = @(gxid);
        params[@"gxname"] = gxname;
        [BBQHTTPRequest
         queryWithType:BBQHTTPRequestTypeUpdateBabyInfo
         param:params
         successHandler:^(AFHTTPRequestOperation *operation,
                          NSDictionary *responseObject, bool apiSuccess) {
             [[NSNotificationCenter defaultCenter] postNotificationName:kSetNeedsRefreshEntireDataNotification object:nil userInfo:nil];
             [SVProgressHUD showSuccessWithStatus:responseObject[@"msg"]];
             [self updateBaoBaoDataWithgxid:gxid gxname:gxname];
             if (self.type == BBQBabyModifyTypeNormal) {
                 [self.navigationController popToRootViewControllerAnimated:YES];
             }else{
                 if (TheCurUser.member.firstlogin) {
                     [self jumpToResetPass];
                 }else{
                     [((AppDelegate *)[UIApplication sharedApplication].delegate)
                      setupTabBarController];
                 }
             }
             
     } errorHandler:^(NSDictionary *responseObject) {
         NSLog(@"%@",responseObject);
         [SVProgressHUD showErrorWithStatus:@"宝宝信息修改失败,请检查信息是否正确"];
         
     }
     failureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
       [SVProgressHUD dismiss];  
     }];
    }

}
- (IBAction)relateButtonClick {
    [self performSegueWithIdentifier:@"modifyRelationShip" sender:nil];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"modifyRelationShip"]) {
        RelationshipViewController *vc = segue.destinationViewController;
        WS(weakSelf);
        vc.relationshipCallBack = ^(RelationshipModel *model) {
            weakSelf.relation = model;
            [weakSelf.relatButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [weakSelf.relatButton setTitle:model.relaName
                                  forState:UIControlStateNormal];
        };
    }
}
/// 更新本地宝宝数据
- (void)updateBaoBaoDataWithgxid:(NSInteger )gxid gxname:(NSString*)gxname {
    self.baby.gxid = @(gxid);
    self.baby.gxname = gxname;
    self.baby.realname = self.babyNameLabel.text;
    self.baby.gender = @(self.gender);
    
    NSDate *date = [NSDate dateWithString:self.birthdayButton.titleLabel.text
                             formatString:@"yyyy-MM-dd"];
    
    self.baby.birthyear = @(date.year);
    
    self.baby.birthmonth = @(date.month);
    self.baby.birthday = @(date.day);
    
    [TheCurUser updateBaby:self.baby];
    TheCurBaoBao = self.baby;
}
//关闭滑动返回手势
- (BOOL)fd_interactivePopDisabled {
    if (self.baby.realname.length == 0 || self.baby.gxid.integerValue < 1)
        return YES;
    else
        return NO;
}
-(void)jumpToResetPass{
    UIStoryboard *storyBoard =
    [UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil];
    ResetPassKeyTableViewController *ResetPassVcl =
    [storyBoard instantiateViewControllerWithIdentifier:@"ResetPassVcl"];
    ResetPassVcl.type = BBQResetPasswordTypeLogin;
    [self.navigationController pushViewController:ResetPassVcl animated:YES];
}

@end
