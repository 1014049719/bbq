//
//  BBQVisitsViewController.m
//  BBQ
//
//  Created by slovelys on 16/3/11.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQVisitsViewController.h"
#import "BBQVisitsCell.h"
#import "BBQVistisApi.h"
#import "BBQVisitsModel.h"
#import <DateTools.h>

@interface BBQVisitsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) Dynamic *dynamic;

@property (nonatomic, assign) NSInteger visitNum;

@property (weak, nonatomic) IBOutlet UILabel *visitPerson;

@end

@implementation BBQVisitsViewController

- (instancetype)initWithDynamic:(Dynamic *)dynamic {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Family" bundle:nil];
    self = [sb instantiateViewControllerWithIdentifier:@"VisitsVC"];
    self.hidesBottomBarWhenPushed = YES;
    _dynamic = dynamic;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"浏览列表";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _tableView.tableFooterView = [UIView new];
    _dataSource = [NSMutableArray arrayWithCapacity:0];
    [self downloadVisits];
}

- (void)updateVisitPersonLabel {
    _visitPerson.text = [NSString stringWithFormat:@"已浏览 (%ld人)", _visitNum];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BBQVisitsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"visitsCell" forIndexPath:indexPath];
    BBQVisitsModel *model = _dataSource[indexPath.row];
    [cell.headImgView setImageWithURL:[NSURL URLWithString:model.avatar] placeholder:Placeholder_avatar];
    cell.nameLabel.text = model.nickname;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[model.dateline doubleValue]];
    cell.timeLabel.text = [date formattedDateWithFormat:@"yyyy-MM-dd HH:SS"];
    return cell;
}

#pragma mark - net
- (void)downloadVisits {
    [SVProgressHUD showWithStatus:@"请稍后"];
    BBQVistisApi *api = [[BBQVistisApi alloc] initWithDynamic:_dynamic];
    [api startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest *request) {
        NSDictionary *dataDic = request.responseJSONObject[@"data"];
        if (![[NSString stringWithFormat:@"%@", dataDic[@"num"]] isEqualToString:@"<null>"]) {
            [SVProgressHUD dismiss];
            _visitNum = [dataDic[@"browsers"] count];
            for (NSDictionary *dic in dataDic[@"browsers"]) {
                BBQVisitsModel *model = [BBQVisitsModel modelWithDictionary:dic];
                [_dataSource addObject:model];
            }
            dispatch_async_on_main_queue(^{
                [self updateVisitPersonLabel];
                [_tableView reloadData];
            });
        } else {
            [SVProgressHUD showErrorWithStatus:@"没有浏览记录"];
        }
    } failure:^(__kindof YTKBaseRequest *request) {
        ShowApiError
    }];
}

@end
