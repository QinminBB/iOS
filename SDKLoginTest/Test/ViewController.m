//
//  ViewController.m
//  Test
//
//  Created by fanren on 16/6/7.
//  Copyright © 2016年 Qinmin. All rights reserved.
//

#import "ViewController.h"
#import <SDKLogin.h>

@interface ViewController ()<SDKLoginViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[SDKLoginView sharedLoginView] setRootViewController:self];
    [[SDKLoginView sharedLoginView] setDelegate:self];
    [[SDKLoginView sharedLoginView] show];
}


- (void)loginView:(SDKLoginView *)loginView didClickRegisterButtonWithUserInfo:(NSDictionary *)userInfo
{

}

- (void)loginView:(SDKLoginView *)loginView didClickLoginButtonWithUserInfo:(NSDictionary *)userInfo
{

}

@end
