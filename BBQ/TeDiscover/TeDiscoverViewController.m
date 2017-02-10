//
//  TeDiscoverViewController.m
//  BBQ
//
//  Created by slovelys on 16/3/17.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "TeDiscoverViewController.h"
#import "BBQDiscoverViewController.h"

@interface TeDiscoverViewController ()

@end

@implementation TeDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil];
    BBQDiscoverViewController *discoverVC = [sb instantiateViewControllerWithIdentifier:@"discoverVC"];
    [self addChildViewController:discoverVC];
    [self.view addSubview:discoverVC.view];
    [discoverVC didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
