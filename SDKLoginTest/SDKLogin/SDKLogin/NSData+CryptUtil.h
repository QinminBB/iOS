//
//  NSData+CryptUtil.h
//  Engine
//
//  Created by fanren on 16/6/7.
//  Copyright © 2016年 guangyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (CryptUtil)

- (NSData*)AES256EncryptWithKey:(NSString*)key;

- (NSData*)AES256DecryptWithKey:(NSString*)key;

@end
