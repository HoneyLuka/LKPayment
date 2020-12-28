//
//  LKPaymentManager.m
//  LKImageInfoViewer
//
//  Created by Selina on 11/12/2020.
//  Copyright © 2020 Luka Li. All rights reserved.
//

#import "LKPaymentManager.h"

@interface LKPaymentManager () <SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (nonatomic, assign) LKPaymentManagerStatus status;

@property (nonatomic, strong) SKProductsRequest *preloadRequest;

@property (nonatomic, strong) SKProductsRequest *productRequest;
@property (nonatomic, copy) LKPaymentManagerProductCallback productCallback;

@property (nonatomic, copy) LKPaymentManagerRestoreProcessCallback restoreProcessCallback;
@property (nonatomic, copy) LKPaymentManagerRestoreFinishedCallback restoreCompletionCallback;

@property (nonatomic, copy) LKPaymentManagerBuyCallback buyCallback;

@property (nonatomic, copy) LKPaymentManagerFallbackCallback fallbackCallback;

@end

@implementation LKPaymentManager

+ (instancetype)sharedManager
{
    static LKPaymentManager *sManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sManager = [LKPaymentManager new];
    });
    return sManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addNotification];
    }
    return self;
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(desetup)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
}

- (void)setupWithFallbackHandler:(LKPaymentManagerFallbackCallback)fallbackHandler
{
    NSAssert(fallbackHandler != nil, @"fallbackHandler must not be nil");
    
    self.fallbackCallback = fallbackHandler;
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)desetup
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (BOOL)canMakePayment
{
    return [SKPaymentQueue canMakePayments];
}

#pragma mark - Request Product

- (void)preloadProducts:(NSArray<NSString *> *)productIds
{
    if (!productIds.count) {
        return;
    }
    
    if (![self canMakePayment]) {
        return;
    }
    
    self.preloadRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIds]];
    [self.productRequest start];
}

- (void)requestProductDataForIds:(NSArray<NSString *> *)productIds completion:(LKPaymentManagerProductCallback)completion
{
    if (![self canMakePayment]) {
        LK_SAFE_BLOCK(completion, nil);
        return;
    }
    
    if (!productIds.count) {
        LK_SAFE_BLOCK(completion, nil);
        return;
    }
    
    self.status = LKPaymentManagerStatusProductRequesting;
    
    self.productCallback = completion;
    self.productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIds]];
    self.productRequest.delegate = self;
    [self.productRequest start];
}

#pragma mark SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if (self.productRequest != request) {
        return;
    }
    
    if (response.invalidProductIdentifiers.count) {
        LKPaymentWarningLog(@"response.invalidProductIdentifiers is not empty");
    }
    
    self.status = LKPaymentManagerStatusIdle;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        LK_SAFE_BLOCK(self.productCallback, response.products);
        self.productRequest = nil;
        self.productCallback = nil;
    });
}

#pragma mark - Restore

- (void)restoreWithProcess:(LKPaymentManagerRestoreProcessCallback)processCallback completion:(LKPaymentManagerRestoreFinishedCallback)completion
{
    self.status = LKPaymentManagerStatusRestoring;
    self.restoreProcessCallback = processCallback;
    self.restoreCompletionCallback = completion;
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    if (error.code != SKErrorPaymentCancelled) {
        LKPaymentErrorLog(@"Restore failed, info: %@", error.localizedDescription);
    }
    
    self.status = LKPaymentManagerStatusIdle;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        LK_SAFE_BLOCK(self.restoreCompletionCallback, error, error.code == SKErrorPaymentCancelled);
        self.restoreProcessCallback = nil;
        self.restoreCompletionCallback = nil;
    });
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    LKPaymentInfoLog(@"All restorable transactions have been processed by the payment queue.");
    
    self.status = LKPaymentManagerStatusIdle;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        LK_SAFE_BLOCK(self.restoreCompletionCallback, nil, NO);
        self.restoreProcessCallback = nil;
        self.restoreCompletionCallback = nil;
    });
}

#pragma mark - Buy

- (void)buy:(SKProduct *)product completion:(LKPaymentManagerBuyCallback)completion
{
    self.status = LKPaymentManagerStatusBuying;
    self.buyCallback = completion;
    
    SKMutablePayment *payments = [SKMutablePayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payments];
}

- (void)finishTransaction:(SKPaymentTransaction *)transaction
{
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    for(SKPaymentTransaction *transaction in transactions) {
        LKPaymentInfoLog(@"%@ removed from queue", transaction.payment.productIdentifier);
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    for(SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
            {
                LKPaymentInfoLog(@"%@ Purchasing", transaction.payment.productIdentifier);
            }
                break;
            case SKPaymentTransactionStateDeferred:
            {
                LKPaymentInfoLog(@"%@ Deferred", transaction.payment.productIdentifier);
            }
                break;
            case SKPaymentTransactionStatePurchased:
            {
                LKPaymentInfoLog(@"%@ Purchased", transaction.payment.productIdentifier);
                [self handleSuccessTransaction:transaction];
            }
                break;
            case SKPaymentTransactionStateFailed:
            {
                if (transaction.error.code == SKErrorPaymentCancelled) {
                    LKPaymentInfoLog(@"%@ Cancelled", transaction.payment.productIdentifier);
                } else {
                    LKPaymentErrorLog(@"%@ Failed, info: %@", transaction.payment.productIdentifier, transaction.error);
                }
                
                [self handleFailedTransaction:transaction error:transaction.error];
            }
                break;
            case SKPaymentTransactionStateRestored:
            {
                LKPaymentInfoLog(@"%@ Restored", transaction.payment.productIdentifier);
                [self handleRestoredTransaction:transaction];
            }
                break;
            default:
                break;
        }
    }
}

- (void)handleSuccessTransaction:(SKPaymentTransaction *)transaction
{
    if (self.status == LKPaymentManagerStatusIdle) {
        LK_SAFE_BLOCK(self.fallbackCallback, transaction);
        return;
    }
    
    self.status = LKPaymentManagerStatusIdle;
    
    LKPaymentManagerFinishTransactionBlock block = ^() {
        [self finishTransaction:transaction];
    };
    
    LK_SAFE_BLOCK(self.buyCallback, transaction, transaction.error, transaction.error.code == SKErrorPaymentCancelled, block);
    self.buyCallback = nil;
}

- (void)handleFailedTransaction:(SKPaymentTransaction *)transaction error:(NSError *)error
{
    self.status = LKPaymentManagerStatusIdle;
    LK_SAFE_BLOCK(self.buyCallback, transaction, error, error.code == SKErrorPaymentCancelled, nil);
    self.buyCallback = nil;
    
    [self finishTransaction:transaction];
}

- (void)handleRestoredTransaction:(SKPaymentTransaction *)transaction
{
    LK_SAFE_BLOCK(self.restoreProcessCallback, transaction);
    [self finishTransaction:transaction];
}

@end
