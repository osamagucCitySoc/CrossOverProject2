//
//  CategoryChooserViewController.h
//  CrossOverProject
//
//  Created by Osama Rabie on 2/16/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManageTransactionsViewController.h"

@protocol AddRecurringTransactionDelegate <NSObject>
@optional
-(void)addRecurringTransaction:(NSString*)category;
@end


@interface CategoryChooserViewController : UIViewController<AddRecurringTransactionDelegate>

@property (nonatomic, strong) id <AddRecurringTransactionDelegate> delegate;

@end
