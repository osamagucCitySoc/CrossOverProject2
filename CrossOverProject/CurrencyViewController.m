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
    NSString* currentlySelectedCurrencyCode;
    NSMutableArray* currencyCodesDataSource;
    NSMutableArray* filteredCurrencyCodesDataSource;
    __weak IBOutlet UISearchBar *searchBar;
    __weak IBOutlet UITableView *tableVieww;
    NSUserDefaults* userDefaults;
    __weak IBOutlet UILabel *currentlySelectedLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initVariables];
}

-(void)initVariables
{
    userDefaults = [NSUserDefaults standardUserDefaults];
    currentlySelectedCurrencyCode = [userDefaults objectForKey:consCurrencyUserDefaultsKey];
    if(!currentlySelectedCurrencyCode)
    {
        currentlySelectedCurrencyCode = @"$";
    }
    [currentlySelectedLabel setText:currentlySelectedCurrencyCode];
    
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
    [userDefaults setObject:currentlySelectedCurrencyCode forKey:consCurrencyUserDefaultsKey];
    [userDefaults synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark UITableViewDelegate methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [filteredCurrencyCodesDataSource count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellID = @"currencyCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    
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
    currentlySelectedCurrencyCode = [[filteredCurrencyCodesDataSource objectAtIndex:indexPath.row] objectForKey:@"code"];
    NSRange range = NSMakeRange(0, 1);
    NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
    [tableView reloadSections:section withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [UIView transitionWithView:currentlySelectedLabel duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [currentlySelectedLabel setText:currentlySelectedCurrencyCode];
    } completion:nil];

}

#pragma mark UISearchBarDelegate methods
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
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
