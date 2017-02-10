//
//  BBQNewCardViewController.m
//  BBQ
//
//  Created by wth on 15/12/10.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import "BBQNewCardViewController.h"
#import "CardWebViewController.h"
#import <Masonry.h>
#import "SDCycleScrollView.h"
#import "WebViewController.h"
#import "MessageViewController.h"


@interface BBQNewCardViewController ()<SDCycleScrollViewDelegate>

//轮播广告
@property(strong,nonatomic)SDCycleScrollView *cycleScrollView;
//成长书网页
@property(strong,nonatomic)CardWebViewController *cardWebVcl;
//轮播广告图片数组
@property(strong,nonatomic)NSMutableArray *imagesUrlMutableArr;
//跳转页面地址
@property(strong,nonatomic)NSMutableArray *TiaozhuanUrlMutableArr;
//oMode参数
@property(strong,nonatomic)NSMutableArray *oModeMutableArr;
//滚动时间
@property(assign,nonatomic)int showTime;

@property (strong, nonatomic) id model;         // 请求成长书的对象

@end

@implementation BBQNewCardViewController

- (instancetype)initWithModel:(id)model {
    if (self = [super init]) {
        _model = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hidesBottomBarWhenPushed = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:245/255.0 blue:246/255.0 alpha:1];
    _imagesUrlMutableArr = [NSMutableArray array];
    _TiaozhuanUrlMutableArr = [NSMutableArray array];
    _oModeMutableArr = [NSMutableArray array];
    
    //请求广告
    [self RequestAdvertisement];
    
    //下方成长书网页
    self.cardWebVcl = [[CardWebViewController alloc] init];
    self.cardWebVcl.model = _model;
    [self addChildViewController:_cardWebVcl];
    [self.view addSubview:_cardWebVcl.view];
    [self.cardWebVcl.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
        make.top.mas_equalTo(80);
        make.width.equalTo(self.view);
    }];
}

-(void)RequestAdvertisement{
//#ifdef TARGET_PARENT
    NSDictionary *ParamDic;
    if ([_model isKindOfClass:[BBQBabyModel class]]) {
        ParamDic=@{@"advPosition":@"0",@"params":@{@"baobaouid":((BBQBabyModel *)_model).uid}};
    } else if ([_model isKindOfClass:[BBQClassDataModel class]]) {
        ParamDic=@{@"advPosition":@"0",@"params":@{@"classid":((BBQClassDataModel *)_model).classid}};
    } else if ([_model isKindOfClass:[BBQSchoolDataModel class]]){
        ParamDic=@{@"advPosition":@"0",@"params":@{@"schoolid":((BBQSchoolDataModel *)_model).schoolid}};
    }
//#elif TARGET_TEACHER
//    NSDictionary *ParamDic=@{@"advPosition":@"0",@"params":@{@"classid":TheCurUser.curClass.classid,@"schoolid":TheCurUser.curSchool.schoolid}};
//#elif TARGET_MASTER
//    NSDictionary *ParamDic=@{@"advPosition":@"0",@"params":@{@"schoolid":TheCurUser.curSchool.schoolid}};
//#endif
    
    [BBQHTTPRequest queryWithType:BBQHTTPRequestTypeAdvertisementCZS param:ParamDic successHandler:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject, bool apiSuccess) {
        
        NSLog(@"轮播广告数据：%@",responseObject);
        NSArray *arr=responseObject[@"data"][@"adarr"];
        if (arr.count>0) {
            for (NSDictionary *dic in arr) {
                [_imagesUrlMutableArr addObject:dic[@"advPic"]];
                [_TiaozhuanUrlMutableArr addObject:dic[@"advUrl"]];
                [_oModeMutableArr addObject:dic[@"oMode"]];
            }
            //滚动时间
            self.showTime=[arr[0][@"showTime"] floatValue];
            //创建轮播广告
            [self CreatCycleScrollView];
        }else{
            
            [self.cardWebVcl.view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
            }];
        }
        
    } errorHandler:^(NSDictionary *responseObject) {
        NSLog(@"成长书广告错误 %@",responseObject);
        
    } failureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"成长书广告失败 %@",error);
    }];
    
}

-(void)CreatCycleScrollView{

    //网络加载 --- 创建带标题的图片轮播器
    _cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0,0, self.view.bounds.size.width, 80) imageURLStringsGroup:nil]; // 模拟网络延时情景
    _cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    _cycleScrollView.delegate = self;
    _cycleScrollView.autoScrollTimeInterval=self.showTime;
//    _cycleScrollView.titlesGroup = titles;
    _cycleScrollView.dotColor = [UIColor yellowColor]; // 自定义分页控件小圆标颜色
    _cycleScrollView.placeholderImage = [UIImage imageNamed:@"guanggao_placeholder"];
    [self.view addSubview:_cycleScrollView];
    
    //    模拟加载延迟
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _cycleScrollView.imageURLStringsGroup = _imagesUrlMutableArr;
    });
    
    //关闭广告按钮
    UIButton *closeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"close-yuan"] forState:UIControlStateNormal];
    closeBtn.alpha=0.7;
    closeBtn.imageEdgeInsets=UIEdgeInsetsMake(8, 0, 0, 8);
    [closeBtn addTarget:self action:@selector(dealCloseBtn) forControlEvents:UIControlEventTouchUpInside];
    [_cycleScrollView addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(25);
        make.height.mas_equalTo(25);
        make.top.equalTo(_cycleScrollView);
        make.right.equalTo(_cycleScrollView);
    }];
    

}
//关闭广告
-(void)dealCloseBtn{

    _cycleScrollView.alpha=0;
    [UIView animateWithDuration:0.2 animations:^{
        [self.cardWebVcl.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
        }];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"---点击了第%ld张图片", (long)index);
    //消息通用处理
    //通用处理接口（和消息一样处理）
//    NSLog(@"通用处理。。%@",notification.userInfo[@"para"]);
    
    UITabBarController *rootController = (UITabBarController *)kKeyWindow.rootViewController;
    [(UINavigationController *)rootController.selectedViewController
     popToRootViewControllerAnimated:NO];

    [MessageViewController
     MessageAction:[[self.oModeMutableArr objectAtIndex:index] intValue]
     url:[self.TiaozhuanUrlMutableArr objectAtIndex:index]
     viewcontroller:rootController.selectedViewController];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
