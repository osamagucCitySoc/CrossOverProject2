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
/**
 This method is used to inform the caller, what category did the user enters. So the caller can then complete the storing procedure.
 @param the entered category by the user.
 */
-(void)addRecurringTransaction:(NSString*)category;
@end


@interface CategoryChooserViewController : UIViewController<AddRecurringTransactionDelegate>

@property (nonatomic, strong) id <AddRecurringTransactionDelegate> delegate; /** @param this is the delegate instance.*/

@end
