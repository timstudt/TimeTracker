//
//  TimeEntry+CoreDataProperties.m
//  TimeTracker
//
//  Created by Tim Studt on 30/09/2015.
//  Copyright © 2015 Tim Studt. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TimeEntry+CoreDataProperties.h"

@implementation TimeEntry (CoreDataProperties)

@dynamic dateString;
@dynamic endTime;
@dynamic note;
@dynamic project;
@dynamic startTime;
@dynamic recordId;

@end
