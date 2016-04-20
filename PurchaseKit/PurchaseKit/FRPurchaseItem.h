//
//  FRPurchaseItem.h
//  PurchaseKit
//
//  Created by fanren on 16/4/14.
//  Copyright © 2016年 Qinmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRPurchaseItem : NSObject

@property(nonatomic,copy) NSString *version;

@property(nonatomic,copy) NSString *plateform;

@property(nonatomic,copy) NSString* orderId;

@property(nonatomic,copy) NSString* amount;

@property(nonatomic,copy) NSString* userName;

@property(nonatomic,copy) NSString* roleName;

@property(nonatomic,copy) NSString* serverId;

@property(nonatomic,copy) NSString* productId;

@property(nonatomic,assign) NSUInteger time;

@end
