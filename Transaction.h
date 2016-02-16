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
 This method is used to generate the report detailing for an upcoming year. Where each NSMutableDicrionary entry will include : The name of the month, the total expenses by this month, the total incomes by this month, the end balance for this month and the categories where the expenses and the incomes are falling into.
 */
+(NSMutableArray*)loadTransactions;


@end

NS_ASSUME_NONNULL_END

#import "Transaction+CoreDataProperties.h"
