//
//  MonthReportViewController.h
//  CrossOverProject
//
//  Created by Osama Rabie on 2/16/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MonthReportViewController : UIViewController


@property(nonatomic,strong)NSString* reportType; /** @param This is used to tell what is the report type the user wants to see its decomposition. Accepted Values are : Expenses and Incomes. */
@property(nonatomic,strong)NSDictionary* monthData; /** @param This is a dictionary that contains the details and summary of the needed month by the user to be analysed.*/

@end
