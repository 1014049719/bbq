//
//  BBQAttentionClassBaoBaoViewController.m
//  BBQ
//
//  Created by anymuse on 16/3/3.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQAttentionClassBaoBaoViewController.h"
#import "BBQAttentionBaby.h"
#import "BBQAttentionMangerCell.h"

@interface BBQAttentionClassBaoBaoViewController ()<UITableViewDataSource,UITableViewDelegate,BBQAttentionMangerCellDelegate>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *babys;
@property (nonatomic, weak) UILabel *hudLabel;

@end

@implementation BBQAttentionClassBaoBaoViewController

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
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 150, [[UIScreen mainScreen] bounds].size.width, 50)];
    [self.view addSubview:label];
    self.hudLabel = label;
    
    self.hudLabel.alpha = 0.0;
    self.hudLabel.textColor = [UIColor darkGrayColor];
    self.hudLabel.textAlignment = NSTextAlignmentCenter;
    [self getClassBaoBao];
    
}

-(void)getClassBaoBao{
    [SVProgressHUD showWithStatus:@"请稍候..."];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"classid"]= self.paramID;
    [BBQHTTPRequest
     queryWithType:BBQHTTPRequestTypeclassbaobao
     param:param
     successHandler:^(AFHTTPRequestOperation *operation,
                      NSDictionary *responseObject, bool apiSuccess) {
         [SVProgressHUD dismiss];
         self.babys = [NSArray modelArrayWithClass:[BBQAttentionBaby class] json:responseObject[@"data"][@"arr"]];
         [self.tableView reloadData];
         
     } errorHandler:^(NSDictionary *responseObject) {
         [SVProgressHUD dismiss];
     }
     failureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
         [SVProgressHUD showErrorWithStatus:@"网络繁忙"];
     }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.babys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BBQAttentionMangerCell *cell =
    [BBQAttentionMangerCell cellWithTableView:tableView];
    cell.delegate = self;
    cell.baby = self.babys[indexPath.row];
    return cell;
}
//BBQHTTPRequestTypecancelattentionbaobao
-(void)attentionManagerCell:(BBQAttentionMangerCell *)cell DidClickButton:(BBQAttentionBaby *)baby status:(NSInteger)status{
    [BBQHTTPRequest
     queryWithType:status?BBQHTTPRequestTypecancelattentionbaobao: BBQHTTPRequestTypeattentionbaobao
     param:@{@"baobaouid":baby.baobaouid}
     successHandler:^(AFHTTPRequestOperation *operation,
                      NSDictionary *responseObject, bool apiSuccess) {
         [UIView animateWithDuration:0.5 animations:^{
             self.hudLabel.text = status?@"已经取消关注":@"已经申请关注,等待宝宝家长审核中";
             self.hudLabel.alpha = 1.0;
         } completion:^(BOOL finished) {
             [UIView animateWithDuration:5.0 animations:^{
                 self.hudLabel.alpha = 0.0;
                 if (status) {
                     [self getClassBaoBao];
                 }
             }];
         }];
     } errorHandler:^(NSDictionary *responseObject) {
         [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
     }
     failureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
         [SVProgressHUD showErrorWithStatus:@"网络繁忙"];
     }];
    
}
@end
