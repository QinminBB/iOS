//
//  SDKLoginView.h
//  Login
//
//  Created by fanren on 16/6/6.
//  Copyright © 2016年 Qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const USER_INFO_NAME;
extern NSString * const USER_INFO_PWD;

@class SDKLoginView;

@protocol SDKLoginViewDelegate <NSObject>

- (void)loginView:(SDKLoginView *)loginView didClickRegisterButtonWithUserInfo:(NSDictionary *)userInfo;

- (void)loginView:(SDKLoginView *)loginView didClickLoginButtonWithUserInfo:(NSDictionary *)userInfo;

@end


@interface SDKLoginView : UIView

@property(nonatomic,weak) UIViewController *rootViewController;

@property(nonatomic,weak) id<SDKLoginViewDelegate> delegate;

+ (instancetype)sharedLoginView;

- (void)show;

- (void)hide;

@end
