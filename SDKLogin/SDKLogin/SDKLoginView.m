//
//  SDKLoginView.m
//  Login
//
//  Created by fanren on 16/6/6.
//  Copyright © 2016年 Qinmin. All rights reserved.
//

#import "SDKLoginView.h"
#import "NSString+CryptUtil.h"

NSString * const USER_INFO_NAME = @"userName";
NSString * const USER_INFO_PWD = @"pwd";

static NSString* const UserNameStorageKey = @"kusername";
static NSString* const UserPWDStorageKey = @"kuserpw";
static NSString* const SecretKey = @"#kuse@rpw*&%#@!$$#@@$%%DSSRYWS!@#$%#@DFRE$#RDDEETHGGFCRRD";

#define LeftMargin   15
#define RightMargin  15
#define TopMargin    15

@interface SDKLoginView () <UITextFieldDelegate>
{
    UITapGestureRecognizer *_tapGesture;
}
@property(nonatomic,weak) UIButton *checkBtn;
@property(nonatomic,weak) UITextField *account;
@property(nonatomic,weak) UITextField *pwd;
@end

@implementation SDKLoginView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.8;
        self.layer.cornerRadius = 5;
        
        //logo1
        UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(LeftMargin+5, TopMargin, 45, 42)];
        logo.image = [self imageFromBundelWithName:@"jh_title_bar_logo@2x.png"];
        [self addSubview:logo];
        
        //logotext
        UIImageView *logotext = [[UIImageView alloc] initWithFrame:CGRectMake(LeftMargin+50, TopMargin, 60, 40)];
        logotext.image = [self imageFromBundelWithName:@"jh_title_bar_text@2x.png"];
        [self addSubview:logotext];
        
        //account
        UIView *accountBg = [[UIView alloc] initWithFrame:CGRectMake(LeftMargin, 55+TopMargin, 290, 36)];
        accountBg.backgroundColor = [UIColor whiteColor];
        accountBg.layer.cornerRadius = 5;
        [self addSubview:accountBg];
        UILabel *accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(LeftMargin-5, 0, 50, 36)];
        accountLabel.text = @"账户:";
        accountLabel.textColor = [UIColor blackColor];
        [accountBg addSubview:accountLabel];
        UITextField *account = [[UITextField alloc] initWithFrame:CGRectMake(60, 0, 230, 36)];
        account.backgroundColor = [UIColor whiteColor];
        account.layer.cornerRadius = 5;
        account.backgroundColor = [UIColor whiteColor];
        account.returnKeyType = UIReturnKeyDone;
        [accountBg addSubview:account];
        _account = account;
        
        //pwd
        UIView *pwdBg = [[UIView alloc] initWithFrame:CGRectMake(LeftMargin, 105+TopMargin, 290, 36)];
        pwdBg.backgroundColor = [UIColor whiteColor];
        pwdBg.layer.cornerRadius = 5;
        [self addSubview:pwdBg];
        UILabel *pwdBgLabel = [[UILabel alloc] initWithFrame:CGRectMake(LeftMargin-5, 0, 50, 36)];
        pwdBgLabel.text = @"密码:";
        pwdBgLabel.textColor = [UIColor blackColor];
        [pwdBg addSubview:pwdBgLabel];
        UITextField *pwd = [[UITextField alloc] initWithFrame:CGRectMake(60, 0, 230, 36)];
        pwd.backgroundColor = [UIColor whiteColor];
        pwd.layer.cornerRadius = 5;
        pwd.secureTextEntry = YES;
        pwd.returnKeyType = UIReturnKeyDone;
        pwd.delegate = self;
        [pwdBg addSubview:pwd];
        _pwd = pwd;
        
        //checkBtn
        UIButton *checkBtn = [[UIButton alloc] initWithFrame:CGRectMake(LeftMargin-10, 152+TopMargin, 137, 38)];
        checkBtn.layer.cornerRadius = 5;
        checkBtn.tag = 0;
        [checkBtn setImage:[self imageFromBundelWithName:@"btn_check_on_disable.png"] forState:UIControlStateNormal];
        [checkBtn setImage:[self imageFromBundelWithName:@"btn_check_on.png"] forState:UIControlStateSelected];
        checkBtn.selected = YES;
        [checkBtn setTitle:@" 记住密码" forState:UIControlStateNormal];
        [checkBtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:checkBtn];
        _checkBtn = checkBtn;
        
        //loginbtn
        UIButton *loginbtn = [[UIButton alloc] initWithFrame:CGRectMake(LeftMargin, 195+TopMargin, 137, 40)];
        loginbtn.backgroundColor = [UIColor colorWithRed:39/255.0 green:220/255.0 blue:253.0/255.0 alpha:1.0];
        loginbtn.layer.cornerRadius = 5;
        loginbtn.tag = 1;
        [loginbtn setTitle:@"登录" forState:UIControlStateNormal];
        [loginbtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:loginbtn];
        
        //regbtn
        UIButton *regbtn = [[UIButton alloc] initWithFrame:CGRectMake(167, 195+TopMargin, 137, 40)];
        regbtn.backgroundColor = [UIColor orangeColor];
        regbtn.layer.cornerRadius = 5;
        regbtn.tag = 2;
        [regbtn setTitle:@"一键注册" forState:UIControlStateNormal];
        [regbtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:regbtn];
          
        //NSNotification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardShow:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardHide:)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
        
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLoginView:)];
        [self addGestureRecognizer:_tapGesture];
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeGestureRecognizer:_tapGesture];
}

+ (instancetype)sharedLoginView
{
    static SDKLoginView *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        if (winSize.width < winSize.height) {
            float tmp = winSize.width;
            winSize.width = winSize.height;
            winSize.height = tmp;
        }
        _instance = [[[self class] alloc] initWithFrame:CGRectMake(winSize.width/2-320/2, winSize.height/2-260/2, 320, 260)];
    });
    return _instance;
}

- (void)show
{
    if (!self.superview) {
        [_rootViewController.view addSubview:self];
    }
    
    NSData *userNameData = [[NSUserDefaults standardUserDefaults] objectForKey:UserNameStorageKey];
    NSData *userPWDData = [[NSUserDefaults standardUserDefaults] objectForKey:UserPWDStorageKey];
    
    if (userNameData && userPWDData) {
        _account.text = [NSString AES256Decrypt:userNameData withKey:SecretKey];
        _pwd.text = [NSString AES256Decrypt:userPWDData withKey:SecretKey];
    }
}

- (void)hide
{
    [self removeFromSuperview];
}

#pragma mark -
- (void)clickButton:(UIButton *)btn
{
    if (btn.tag == 0) {
        btn.selected = !btn.selected;
        return;
    }
    
    if (_account.text.length <= 0 || _pwd.text.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"账号或密码不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSDictionary *userInfo = @{
                               USER_INFO_NAME : _account.text,
                               USER_INFO_PWD : _pwd.text
                               };
    if (btn.tag == 1) {
        if (_delegate && [_delegate respondsToSelector:@selector(loginView:didClickLoginButtonWithUserInfo:)]) {
            [_delegate loginView:self didClickLoginButtonWithUserInfo:userInfo];
        }
    }else if(btn.tag == 2) {
        if (_delegate && [_delegate respondsToSelector:@selector(loginView:didClickRegisterButtonWithUserInfo:)]) {
            [_delegate loginView:self didClickRegisterButtonWithUserInfo:userInfo];
        }
    }
    
    if (_checkBtn.selected) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString AES256Encrypt:_account.text withKey:SecretKey] forKey:UserNameStorageKey];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString AES256Encrypt:_pwd.text withKey:SecretKey] forKey:UserPWDStorageKey];
    }else {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:UserNameStorageKey];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:UserPWDStorageKey];
    }
}

- (void)tapLoginView:(UITapGestureRecognizer *)gesture
{
    [_account endEditing:YES];
    [_pwd endEditing:YES];
}

#pragma mark -
- (UIImage *)imageFromBundelWithName:(NSString *)name
{
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SDKLoginRes.bundle" ofType:nil]];
    return [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:name ofType:nil]];
}

#pragma mark -
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _account) {
        [_account endEditing:YES];
        [_pwd becomeFirstResponder];
    }else {
        [_account endEditing:YES];
        [_pwd endEditing:YES];
    }
    return YES;
}

#pragma mark -
- (void)keyboardWillShow:(NSNotification *)notif {
    if (self.hidden == YES) {
        return;
    }
    
    CGRect rect = [[notif.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat y = rect.origin.y;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    NSArray *subviews = [self subviews];
    for (UIView *sub in subviews) {
        CGFloat maxY = CGRectGetMaxY(sub.frame);
        if (maxY > y - 10) {
            CGSize winSize = [UIScreen mainScreen].bounds.size;
            if (winSize.width < winSize.height) {
                float tmp = winSize.width;
                winSize.width = winSize.height;
                winSize.height = tmp;
            }
            self.center = CGPointMake(winSize.width/2, sub.center.y - maxY + y - 10);
            break;
        }
    }
    [UIView commitAnimations];
}

- (void)keyboardShow:(NSNotification *)notif {
    if (self.hidden == YES) {
        return;
    }
}

- (void)keyboardWillHide:(NSNotification *)notif {
    if (self.hidden == YES) {
        return;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    NSArray *subviews = [self subviews];
    for (UIView *sub in subviews) {
        if (sub.center.y < CGRectGetHeight(self.frame)/2.0) {
            CGSize winSize = [UIScreen mainScreen].bounds.size;
            if (winSize.width < winSize.height) {
                float tmp = winSize.width;
                winSize.width = winSize.height;
                winSize.height = tmp;
            }
            self.center = CGPointMake(winSize.width/2, winSize.height/2);
            break;
        }
    }
    [UIView commitAnimations];
}

- (void)keyboardHide:(NSNotification *)notif {
    if (self.hidden == YES) {
        return;
    }
}

@end
