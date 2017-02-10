//
//  jyexViewController.m
//  BBQ
//
//  Created by mwt on 15/8/9.
//  Copyright (c) 2015年 bbq. All rights reserved.
//

#import "jyexViewController.h"
#import "WebViewController.h"
#import <Masonry.h>
#import "UIView+Common.h"
#import "BBQSelectButton.h"
#import <KxMenu.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "TestJSObject.h"
#import "BBQLeaveListTabbleViewController.h"
#import "KxMenuItem+BBQSchoolClassItme.h"
#import "XTSegmentControl.h"
#import "BBQAttentionViewController.h"
#import "WDActivityIndicator.h"

@interface jyexViewController ()

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) BBQSelectButton *seleceButton;

@property (nonatomic, strong) WDActivityIndicator *activityIndicator;

@end

#define _basebuttontag 1000

@implementation jyexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //接收JS调用通知跳转
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(CZS_Action:)
                                                 name:@"CZS_Action"
                                               object:nil];
    [self addSelectBtn];
    [self loadActivityIndicator];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _seleceButton.hidden = NO;
    _seleceButton.userInteractionEnabled = YES;
    
    __block int n = 0;
    [TheCurUser.baobaodata enumerateObjectsUsingBlock:^(BBQBabyModel * baobao, NSUInteger idx, BOOL * _Nonnull stop) {
        if (baobao.qx.intValue == 1 || baobao.qx.intValue == 2) {
            for (BBQSchoolDataModel *school in baobao.baobaoschooldata) {
                for (BBQClassDataModel *class in school.classdata) {
                    [_seleceButton setTitle:[NSString stringWithFormat:@"%@的%@", baobao.realname, class.classname] forState:UIControlStateNormal];
                    [self loadWebViewWithBaobaoUid:[baobao.uid stringValue] classid:[class.classid stringValue] schoolid:[school.schoolid stringValue]];
                    n = 1;
                    *stop = YES;
                    break;
                }
                if (n == 1) {
                    break;
                }
            }
        }
    }];
    if (n == 0) {
        self.webView.hidden = YES;
        _seleceButton.hidden = YES;
        _seleceButton.userInteractionEnabled = NO;
        [UIAlertView bk_showAlertViewWithTitle:@"目前没有家园信息哦，请先创建宝宝吧，然后加入班级，就可以查看家园信息了" message:nil cancelButtonTitle:@"取消" otherButtonTitles:[NSArray arrayWithObjects:@"去关注列表", nil] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil];
                BBQAttentionViewController *vc = [sb instantiateViewControllerWithIdentifier:@"AttentionListBoard"];
                vc.type = BBQAttentionViewTypeNormal;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _seleceButton.hidden = YES;
    _seleceButton.userInteractionEnabled = NO;
}

#pragma mark - webViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    [_activityIndicator startAnimating];
    NSString *sMethod = [request HTTPMethod];
    if (sMethod && ([sMethod isEqualToString:@"POST"] ||
                    [sMethod isEqualToString:@"post"])) {
        return YES;
    }
    
    NSString *path = [[request URL] absoluteString];
    NSLog(@"url:%@\r\n", path);
    NSString *url;
#ifdef TARGET_MASTER
    url = PATH_HOMEPAGE_JIAYUAN_MASTER;
    //老师
#elif TARGET_TEACHER
    url = PATH_HOMEPAGE_JIAYUAN_TEACHER;
    //家长
#else
    url = PATH_HOMEPAGE_JIAYUAN_PARENT;
#endif
    NSRange range1 = [path rangeOfString:url];
    if ([path rangeOfString:@"_self=1"].length > 0 ||
        [path rangeOfString:@"action=login"].length > 0) {
        return YES;
    }
    if (range1.length == 0 && ![path isEqualToString:@"about:blank"]) {
        
        UIStoryboard *sb =
        [UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil];
        WebViewController *vc =
        [sb instantiateViewControllerWithIdentifier:@"WebViewController"];
        vc.url = path;
        [self.navigationController pushViewController:vc animated:YES];
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_activityIndicator stopAnimating];
    JSContext *context = [webView
                          valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    TestJSObject *testJO = [TestJSObject new];
    context[@"client"] = testJO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ([error code] == -999 || [error code] == 102) {
        return;
    }
    NSString *err;
    [self.webView loadHTMLString:err baseURL:nil];
}

#pragma mark - network
- (void)loadWebViewWithBaobaoUid:(NSString *)baobaouid classid:(NSString *)classid schoolid:(NSString *)schoolid {
    NSString * url ;
#ifdef TARGET_PARENT
    url = [CS_URL_BASE stringByAppendingString:[NSString stringWithFormat:@"mh.php?mod=workbench_jiazhang&ac=jzztc_menu&in_mobile=1&baobaouid=%@&classid=%@&schoolid=%@&_self=1", baobaouid, classid, schoolid]];
#elif TARGET_TEACHER
    url = URL_HOMEPAGE_JIAYUAN_TEACHER;
#else
    url = URL_HOMEPAGE_JIAYUAN_MASTER;
#endif
    [self.webView
     loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)selectBtnClick:(BBQSelectButton *)sender {
    NSMutableArray *nameAry = [NSMutableArray arrayWithCapacity:0];
    for (BBQBabyModel *baobao in TheCurUser.baobaodata) {
        if (baobao.qx.intValue == 1 || baobao.qx.intValue == 2) {
            for (BBQSchoolDataModel *school in baobao.baobaoschooldata) {
                for (BBQClassDataModel *class in school.classdata) {
                    KxMenuItem *item = [KxMenuItem menuItem:[NSString stringWithFormat:@"%@的%@", baobao.realname, class.classname] image:nil target:self action:@selector(kxmenuItemClick:)];
                    item.schoolclassname = [NSString stringWithFormat:@"%@的%@", baobao.realname, class.classname];
                    item.baobaouid = [baobao.uid stringValue];
                    item.schoolid = [school.schoolid stringValue];
                    item.classid = [class.classid stringValue];
                    [nameAry addObject:item];
                }
            }
        }
    }
    
    [KxMenu showMenuInView:self.navigationController.view fromRect:sender.frame menuItems:nameAry];
}

- (void)kxmenuItemClick:(KxMenuItem *)item {
    [_seleceButton setTitle:item.title forState:UIControlStateNormal];
    [self loadWebViewWithBaobaoUid:item.baobaouid classid:item.classid schoolid:item.schoolid];
    [KxMenu dismissMenu];
}

- (void)CZS_Action:(NSNotification *)notification {
    if ([notification.userInfo[@"action"] isEqual:@"cmd_intoqj"]) {
        BBQLeaveListTabbleViewController *vc = [[UIStoryboard storyboardWithName:@"Family" bundle:nil] instantiateViewControllerWithIdentifier:@"leaveListVC"];
        vc.params = notification.userInfo[@"para"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)addSelectBtn {
    self.navigationItem.title = @"";
    _seleceButton = [BBQSelectButton buttonWithType:UIButtonTypeCustom];
    [_seleceButton addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _seleceButton.frame = CGRectMake(50, 20, kScreenWidth - 100, 40);
    [_seleceButton setImage:[UIImage imageNamed:@"daosanjiao"] forState:UIControlStateNormal];
    [_seleceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.navigationController.view addSubview:_seleceButton];
    [TheCurUser.baobaodata enumerateObjectsUsingBlock:^(BBQBabyModel * baobao, NSUInteger idx, BOOL * _Nonnull stop) {
        if (baobao.qx.intValue == 1 || baobao.qx.intValue == 2) {
            for (BBQSchoolDataModel *school in baobao.baobaoschooldata) {
                for (BBQClassDataModel *class in school.classdata) {
                    [_seleceButton setTitle:[NSString stringWithFormat:@"%@的%@", baobao.realname, class.classname] forState:UIControlStateNormal];
                    *stop = YES;
                }
            }
        }
    }];
}

- (void)loadActivityIndicator {
    _activityIndicator = [WDActivityIndicator new];
    _activityIndicator.hidesWhenStopped = YES;
    _activityIndicator.indicatorStyle = WDActivityIndicatorStyleGradient;
    [self.webView addSubview:_activityIndicator];
    [_activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.webView);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
}

- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 100)];
        _webView.delegate = self;
        [self.view addSubview:_webView];
    }
    return _webView;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
