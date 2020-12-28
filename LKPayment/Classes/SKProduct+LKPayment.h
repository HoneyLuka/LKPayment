//
//  SKProduct+LKPaymentHelper.h
//  LKImageInfoViewer
//
//  Created by Selina on 11/12/2020.
//  Copyright © 2020 Luka Li. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@interface SKProduct (LKPayment)

- (NSString *)lk_regularPrice;

@end
