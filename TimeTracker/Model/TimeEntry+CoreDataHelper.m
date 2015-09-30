//
//  TimeEntry+CoreDataHelper.m
//  TimeTracker
//
//  Created by Tim Studt on 26/04/15.
//  Copyright (c) 2015 Tim Studt. All rights reserved.
//

#import "TimeEntry+CoreDataHelper.h"
#import "NSDate+Helpers.h"
#import <CloudKit/CloudKit.h>

@implementation TimeEntry (CoreDataHelper)

#pragma mark - public class functions

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
    
    TimeEntry *newEntry = [NSEntityDescription insertNewObjectForEntityForName:kTimeEntryEntityName inManagedObjectContext:context];

    [newEntry mapDictionary:timeEntryDictionary];
    
    NSError __autoreleasing *error;
    BOOL success;
    if (!(success = [context save:&error]))
        NSLog(@"Error saving context: %@", error.localizedFailureReason);
    return success;

}

+ (NSPredicate *)predicateWithDateSting:(NSString *)date{
    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", @"dateString", date];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(dateString = %@)", date];
    return predicate;
    
}

+ (NSPredicate *)predicateWithDate:(NSDate *)date{
    
    return [self.class predicateWithStartDate:[date startOfDay] endDate:[date endOfDay]];
    
}

+ (NSPredicate *)predicateWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date <= %@)", startDate, endDate];
    return predicate;
    
}


#pragma mark - public methods

- (NSTimeInterval)duration{
    
    NSTimeInterval durationInSeconds;
    durationInSeconds = [self.endTime timeIntervalSinceDate:self.startTime];
    return durationInSeconds;
    
}

- (NSString *)durationString{

    NSTimeInterval timeInHours = self.duration / 3600.;
    return [NSString stringWithFormat:@"%.2f", timeInHours];
//    return [NSDate timeStringFromInterval:self.duration];

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
@implementation TimeEntry (CloudKitHelper)

#pragma mark - public class functions
+ (void)CKFindTimeEntriesWithDateString:(NSString *)date completion:(void (^)(NSArray <CKRecord *> * __nullable results, NSError * __nullable error))completion
{
    
    NSPredicate *predicate = [self.class predicateBeginsWithDateString:date];
    NSSortDescriptor *sortDescriptorDate = [NSSortDescriptor sortDescriptorWithKey:kTimeEntryAttributeDateString ascending:NO];
    NSSortDescriptor *sortDescriptorTime = [NSSortDescriptor sortDescriptorWithKey:kTimeEntryAttributeStartTime ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptorDate, sortDescriptorTime];
    //    [self findTimeEntriesWithAttribute:kTimeEntryAttributeDateString predicate:predicate sortDescriptors:sortDescriptors inContext:context];

    [self CKFindTimeEntriesWithAttribute:kTimeEntryAttributeDateString predicate:predicate sortDescriptors:sortDescriptors completion:completion];
    
}

#pragma mark - private class functions

+ (void)CKFindTimeEntriesWithAttribute:(NSString *)attribute predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors completion:(void (^)(NSArray <CKRecord *> * __nullable results, NSError * __nullable error))completion
{
    CKQuery *query = [[CKQuery alloc] initWithRecordType:kCKRecordTypeTimeEntry predicate:predicate];
    
    [[self database] performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
        NSLog(@"CloudKit results: %@", results);
        if (completion) {
            completion(results, error);
        }
    }];
    //    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kTimeEntryEntityName];
    //    request.predicate = predicate;
    //
    //    request.sortDescriptors = sortDescriptors;
    //
    //    NSError *error = nil;
    //    NSArray *matches = [context executeFetchRequest:request error:&error];
    //    if (error) {
    //        NSLog(@"%s: ERROR: %@", __FUNCTION__, error.debugDescription);
    //        abort();
    //    }
    //    return matches;
}

+ (void)CKFetchRecordWithIdString:(NSString *)idString completion:(void (^)(CKRecord * __nullable record, NSError * __nullable error))completion{
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:idString];
    
    [[self database] fetchRecordWithID:recordID completionHandler:^(CKRecord *record, NSError *error) {
        if (completion) {
            completion(record, error);
        }
    }];
}

+ (void)CKDeleteRecordWithIdString:(NSString * __nonnull)idString completion:(void (^_Nonnull)(CKRecordID * _Nullable recordID, NSError * _Nullable error))completion{
    //record ID
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:idString];
    //delete
    [[self database] deleteRecordWithID:recordID completionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
        if (completion) {
            completion (recordID, error);
        }
    }];
}


- (void)mapFromRecord:(CKRecord *)record
{
//    TimeEntry *timeEntry = [TimeEntry CKNewTimeEntry];
    //map
    self.recordId = record.recordID.recordName;
    self.startTime = record[@"startTime"];
    self.endTime = record[@"endTime"];
    self.dateString = record[@"dateString"];
    self.project = record[@"category"];
    self.note = record[@"note"];
}

- (CKRecord *)mapToRecord:(CKRecord *)record{
    //map
    record[@"dateString"] = self.dateString;
    record[@"category"] = self.project;
    record[@"startTime"] = self.startTime;
    record[@"endTime"] = self.endTime;
    record[@"note"] = self.note;
    return record;
}
+ (TimeEntry *)CKNewTimeEntry //InContext:(NSManagedObjectContext *)context
{
    return [[TimeEntry alloc] init];
//    NSEntityDescription *dateEntryEntity = [NSEntityDescription entityForName:kTimeEntryEntityName
//                                                       inManagedObjectContext:context];
//    return [[TimeEntry alloc] initWithEntity:dateEntryEntity
//              insertIntoManagedObjectContext:context];
    
}

+ (void)CKSaveTimeEntry:(TimeEntry *)timeEntry completion:(void (^)(CKRecord * record, NSError * error))completion {
    NSAssert(timeEntry, @"CKSaveTimeEntry: entry can not be nil");
    //create
    CKRecord *timeEntryRecord = nil;
    NSString *recordId = timeEntry.recordId;
    if (!recordId) {
        //new
        timeEntryRecord = [self newRecordTimeEntry];
        //map
        [timeEntry mapToRecord:timeEntryRecord];
        //save
        [self CKSaveTimeEntryRecord:timeEntryRecord completion:completion];
    }else{
        //update
        [self CKFetchRecordWithIdString:recordId completion:^(CKRecord * _Nullable record, NSError * _Nullable error) {
            if (error) {
                NSLog(@"CK FetchRecord error: %@",error.debugDescription);
            }
            if (record) {
                //map
                [timeEntry mapToRecord:record];
                //save
                [self CKSaveTimeEntryRecord:record completion:completion];
            }
        }];
    }
}
+ (void)CKDeleteTimeEntry:(TimeEntry *)timeEntry completion:(void (^_Nonnull)(CKRecordID * _Nullable recordID, NSError * _Nullable error))completion{
    NSAssert1(timeEntry && timeEntry.recordId, @"CKSaveTimeEntry: entry can not be nil; id %@", timeEntry.recordId);
    //create
    NSString *recordId = timeEntry.recordId;
    if (recordId) {
        [self CKDeleteRecordWithIdString:recordId completion:completion];
    }
}

+ (void)CKSaveTimeEntryRecord:(CKRecord *)timeEntryRecord completion:(void (^)(CKRecord * record, NSError * error))completion{
    NSAssert(timeEntryRecord, @"CKSaveTimeEntryRecord: entry can not be nil");
    //save
    [[self database] saveRecord:timeEntryRecord completionHandler:^(CKRecord *timeEntryRecord, NSError *error){
        
        if (!error) {
            
            // Insert successfully saved record code
            
        }
        
        else {
            
            // Insert error handling
            
        }
        if (completion) {
            completion(timeEntryRecord,error);
        }
        
    }];
}
+ (CKRecord *)newRecordTimeEntry{
    return [self newRecordType:@"TimeEntry"];
}

+ (CKRecord *)newRecordType:(NSString *)type{
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:[NSString stringWithFormat:@"%@_%@", type, [NSDate date]]];
    CKRecord *record = [[CKRecord alloc] initWithRecordType:type recordID:recordID];
    return record;
}


+ (NSPredicate *)predicateBeginsWithDateString:(NSString *)date{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K BEGINSWITH %@", @"dateString", date];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(dateString = %@)", date];
    return predicate;
    
}

#pragma mark - private data source
+ (CKDatabase *)database{
    return [self container].publicCloudDatabase;
}
+ (CKContainer *)container{
    return [CKContainer defaultContainer];
}

@end
