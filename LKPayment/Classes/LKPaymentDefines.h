//
//  LKPaymentDefines.h
//  LKPayment
//
//  Created by Selina on 25/12/2020.
//

#ifndef LKPaymentDefines_h
#define LKPaymentDefines_h

#define LKPaymentLog(fmt, ...) NSLog((@"LKPayment: " fmt), ##__VA_ARGS__)

typedef NS_ENUM(NSUInteger, LKPaymentManagerStatus) {
    LKPaymentManagerStatusIdle,
    LKPaymentManagerStatusProductRequesting,
    LKPaymentManagerStatusBuying,
    LKPaymentManagerStatusRestoring,
};

#endif /* LKPaymentDefines_h */
