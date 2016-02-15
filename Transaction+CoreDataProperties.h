//
//  Transaction+CoreDataProperties.h
//  CrossOverProject
//
//  Created by Osama Rabie on 2/15/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Transaction.h"

NS_ASSUME_NONNULL_BEGIN

@interface Transaction (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *amount;
@property (nullable, nonatomic, retain) NSNumber *day;
@property (nullable, nonatomic, retain) NSNumber *month;
@property (nullable, nonatomic, retain) NSNumber *recurring;
@property (nullable, nonatomic, retain) NSString *tag;
@property (nullable, nonatomic, retain) NSNumber *year;

@end

NS_ASSUME_NONNULL_END
