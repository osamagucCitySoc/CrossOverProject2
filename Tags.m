//
//  Tags.m
//  CrossOverProject
//
//  Created by Osama Rabie on 2/15/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "Tags.h"
#import <MagicalRecord/MagicalRecord.h>

@implementation Tags

// Insert code here to add functionality to your managed object subclass


+(NSMutableArray*)loadTags
{
    return [[NSMutableArray alloc]initWithArray:[Tags MR_findAllSortedBy:@"tag" ascending:YES inContext:[NSManagedObjectContext MR_defaultContext]]];
}
+(void)storeTag:(NSString*)tag
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Tags* newTag = [Tags MR_createEntityInContext:localContext];
        newTag.tag = tag;
    } completion:^(BOOL contextDidSave, NSError *error) {}];
}
+(void)deleteTag:(Tags*)tag
{
    [tag MR_deleteEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}
+(long)countAll
{
    return [Tags countAll];
}
@end
