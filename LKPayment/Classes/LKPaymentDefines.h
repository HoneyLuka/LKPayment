//
//  LKPaymentDefines.h
//  LKPayment
//
//  Created by Selina on 25/12/2020.
//

#ifndef LKPaymentDefines_h
#define LKPaymentDefines_h

#define LKPaymentInfoLog(fmt, ...) LKLogInfo(@"LKPayment", nil, fmt, ##__VA_ARGS__)
#define LKPaymentWarningLog(fmt, ...) LKLogWarning(@"LKPayment", nil, fmt, ##__VA_ARGS__)
#define LKPaymentErrorLog(fmt, ...) LKLogError(@"LKPayment", nil, fmt, ##__VA_ARGS__)

typedef NS_ENUM(NSUInteger, LKPaymentManagerStatus) {
    LKPaymentManagerStatusIdle,
    LKPaymentManagerStatusProductRequesting,
    LKPaymentManagerStatusBuying,
    LKPaymentManagerStatusRestoring,
};

#endif /* LKPaymentDefines_h */
