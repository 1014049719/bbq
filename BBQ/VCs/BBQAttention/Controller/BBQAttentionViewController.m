//
//  BBQAttentionViewController.m
//  BBQ
//  Created by wenjing on 15/11/19.
//  Copyright © 2015年 bbq. All rights reserved.

#import "BBQAttentionViewController.h"
#import "BBQAttentionCell.h"
#import "BBQAttentionClassCell.h"
#import "BBQClassDataModel.h"
#import "BBQAttentionClassWithBaby.h"
#import "BBQBabyDataCreateViewController.h"
#import "BBQSchoolDataModel.h"
#import "BBQInviteViewController.h"
#import "UIBarButtonItem+Extention.h"
#import "BBQLoginManager.h"
#import "AppDelegate.h"
#import "BBQCreateBBCell.h"
#import "MJRefresh.h"
#import "BBQNewLoginViewController.h"
#import "BBQAttentionBabyViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "BBQDynamicPageController.h"
#import "IMYThemeConfig.h"

@interface BBQAttentionViewController ()<UITableViewDataSource,UITableViewDelegate,BBQCreateBBCellDelegate,BBQAttentionCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *crebabies;
@property (nonatomic, strong) NSMutableArray *attbabies;
@property (nonatomic, strong) NSMutableArray *classinfos;
@property (nonatomic, strong) id deletemodel;
@property (nonatomic, assign) NSInteger deleteSection;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UILabel *deleteNameLabel;
@property (nonatomic, strong) NSNumber *curBabyID;
@property (weak, nonatomic) IBOutlet UILabel *deleteDescLabel;
@property (nonatomic, strong) BBQBabyModel *deletebaby;
@property (nonatomic, strong) BBQAttentionClassWithBaby *deleteClass;

@end

@implementation BBQAttentionViewController
- (NSMutableArray *)classinfos
{
    if (!_classinfos) {
        self.classinfos = [[NSMutableArray alloc] init];
    }
    return _classinfos;
}
- (NSMutableArray *)crebabies
{
    if (!_crebabies) {
        self.crebabies = [[NSMutableArray alloc] init];
    }
    return _crebabies;
}

- (NSMutableArray *)attbabies
{
    if (!_attbabies) {
        self.attbabies = [[NSMutableArray alloc] init];
    }
    return _attbabies;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _coverView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupData) name:@"baobaoDataChange" object:nil];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithtTarget:self anction:@selector(back) image:@"nav_back_arrow" title:nil];
    [self setupDownRefresh];
    [self setupData];
}

/**
 *  集成下拉刷新控件
 */
- (void)setupDownRefresh
{
    // 设置回调（一旦进入刷新状态，就调用target的action）
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getAttentionList)];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    header.autoChangeAlpha = YES;
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    // 设置header
    self.tableView.header = header;
}
-(void)back{
    
    if (self.type == BBQAttentionViewTypeNormal) {
        if (TheCurUser.baobaodata.count ==0 &&((UITabBarController*)([UIApplication sharedApplication].keyWindow.rootViewController)).selectedIndex ==0) {
            ((UITabBarController*)([UIApplication sharedApplication].keyWindow.rootViewController)).selectedIndex =2;
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[BBQNewLoginViewController class]]) {
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
    }
}
- (void)showAlertWithName:(NSString *)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil, nil];
    [alert show];
}
-(void)pushToInviteController{
    [self performSegueWithIdentifier:@"pushToAttentionBaby" sender:nil];
    
}
-(void)pushTobabyDataCreateVC{
    [self performSegueWithIdentifier:@"pushTobabyDataCreateVC" sender:nil];
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"pushToAttentionBaby"]) {
        BBQAttentionBabyViewController *Vc = segue.destinationViewController;
        Vc.crebabies = self.crebabies;
        Vc.datasource = @[@"输入邀请码关注",[NSString stringWithFormat:@"关注%@的同班宝宝",TheCurBaoBao.realname],@"输入家长手机号",@"谁申请关注我的宝宝"];
        Vc.imagesource = @[@"sr",@"gb",@"ss",@"sq"];
        NSMutableArray *arrM = [NSMutableArray array];
        [self.classinfos enumerateObjectsUsingBlock:^(BBQAttentionClassWithBaby*  _Nonnull baby, NSUInteger idx, BOOL * _Nonnull stop) {
            if (baby.babyModel.uid.intValue == TheCurBaoBao.uid.intValue) {
                [arrM addObject:baby];
            };
        }];
        Vc.classinfos = arrM;
        Vc.title = @"关注宝宝";
        Vc.type = BBQAttentionTypeBaby;
        
    }else if ([segue.identifier isEqualToString:@"pushTobabyDataCreateVC"]) {
        BBQBabyDataCreateViewController *createVc = segue.destinationViewController;
        createVc.type = (self.type ==BBQAttentionViewTypeLogin)?BBQBabyDataCreateTypeLogin:BBQBabyDataCreateTypeNormal;
    }else if ([segue.identifier isEqualToString:@"pushToJoinInClass"]){
        BBQAttentionBabyViewController *Vc = segue.destinationViewController;
        Vc.datasource = @[@"通过指定班级加入",@"通过老师手机加入",@"输入班级邀请码加入"/*,@"查找附近的幼儿园/培训"*/];
        Vc.imagesource = @[@"zd",@"sj",@"tb"/*,@"cz"*/];
        Vc.title = @"加入班级";
        Vc.curBabyID = self.curBabyID;
        Vc.type = BBQAttentionTypeClass;
    }
}
-(void)setupData{
    if (self.crebabies.count) {
        [self.crebabies removeAllObjects];
    }
    if (self.attbabies.count) {
        [self.attbabies removeAllObjects];
    }
    if (self.classinfos.count) {
        [self.classinfos removeAllObjects];
    }
    for (BBQBabyModel *baby in TheCurUser.baobaodata) {
        if (baby.qx.integerValue == BBQAuthorityTypeAdmin) {
            [self.crebabies addObject:baby];
        }else{
            [self.attbabies addObject:baby];
        }
        for (BBQSchoolDataModel *school in baby.baobaoschooldata) {
            for (BBQClassDataModel *class in school.classdata) {
                BBQAttentionClassWithBaby *model = [[BBQAttentionClassWithBaby alloc] init];
                model.showname = baby.realname;
                model.babyModel = baby;
                model.schoolname = school.schoolname;
                model.classmodel = class;
                model.schooltype = school.schooltype;
                model.schoolavartar = school.schoolavartar;
                model.qx = baby.qx;
                [self.classinfos addObject:model];
            }
        }
    }
    [self.tableView reloadData];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 1:
            return (self.crebabies.count) ? self.crebabies.count:1 ;
            break;
        case 2:
            return self.attbabies.count ?self.attbabies.count :1;
            break;
        case 3:
            return self.classinfos.count;
            break;
        default:
            return 1;
            break;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section?70:110;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section){
        case 1:
            return self.crebabies.count;
            break;
        case 2:
            return self.attbabies.count;
            break;
        case 3:
            return YES;
            break;
        default:
            return NO;
            break;
    }
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 1:
            return  self.crebabies? UITableViewCellEditingStyleDelete:UITableViewCellEditingStyleNone;
            break;
        case 2:
            return  self.attbabies? UITableViewCellEditingStyleDelete:UITableViewCellEditingStyleNone;
            break;
        case 3:
            return  self.classinfos? UITableViewCellEditingStyleDelete:UITableViewCellEditingStyleNone;
            break;
        default:
            return UITableViewCellEditingStyleNone;
            break;
    }
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.deleteSection = indexPath.section;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        switch (self.deleteSection) {
            case 1:{
                BBQBabyModel *model = [[BBQBabyModel alloc] init];
                model = self.crebabies[indexPath.row];
                self.deleteNameLabel.text = [NSString stringWithFormat:@"确定删除%@吗？",model.realname];
                self.deleteDescLabel.text = @"删除后,您将无法继续关注和为该宝宝发表动态";
                self.deletemodel = model;
            }break;
            case 2:{
                BBQBabyModel *model = [[BBQBabyModel alloc] init];
                model = self.attbabies[indexPath.row];
                self.deleteNameLabel.text = [NSString stringWithFormat:@"确定取消关注%@吗？",model.realname];
                self.deleteDescLabel.text = @"取消后,您将无法继续关注和为该宝宝发表动态";
                self.deletemodel = model;
            }break;
            case 3:{
                BBQAttentionClassWithBaby *model = [[BBQAttentionClassWithBaby alloc]init];
                model = self.classinfos[indexPath.row];
                if (model.qx.integerValue == BBQAuthorityTypeAdmin) {
                    self.deleteNameLabel.text = [NSString stringWithFormat:@"确定取消关注%@吗？",model.classmodel.classname];
                    self.deleteDescLabel.text = @"取消后,您将无法继续关注该班级的动态";
                    self.deletemodel = model;
                }else{
                    [self showAlertWithName:@"对不起,您不是该宝宝的圈主,无此权限!"];
                    return;
                }
            }break;
        }
        [UIView animateWithDuration:0.5 animations:^{
            self.coverView.alpha = 1.0;
        }];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger section = indexPath.section;
    if (section ==1) {
        BBQAttentionCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"babyAttentionCell"];
        if (self.crebabies.count) {
            cell.curBaobao = self.crebabies[indexPath.row];
            cell.nodataView.alpha = 0.0;
            cell.delegate = self;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else{
            cell.nodataView.alpha = 1.0;
            cell.nodataLabel.text = @"您还没创建自己的宝宝";
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    }else if(section == 2){
        BBQAttentionCell *cell =[tableView dequeueReusableCellWithIdentifier:@"babyAttentionCell"];
        if (self.attbabies.count) {
            cell.curBaobao = self.attbabies[indexPath.row];
            cell.nodataView.alpha = 0.0;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else{
            cell.nodataView.alpha = 1.0;
            cell.nodataLabel.text = @"您还没关注任何宝宝";
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    }else if(section == 3){
        BBQAttentionClassCell *cell =[tableView dequeueReusableCellWithIdentifier:@"babyAttentionClassCell"];
        cell.curBaobao = self.classinfos[indexPath.row];
        return cell;
    }else{
        BBQCreateBBCell *cell =[tableView dequeueReusableCellWithIdentifier:@"babyCreateCell"];
        cell.delegate = self;
        return cell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 1:{
            if (self.crebabies.count==0) return;
            TheCurBaoBao = self.crebabies[indexPath.row];
        }
            break;
        case 2:{
            if (self.attbabies.count==0) return;
            TheCurBaoBao = self.attbabies[indexPath.row];
        }break;
        case 3:{
            if (self.classinfos.count==0) return;
            BBQAttentionClassWithBaby *baby = self.classinfos[indexPath.row];
            for (BBQBabyModel *model in TheCurUser.baobaodata)
                if ([model.uid isEqualToNumber:baby.babyModel.uid]) {
                    TheCurBaoBao = model;
                    if (self.didSelectClassBlock) {
                        self.didSelectClassBlock(baby.classmodel.classname);
                    }
                    break;
                }
        }break;
        default:
            return;
            break;
    }
    if (self.type == BBQAttentionViewTypeNormal) {
        if (((UITabBarController*)([UIApplication sharedApplication].keyWindow.rootViewController)).selectedIndex !=0) {
            ((UITabBarController*)([UIApplication sharedApplication].keyWindow.rootViewController)).selectedIndex =0;
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [((AppDelegate *)[UIApplication sharedApplication].delegate)
         setupTabBarController];
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section ==0) {
        return 0;
    }else
        return 50;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
        headerView.backgroundColor = UIColorHex(F5F5F5);;
        UILabel *label = [[UILabel alloc] init];
        [headerView addSubview:label];
        NSString *imageName = nil;
        switch (section) {
            case 1:
                label.text = @"已创建的宝宝";
                imageName =@"create";
                break;
            case 2:
                label.text = @"已关注的宝宝";
                imageName =@"attentionBB";
                break;
            case 3:
                label.text = @"已加入的班级";
                imageName =@"joinin";
                break;
            default:
                break;
        }
        UIImage *image = [UIImage imageNamed:imageName];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(15, 15, imageView.size.width, imageView.size.height);
        label.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + 15, 15, 150, 20);
        [headerView addSubview:imageView];
        return headerView;
    }else{
        return nil;
    }
}
-(void)attentionCell:(BBQAttentionCell *)cell DidClickButtonWithBaby:(BBQBabyModel *)baby{
    self.curBabyID = baby.uid;
    [self performSegueWithIdentifier:@"pushToJoinInClass" sender:nil];
}

- (IBAction)sureClick {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    BBQHTTPRequestType requestType;
    switch (self.deleteSection) {
        case 1:
            requestType= BBQHTTPRequestTypedeletebaobao;
            _deletebaby = self.deletemodel;
            params[@"baobaouid"] =_deletebaby.uid;
            break;
        case 2:
            requestType= BBQHTTPRequestTypeCancelBaobao;
            _deletebaby = self.deletemodel;
            params[@"baobaouid"] =_deletebaby.uid;
            break;
        default:
            requestType= BBQHTTPRequestTypecancelattentionclass;
            _deleteClass = self.deletemodel;
            params[@"baobaouid"] =_deleteClass.babyModel.uid;
            params[@"classuid"] =_deleteClass.classmodel.classid;
            break;
    }
    [SVProgressHUD showWithStatus:@"请稍候"];
    [BBQHTTPRequest
     queryWithType:requestType
     param:params
     successHandler:^(AFHTTPRequestOperation *operation,
                      NSDictionary *responseObject, bool apiSuccess) {
         dispatch_async(dispatch_get_main_queue(), ^(){
             [SVProgressHUD dismiss];
             [self.tableView.header beginRefreshing];
         });
     }  errorHandler:^(NSDictionary *responseObject) {
         [SVProgressHUD dismiss];
     }
     failureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
         [SVProgressHUD dismiss];
     }];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.coverView.alpha = 0.0;
    }];
}
- (IBAction)cancelClick {
    [UIView animateWithDuration:0.5 animations:^{
        self.coverView.alpha = 0.0;
    }];
}


-(void)getAttentionList{
    NSArray *arrTemp = [NSArray arrayWithArray:TheCurUser.baobaodata];
    [BBQHTTPRequest
     queryWithType:BBQHTTPRequestTypeGetAttentionList
     param:nil
     successHandler:^(AFHTTPRequestOperation *operation,
                      NSDictionary *responseObject, bool apiSuccess) {
         TheCurUser.baobaodata = [NSArray modelArrayWithClass:[BBQBabyModel class] json:responseObject[@"data"][@"attbaby"]] ;
         if (_deletebaby == TheCurBaoBao) {
             TheCurBaoBao = [TheCurUser.baobaodata firstObject];
             _deletebaby = nil;
         }else if (_deleteClass.babyModel == TheCurBaoBao){
             TheCurBaoBao = _deleteClass.babyModel;
             _deleteClass=nil;
         }
         [self setupData];
         [self.tableView.header endRefreshing];
         if (arrTemp.count ==0 && TheCurUser.baobaodata.count !=0) {
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
         }
     }  errorHandler:^(NSDictionary *responseObject) {
         [self.tableView.header endRefreshing];
     }
     failureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
         [self.tableView.header endRefreshing];
     }];
    
}
-(void)createBBCell:(BBQCreateBBCell *)cell DidClickViewWithTag:(NSInteger)tag{
    if (tag ==100) {
        [self pushTobabyDataCreateVC];
    }else{
        [self pushToInviteController];
    }
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *str;
    switch (indexPath.section) {
        case 1:
            str = @"删除";
            break;
        case 2:
            str = @"取消关注";
            break;
        case 3:
            str = @"取消加入";
            break;
        default:
            break;
    }
    return str;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.tableView.isEditing) {
        [self.tableView setEditing:NO];
    }
    
}
//关闭滑动返回手势
- (BOOL)fd_interactivePopDisabled {
    return (TheCurUser.baobaodata.count&&TheCurBaoBao)?NO:YES;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
