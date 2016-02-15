//
//  ViewController.m
//  CrossOverProject
//
//  Created by Osama Rabie on 2/15/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "ViewController.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Constants.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation ViewController
{
    NSUserDefaults* userDefaults;
    __weak IBOutlet UILabel *currentBankAccountAmountLabel;
    __weak IBOutlet UITableView *tableVieww;
    NSArray* optionsDataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initVariables];
    [self initialiseTheBankAccount];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIView transitionWithView:currentBankAccountAmountLabel duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        NSString* currentAmount;
        if(![userDefaults objectForKey:consBankAccountUserDefaultsKey])
        {
            currentAmount = @"0.000";
        }else
        {
            currentAmount = [userDefaults objectForKey:consBankAccountUserDefaultsKey];
        }
        currentBankAccountAmountLabel.text = [NSString stringWithFormat:@"%@ %@",currentAmount,@"$"];
    } completion:nil];
}



-(void)initVariables
{
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary* manageOptions = [[NSDictionary alloc]initWithObjects:@[@"Manage your wallet",@[@"Manage your account amount",@"Manage your currency symbol",@"Manage your expenses",@"Manage your income"]] forKeys:@[@"title",@"options"]];
     NSDictionary* reportOptions = [[NSDictionary alloc]initWithObjects:@[@"Analyse your wallet",@[@"Balance per month",@"Expenses by end of each month"]] forKeys:@[@"title",@"options"]];
    optionsDataSource = [[NSArray alloc]initWithObjects:manageOptions,reportOptions, nil];
    [tableVieww setDelegate:self];
    [tableVieww setDataSource:self];
}

-(void)initialiseTheBankAccount
{
    // First, check if this is the first launch for the app, hence show the popup controller for adjusting the initial amount in the bank account.
    // The value of the bank account amount entered by the user will be simply stored inside the NSUserDefaults
    if(![userDefaults objectForKey:consBankAccountUserDefaultsKey])
    {
        // This means that the user never setteled the bank account amount, hence he needs to initially put the amount he has at the moment.
        [self performSegueWithIdentifier:@"enterBankAccountAmountSeg" sender:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UITableViewDelegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [optionsDataSource count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[optionsDataSource objectAtIndex:section] objectForKey:@"options"] count];
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[optionsDataSource objectAtIndex:section] objectForKey:@"title"];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellID = @"optionsCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    [[cell textLabel]setText:[[[optionsDataSource objectAtIndex:indexPath.section] objectForKey:@"options"] objectAtIndex:indexPath.row]];
    
    return cell;
}



@end
