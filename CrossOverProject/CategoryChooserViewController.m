//
//  CategoryChooserViewController.m
//  CrossOverProject
//
//  Created by Osama Rabie on 2/16/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "CategoryChooserViewController.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Tags.h"

@interface CategoryChooserViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@end

@implementation CategoryChooserViewController
{
    __weak IBOutlet UITextField *categoryTextField;
    __weak IBOutlet UITableView *tableVieww;
    NSArray* allTags;
    NSMutableArray* dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initVariables];
    // Do any additional setup after loading the view.
}

-(void)initVariables
{
    dataSource = [[NSMutableArray alloc]init];
    allTags = [Tags MR_findAllSortedBy:@"tag" ascending:YES inContext:[NSManagedObjectContext MR_defaultContext]];
    dataSource = [[NSMutableArray alloc]initWithArray:allTags];
    [tableVieww setDelegate:self];
    [tableVieww setDataSource:self];
    [categoryTextField setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)submitButtonClicked:(id)sender {
    if(categoryTextField.text.length > 0)
    {
        // Then the user entered some category. Now we need to store it and get back to the caller UIViewController
        
        // Check if the category is new to save it.
        BOOL unique = YES;
        for(Tags* tag in allTags)
        {
            if([tag.tag isEqualToString:categoryTextField.text])
            {
                unique = NO;
                break;
            }
        }
        if(unique)
        {
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                Tags* newTag = [Tags MR_createEntityInContext:localContext];
                newTag.tag = categoryTextField.text;
            } completion:^(BOOL contextDidSave, NSError *error) {
                [self dismissViewControllerAnimated:YES completion:^
                 {
                     [[self delegate]addRecurringTransaction:categoryTextField.text];
                 }];
            }];
        }else
        {
            [self dismissViewControllerAnimated:YES completion:^
             {
                 [[self delegate]addRecurringTransaction:categoryTextField.text];
             }];
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
                                 CGPointMake([categoryTextField center].x - 20.0f, [categoryTextField center].y)]];
        [animation setToValue:[NSValue valueWithCGPoint:
                               CGPointMake([categoryTextField center].x + 20.0f, [categoryTextField center].y)]];
        [[categoryTextField layer] addAnimation:animation forKey:@"position"];
        [categoryTextField becomeFirstResponder];
    }

}

#pragma mark UITableViewDelegate methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // For each cell, the code and its country is displayed in an alphabaticall asc order
    static NSString* cellID = @"tagCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    Tags* tag = [dataSource objectAtIndex:indexPath.row];
    
    [[cell textLabel]setText:tag.tag];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tags* tag = [dataSource objectAtIndex:indexPath.row];
    [categoryTextField setText:tag.tag];
    [categoryTextField resignFirstResponder];
}

#pragma mark UITextFieldDelegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString* newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if(newString.length == 0)
    {
        dataSource = [[NSMutableArray alloc]initWithArray:allTags];
    }else
    {
        dataSource = [[NSMutableArray alloc]initWithArray:allTags];
        [dataSource filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Tags* evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject.tag containsString:newString];
        }]];
    }
    
    [tableVieww reloadData];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}



@end
