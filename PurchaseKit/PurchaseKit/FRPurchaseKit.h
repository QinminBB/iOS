//
//  FRPurchaseKit.h
//  PurchaseKit
//
//  Created by fanren on 16/4/14.
//  Copyright © 2016年 Qinmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "FRPurchaseItem.h"

typedef NS_ENUM(NSInteger,PurchaseError) {
    PurchaseErrorForbidden = 0,
    PurchaseErrorNoProduct = 1,
    PurchaseErrorNoProductInfo = 2
};

typedef NS_ENUM(NSInteger,PurchaseStep) {
    PurchaseStepWillRequest = 1,
    PurchaseStepDidRequest = 2,
    PurchaseStepWillMakePayment = 3,
    PurchaseStepDidMakePayment = 4,
    PurchaseStepRequestErrorForbidden = 5,
};

@interface FRPurchaseKit : NSObject

+ (instancetype)sharedPurchaseKit;

- (void)setURLDomain:(NSString *)URLDomain;

- (void)applicationDidBecomeActive;

- (void)applicationWillTerminate;

- (void)setProductItem:(FRPurchaseItem *)productItem;

- (void)requestProducts:(NSSet *)products
             completion:(void(^)(SKProductsResponse* response))completion
          errorResponse:(void(^)(NSError *error))error;

- (void)makePaymentWithProductParam:(SKProduct *)product
                         completion:(void (^)(SKPaymentTransaction *transaction))completion
                              error:(void (^)(NSError *))error;

- (void)restoreProductsWithCompletion:(void (^)())completion errorResponse:(void(^)(NSError *error))error;

@end
