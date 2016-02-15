//
//  ManageTransactionsTableViewController.m
//  CrossOverProject
//
//  Created by Osama Rabie on 2/15/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "ManageTransactionsViewController.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Transaction.h"
#import "Constants.h"
#import "JTMaterialSwitch.h"
#import "CategoryChooserViewController.h"

@interface ManageTransactionsViewController ()<UITableViewDataSource,UITableViewDelegate,AddRecurringTransactionDelegate>

@end

@implementation ManageTransactionsViewController
{
    IBOutlet UIBarButtonItem *addButton;
    NSMutableArray* dataSource;
    NSArray* monthNames;
    __weak IBOutlet UITableView *tableVieww;
    __weak IBOutlet UIView *addTransactionView;
    IBOutlet UIBarButtonItem *cancelButton;
    __weak IBOutlet UITextField *newTransactionAmountTextField;
    __weak IBOutlet UIDatePicker *newTransactionDatePicker;
    __weak IBOutlet UISegmentedControl *newTransactionTypeSegment;
    __weak IBOutlet UILabel *newTransactionDateHintLabel;
    __weak IBOutlet UIButton *newTransactionSubmitButton;
    NSUserDefaults* userDefaults;
}

@synthesize transactionType;



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier]isEqualToString:@"categorySeg"])
    {
        CategoryChooserViewController* dst = (CategoryChooserViewController*)[segue destinationViewController];
        [dst setDelegate:self];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [addTransactionView setAlpha:0.0];
    [self initVariables];
}

-(void)initVariables
{
    
    // We create a list of the months names
    monthNames = @[@"January",@"February",@"March",@"April",@"May",@"June",@"July",@"August",@"September",@"October",@"November",@"December"];
    [self loadTransactions];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    [newTransactionDatePicker setMinimumDate:[NSDate date]];
    [newTransactionDatePicker setDate:[NSDate date] animated:YES];
    
    [self setTitle:transactionType];
    
    [tableVieww setDelegate:self];
    [tableVieww setDataSource:self];
}

-(void)loadTransactions
{
    // We first get all the transactions exepnses or incomes depending on the type ordered by the month and then the day.
    dataSource = [[NSMutableArray alloc]init];
    NSPredicate *transactionFilter;
    if([transactionType isEqualToString:@"Expenses"])
    {
         transactionFilter = [NSPredicate predicateWithFormat:@"amount < %i", 0];
    }else
    {
        transactionFilter  = [NSPredicate predicateWithFormat:@"amount > %i", 0];
    }
    NSArray* allTransactions = [Transaction MR_findAllSortedBy:@"year,month,day" ascending:YES withPredicate:transactionFilter inContext:[NSManagedObjectContext MR_defaultContext]];
    // Then we create a grouping based on the month so we show them more elegant in the table view summary grouped by the month
    if([allTransactions count]>0)
    {
        NSString* currentMonth = @"";
        NSMutableArray* transactionForAMonth = [[NSMutableArray alloc]init];
        
        for(Transaction* transaction in allTransactions)
        {
            NSString* transactionMonth = [NSString stringWithFormat:@"%@/%@",[monthNames objectAtIndex:transaction.month.intValue-1],transaction.year];
            
            if(![currentMonth isEqualToString:transactionMonth])
            {
                if(transactionForAMonth.count > 0)
                {
                    // We had grapped all the transactions for the previous month, so we need to add them as one entity to the data source.
                    NSDictionary* transactionsGroupByMonth = [[NSDictionary alloc]initWithObjects:@[currentMonth,transactionForAMonth] forKeys:@[@"title",@"transactions"]];
                    [dataSource addObject:transactionsGroupByMonth];
                    transactionForAMonth = [[NSMutableArray alloc]init];
                }
                currentMonth = transactionMonth;
            }
            [transactionForAMonth addObject:transaction];
        }
        
        if(transactionForAMonth.count > 0)
        {
            // Add any non-added values
            NSDictionary* transactionsGroupByMonth = [[NSDictionary alloc]initWithObjects:@[currentMonth,transactionForAMonth] forKeys:@[@"title",@"transactions"]];
            [dataSource addObject:transactionsGroupByMonth];
            transactionForAMonth = [[NSMutableArray alloc]init];
        }
    }
    [tableVieww reloadData];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Adding the add button on the top right
    [self.navigationItem setRightBarButtonItem:addButton animated:YES];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[dataSource objectAtIndex:section] objectForKey:@"transactions"] count];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[dataSource objectAtIndex:section] objectForKey:@"title"];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellID = @"transactionsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    Transaction* transaction = [[[dataSource objectAtIndex:indexPath.section] objectForKey:@"transactions"] objectAtIndex:indexPath.row];
    
    
    [[(UILabel*)cell viewWithTag:1]setText:[NSString stringWithFormat:@"%0.3f %@",transaction.amount.doubleValue,[userDefaults objectForKey:consCurrencyUserDefaultsKey]]];

    JTMaterialSwitch* recurringSwitch;
    
    if([cell viewWithTag:5])
    {
        recurringSwitch = [(JTMaterialSwitch*)cell viewWithTag:5];
    }else
    {
        recurringSwitch = [[JTMaterialSwitch alloc]initWithSize:JTMaterialSwitchSizeSmall style:JTMaterialSwitchStyleDefault state:JTMaterialSwitchStateOff];
        [recurringSwitch setTag:5];
        [[(UIView*)cell viewWithTag:4] addSubview:recurringSwitch];
    }
    [recurringSwitch setEnabled:NO];
    
    if(transaction.recurring.intValue == 0)
    {
        [[(UILabel*)cell viewWithTag:2]setText:[NSString stringWithFormat:@"Occuring on : %i/%@/%i",transaction.day.intValue,[monthNames objectAtIndex:(transaction.month.intValue-1)],transaction.year.intValue]];
        [[(UILabel*)cell viewWithTag:3]setText:@"No assigned category"];
        [recurringSwitch setOn:NO animated:YES];
    }else
    {
        [[(UILabel*)cell viewWithTag:2]setText:[NSString stringWithFormat:@"Starting from : %i/%@/%i",transaction.day.intValue,[monthNames objectAtIndex:(transaction.month.intValue-1)],transaction.year.intValue]];
        [[(UILabel*)cell viewWithTag:3]setText:transaction.tag];
        [recurringSwitch setOn:YES animated:YES];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 112.0f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Transaction* transaction =[[[dataSource objectAtIndex:indexPath.section] objectForKey:@"transactions"] objectAtIndex:indexPath.row];
        [transaction MR_deleteEntityInContext:[NSManagedObjectContext MR_defaultContext]];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [[[dataSource objectAtIndex:indexPath.section] objectForKey:@"transactions"] removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)addButtonClicked:(id)sender {
    [newTransactionDateHintLabel setText:@"Occuring on:"];
    [newTransactionSubmitButton setTitle:@"Submit" forState:UIControlStateNormal];
    [newTransactionAmountTextField setText:@""];
    [newTransactionDatePicker setDate:[NSDate date]];
    
    [UIView animateWithDuration:2.0f animations:^{
        
        [addTransactionView setAlpha:1.0f];
        [self.navigationItem setRightBarButtonItem:cancelButton animated:YES];
    } completion:^(BOOL finished) {
    }];
}
- (IBAction)cancelButtonClicked:(id)sender {
    
    [UIView animateWithDuration:2.0f animations:^{
        
        [addTransactionView setAlpha:0.0f];
        [self.navigationItem setRightBarButtonItem:addButton animated:YES];
    } completion:^(BOOL finished) {
        
    }];
}
- (IBAction)submitNewTransactionClicked:(id)sender {
    if(newTransactionAmountTextField.text.length>0)
    {
        // The saving logic will differ based on the type whether recurring or one time
        if([newTransactionTypeSegment selectedSegmentIndex] == 0)
        {
            // It is a one time event, then no more data needed to be added by the user and we are ready to store
            [self addTransaction:0 category:@""];
        }else
        {
            // It is a recurring event, then we need one more step, which is defining the category for the recurring event.'
            [self performSegueWithIdentifier:@"categorySeg" sender:self];
        }
    }else
    {
        // Then the user didn't enter anything, and we need to highlight that he should!
        CABasicAnimation *animation =
        [CABasicAnimation animationWithKeyPath:@"position"];
        [animation setDuration:0.10];
        [animation setRepeatCount:4];
        [animation setAutoreverses:YES];
        [animation setFromValue:[NSValue valueWithCGPoint:
                                 CGPointMake([newTransactionAmountTextField center].x - 20.0f, [newTransactionAmountTextField center].y)]];
        [animation setToValue:[NSValue valueWithCGPoint:
                               CGPointMake([newTransactionAmountTextField center].x + 20.0f, [newTransactionAmountTextField center].y)]];
        [[newTransactionAmountTextField layer] addAnimation:animation forKey:@"position"];
    }
}
- (IBAction)newTransactionTypeSegmentChanged:(id)sender {
    // Change the adding of a new transaction logic based on the type whether recurring or one time
    if([newTransactionTypeSegment selectedSegmentIndex] == 0)
    {
        // It is a one time event
        [UIView transitionWithView:newTransactionDateHintLabel duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [newTransactionDateHintLabel setText:@"Occuring on:"];
            [newTransactionSubmitButton setTitle:@"Submit" forState:UIControlStateNormal];
        } completion:nil];
    }else
    {
        // It is a recurring event
        [UIView transitionWithView:newTransactionDateHintLabel duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [newTransactionDateHintLabel setText:@"Starting from:"];
            [newTransactionSubmitButton setTitle:@"Choose category" forState:UIControlStateNormal];
        } completion:nil];

    }
}

-(void)addTransaction:(int)type category:(NSString*)category
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Transaction* newTransaction = [Transaction MR_createEntityInContext:localContext];
        // The amount will be - or + based on the current type of the transactions (if the user chose to see the exepenses or the incomings
        if([transactionType isEqualToString:@"Expenses"])
        {
            newTransaction.amount = [NSNumber numberWithDouble:(-newTransactionAmountTextField.text.doubleValue)];
        }else
        {
            newTransaction.amount = [NSNumber numberWithDouble:newTransactionAmountTextField.text.doubleValue];
        }
        NSDate *dateFromPicker = [newTransactionDatePicker date];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
        unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        NSDateComponents *components = [calendar components: unitFlags fromDate: dateFromPicker];
        
        newTransaction.day = [NSNumber numberWithInteger:[components day]];
        newTransaction.month = [NSNumber numberWithInteger:[components month]];
        newTransaction.year = [NSNumber numberWithInteger:[components year]];
        newTransaction.recurring = [NSNumber numberWithInt:type];
        newTransaction.tag = category;
    
    } completion:^(BOOL contextDidSave, NSError *error) {
        [self cancelButtonClicked:nil];
        [self loadTransactions];
    }];
}


-(void)addRecurringTransaction:(NSString*)category
{
    [self addTransaction:1 category:category];
}

@end
