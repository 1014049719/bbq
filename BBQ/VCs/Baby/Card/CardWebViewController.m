//
//  CardWebViewController.m
//  BBQ
//
//  Created by wth on 15/10/13.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import "CardWebViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "TestJSObject.h"
#import "CardPageViewController.h"
#import "NoPhotoRemindViewController.h"
#import "BuyCardView.h"
#import "OrderDetailViewController.h"
#import "WebViewController.h"
#import "CardPopTableViewController.h"
#import <Masonry.h>
#import "CardPreviewController.h"
//#import "SBJson.h"
#import "ODRefreshControl.h"
#import <CNPPopupController.h>

@interface CardWebViewController () <UIWebViewDelegate>

//网页
@property(strong, nonatomic) UIWebView *CardWebView;

@property(strong, nonatomic) CardPageViewController *CardPageVcl;

//购买浮窗
@property(strong, nonatomic) BuyCardView *buyCardView;
//成长书类型
@property(strong, nonatomic) NSString *bookcode;

@property(nonatomic, strong) NSString *orderid; //购买相关数据
@property(nonatomic, strong) NSDictionary *charge;
@property(nonatomic, strong) NSNumber *ordertime;
@property(nonatomic, strong) NSNumber *orderprice;
@property(nonatomic, strong) NSString *bookNumStr;
@property (nonatomic, assign) int dynamictype;
@property (nonatomic, assign) int classid;
@property (nonatomic, assign) int schoolid;
//成长书介绍浮层
@property(nonatomic, strong) CardPopTableViewController *CardPopTbvcl;
//半透明背景
@property(nonatomic, strong) UIView *alphaView;
//浮层数据源数组
@property(nonatomic, strong) NSArray *popViewDataArr;

//下拉刷新
@property (strong, nonatomic) ODRefreshControl *refresh;

@end

@implementation CardWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //本地网页
    //    NSString *htmlPath=[[NSBundle mainBundle] pathForResource:@"222"
    //    ofType:@"html"];
    //    [self.CardWebView loadRequest:[NSURLRequest requestWithURL:[NSURL
    //    fileURLWithPath:htmlPath]]];
    
    self.CardWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.CardWebView.backgroundColor=[UIColor colorWithRed:244/255.0 green:245/255.0 blue:246/255.0 alpha:1];
    self.CardWebView.delegate = self;
    self.view=self.CardWebView;
    
    //切换宝宝刷新数据
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(uploadWeb)
     name:kSetNeedsRefreshEntireDataNotification
     object:nil];
    
    //购买成功刷新数据
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(uploadWeb)
     name:NOTIFICATION_Update_BuyResult
     object:nil];
    
    //接收JS调用通知跳转
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(CZS_Action:)
                                                 name:@"CZS_Action"
                                               object:nil];
    
    //下拉刷新
    self.refresh = [[ODRefreshControl alloc] initInScrollView:self.CardWebView.scrollView];
    [self.refresh addTarget:self action:@selector(uploadWeb) forControlEvents:UIControlEventValueChanged];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self uploadWeb];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//刷新web数据
- (void)uploadWeb {
    NSString *URLStr;
//#ifdef TARGET_PARENT
//    if ([_model isKindOfClass:[BBQBabyModel class]]) {
//        URLStr = [NSString stringWithFormat:@"%@bbq.php?mod=bbq&ac=h5_czs&baobaouid=%@" , CS_URL_BASE, ((BBQBabyModel *)_model).uid];
//    } else if ([_model isKindOfClass:[BBQClassDataModel class]]) {
//        URLStr = [NSString stringWithFormat:@"%@bbq.php?mod=bbq&ac=h5_czs&baobaouid=%@" , CS_URL_BASE, ((BBQClassDataModel *)_model).classid];
//    }
//#elif TARGET_TEACHER
//    
//#elif TARGET_MASTER
//    
//#endif
    
    if ([_model isKindOfClass:[BBQBabyModel class]]) {
        URLStr = [NSString stringWithFormat:@"%@bbq.php?mod=bbq&ac=h5_czs&baobaouid=%@" , CS_URL_BASE, ((BBQBabyModel *)_model).uid];
    } else if ([_model isKindOfClass:[BBQClassDataModel class]]) {
        URLStr = [NSString stringWithFormat:@"%@bbq.php?mod=bbq&ac=h5_czs&classid=%@&groupid=20" , CS_URL_BASE, ((BBQClassDataModel *)_model).classid];
    } else if ([_model isKindOfClass:[BBQSchoolDataModel class]]) {
        URLStr =
        [NSString stringWithFormat:@"%@bbq.php?mod=bbq&ac=h5_czs&schoolid=%@&groupid=21",
         CS_URL_BASE, ((BBQSchoolDataModel *)_model).schoolid];
    }
    NSURLRequest *UrlRequest =[NSURLRequest requestWithURL:[NSURL URLWithString:URLStr]];
    [self.CardWebView loadRequest:UrlRequest];
}

//通知动作
- (void)CZS_Action:(NSNotification *)notification {
    if ([notification.userInfo[@"action"] isEqual:@"cmd_buyczs"]) {
        self.buyCardView = [[BuyCardView alloc] init];
        //价格
        [self.buyCardView showBuyCardViewWithPrice:[notification.userInfo[@"para"][
                                                                                   @"price"] floatValue]];
        //成长书编号
        self.bookcode = notification.userInfo[@"para"][@"bookcode"];
        self.bookNumStr=@"1";
        [self.buyCardView.confirmButton addTarget:self
                                           action:@selector(ToPay)
                                 forControlEvents:UIControlEventTouchUpInside];
        
    } else if ([notification.userInfo[@"action"] isEqual:@"cmd_czslist"]) {
        //进入成长书预览
        CardPreviewController *CardPreviewVcl =
        [[UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil]
         instantiateViewControllerWithIdentifier:@"CardPreviewVcl"];
        CardPreviewVcl.title = @"成长书";
        CardPreviewVcl.previewType = [notification.userInfo[@"para"][@"dtype"] intValue];
        //传数据源数组
        [self.navigationController pushViewController:CardPreviewVcl animated:YES];
        CardPreviewVcl.CZS_dic = notification.userInfo[@"para"];
        
    } else if ([notification.userInfo[@"action"] isEqual:@"cmd_callQQ"]) {
        //进入QQ
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        NSURL *url = [NSURL
                      URLWithString:[NSString stringWithFormat:@"mqq://im/"
                                     @"chat?chat_type=wpa&uin=%@&"
                                     @"version=1&src_type=web",
                                     notification.userInfo[@"para"][
                                                                    @"qq"]]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [webView loadRequest:request];
        [self.view addSubview:webView];
    } else if ([notification.userInfo[@"action"] isEqual:@"cmd_more"]) {
    } else if ([notification.userInfo[@"action"] isEqual:@"cmd_openwin"]) {
        //进入网页
        WebViewController *WebVcl =
        [[UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil]
         instantiateViewControllerWithIdentifier:@"WebViewController"];
        
        WebVcl.url = notification.userInfo[@"para"][@"url"];
        //        WebVcl.url=@"http://117.141.115.68:883/H5/book/cmdtest.html";
        
        [self.navigationController pushViewController:WebVcl animated:YES];
    } else if ([notification.userInfo[@"action"] isEqual:@"cmd_czsdesc"]) {
        self.popViewDataArr = notification.userInfo[@"para"][@"czsdesc"];
        //加成长书介绍 浮层
        [self CreatCZS_PopTbVcl];
    }else if ([notification.userInfo[@"action"] isEqual:@"cmd_teacherOrder"]) {
        
        //老师、园长版成长书购买
        self.buyCardView = [[BuyCardView alloc] init];
        //价格
        [self.buyCardView showBuyCardViewWithPrice:[notification.userInfo[@"para"][
                                                                                   @"total"] floatValue]];
        //成长书编号
        self.bookcode = notification.userInfo[@"para"][@"bookcode"];
        self.bookNumStr=notification.userInfo[@"para"][@"number"];
        self.dynamictype = [notification.userInfo[@"para"][@"dynamictype"] intValue];
        self.classid = [notification.userInfo[@"para"][@"classid"] intValue];
        self.schoolid = [notification.userInfo[@"para"][@"schoolid"] intValue];
        
        [self.buyCardView.confirmButton addTarget:self
                                           action:@selector(ToPay)
                                 forControlEvents:UIControlEventTouchUpInside];
        
    }
}

//成长书介绍 浮层
- (void)CreatCZS_PopTbVcl {
    
    
    //加半透明背景
    [self addAlphaView];
    
    //加介绍图浮层
    self.CardPopTbvcl =
    [self.storyboard instantiateViewControllerWithIdentifier:@"CardPopTbvcl"];
    //传递数据源数组
    self.CardPopTbvcl.DataSourceArr = self.popViewDataArr;
    [self.view addSubview:_CardPopTbvcl.view];
    _CardPopTbvcl.view.layer.cornerRadius = 7;
    
    [_CardPopTbvcl.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(self.view.frame.origin.y + 33);
        make.height.mas_equalTo(self.view.frame.size.height - 70);
        make.width.mas_equalTo(kScreenWidth - 50);
        make.centerX.equalTo(self.view);
    }];
    //手势
    UITapGestureRecognizer *tap1 =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(dealTap)];
    [_CardPopTbvcl.view addGestureRecognizer:tap1];
}

-(void)addAlphaView{
    
    self.alphaView = [[UIView alloc] initWithFrame:self.view.frame];
    _alphaView.backgroundColor = [UIColor blackColor];
    _alphaView.alpha = 0.4;
    [self.view addSubview:_alphaView];
    //加手势
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(dealTap)];
    [_alphaView addGestureRecognizer:tap];
}
//单击手势
- (void)dealTap {
    
    self.alphaView.hidden = YES;
    self.CardPopTbvcl.view.hidden = YES;
}

//支付
- (void)ToPay {
    
    if (self.buyCardView.payWay == ChosedNull) {
        [SVProgressHUD showErrorWithStatus:@"请先选择一种支付方式"];
        return;
    }
    
    [self buyQzk:TheCurBaoBao.uid
        bookcode:self.bookcode
         paytype:(self.buyCardView.payWay == ChosedPayWayAlipay ? @1 : @2)];
}

//购买亲子卡
- (void)buyQzk:(NSNumber *)baobaouid
      bookcode:(NSString *)bookcode
       paytype:(NSNumber *)paytype {
    NSDictionary *params = @{
                             @"baobaouid" : baobaouid ?:@"",
                             @"bookcode" : bookcode,
                             @"paytype" : paytype,
                             @"dynamictype" : @(self.dynamictype),
                             @"booknum" : self.bookNumStr,
                             @"classid" : @(self.classid),
                             @"schoolid" : @(self.schoolid)
                             };
//#ifdef TARGET_PARENT
//    
//    NSDictionary *params = @{
//                             @"baobaouid" : baobaouid,
//                             @"bookcode" : bookcode,
//                             @"paytype" : paytype,@"dynamictype" : @"0",@"schoolid" : @"",@"classid" : @"",@"booknum" : self.bookNumStr
//                             };
//    
//#elif TARGET_TEACHER
//    
//    NSDictionary *params = @{
//                             @"baobaouid" : @"",
//                             @"bookcode" : bookcode,
//                             @"paytype" : paytype,@"dynamictype" : @"2",@"schoolid" : TheCurUser.curSchool.schoolid,@"classid" : TheCurUser.curClass.classid,@"booknum" : self.bookNumStr
//                             };
//#elif TARGET_MASTER
//    
//    NSDictionary *params = @{
//                             @"baobaouid" : @"",
//                             @"bookcode" : bookcode,
//                             @"paytype" : paytype,@"dynamictype" : @"2",@"schoolid" : TheCurUser.curSchool.schoolid,@"classid" : @"",@"booknum" : self.bookNumStr
//                             };
//    
//#endif
    
    [SVProgressHUD showWithStatus:@"请稍候..."];
    
    [BBQHTTPRequest
     queryWithType:BBQHTTPRequestTypeBuyQZK
     param:params
     successHandler:^(AFHTTPRequestOperation *operation,
                      NSDictionary *responseObject, bool apiSuccess) {
         [SVProgressHUD dismiss];
         dispatch_async(dispatch_get_main_queue(), ^{
             
             NSDictionary *dicData = [responseObject objectForKey:@"data"];
             NSLog(@"购买返回数据 。。。%@",dicData);
             if (dicData) {
                 self.orderid = pickJsonStrValue(dicData, @"orderid");
                 self.charge = [dicData objectForKey:@"charge"];
                 self.ordertime = [NSNumber
                                   numberWithInteger:[[dicData
                                                       objectForKey:@"ordertime"] integerValue]];
                 //                 self.bookNumStr=pickJsonStrValue(dicData, @"booknum");
                 self.orderprice = [NSNumber
                                    numberWithFloat:[[dicData objectForKey:@"price"] floatValue]];
                 
                 // NSLog(@"支付方式%ld", self.buyCardView.payWay);
                 [self.buyCardView hideSelf];
                 dispatch_async(dispatch_get_main_queue(), ^(){
                     //跳转详情界面
                     [self dispDetailController];
                 });
             }
         });
     } errorHandler:^(NSDictionary *responseObject) {
         [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
     } failureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
         [SVProgressHUD showErrorWithStatus:error.localizedDescription];
     }];
}

//详情界面
- (void)dispDetailController {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil];
    OrderDetailViewController *vc =
    [sb instantiateViewControllerWithIdentifier:@"OrderDetailViewController"];
    
    if ([self.bookcode isEqualToString:@"QY"]) {
        vc.strName = @"成长书-轻盈版";
    } else {
        
        vc.strName = @"成长书-尊享版";
    }
    vc.strOrdrer = self.orderid;
    vc.strOrderTime = [CommonFunc getCurrentTime];
    vc.bookNum=[NSString stringWithFormat:@"%@本", self.bookNumStr];
    vc.strOrderMoney =
    [NSString stringWithFormat:@"%.2f元", [self.orderprice floatValue]];
    vc.strOrderUser = TheCurUser.member.nickname;
    vc.charge = self.charge;
    vc.buytype = BUY_QZK;
    //可以定义回调
    [self.navigationController pushViewController:vc animated:YES];
}

//网页加载完成
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    JSContext *context = [self.CardWebView
                          valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    TestJSObject *testJO = [TestJSObject new];
    context[@"client"] = testJO;
    //停止刷新
    [self.refresh endRefreshing];
}

@end
