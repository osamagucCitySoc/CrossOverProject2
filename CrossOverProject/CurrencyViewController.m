//
//  CurrencyViewController.m
//  CrossOverProject
//
//  Created by Osama Rabie on 2/15/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "CurrencyViewController.h"
#import "Constants.h"

@interface CurrencyViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@end

@implementation CurrencyViewController
{
    NSString* currentlySelectedCurrencyCode /** @param holds the currently selected currency code by the user or $ by default.*/;
    NSMutableArray* currencyCodesDataSource /** @param the full currency codes ISO list.*/;
    NSMutableArray* filteredCurrencyCodesDataSource;/** @param the filtered version of currency codes based on keywords entered by the user*/
    __weak IBOutlet UISearchBar *searchBar /** @param outlet of a search bar used to filter the currency codes list*/;
    __weak IBOutlet UITableView *tableVieww /** @param the table that shows the currency codes*/;
    NSUserDefaults* userDefaults/** @param Instance of the NSUserDefaults.*/;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initVariables];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [tableVieww deselectRowAtIndexPath:tableVieww.indexPathForSelectedRow animated:YES];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
/**
 This method is used to initialise the inner variables and views used by this controller.
 */

-(void)initVariables
{
    userDefaults = [NSUserDefaults standardUserDefaults];
    currentlySelectedCurrencyCode = [userDefaults objectForKey:consCurrencyUserDefaultsKey];

    
    // Get the list of currency codes and associated countries to be displayed for the user to choose from.
    NSLocale *locale = [NSLocale currentLocale];
    currencyCodesDataSource = [[NSMutableArray alloc]init];
    filteredCurrencyCodesDataSource = [[NSMutableArray alloc]init];
    
    for (NSString *code in [NSLocale ISOCurrencyCodes]) {
        @try {
            NSDictionary* currencyDict = [[NSDictionary alloc]initWithObjects:@[code,[locale displayNameForKey:NSLocaleCurrencyCode value:code]] forKeys:@[@"code",@"country"]];
            [currencyCodesDataSource addObject:currencyDict];
            [filteredCurrencyCodesDataSource addObject:currencyDict];
        }
        @catch (NSException *exception) {
            continue;
        }
    }
    [searchBar setDelegate:self];
    [tableVieww setDelegate:self];
    [tableVieww setDataSource:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitClicked:(id)sender {
    // Store the new seleceted currency and get back to the caller.
    [userDefaults setObject:currentlySelectedCurrencyCode forKey:consCurrencyUserDefaultsKey];
    [userDefaults synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark UITableViewDelegate methods

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [@"Current Symbol: " stringByAppendingString:currentlySelectedCurrencyCode];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [filteredCurrencyCodesDataSource count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // For each cell, the code and its country is displayed in an alphabaticall asc order
    static NSString* cellID = @"currencyCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    UIView *backView = [[UIView alloc] init];
    
    backView.backgroundColor = [UIColor colorWithRed:52.0/255.0 green:168.0/255.0 blue:194.0/255.0 alpha:1.0];
    
    cell.selectedBackgroundView = backView;
    
    [[cell textLabel]setText:[[filteredCurrencyCodesDataSource objectAtIndex:indexPath.row] objectForKey:@"code"]];
    [[cell detailTextLabel]setText:[[filteredCurrencyCodesDataSource objectAtIndex:indexPath.row] objectForKey:@"country"]];
    
    
    if([[[filteredCurrencyCodesDataSource objectAtIndex:indexPath.row] objectForKey:@"code"]isEqualToString:currentlySelectedCurrencyCode])
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else
    {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Change the preffered currency symbol as per the new user selection
    currentlySelectedCurrencyCode = [[filteredCurrencyCodesDataSource objectAtIndex:indexPath.row] objectForKey:@"code"];
    NSRange range = NSMakeRange(0, 1);
    NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
    [tableView reloadSections:section withRowAnimation:UITableViewRowAnimationAutomatic];

}

#pragma mark UISearchBarDelegate methods
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // Show only the currencies that has at least the code or the country name contains the entered text in the search bar.
    if(searchText.length == 0)
    {
        filteredCurrencyCodesDataSource = [[NSMutableArray alloc]initWithArray:currencyCodesDataSource];
    }else
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code contains[c] %@ OR country contains[c] %@",searchText,searchText];
        filteredCurrencyCodesDataSource = [[NSMutableArray alloc]initWithArray:[[currencyCodesDataSource filteredArrayUsingPredicate:predicate] copy]];
    }
    
    NSRange range = NSMakeRange(0, 1);
    NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
    [tableVieww reloadSections:section withRowAnimation:UITableViewRowAnimationFade];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [[self view]endEditing:YES];
}

@end
