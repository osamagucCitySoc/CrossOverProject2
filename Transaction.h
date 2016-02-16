//
//  Transaction.h
//  CrossOverProject
//
//  Created by Osama Rabie on 2/15/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Transaction : NSManagedObject

// Insert code here to declare functionality of your managed object subclass


/**
 This method is used to generate the report detailing for an a given period. Where each NSMutableDicrionary entry will include : The name of the month, the total expenses by this month, the total incomes by this month, the end balance for this month and the categories where the expenses and the incomes are falling into.
 @param minMonth the starting month of the period.
 @param minYear the starting year of the period.
 @param maxMonth the ending month of the period.
 @param maxYear the ending year of the period.
 @return sorted based on year,month Array of NSMutableDictionaries, where each dictionary contains the information about a month in the selected period
 */
+(NSMutableArray*)loadTransactions:(int)minMonth minYear:(int)minYear maxMonth:(int)maxMonth maxYear:(int)maxYear;


/**
 This method is used to fetch all the transactions of a certain type.
 @param transactionType decides which transactions should be fetched. Accepted values are : Expenses and Incomes
 @return  sorted based on year,month,year Array of NSMutableDictionaries, where each dictionary contains the information about each transaction, its date, its value and whether it is recurring or not.
 */
+(NSMutableArray*)loadTransactions:(NSString*)transactionType;

/**
 This method is used for storing a transaction in the database.
 @param amount is the amount of this expens/income.
 @param day is the day component of the transaction date.
 @param month is the month component of the transaction date.
 @param year is the year component of the transaction date.
 @param recurring whether this transaction is a repeated monthly or not.
 @param category is the category of the transaction. nothing is the default of not recurring.
 */
+(void)storeTransaction:(float)amount day:(int)day month:(int)month year:(int)year recurring:(BOOL)recurring category:(NSString*)category;

/**
 This method is used for deleting a transaction from the database.
 @param transaction is the transaction to be deleted. */
+(void)deleteTransaction:(Transaction*)transaction;

/**
 This method is used only for testing purposes. It returns the number of all stored transactions.
 @return number of all stored transactions
 */
+(long)countAll;

@end

NS_ASSUME_NONNULL_END

#import "Transaction+CoreDataProperties.h"
