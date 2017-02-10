//
//  BBQDiscoverTopicViewController.m
//  BBQ
//
//  Created by anymuse on 16/3/3.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQDiscoverTopicViewController.h"
#import "BBQTopicsModel.h"
#import "BBQDynamicViewModel.h"
#import "BBQDynamicTableViewController.h"
#import "BBQDiscoverCell.h"

@interface BBQDiscoverTopicViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, weak) UITableView *tableView;
@end

@implementation BBQDiscoverTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    tableView.tableFooterView =[UIView new];
    tableView.backgroundColor = UIColorHex(eeeeee);
    [self.view addSubview:tableView];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = 60;
    self.tableView =tableView;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.topics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BBQDiscoverCell *cell = [BBQDiscoverCell cellWithTableView:tableView];
    BBQTopicsModel *topic = self.topics[indexPath.row];
    cell.nameLabel.text = topic.name;
    cell.iconView.image = [UIImage imageNamed:self.imgStr];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BBQTopicsModel *topic = self.topics[indexPath.row];
    BBQDynamicViewModel *viewModel = [BBQDynamicViewModel viewModelForSquareWithTopic:topic];
    BBQDynamicTableViewController *vc = [[BBQDynamicTableViewController alloc] initWithViewModel:viewModel];
    viewModel.needHeader = NO;
    vc.navigationItem.title = topic.name;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
