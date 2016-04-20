//
//  FRPurchaseKit.m
//  PurchaseKit
//
//  Created by fanren on 16/4/14.
//  Copyright © 2016年 Qinmin. All rights reserved.
//

#import "FRPurchaseKit.h"
#import "SSKeychain.h"
#import "SKPayment+FRPurchaseItem.h"


@interface FRPurchaseKit () <SKProductsRequestDelegate,SKPaymentTransactionObserver>

@property(nonatomic,copy) NSString *URLDomain;
@property(nonatomic,strong) FRPurchaseItem *productItem;

@property(nonatomic,copy) void(^RequestCompletionBlock)(SKProductsResponse* response);
@property(nonatomic,copy) void(^RequestErrorBlock)(NSError* error);
@property(nonatomic,copy) void(^PaymentCompletionBlock)(SKPaymentTransaction *transaction);
@property(nonatomic,copy) void(^PaymentErrorBlock)(NSError* error);

@property(nonatomic,copy) void(^RestoreCompletionBlock)();
@property(nonatomic,copy) void(^RestoreErrorBlock)(NSError* error);

@end

@implementation FRPurchaseKit

#pragma mark - LifeMethod
+ (instancetype)sharedPurchaseKit
{
    static FRPurchaseKit* _purchaseKit = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _purchaseKit = [[FRPurchaseKit alloc] init];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:_purchaseKit];
    });
    return _purchaseKit;
}

- (void)applicationWillTerminate
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)applicationDidBecomeActive
{
    [self verifyPruchaseWithProductItem:nil];
}

- (void)resetPurchaseKit
{
    _RequestErrorBlock = nil;
    _RequestCompletionBlock = nil;
    _PaymentCompletionBlock = nil;
    _PaymentErrorBlock = nil;
    _RestoreErrorBlock = nil;
    _RestoreCompletionBlock = nil;
}

#pragma mark - Pubilc Payment API
- (void)requestProducts:(NSSet *)products
             completion:(void(^)(SKProductsResponse* response))completion
          errorResponse:(void(^)(NSError *error))error
{
    self.RequestCompletionBlock = completion;
    self.RequestErrorBlock = error;
    if (self.productItem == nil) {
        NSError *paymentError = [[NSError alloc] initWithDomain:@"FRPurchaseKit" code:PurchaseErrorNoProductInfo userInfo:@{NSLocalizedDescriptionKey:@"支付参数不能为空"}];
        if (self.RequestErrorBlock) {
            self.RequestErrorBlock(paymentError);
        }
        [self resetPurchaseKit];
        return;
    }
    if ([SKPaymentQueue canMakePayments] == NO) {
        NSError *requestError = [[NSError alloc] initWithDomain:@"FRPurchaseKit" code:PurchaseErrorForbidden userInfo:@{NSLocalizedDescriptionKey:@"内购功能不可用"}];
        if(self.RequestErrorBlock) {
            self.RequestErrorBlock(requestError);
        }
        [self resetPurchaseKit];
        return;
    }
    
    SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers:products];
    request.delegate = self;
    [request start];
}

- (void)makePaymentWithProductParam:(SKProduct *)product
                         completion:(void (^)(SKPaymentTransaction *transaction))completion
                              error:(void (^)(NSError *))error
{
    self.PaymentErrorBlock = error;
    self.PaymentCompletionBlock = completion;
    
    if (self.productItem == nil) {
        NSError *paymentError = [[NSError alloc] initWithDomain:@"FRPurchaseKit" code:PurchaseErrorNoProductInfo userInfo:@{NSLocalizedDescriptionKey:@"支付参数不能为空"}];
        if (self.PaymentErrorBlock) {
            self.PaymentErrorBlock(paymentError);
        }
        [self resetPurchaseKit];
        return;
    }
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [payment setPurchaseItem:_productItem];
    if ([SKPaymentQueue defaultQueue]) {
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }else {
        NSError *paymentError = [[NSError alloc] initWithDomain:@"FRPurchaseKit" code:PurchaseErrorForbidden userInfo:@{NSLocalizedDescriptionKey:@"内购功能不可用"}];
        if (self.PaymentErrorBlock) {
            self.PaymentErrorBlock(paymentError);
        }
        [self resetPurchaseKit];
        return;
    }
}

- (void)restoreProductsWithCompletion:(void (^)())completion errorResponse:(void(^)(NSError *error))error
{
    self.RestoreCompletionBlock = completion;
    self.RestoreErrorBlock = error;
    
    //clear it
    self.PaymentErrorBlock = nil;
    self.PaymentCompletionBlock = nil;
    self.RequestCompletionBlock = nil;
    self.RequestErrorBlock = nil;
    
    if ([SKPaymentQueue defaultQueue]) {
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }else {
        if (self.RestoreErrorBlock) {
            NSError *restoreError = [[NSError alloc] initWithDomain:@"FRPurchaseKit" code:PurchaseErrorForbidden userInfo:@{NSLocalizedDescriptionKey:@"内购功能不可用"}];
            self.RestoreErrorBlock(restoreError);
        }
        [self resetPurchaseKit];
        return;
    }
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if(response.products.count == 0) {
        NSError *requestError = [[NSError alloc] initWithDomain:@"FRPurchaseKit" code:PurchaseErrorNoProduct userInfo:@{NSLocalizedDescriptionKey:@"产品数量为0"}];
        if(self.RequestErrorBlock) {
            self.RequestErrorBlock(requestError);
        }
        [self resetPurchaseKit];
        return;
    }
    //for (SKProduct* product in response.products) {
    //    SKMutablePayment* payment = [SKMutablePayment paymentWithProduct:product];
    //
    //}
    //for (NSString* identifiers in response.invalidProductIdentifiers) {
    //
    //}
    if (self.RequestCompletionBlock) {
        self.RequestCompletionBlock(response);
    }
    [self resetPurchaseKit];
}

#pragma mark - SKPaymentTransactionObserver
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"Purchasing");
                break;
            default:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    if (self.RestoreErrorBlock) {
        self.RestoreErrorBlock(error);
    }
    [self resetPurchaseKit];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    
    for (SKPaymentTransaction *transaction in queue.transactions) {
        
        switch (transaction.transactionState) {
            case SKPaymentTransactionStateRestored:
                break;
            default:
                break;
        }
    }
    
    if(self.RestoreCompletionBlock) {
        self.RestoreCompletionBlock();
    }
    [self resetPurchaseKit];
}

#pragma mark - PaymentQueueHandler
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    
    //[self recordTransaction: transaction];
    
    if ([SKPaymentQueue defaultQueue]) {
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
    
    if(self.PaymentCompletionBlock) {
        _PaymentCompletionBlock(transaction);
    }
    
    [self resetPurchaseKit];
    
    [self verifyPruchaseWithProductItem:transaction.payment.purchaseItem];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if ([SKPaymentQueue defaultQueue]) {
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
    
    if (_PaymentErrorBlock) {
        _PaymentErrorBlock(transaction.error);
    }
    
    [self resetPurchaseKit];
}

#pragma mark - 验证购买凭据
- (void)verifyPruchaseWithProductItem:(FRPurchaseItem *)item
{
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    
    NSError *receiptError = nil;
    BOOL isPresent = [receiptURL checkResourceIsReachableAndReturnError:&receiptError];
    if (!isPresent) {
        NSLog(@"%@",[receiptError localizedDescription]);
        return;
    }
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    if (receiptData == nil) {
        return;
    }
    
    NSURL *urlString = [NSURL URLWithString:@"<#string#>"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"response : %@", response);
    }];
    [task resume];

 
}

#pragma mark - 数据上报
- (void)logPurchaseWithUserStep:(PurchaseStep)step
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *deviceID = [self deviceUUID];
    NSString *sign = @"";
    NSString *urlString = @"";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"response : %@", response);
    }];
    [task resume];
}

- (NSString *)deviceUUID
{
    NSError *error = nil;
    NSString *uuid = [SSKeychain passwordForService:@"com.dourui.PurchaseKit" account:@"FRPurchaseKit" error:&error];
    if (uuid == nil || [error code] == SSKeychainErrorNotFound) {
        uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [SSKeychain setPassword:uuid forService:@"com.dourui.PurchaseKit" account:@"FRPurchaseKit"];
    }
    return uuid;
}

@end
