//
//  BankAccountAmountViewController.m
//  CrossOverProject
//
//  Created by Osama Rabie on 2/15/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "BankAccountAmountViewController.h"
#import "Constants.h"

@interface BankAccountAmountViewController ()

@end

@implementation BankAccountAmountViewController
{
    __weak IBOutlet UISegmentedControl *minusPlusSegmentController;
    __weak IBOutlet UITextField *amountTextField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)submitButtonClicked:(id)sender {
    // First, we need to check that the user has enetred something in the bank account amount textfield
    if(amountTextField.text.length > 0)
    {
        // Then the user entered some number. Now we need to store it and get back to the caller UIViewController
        NSNumber* enteredAmount;
        if(minusPlusSegmentController.selectedSegmentIndex == 0)
        {
            // The user has a balance with positive value.
            enteredAmount = [NSNumber numberWithDouble:[amountTextField.text doubleValue]];
        }else
        {
            // The user has a balance with negative value.
             enteredAmount = [NSNumber numberWithDouble:(-[amountTextField.text doubleValue])];
        }
        [[NSUserDefaults standardUserDefaults]setObject:enteredAmount forKey:consBankAccountUserDefaultsKey];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else
    {
        // Then the user didn't enter anything, and we need to highlight that he should!
        CABasicAnimation *animation =
        [CABasicAnimation animationWithKeyPath:@"position"];
        [animation setDuration:0.10];
        [animation setRepeatCount:4];
        [animation setAutoreverses:YES];
        [animation setFromValue:[NSValue valueWithCGPoint:
                                 CGPointMake([amountTextField center].x - 20.0f, [amountTextField center].y)]];
        [animation setToValue:[NSValue valueWithCGPoint:
                               CGPointMake([amountTextField center].x + 20.0f, [amountTextField center].y)]];
        [[amountTextField layer] addAnimation:animation forKey:@"position"];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
