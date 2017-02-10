//
//  BBQAttentionBabyViewController.m
//  BBQ
//
//  Created by anymuse on 16/3/2.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQAttentionBabyViewController.h"
#import "BBQInviteViewController.h"
#import "BBQAttentionTypeCell.h"
#import "BBQAttentionClassBaoBaoViewController.h"
#import "BBQAttentionClassWithBaby.h"
#import "BBQAttentionManagerViewController.h"
#import "BBQAttentionSpecefiedClassController.h"
#import "SSSearchBar.h"
#import "BBQSearchClassModel.h"
#import "BBQSearchShoolModel.h"
@interface BBQAttentionBabyViewController ()<SSSearchBarDelegate>

@property (weak, nonatomic)  SSSearchBar *searchBar;
@property (weak, nonatomic)  UIView *coverView;
@property (weak, nonatomic)  UITableView *choiceTableView;
@property (weak, nonatomic)  UILabel *descLabel;
@property (nonatomic) NSArray *searchData;
@end

@implementation BBQAttentionBabyViewController
-(UIView *)coverView{
    if (_coverView==nil) {
       UIView *coverView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        coverView.backgroundColor= [UIColor colorWithWhite:0.0 alpha:0.5];
        [self.view addSubview:coverView];
        UIView *descView = [[UIView alloc] init];
        descView.backgroundColor = [UIColor whiteColor];
        [coverView addSubview:descView];
        CGFloat tableViewH;
        if (self.type == BBQAttentionTypeBaby){
            descView.frame = CGRectMake(20, 100, [[UIScreen mainScreen] bounds].size.width - 40, 30);
            tableViewH= self.classinfos.count>5?220:self.classinfos.count*44;
        }else{
            tableViewH = self.searchData.count>5?220:self.searchData.count*44;
            descView.frame = CGRectMake(20, 64, [[UIScreen mainScreen] bounds].size.width - 40, 30);
        }
        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, descView.bounds.size.width, 21)];
        [descView addSubview:descLabel];
        descLabel.font = [UIFont systemFontOfSize:15];
        descLabel.textColor = [UIColor darkGrayColor];
        self.descLabel = descLabel;
        self.descLabel.text = @"请选择想要关注宝宝所在班级";
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(descView.bounds.size.width - 40, 0, 30, 30)];
        [btn setBackgroundImage:[UIImage imageNamed:@"close-yuan"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(hideCover) forControlEvents:UIControlEventTouchUpInside];
        [descView addSubview:btn];
        UITableView *choiceTableView = [[UITableView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(descView.frame)+1, descView.bounds.size.width, tableViewH)];
        choiceTableView.dataSource = self;
        choiceTableView.delegate = self;
        choiceTableView.tableHeaderView = [UIView new];
        [coverView addSubview:choiceTableView];
        self.choiceTableView = choiceTableView;
//        [coverView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideCover) ] ];
        _coverView = coverView;
    }
    return _coverView;
}

-(void)hideCover{
    self.coverView.alpha = 0.0;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupHeaderView];
    //去掉多余分割线
    self.tableView.scrollEnabled = NO;
    self.tableView.tableFooterView = [UIView new];
}

- (void)searchBarSearchButtonClicked:(SSSearchBar *)searchBar {
    [self filterTableViewWithText:searchBar.text];
}
//- (void)searchBar:(SSSearchBar *)searchBar textDidChange:(NSString *)searchText {
//    [self filterTableViewWithText:searchText];
//}
-(void)setupHeaderView{
    if (self.type == BBQAttentionTypeBaby) {
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 20)];
    }else{
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 74)];
        header.backgroundColor = [UIColor whiteColor];
        SSSearchBar *searchBar = [[SSSearchBar alloc]initWithFrame:CGRectMake(40, 10, self.view.width-80, 44)];
        searchBar.delegate = self;
        searchBar.placeholder = @"输入幼儿园名称";
        [header addSubview:searchBar];
        self.searchBar = searchBar;
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, 10)];
        backView.backgroundColor = UIColorHex(F5F5F5);
        [header addSubview:backView];
        self.tableView.tableHeaderView = header;
    }
    
}

- (void)filterTableViewWithText:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        return;
    }
    else {
        [BBQHTTPRequest
         queryWithType:BBQHTTPRequestTypeSearchInput
         param:@{@"inputname":searchText}
         successHandler:^(AFHTTPRequestOperation *operation,
                          NSDictionary *responseObject, bool apiSuccess) {
             [SVProgressHUD dismiss];
             NSLog(@"%@",responseObject);
             self.searchData = [NSArray modelArrayWithClass:[BBQSearchShoolModel class] json:responseObject[@"data"][@"arr"]];
             if (self.searchData.count>0) {
                 if (self.coverView.alpha ==0.0) {
                     self.coverView.alpha =1.0;
                 }
                 [self.choiceTableView reloadData];
             }
         }  errorHandler:^(NSDictionary *responseObject) {
             [SVProgressHUD dismiss];
         }
         failureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
             [SVProgressHUD dismiss];
         }];
    }
    
    [self.tableView reloadData];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return self.datasource.count;
    }else {
        if (self.type == BBQAttentionTypeBaby)
            return self.classinfos.count;
       else
           return self.searchData.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.tableView){
        BBQAttentionTypeCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"attentionTypeCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.describeLabel.text = self.datasource[indexPath.row];
        cell.iconImage.image = [UIImage imageNamed:self.imagesource[indexPath.row]];
        return cell;
    }else{
        static NSString *cellID = @"classCell";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (self.type == BBQAttentionTypeBaby){
          BBQAttentionClassWithBaby *classinfo = self.classinfos[indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@%@",classinfo.schoolname,classinfo.classmodel.classname];
        }else{
            if ([[self.searchData lastObject] isKindOfClass:[BBQSearchShoolModel class]]) {
                BBQSearchShoolModel *shoolModel = self.searchData[indexPath.row];
                cell.textLabel.text = shoolModel.schoolrealname;
            }else{
                BBQSearchClassModel *classModel = self.searchData[indexPath.row];
                cell.textLabel.text = classModel.classrealname;
            }
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        if (self.type == BBQAttentionTypeClass) {
            [self jumpForJoinClass:indexPath.row];
        }else{
            [self jumpForAttentionBaoBao:indexPath.row];
        }
    }else{
        if (self.type == BBQAttentionTypeClass){
            if ([[self.searchData lastObject] isKindOfClass:[BBQSearchShoolModel class]]) {
                BBQSearchShoolModel *schoolModel = self.searchData[indexPath.row];
                self.searchData = schoolModel.myclassarr;
                self.descLabel.text = schoolModel.schoolrealname;
                CGRect frame = self.choiceTableView.frame;
                frame.size.height = self.searchData.count>5?220:self.searchData.count*44;
                self.choiceTableView.frame = frame;
                [self.choiceTableView reloadData];
            }else{
                [self hideCover];
                BBQSearchClassModel *classModel = self.searchData[indexPath.row];
                [self joinSpecefiedClass:classModel];
            }
            
        }else{
        BBQAttentionClassWithBaby *classinfo = self.classinfos[indexPath.row];
        [self jumpToAttentionClassBaby:classinfo];
        }
        
    }
    
}
-(void)joinSpecefiedClass:(BBQSearchClassModel*)classModel{
    [SVProgressHUD showWithStatus:@"请稍候"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"baobaouid"] = self.curBabyID;
    params[@"classuid"]=classModel.classid;
    [BBQHTTPRequest
     queryWithType:BBQHTTPRequestTypeIntoClass
     param:params
     successHandler:^(AFHTTPRequestOperation *operation,
                      NSDictionary *responseObject, bool apiSuccess) {
         [UIView animateWithDuration:0.5 animations:^{
             [SVProgressHUD showWithStatus:@"已经向老师发出申请,等待老师审核中"];
         }completion:^(BOOL finished){
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [SVProgressHUD dismiss];
             });
         }];
     } errorHandler:^(NSDictionary *responseObject) {
         [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
     }
     failureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
         [SVProgressHUD showErrorWithStatus:@"网络繁忙"];
     }];
}
-(void)jumpToAttentionClassBaby:(BBQAttentionClassWithBaby*)classinfo{
    BBQAttentionClassBaoBaoViewController *vc = [[BBQAttentionClassBaoBaoViewController alloc]init];
    vc.paramID = classinfo.classmodel.classid;
    vc.title = classinfo.classmodel.classname;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)jumpForJoinClass:(NSInteger)row{
    switch (row) {
        case 0:{
            BBQAttentionSpecefiedClassController *vc = [[BBQAttentionSpecefiedClassController alloc] init];
            vc.title = @"指定班级加入";
            vc.curBabyID = self.curBabyID;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:{
            BBQInviteViewController *vc = [[UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil]
                                           instantiateViewControllerWithIdentifier:@"InviteCode"];
            vc.type = BBQInviteViewTypeTeacherPhone;
            vc.title = @"输入手机号码";
            vc.curBabyID = self.curBabyID;
            [self.navigationController pushViewController:vc animated:YES];}
            break;
        case 2:{
            BBQInviteViewController *inviteVc = [[UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil]
                                                 instantiateViewControllerWithIdentifier:@"InviteCode"];
            inviteVc.type = BBQInviteViewTypeClassYQM;
            inviteVc.title = @"输入邀请码";
            inviteVc.curBabyID = self.curBabyID;
            [self.navigationController pushViewController:inviteVc animated:YES];
        }
            break;
        case 3:
            break;
    }
    
}
-(void)jumpForAttentionBaoBao:(NSInteger)row{
    switch (row) {
        case 0:{
            BBQInviteViewController *inviteVc = [[UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil]
                                                 instantiateViewControllerWithIdentifier:@"InviteCode"];
            inviteVc.type = BBQInviteViewTypeBabyYQM;
            inviteVc.title = @"输入邀请码";
            [self.navigationController pushViewController:inviteVc animated:YES];
        }
            break;
        case 1:
            if (self.classinfos.count){
                if (self.classinfos.count ==1)
                    [self jumpToAttentionClassBaby:[self.classinfos lastObject]];
                else
                    self.coverView.alpha = 1.0;
            }else
                [SVProgressHUD showErrorWithStatus:@"还没加入任何班级!"];
            
            break;
        case 2:{
            BBQInviteViewController *vc = [[UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil]
                                           instantiateViewControllerWithIdentifier:@"InviteCode"];
            vc.type = BBQInviteViewTypeParentsPhone;
            vc.title = @"输入手机号码";
            [self.navigationController pushViewController:vc animated:YES];
            
        }
            break;
        case 3:{
            BBQAttentionManagerViewController *vc = [[BBQAttentionManagerViewController alloc]init];
            vc.paramID= self.curBabyID;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
    }
}
@end
