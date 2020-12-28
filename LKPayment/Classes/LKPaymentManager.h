//
//  LKPaymentManager.h
//  LKImageInfoViewer
//
//  Created by Selina on 11/12/2020.
//  Copyright © 2020 Luka Li. All rights reserved.
//

#import <LKFoundation/LKFoundation.h>
#import <StoreKit/StoreKit.h>
#import "LKPaymentDefines.h"

typedef void(^LKPaymentManagerProductCallback)(NSArray<SKProduct *> *products);
typedef void(^LKPaymentManagerRestoreProcessCallback)(SKPaymentTransaction *transaction);
typedef void(^LKPaymentManagerRestoreFinishedCallback)(NSError *error, BOOL isCancelled);

typedef void(^LKPaymentManagerFinishTransactionBlock)(void);
typedef void(^LKPaymentManagerBuyCallback)(SKPaymentTransaction *transaction, NSError *error, BOOL isCancelled, LKPaymentManagerFinishTransactionBlock finishTransactionBlock);

typedef void(^LKPaymentManagerFallbackCallback)(SKPaymentTransaction *transaction);

@interface LKPaymentManager : NSObject

@property (nonatomic, assign, readonly) LKPaymentManagerStatus status;

/// must call setup when app launched, when user has unfinished transaction, fallbackHandler will be called to handle it.
- (void)setupWithFallbackHandler:(LKPaymentManagerFallbackCallback)fallbackHandler;

/// music call desetup when app terminated
- (void)desetup;

///  check if use can make payment
- (BOOL)canMakePayment;

- (void)preloadProducts:(NSArray<NSString *> *)productIds;

- (void)requestProductDataForIds:(NSArray<NSString *> *)productIds completion:(LKPaymentManagerProductCallback)completion;

- (void)restoreWithProcess:(LKPaymentManagerRestoreProcessCallback)processCallback completion:(LKPaymentManagerRestoreFinishedCallback)completion;

- (void)buy:(SKProduct *)product completion:(LKPaymentManagerBuyCallback)completion;

/// transactions can be finish automatically except purchased transaction, It's your responsibility to finish it. Call LKPaymentManagerFinishTransactionBlock in LKPaymentManagerBuyCallback or call this method directly.
- (void)finishTransaction:(SKPaymentTransaction *)transaction;

+ (instancetype)sharedManager;

@end
