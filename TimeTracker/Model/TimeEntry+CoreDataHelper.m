//
//  TimeEntry+CoreDataHelper.m
//  TimeTracker
//
//  Created by Tim Studt on 26/04/15.
//  Copyright (c) 2015 Tim Studt. All rights reserved.
//

#import "TimeEntry+CoreDataHelper.h"
#import "NSDate+Helpers.h"

@implementation TimeEntry (CoreDataHelper)

#pragma mark - public class functions

+ (NSPredicate *)predicateWithDateSting:(NSString *)date{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(dateString = %@)", date];
    return predicate;
    
}

+ (NSPredicate *)predicateWithDate:(NSDate *)date{
    
    return [self.class predicateWithStartDate:[date startOfDay] endDate:[date endOfDay]];
    
}

+ (NSPredicate *)predicateWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate{

    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date BETWEEN %@", @[startDate, endDate]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date <= %@)", startDate, endDate];
    return predicate;
    
}

+ (NSArray *)findTimeEntriesWithDateString:(NSString *)date inContext:(NSManagedObjectContext *)context
{
    
    NSPredicate *predicate = [self.class predicateWithDateSting:date];
    NSSortDescriptor *sortDescriptorDate = [NSSortDescriptor sortDescriptorWithKey:kTimeEntryAttributeDateString ascending:NO];
    NSSortDescriptor *sortDescriptorTime = [NSSortDescriptor sortDescriptorWithKey:kTimeEntryAttributeStartTime ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptorDate, sortDescriptorTime];
    return [self findTimeEntriesWithAttribute:kTimeEntryAttributeDateString predicate:predicate sortDescriptors:sortDescriptors inContext:context];

}

+ (NSArray *)findTimeEntriesWithDate:(NSDate *)date inContext:(NSManagedObjectContext *)context
{

    NSPredicate *predicate = [self.class predicateWithDate:date];
    NSSortDescriptor *sortDescriptorDate = [NSSortDescriptor sortDescriptorWithKey:kTimeEntryAttributeDateString ascending:YES];
    NSSortDescriptor *sortDescriptorTime = [NSSortDescriptor sortDescriptorWithKey:kTimeEntryAttributeStartTime ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptorDate, sortDescriptorTime];
    return [self findTimeEntriesWithAttribute:kTimeEntryAttributeDateString predicate:predicate sortDescriptors:sortDescriptors inContext:context];

}

+ (NSArray *)findTimeEntriesWithAttribute:(NSString *)attribute predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context
{

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kTimeEntryEntityName];
    request.predicate = predicate;

    request.sortDescriptors = sortDescriptors;

    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"%s: ERROR: %@", __FUNCTION__, error.debugDescription);
        abort();
    }
    return matches;
    
}

+ (NSUInteger)countTimeEntriesWithDateString:(NSString *)date inContext:(NSManagedObjectContext *)context
{
    
    NSPredicate *predicate = [self.class predicateWithDateSting:date];
    return [self countTimeEntriesWithAttribute:kTimeEntryAttributeDateString predicate:predicate inContext:context];
    
}

+ (NSUInteger)countTimeEntriesWithAttribute:(NSString *)attribute predicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kTimeEntryEntityName];
    request.predicate = predicate;
    
    NSError *error = nil;
    NSUInteger matches = [context countForFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"%s: ERROR: %@", __FUNCTION__, error.debugDescription);
        abort();
    }
    return matches;
    
}

+ (TimeEntry *)newTimeEntryInContext:(NSManagedObjectContext *)context{
    
    NSEntityDescription *dateEntryEntity = [NSEntityDescription entityForName:kTimeEntryEntityName
                                                     inManagedObjectContext:context];
   return [[TimeEntry alloc] initWithEntity:dateEntryEntity
             insertIntoManagedObjectContext:context];
    
}

+ (BOOL)addTimeEntryWithDictionary:(NSDictionary *)timeEntryDictionary inContext:(NSManagedObjectContext *)context{
    
    //Test Entry
//    TimeEntry *timeEntry = [[TimeEntry alloc] initWithEntity:[NSEntityDescription entityForName:kTimeEntryEntityName inManagedObjectContext:self.coreDataHelper.context] insertIntoManagedObjectContext:self.coreDataHelper.context];

    TimeEntry *newEntry = [NSEntityDescription insertNewObjectForEntityForName:kTimeEntryEntityName inManagedObjectContext:context];

    [newEntry mapDictionary:timeEntryDictionary];
    
    NSError __autoreleasing *error;
    BOOL success;
    if (!(success = [context save:&error]))
        NSLog(@"Error saving context: %@", error.localizedFailureReason);
    return success;

}

#pragma mark - public methods

- (NSTimeInterval)duration{
    
    NSTimeInterval durationInSeconds;
    durationInSeconds = [self.endTime timeIntervalSinceDate:self.startTime];
    return durationInSeconds;
    
}

- (NSString *)durationString{

    return [NSDate timeStringFromInterval:self.duration];

}

#pragma mark - private

- (void)mapDictionary:(NSDictionary *)dictionary{
    
    self.dateString = dictionary[kTimeEntryAttributeDateString];
    self.startTime = dictionary[kTimeEntryAttributeStartTime];
    self.endTime = dictionary[kTimeEntryAttributeEndTime];
    self.project = dictionary[kTimeEntryAttributeProject];
    self.note = dictionary[kTimeEntryAttributeNote];

}

@end
