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
#import "Constants.h"

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

/**
 This method tends to test the functionality used in managing the expenses and incomes by the user. It tests the ability to retrive the transactions of a certain type grouped by the month of their occurence.
 */
- (void)testTransactionRetrival{
    //By doing the previous test cases, we add at least one transaction (in the category of Incomes as it is inserted with positive amounts) stored successfully. Now we test retriving transactions and deleting them. The month we will test on is 1 for 2017
    
    [Transaction storeTransaction:220 day:1 month:1 year:2017 recurring:NO category:@""];
    
    NSMutableArray* incomesTransactionsBeforeNewInsertions = [Transaction loadTransactions:@"Incomes"];
    
    int countJan2017BeforeInsertions = 0;
    for(NSDictionary* transaction in incomesTransactionsBeforeNewInsertions)
    {
        if([[transaction objectForKey:@"title"]isEqualToString:@"January/2017"])
        {
            countJan2017BeforeInsertions+= [[transaction objectForKey:@"transactions"] count];;
        }
    }
    
    [Transaction storeTransaction:160 day:1 month:1 year:2017 recurring:NO category:@""];
    
    NSMutableArray* incomesTransactionsAfterNewInsertions = [Transaction loadTransactions:@"Incomes"];
    
    int countJan2017AfterInsertions = 0;
    for(NSDictionary* transaction in incomesTransactionsAfterNewInsertions)
    {
        if([[transaction objectForKey:@"title"]isEqualToString:@"January/2017"])
        {
            countJan2017AfterInsertions += [[transaction objectForKey:@"transactions"] count];
        }
    }

    XCTAssertEqual(countJan2017AfterInsertions,countJan2017BeforeInsertions+1,@"Error in loading transactions with a certain type");
    
    
    [Transaction storeTransaction:-120 day:1 month:1 year:2017 recurring:NO category:@""];
    
    NSMutableArray* incomesTransactionsAfterNonRelevantNewInsertions = [Transaction loadTransactions:@"Incomes"];
    
    
    
    int countJan2017AfterNonRelevantInsertions = 0;
    for(NSDictionary* transaction in incomesTransactionsAfterNonRelevantNewInsertions)
    {
        if([[transaction objectForKey:@"title"]isEqualToString:@"January/2017"])
        {
            countJan2017AfterNonRelevantInsertions+= [[transaction objectForKey:@"transactions"] count];;
        }
    }
    
    XCTAssertEqual(countJan2017AfterInsertions,countJan2017AfterNonRelevantInsertions,@"Error in loading transactions with a certain type");
}
@end
