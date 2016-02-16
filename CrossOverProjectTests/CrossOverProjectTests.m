//
//  CrossOverProjectTests.m
//  CrossOverProjectTests
//
//  Created by Osama Rabie on 2/16/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Transaction.h"
#import "Tags.h"

@interface CrossOverProjectTests : XCTestCase

@end

@implementation CrossOverProjectTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTransactionInsertion {
    // We will count the current transactions and then we insert a new one and get the count again and check that it had increased by 1.
    
    long countBeforeInsertion = [Transaction countAll];
    [Transaction storeTransaction:120 day:1 month:1 year:2017 recurring:NO category:@""];
    long countAfterInsertion = [Transaction countAll];
    
    XCTAssertEqual(countBeforeInsertion+1, countAfterInsertion,@"The storing is not working for Transaction core entitiy");
    
}

- (void)testTagInsertion {
    // We will count the current transactions and then we insert a new one and get the count again and check that it had increased by 1.
    
    long countBeforeInsertion = [Tags countAll];
    [Tags storeTag:@"tagTesting"];
    long countAfterInsertion = [Tags countAll];
    XCTAssertEqual(countBeforeInsertion+1, countAfterInsertion,@"The storing is not working for Tags core entitiy");
}

@end
