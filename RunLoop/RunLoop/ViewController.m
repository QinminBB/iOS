//
//  ViewController.m
//  RunLoop
//
//  Created by fanren on 16/4/9.
//  Copyright © 2016年 Qinmin. All rights reserved.
//

#import "ViewController.h"
#import <AdSupport/AdSupport.h>

@interface ViewController ()
{
    NSTimer *_timer;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    //95955F33-BFBD-48BA-A630-866D2DAE482D
    //95955F33-BFBD-48BA-A630-866D2DAE482D
    
    //95955F33-BFBD-48BA-A630-866D2DAE482D
    
    //FEEA57D5-A8AF-4CB6-8698-DDE5F6BC53BB
    NSLog(@"%@",[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]);
}

+ (NSString *)UUID {
    KeychainItemWrapper *keyChainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"MYAppID" accessGroup:@"com.test.app"];
    NSString *UUID = [keyChainWrapper objectForKey:(__bridge id)kSecValueData];
    
    if (UUID == nil || UUID.length == 0) {
        UUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [keyChainWrapper setObject:UUID forKey:(__bridge id)kSecValueData];
    }
    
    return UUID;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
