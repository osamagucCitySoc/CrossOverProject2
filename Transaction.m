//
//  Transaction.m
//  CrossOverProject
//
//  Created by Osama Rabie on 2/15/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "Transaction.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Constants.h"

@implementation Transaction

// Insert code here to add functionality to your managed object subclass


+(NSMutableArray*)loadTransactions
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    // We need to display the total expenses and incomes for each month Then the query will get all entries for all months and then they will be grouped.
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *components = [calendar components: unitFlags fromDate: currentDate];
    int minMonth = [[NSNumber numberWithInteger:[components month]] intValue];
    int minYear  = [[NSNumber numberWithInteger:[components year]] intValue];
    int maxYear  = minYear+1;
    
    NSPredicate *transactionFilter = [NSPredicate predicateWithFormat:@"(month >= %i AND year = %i) OR (month <= %i AND year = %i)", minMonth,minYear,minMonth,maxYear];
    
    // Now we get all the saved transactions between a period of one year starting from the current month.
    NSArray* allTransactions = [Transaction MR_findAllSortedBy:@"year,month" ascending:YES withPredicate:transactionFilter inContext:[NSManagedObjectContext MR_defaultContext]];
    
    
    // Assumption is, the current bank account amount is the current amount the user has at this moment. So it will be the initial starting point value.
    float startingAmount = [[userDefaults objectForKey:consBankAccountUserDefaultsKey] floatValue];
    
    // We then need to have a data source that will have the name of each month in the coming year, total expenses in this month, total incomes in this month, the estimated balance by end of this month and the related categories.
    // First, we initialise this data source
    NSMutableArray* mainDataSource = [[NSMutableArray alloc]init];
    NSMutableDictionary* mainDataSourceHelper = [[NSMutableDictionary alloc]init];
    // Second, we fill it with dictionaries only having the name of the 12 period months with expenses, incomes and balance are set to 0
    for(int i = minMonth ; i <= 12 ; i++)
    {
        NSMutableDictionary* monthSummary = [[NSMutableDictionary alloc]initWithObjects:@[[NSString stringWithFormat:@"%i-%i",i,minYear],@(0),@(0),@(0),@(mainDataSourceHelper.count),[[NSMutableDictionary alloc] initWithObjects:@[[NSMutableDictionary dictionary],[NSMutableDictionary dictionary]] forKeys:@[@"expensesCategories",@"incomesCategories"]]] forKeys:@[@"title",@"expenses",@"incomes",@"endBalance",@"orderingKey",@"tags"]];
        [mainDataSourceHelper setValue:monthSummary forKey:[NSString stringWithFormat:@"%i-%i",i,minYear]];
    }
    for(int i = 1 ; i < minMonth ; i++)
    {
        NSMutableDictionary* monthSummary = [[NSMutableDictionary alloc]initWithObjects:@[[NSString stringWithFormat:@"%i-%i",i,maxYear],@(0),@(0),@(0),@(mainDataSourceHelper.count),[[NSMutableDictionary alloc] initWithObjects:@[[NSMutableDictionary dictionary],[NSMutableDictionary dictionary]] forKeys:@[@"expensesCategories",@"incomesCategories"]]] forKeys:@[@"title",@"expenses",@"incomes",@"endBalance",@"orderingKey",@"tags"]];
        [mainDataSourceHelper setValue:monthSummary forKey:[NSString stringWithFormat:@"%i-%i",i,maxYear]];
    }
    
    
    // Now we need to calculate for each month in the coming year what will be the expenses and the incomes and hence, the ending balance by this month. This will use the results fetched from the database above.
    if([allTransactions count]>0)
    {
        // This means, we have at least one transaction and we need to update the values (expenses and the incomes and hence, the ending balance) for each month accordingly.
        
        // First, we fill in the total expenses and incomes for each month based on the transactions stored
        for(Transaction* transaction in allTransactions)
        {
            NSString* transactionMonth = [NSString stringWithFormat:@"%i-%i",transaction.month.intValue,transaction.year.intValue];
            NSMutableDictionary* monthSummary = [mainDataSourceHelper objectForKey:transactionMonth];
            float monthSummaryExpenses = [[monthSummary objectForKey:@"expenses"] floatValue];
            float monthSummaryIncomes = [[monthSummary objectForKey:@"incomes"] floatValue];
            
            
            // Then we need to check if it is a one time event or a recurring event.
            if(transaction.recurring.intValue == 0)
            {
                // Then this is a one time event, hence, only affects its month.
                if(transaction.amount.floatValue < 0)
                {
                    // Update the expense
                    monthSummaryExpenses += transaction.amount.floatValue;
                }else
                {
                    monthSummaryIncomes += transaction.amount.floatValue;
                }
                [monthSummary setValue:@(monthSummaryExpenses) forKey:@"expenses"];
                [monthSummary setValue:@(monthSummaryIncomes) forKey:@"incomes"];
                [mainDataSourceHelper setObject:monthSummary forKey:transactionMonth];
            }else
            {
                // Then this is a recurring event and need to affect this month and all coming ones.
                int orderingKey = [[monthSummary objectForKey:@"orderingKey"] intValue];
                for(NSString* key in [mainDataSourceHelper allKeys])
                {
                    if([[[mainDataSourceHelper objectForKey:key] objectForKey:@"orderingKey"] floatValue] >= orderingKey)
                    {
                        if(transaction.amount.floatValue < 0)
                        {
                            NSLog(@"%@",[mainDataSourceHelper objectForKey:key]);
                            [[mainDataSourceHelper objectForKey:key] setValue:@([[[mainDataSourceHelper objectForKey:key] objectForKey:@"expenses"] floatValue]+transaction.amount.floatValue) forKey:@"expenses"];
                            NSLog(@"%@",[mainDataSourceHelper objectForKey:key]);
                            // Update the categories for the expense
                            float expensesForThatTag = [[[[[mainDataSourceHelper objectForKey:key] objectForKey:@"tags"] objectForKey:@"expensesCategories"] objectForKey:transaction.tag] floatValue];
                            if(expensesForThatTag)
                            {
                                expensesForThatTag += (-transaction.amount.floatValue);
                                
                                [[[[mainDataSourceHelper objectForKey:key] objectForKey:@"tags"] objectForKey:@"expensesCategories"] setObject:@(expensesForThatTag) forKey:transaction.tag];
                            }else
                            {
                                [[[[mainDataSourceHelper objectForKey:key] objectForKey:@"tags"] objectForKey:@"expensesCategories"] setObject:@(-transaction.amount.floatValue) forKey:transaction.tag];
                            }
                        }else
                        {
                            [[mainDataSourceHelper objectForKey:key] setValue:@([[[mainDataSourceHelper objectForKey:key] objectForKey:@"incomes"] floatValue]+transaction.amount.floatValue) forKey:@"expenses"];
                            // Update the categories for the expense
                            float expensesForThatTag = [[[[[mainDataSourceHelper objectForKey:key] objectForKey:@"tags"] objectForKey:@"incomesCategories"] objectForKey:transaction.tag] floatValue];
                            if(expensesForThatTag)
                            {
                                expensesForThatTag += transaction.amount.floatValue;
                                
                                [[[[mainDataSourceHelper objectForKey:key] objectForKey:@"tags"] objectForKey:@"incomesCategories"] setObject:@(expensesForThatTag) forKey:transaction.tag];
                            }else
                            {
                                [[[[mainDataSourceHelper objectForKey:key] objectForKey:@"tags"] objectForKey:@"incomesCategories"] setObject:@(transaction.amount.floatValue) forKey:transaction.tag];
                            }
                        }
                    }
                }
            }
        }
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"orderingKey"  ascending:YES];
        mainDataSource = [[NSMutableArray alloc]initWithArray:[[mainDataSourceHelper allValues] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]]];
        
        // Then we need to set the balance by the end of each month.
        for(int i = 0 ;i < mainDataSource.count ; i++)
        {
            startingAmount += [[[mainDataSource objectAtIndex:i] objectForKey:@"expenses"] floatValue];
            startingAmount += [[[mainDataSource objectAtIndex:i] objectForKey:@"incomes"] floatValue];
            [[mainDataSource objectAtIndex:i] setValue:@(startingAmount) forKey:@"endBalance"];
        }
    }else
    {
        // This means, we have no transactions stored and hence, all the values can be filled by default value with expenses = 0, incomes = 0 and total balance for each month is the starting amount.
        for(int i = 0 ;i < mainDataSource.count ; i++)
        {
            [[mainDataSource objectAtIndex:i] setValue:@(startingAmount) forKey:@"endBalance"];
        }
    }
    return mainDataSource;
}


@end
