//
//  BBQDiscoverViewController.m
//  BBQ
//
//  Created by anymuse on 16/3/1.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQDiscoverViewController.h"
#import "BBQDiscoverTopicViewController.h"
#import "BBQTopicsModel.h"
#import "BBQAttentionViewController.h"
#import "BBQDynamicPageController.h"
#import "BBQDiscoverCell.h"
#import "jyexViewController.h"
#import "WebViewController.h"
#import "IMYThemeConfig.h"

@interface BBQDiscoverViewController ()<UITableViewDataSource,UITableViewDelegate, UITabBarControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *topics;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) BBQTopicsModel *yzTopic;

@end

@implementation BBQDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.delegate = self;
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self getTopicsList];
}
-(BBQTopicsModel *)yzTopic{
    if (!_yzTopic) {
        _yzTopic = [[BBQTopicsModel alloc] init];
        _yzTopic.name = @"育儿资讯";
    }
    return _yzTopic;
}
-(NSArray *)images{
    if (!_images) {
        _images = @[@"lg",@"lq",@"gt",@"hq",@"yz"];
    }
    return _images;
}
#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
#ifdef TARGET_PARENT
    if (tabBarController.selectedIndex == 0 || tabBarController.selectedIndex == 1) {
        if (!TheCurBaoBao) {
            [UIAlertView bk_showAlertViewWithTitle:@"提示" message:@"请先创建宝宝或者关注宝宝" cancelButtonTitle:@"取消" otherButtonTitles:[NSArray arrayWithObjects:@"去关注列表", nil] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil];
                    BBQAttentionViewController *vc = [sb instantiateViewControllerWithIdentifier:@"AttentionListBoard"];
                    vc.type = BBQAttentionViewTypeNormal;
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }];
            [tabBarController setSelectedIndex:2];
        } 
    }
#endif
}

/**
 获取话题圈列表
 */
-(void)getTopicsList{
    [BBQHTTPRequest
     queryWithType:BBQHTTPRequestTypeSquare
     param:@{@"fid":@0}
     successHandler:^(AFHTTPRequestOperation *operation,
                      NSDictionary *responseObject, bool apiSuccess) {
         self.topics = [NSMutableArray arrayWithArray:[NSArray modelArrayWithClass:[BBQTopicsModel class] json:responseObject[@"data"][@"arr"]]];
         [self.topics addObject:self.yzTopic];
         [self.tableView reloadData];
     } errorHandler:^(NSDictionary *responseObject) {
         [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
         
     }
     failureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
         [SVProgressHUD showErrorWithStatus:@"网络繁忙"];
     }];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.topics.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BBQDiscoverCell *cell = [BBQDiscoverCell cellWithTableView:tableView];
    BBQTopicsModel *topic = self.topics[indexPath.row];
    cell.nameLabel.text = topic.name;
    if (indexPath.row < self.images.count) {
        NSString *imgStr = self.images[indexPath.row];
        cell.iconView.image = [UIImage imageNamed:imgStr];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 4: {
            UIStoryboard *sb =
            [UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil];
            WebViewController *vc =
            [sb instantiateViewControllerWithIdentifier:@"WebViewController"];
            vc.url= URL_HOMEPAGE_YUER;
            [vc hidesBottomBarWhenPushed];
            [self.navigationController pushViewController:vc animated:YES];
        }break;
            
        default:{
            BBQDiscoverTopicViewController *topicVc= [[BBQDiscoverTopicViewController alloc]init];
            topicVc.hidesBottomBarWhenPushed = YES;
            BBQTopicsModel *topic = self.topics[indexPath.row];
            topicVc.title = topic.name;
            topicVc.topics = topic.childdata;
            if (indexPath.row < self.images.count) {
                NSString *imgStr = self.images[indexPath.row];
                topicVc.imgStr = imgStr;
            }
            [topicVc setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:topicVc animated:YES];
        }break;
    }
    
    
}

@end
