//
//  ManageTransactionsTableViewController.h
//  CrossOverProject
//
//  Created by Osama Rabie on 2/15/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface ManageTransactionsViewController : UIViewController

@property(nonatomic,strong)NSString* transactionType; /** @param transactioType is a NSString that tells the instance which transactions types the user wants to manage. The accepted values are : Expenses or Incomes.*/




@end
