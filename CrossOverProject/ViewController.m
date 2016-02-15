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
#import "ManageTransactionsViewController.h"


@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation ViewController
{
    NSUserDefaults* userDefaults;
    __weak IBOutlet UILabel *currentBankAccountAmountLabel;
    __weak IBOutlet UITableView *tableVieww;
    NSArray* optionsDataSource;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier]isEqualToString:@"expensesSeg"])
    {
        ManageTransactionsViewController* dst = (ManageTransactionsViewController*)[segue destinationViewController];
        [dst setTransactionType:@"Expenses"];
        
    }else if([[segue identifier]isEqualToString:@"incomeSeg"])
    {
        ManageTransactionsViewController* dst = (ManageTransactionsViewController*)[segue destinationViewController];
        [dst setTransactionType:@"Incomes"];
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initVariables];
    [self initialiseTheBankAccount];
}

-(void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:animated];
    // Each time the homepage appears, we need to update the current bank amount and preferred currency. // Default is 0.000 $
    [UIView transitionWithView:currentBankAccountAmountLabel duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        NSString* currentAmount = [userDefaults objectForKey:consBankAccountUserDefaultsKey];
        NSString* currentCurrencySymbol = [userDefaults objectForKey:consCurrencyUserDefaultsKey];
        
        if(!currentAmount)
        {
            currentAmount = @"0.000";
        }
        if(!currentCurrencySymbol)
        {
            currentCurrencySymbol = @"$";
        }
        currentBankAccountAmountLabel.text = [NSString stringWithFormat:@"%@ %@",currentAmount,currentCurrencySymbol];
    } completion:nil];
}



-(void)initVariables
{
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    // Those are the list of different options that the user can play with.
    NSDictionary* manageOptions = [[NSDictionary alloc]initWithObjects:@[@"Manage your wallet",@[@"Manage your account amount",@"Manage your currency symbol",@"Manage your expenses",@"Manage your income"]] forKeys:@[@"title",@"options"]];
     NSDictionary* reportOptions = [[NSDictionary alloc]initWithObjects:@[@"Analyse your wallet",@[@"Balance per month",@"Expenses per month",@"Income per month"]] forKeys:@[@"title",@"options"]];
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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The user selected a certain option, and we need to deal accordingly.
    if(indexPath.section == 0)
    {
        // The user chose a managing option
        if(indexPath.row == 0)
        {
            // The user wants to change his bank account amount.
            [self performSegueWithIdentifier:@"enterBankAccountAmountSeg" sender:self];
        }else if(indexPath.row == 1)
        {
            // The user wants to change his preferred currency symbol.
            [self performSegueWithIdentifier:@"enterCurrencySeg" sender:self];
        }else if(indexPath.row == 2)
        {
            // The user wants to manage his expenses.
            [self performSegueWithIdentifier:@"expensesSeg" sender:self];
        }else if(indexPath.row == 3)
        {
            // The user wants to manage his expenses.
            [self performSegueWithIdentifier:@"incomeSeg" sender:self];
        }

    }else if(indexPath.section == 1)
    {
        // The user chose a reporting option
        if(indexPath.row == 0)
        {
            
        }
    }
}



@end
