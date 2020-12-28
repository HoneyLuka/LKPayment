//
//  SKProduct+LKPaymentHelper.m
//  LKImageInfoViewer
//
//  Created by Selina on 11/12/2020.
//  Copyright © 2020 Luka Li. All rights reserved.
//

#import "SKProduct+LKPayment.h"

@implementation SKProduct (LKPayment)

- (NSString *)lk_regularPrice
{
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.locale = self.priceLocale;
    return [formatter stringFromNumber:self.price];
}

@end
