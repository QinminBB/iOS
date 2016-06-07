//
//  NSString+CryptUtil.h
//  Engine
//
//  Created by fanren on 16/6/7.
//  Copyright © 2016年 guangyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CryptUtil)

- (NSString*)md5;

+ (NSData*)AES256Encrypt:(NSString*)strSource withKey:(NSString*)key;

+ (NSString*)AES256Decrypt:(NSData*)dataSource withKey:(NSString*)key;

@end
