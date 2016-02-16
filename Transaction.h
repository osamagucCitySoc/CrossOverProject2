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

@end

NS_ASSUME_NONNULL_END

#import "Transaction+CoreDataProperties.h"
