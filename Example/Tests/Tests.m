//
//  LKPaymentTests.m
//  LKPaymentTests
//
//  Created by Luka on 12/28/2020.
//  Copyright (c) 2020 Luka. All rights reserved.
//

@import XCTest;
#import <LKPayment/LKPayment.h>

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//- (void)testExample
//{
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
//}

- (void)testErrorLog
{
    LKPaymentErrorLog(@"test %@ log", @"error");
}

- (void)testInfoLog
{
    LKPaymentInfoLog(@"test info log");
}

@end

