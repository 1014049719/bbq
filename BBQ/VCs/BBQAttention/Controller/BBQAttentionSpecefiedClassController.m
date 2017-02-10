//
//  BBQAttentionSpecefiedClassController.m
//  BBQ
//
//  Created by anymuse on 16/3/11.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQAttentionSpecefiedClassController.h"
#import "BBQSetClassViewController.h"
#import "BBQSetSchoolViewController.h"
#import "BBQSetPlaceViewController.h"

@interface BBQAttentionSpecefiedClassController ()
@property (weak, nonatomic) IBOutlet UIButton *addressBtn;
@property (weak, nonatomic) IBOutlet UIButton *classBtn;
@property (weak, nonatomic) IBOutlet UIButton *schoolBtn;
@property (nonatomic, strong) BBQPlaceParam *placeParam;
@property (weak, nonatomic) IBOutlet UILabel *hudLabel;
@end

@implementation BBQAttentionSpecefiedClassController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)schoolBtnClick {
    if (self.addressBtn.titleLabel.text.length ==0|| [self.addressBtn.titleLabel.text hasPrefix:@"请选择"]) {
        [SVProgressHUD showErrorWithStatus:@"请先选择地区!"];
        [self performSelector:@selector(dismiss:) withObject:nil afterDelay:1];
        return;
    }
    BBQSetSchoolViewController *SchoolVC= [[BBQSetSchoolViewController alloc] init];
    SchoolVC.title = @"填写学校名称";
    SchoolVC.placeParam = self.placeParam;
    WS(weakSelf);
    [SchoolVC returnText:^(BBQSchoolDataModel *model) {
        if(model){
            weakSelf.selectedSchool = model;
            if (self.selectedClass) {
                self.selectedClass = nil;
            }
        }
    }];
    [self.navigationController pushViewController:SchoolVC animated:NO];
}
- (IBAction)addressBtnClick {
    BBQSetPlaceViewController *PlaceVC= [[BBQSetPlaceViewController alloc] init];
    PlaceVC.title = @"选择地区";
    WS(weakSelf);
    [PlaceVC returnText:^(NSString *showText,BBQPlaceParam *placeParam) {
        if(showText.length > 0){
            [weakSelf.addressBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [weakSelf.addressBtn setTitle:showText
                                  forState:UIControlStateNormal];
            weakSelf.placeParam = placeParam;
            if (self.selectedSchool) {
                self.selectedSchool = nil;
            }
            if (self.selectedClass) {
                self.selectedClass = nil;
            }
        }
    }];
    [self.navigationController pushViewController:PlaceVC animated:NO];
}
- (IBAction)classBtnClick:(id)sender {
    if (self.schoolBtn.titleLabel.text.length ==0|| [self.schoolBtn.titleLabel.text hasPrefix:@"请填写"]) {
        [SVProgressHUD showErrorWithStatus:@"请先填写学校!"];
        [self performSelector:@selector(dismiss:) withObject:nil afterDelay:1];
        return;
    }
    BBQSetClassViewController *ClassVC= [[BBQSetClassViewController alloc] init];
    ClassVC.title = @"填写班级名称";
    ClassVC.selectedSchool = self.selectedSchool;
    WS(weakSelf);
    [ClassVC returnText:^(BBQClassDataModel *model) {
        if(model){
            weakSelf.selectedClass = model;
        }
    }];
    [self.navigationController pushViewController:ClassVC animated:NO];
}
- (void)dismiss:(id)sender {
    [SVProgressHUD dismiss];
}
-(void)setSelectedClass:(BBQClassDataModel *)selectedClass{
    _selectedClass = selectedClass;
    [self.classBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.classBtn setTitle:selectedClass.classname
                      forState:UIControlStateNormal];
}
-(void)setSelectedSchool:(BBQSchoolDataModel *)selectedSchool{
    _selectedSchool = selectedSchool;
    [self.schoolBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.schoolBtn setTitle:selectedSchool.schoolname
                       forState:UIControlStateNormal];
    
}
- (IBAction)nextBtnClick:(id)sender {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"baobaouid"] = self.curBabyID;
    params[@"classuid"]=self.selectedClass.classid;
    [BBQHTTPRequest
     queryWithType:BBQHTTPRequestTypeIntoClass
     param:params
     successHandler:^(AFHTTPRequestOperation *operation,
                      NSDictionary *responseObject, bool apiSuccess) {
         [UIView animateWithDuration:0.5 animations:^{
             self.hudLabel.text = @"已经向老师发出申请,等待老师审核中";
             self.hudLabel.alpha = 1.0;
         }completion:^(BOOL finished){
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 self.hudLabel.alpha = 0.0;
             });
         }];
     } errorHandler:^(NSDictionary *responseObject) {
         [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
     }
     failureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
         [SVProgressHUD showErrorWithStatus:@"网络繁忙"];
     }];
}
@end
