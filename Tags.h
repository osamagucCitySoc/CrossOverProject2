//
//  Tags.h
//  CrossOverProject
//
//  Created by Osama Rabie on 2/15/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Tags : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

/**
 This method is used for getting all stored tags sorted.
 @return sorted array of tags.
 */
+(NSMutableArray*)loadTags;


/**
 This method is used for storing a tag in the database.
 @param tag is the tag to be stored.
 */
+(void)storeTag:(NSString*)tag;

/**
 This method is used for deleting a tag from the database.
 @param tag is the tag to be deleted. */
+(void)deleteTag:(Tags*)tag;

/**
 This method is used only for testing purposes. It returns the number of all stored tags.
 @return number of all stored tags
 */
+(long)countAll;

@end

NS_ASSUME_NONNULL_END

#import "Tags+CoreDataProperties.h"
