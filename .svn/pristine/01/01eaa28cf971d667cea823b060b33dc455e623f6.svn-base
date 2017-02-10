//
//  BBQInviteViewController.m
//  BBQ
//
//  Created by anymuse on 15/11/25.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import "BBQInviteViewController.h"
#import "BBQBabyDataCreateViewController.h"
#import "BBQInviteViewCell.h"
#import "BBQSchoolDataModel.h"
#import "BBQClassDataModel.h"
#import "AppDelegate.h"
#import "BBQBabyModifyViewController.h"
#import "BBQAttentionBaby.h"
#import "BBQDynamicPageController.h"
#import "IMYThemeConfig.h"

@interface BBQInviteViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UILabel *classLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) BBQSchoolDataModel *schoolmodel;
@property(strong, nonatomic) BBQClassDataModel *classmodel;
@property(strong, nonatomic) BBQBabyModel *baobao;
@property(copy, nonatomic) NSString *classname;
@property (weak, nonatomic) IBOutlet UILabel *hudLabel;
@property (weak, nonatomic) IBOutlet UILabel *describLabel;
@property (weak, nonatomic) IBOutlet UILabel *inviteLabel;
@property (nonatomic, assign) BBQBabyModifyType babyModifyType;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backViewHightConstraint;

@property(copy, nonatomic) NSString *classuid;
@property (nonatomic, strong) NSArray *babys;
@end

@implementation BBQInviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _coverView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    _tableView.rowHeight = 70;
    if (self.type ==BBQInviteViewTypeParentsPhone) {
        self.classLabel.text =@"请选择需要关注的宝宝";
        self.codeTextField.placeholder = @"请输入手机号码";
        self.codeTextField.keyboardType = UIKeyboardTypeNumberPad;
        self.describLabel.hidden = YES;
        self.inviteLabel.textAlignment = NSTextAlignmentCenter;
        self.inviteLabel.text = @"输入家长手机号码，可以关注家长的宝宝";
    }else if (self.type == BBQInviteViewTypeTeacherPhone){
        self.classLabel.text =@"请选择想要加入的班级";
        self.codeTextField.placeholder = @"请输入手机号码";
        self.codeTextField.keyboardType = UIKeyboardTypeNumberPad;
        self.describLabel.hidden = YES;
        self.inviteLabel.textAlignment = NSTextAlignmentCenter;
        self.inviteLabel.text = @"输入老师手机号码，可以关注老师的班级";
    }
    
}

- (IBAction)verifyButtonDidClick:(id)sender {
    if (self.type ==BBQInviteViewTypeParentsPhone || self.type == BBQInviteViewTypeTeacherPhone){
        if (self.codeTextField.text.length != 11) {
            [SVProgressHUD showErrorWithStatus:@"请输入11位手机号码"];
        } else {
            [self verifyPhone:self.codeTextField.text];
        }
        
    }else{
        if (self.codeTextField.text.length != 6) {
            [SVProgressHUD showErrorWithStatus:@"请输入6位邀请码"];
        } else {
            [self verifyRequestCode:self.codeTextField.text];
        }
    }
}
- (void)showAlertWithName:(NSString *)name {
    NSString *message =
    [NSString stringWithFormat:@"您已经成功添加了宝宝\"%@"
     @"\"，现在可以看到宝宝的最新变化了。",
     name];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - 验证邀请码
- (void)verifyRequestCode:(NSString *)requestcode {
    [self.view endEditing:YES];
    [SVProgressHUD showWithStatus:@"请稍候..."];
    NSDictionary *params = @{ @"yqm" : requestcode };
    [BBQHTTPRequest
     queryWithType:BBQHTTPRequestTypeYQM
     param:params
     successHandler:^(AFHTTPRequestOperation *operation,
                      NSDictionary *responseObject, bool apiSuccess) {
         NSNumber *status = responseObject[@"data"][@"status"];
         if ([status isEqualToNumber:@0]) {
             [SVProgressHUD dismiss];
             NSDictionary *dict = responseObject[@"data"][@"baobaodata"][0];
             BBQBabyModel *babymodel = [BBQBabyModel modelWithDictionary:dict];
             self.baobao = babymodel;
            [TheCurUser addABaby:self.baobao];
             TheCurBaoBao = self.baobao;
             if (TheCurUser.baobaodata.count==1) {
                 UIWindow *window = [UIApplication sharedApplication].keyWindow;
                 UITabBarController *rootVC = (UITabBarController*)window.rootViewController;
                 NSMutableArray *vcs = [rootVC.viewControllers mutableCopy];
                 UINavigationController *nav;
                 BBQDynamicPageController *pageController = [[BBQDynamicPageController alloc] initWithBaby:TheCurBaoBao];
                 nav = [[UINavigationController alloc] initWithRootViewController:pageController];
                 nav.tabBarItem.title = @"宝宝";
                 [nav.tabBarItem imy_setFinishedSelectedImageName:@"tab_1_selected" withFinishedUnselectedImageName:@"tab_1_unselected"];
                 [vcs replaceObjectAtIndex:0 withObject:nav];
                 rootVC.viewControllers = vcs;
                 [window setRootViewController:rootVC];
                 self.babyModifyType = BBQBabyModifyTypeLogin;
             }else
                 self.babyModifyType = BBQBabyModifyTypeNormal;
             //发送通知 刷新关注列表
             [[NSNotificationCenter defaultCenter]
              postNotificationName:@"baobaoDataChange"
              object:nil];
             
             [[NSNotificationCenter defaultCenter]
              postNotificationName:kSetNeedsRefreshEntireDataNotification
              object:nil
              userInfo:@{
                         @"type" : @(BBQRefreshNotificationTypeAll)
                         }];
             [self jumpToModifyViewController];
             
         }else if ([status isEqual:@3]){
             [SVProgressHUD dismiss];
             [UIView animateWithDuration:0.5 animations:^{
                 self.hudLabel.text = @"您已关注该宝宝";
                 self.hudLabel.alpha = 1.0;
             }completion:^(BOOL finished){
                 [UIView animateWithDuration:2.0 animations:^{
                     self.hudLabel.alpha = 0.0;
                 }];
             }];
         }else{
             self.schoolmodel = [[NSArray modelArrayWithClass:[BBQSchoolDataModel class] json:responseObject[@"data"][@"schooldata"]] firstObject];
             self.classmodel = [self.schoolmodel.classdata firstObject];
             self.classuid = self.classmodel.classid.stringValue;
             [self joinInClass:self.classuid];
         }
     } errorHandler:^(NSDictionary *responseObject) {
         [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
     }
     failureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
         [SVProgressHUD showErrorWithStatus:@"验证失败"];
     }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.babys.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BBQInviteViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:@"inviteViewCell"];
    if (self.type ==BBQInviteViewTypeParentsPhone){
        cell.attentionBaobao = self.babys[indexPath.row];
    }else{
        cell.curClass = self.babys[indexPath.row];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.type ==BBQInviteViewTypeParentsPhone){
        BBQAttentionBaby *baby = self.babys[indexPath.row];
        [self attentionRequest:baby];
    }else{
        BBQClassByPhone *class = self.babys[indexPath.row];
        [self joinInClass:class.classuid];
        [UIView animateWithDuration:0.5 animations:^{
            self.coverView.alpha = 0.0;
        }];
    }
    
}
-(void)jumpToModifyViewController{
    UIStoryboard *storyBoard =
    [UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil];
    BBQBabyModifyViewController *vc = [storyBoard
                                       instantiateViewControllerWithIdentifier:@"babyModifyVC"];
    vc.type =self.babyModifyType;
    [self.navigationController pushViewController:vc animated:YES];
    
}
#pragma mark - 验证手机号码
- (void)verifyPhone:(NSString *)requesPhone {
    [self.view endEditing:YES];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    BBQHTTPRequestType requestType;
    if (self.type ==BBQInviteViewTypeParentsPhone) {
        requestType = BBQHTTPRequestTypebaobaolistbynum;
        params[@"phonenum"] = requesPhone;
    }else{
       requestType = BBQHTTPRequestTypeBabyIntoClassByPhone;
        params[@"phonenum"] = requesPhone;
        params[@"baobaouid"] = self.curBabyID;
    }
    [SVProgressHUD showWithStatus:@"请稍候..."];
    [BBQHTTPRequest
     queryWithType:requestType
     param:params
     successHandler:^(AFHTTPRequestOperation *operation,
                      NSDictionary *responseObject, bool apiSuccess) {
         if (self.type == BBQInviteViewTypeParentsPhone) {
             self.babys = [NSArray modelArrayWithClass:[BBQAttentionBaby class] json:responseObject[@"data"][@"arr"]];
             self.backViewHightConstraint.constant= self.babys.count>1?180:110;
         }else{
             self.babys = [NSArray modelArrayWithClass:[BBQClassByPhone class] json:responseObject[@"data"][@"arr"]];
             self.backViewHightConstraint.constant= self.babys.count>1?180:110;
         }
         [self.tableView reloadData];
         
         [UIView animateWithDuration:0.5 animations:^{
             self.coverView.alpha = 1.0;
         }];
         [SVProgressHUD dismiss];
         
     } errorHandler:^(NSDictionary *responseObject) {
         [SVProgressHUD showErrorWithStatus:@"手机号码有误,请核对"];
     }
     failureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
         [SVProgressHUD showErrorWithStatus:@"验证失败"];
     }];
}
-(void)joinInClass:(NSString*)classID{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"baobaouid"] = self.curBabyID;
    params[@"classuid"]=classID;
    [BBQHTTPRequest
     queryWithType:BBQHTTPRequestTypeIntoClass
     param:params
     successHandler:^(AFHTTPRequestOperation *operation,
                      NSDictionary *responseObject, bool apiSuccess) {
         [SVProgressHUD dismiss];
         [UIView animateWithDuration:0.5 animations:^{
             self.hudLabel.text = @"已经向老师发出申请,等待老师审核中";
             self.hudLabel.alpha = 1.0;
         }completion:^(BOOL finished){
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 self.hudLabel.alpha = 0.0;
                 if (((UITabBarController*)([UIApplication sharedApplication].keyWindow.rootViewController)).selectedIndex !=0) {
                     ((UITabBarController*)([UIApplication sharedApplication].keyWindow.rootViewController)).selectedIndex =0;
                 }
                 [self.navigationController popToRootViewControllerAnimated:YES];
             });
         }];
     } errorHandler:^(NSDictionary *responseObject) {
         [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
     }
     failureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
         [SVProgressHUD showErrorWithStatus:@"网络繁忙"];
     }];
}
-(void)attentionRequest:(BBQAttentionBaby *)baby{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"baobaouid"] = baby.baobaouid;
    [BBQHTTPRequest
     queryWithType:BBQHTTPRequestTypeattentionbaobao
     param:params
     successHandler:^(AFHTTPRequestOperation *operation,
                      NSDictionary *responseObject, bool apiSuccess) {
         NSLog(@"%@",responseObject);
         [UIView animateWithDuration:0.5 animations:^{
             self.coverView.alpha = 0.0;
             self.hudLabel.text = @"已经申请关注,等待宝宝家长审核中";
             self.hudLabel.alpha = 1.0;
         } completion:^(BOOL finished) {
             [UIView animateWithDuration:5.0 animations:^{
                 self.hudLabel.alpha = 0.0;
             }];
         }];
     } errorHandler:^(NSDictionary *responseObject) {
         [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
     }
     failureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
         [SVProgressHUD showErrorWithStatus:@"网络繁忙"];
     }];

}
- (IBAction)hideCover {
    [UIView animateWithDuration:0.5 animations:^{
        self.coverView.alpha = 0.0;
    }];
}
@end
