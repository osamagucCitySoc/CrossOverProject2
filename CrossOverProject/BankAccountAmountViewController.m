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
    NSUserDefaults* userDefaults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initVariables];
}

/**
 This method is used to initialise the inner variables and views used by this controller.
 */

-(void)initVariables
{
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    // We need to check if the user has entered something before (Bank account amount and preffered currency) if yes, then we need to initialise the UI with those inputs
    if([userDefaults objectForKey:consBankAccountUserDefaultsKey])
    {
        // Then the user did store before some values.
        [amountTextField setText:[userDefaults objectForKey:consBankAccountUserDefaultsKey]];
    }else
    {
        // User didn't enter anything before.
        [amountTextField setText:@"0.0"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 This method is used to store the new bank account amount enetred by the user and returns back to the caller.
 */
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
        [userDefaults setObject:[NSString stringWithFormat:@"%0.3f",[enteredAmount doubleValue]] forKey:consBankAccountUserDefaultsKey];
        [userDefaults synchronize];
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
