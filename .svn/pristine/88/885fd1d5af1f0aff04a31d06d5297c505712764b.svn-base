//
//  BBQAttentionManagerViewController.m
//  BBQ
//
//  Created by anymuse on 16/3/11.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQAttentionManagerViewController.h"
#import "BBQAttentionBaby.h"
#import "BBQAttentionAgreeCell.h"

@interface BBQAttentionManagerViewController ()<UITableViewDataSource,UITableViewDelegate,BBQAttentionAgreeCellDelegate>
@property (nonatomic, strong) NSArray *attentions;
@property (nonatomic, weak) UITableView *tableView;
@end

@implementation BBQAttentionManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height -54);
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame];
    [self.view addSubview:tableView];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = 70;
    tableView.tableFooterView = [UIView new];
    self.tableView =tableView;
    self.title = @"谁申请关注我的宝宝";
    [self getattentionList];
}

-(void)getattentionList{
    [SVProgressHUD showWithStatus:@"请稍候..."];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"baobaouid"]= self.paramID;
    [BBQHTTPRequest
     queryWithType:BBQHTTPRequestTypeattentionList
     param:param
     successHandler:^(AFHTTPRequestOperation *operation,
                      NSDictionary *responseObject, bool apiSuccess) {
         NSLog(@"%@",responseObject);
         [SVProgressHUD dismiss];//962807
         self.attentions = [NSArray modelArrayWithClass:[BBQAttentionManageBaby class] json:responseObject[@"data"][@"arr"]];
         [self.tableView reloadData];
     } errorHandler:^(NSDictionary *responseObject) {
         [SVProgressHUD dismiss];
         NSLog(@"%@",responseObject);
     }
     failureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
         [SVProgressHUD showErrorWithStatus:@"网络繁忙"];
     }];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.attentions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BBQAttentionAgreeCell *cell =
    [BBQAttentionAgreeCell cellWithTableView:tableView];
    cell.delegate = self;
    cell.attention = self.attentions[indexPath.row];
    return cell;
}
-(void)attentionAgreeCell:(BBQAttentionAgreeCell *)cell DidClickButton:(BBQAttentionManageBaby *)attention status:(NSString *)status{
    [self manageAttentionRequest:attention status:status];
}

-(void)manageAttentionRequest:(BBQAttentionManageBaby *)attention status:(NSString *)status{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"id"]= attention.id;
    param[@"status"]= status;
    [BBQHTTPRequest
     queryWithType:BBQHTTPRequestTypeattentionManager
     param:param
     successHandler:^(AFHTTPRequestOperation *operation,
                      NSDictionary *responseObject, bool apiSuccess) {
         NSLog(@"%@",responseObject);
         [self getattentionList];
     } errorHandler:^(NSDictionary *responseObject) {
         [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
         NSLog(@"%@",responseObject);
     }
     failureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
         [SVProgressHUD showErrorWithStatus:@"网络繁忙"];
     }];
}
@end
