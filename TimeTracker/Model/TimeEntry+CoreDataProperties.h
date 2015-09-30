//
//  TimeEntry+CoreDataProperties.h
//  TimeTracker
//
//  Created by Tim Studt on 30/09/2015.
//  Copyright © 2015 Tim Studt. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TimeEntry.h"

NS_ASSUME_NONNULL_BEGIN

@interface TimeEntry (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *dateString;
@property (nullable, nonatomic, retain) NSDate *endTime;
@property (nullable, nonatomic, retain) NSString *note;
@property (nullable, nonatomic, retain) NSString *project;
@property (nullable, nonatomic, retain) NSDate *startTime;
@property (nullable, nonatomic, retain) NSString *recordId;

@end

NS_ASSUME_NONNULL_END
