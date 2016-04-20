//
//  SKPayment+FRPurchaseItem.h
//  PurchaseKit
//
//  Created by fanren on 16/4/20.
//  Copyright © 2016年 Qinmin. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "FRPurchaseItem.h"

@interface SKPayment (FRPurchaseItem)

@property(nonatomic,strong) FRPurchaseItem *purchaseItem;

@end
