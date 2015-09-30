//
//  TimeEntry+CoreDataHelper.h
//  TimeTracker
//
//  Created by Tim Studt on 26/04/15.
//  Copyright (c) 2015 Tim Studt. All rights reserved.
//

#import "TimeEntry.h"
#import "TimeEntry+CoreDataProperties.h"

@class CKRecord, CKRecordID;

static NSString *const kTimeEntryEntityName = @"TimeEntry";
static NSString *const kCKRecordTypeTimeEntry = @"TimeEntry";

static NSString *const kTimeEntryAttributeDate = @"date";
static NSString *const kTimeEntryAttributeDateString = @"dateString";
static NSString *const kTimeEntryAttributeNote = @"note";
static NSString *const kTimeEntryAttributeProject = @"project";
static NSString *const kTimeEntryAttributeStartTime = @"startTime";
static NSString *const kTimeEntryAttributeEndTime = @"endTime";
static NSString *const kTimeEntryAttributeDuration = @"duration";


@interface TimeEntry (CoreDataHelper)
+ (NSArray *)findTimeEntriesWithDateString:(NSString *)date inContext:(NSManagedObjectContext *)context;
+ (NSArray *)findTimeEntriesWithDate:(NSDate *)date inContext:(NSManagedObjectContext *)context;
+ (NSUInteger)countTimeEntriesWithDateString:(NSString *)date inContext:(NSManagedObjectContext *)context;
+ (TimeEntry *)newTimeEntryInContext:(NSManagedObjectContext *)context;
+ (BOOL)addTimeEntryWithDictionary:(NSDictionary *)timeEntryDictionary inContext:(NSManagedObjectContext *)context;

- (NSTimeInterval)duration;
- (NSString *)durationString;
@end

@interface TimeEntry (CloudKitHelper)
+ (void)CKFindTimeEntriesWithDateString:(NSString *)date completion:(void (^)(NSArray <CKRecord *> * results, NSError * error))completion;
+ (TimeEntry *)CKNewTimeEntry;
- (void)mapFromRecord:(CKRecord *)record;
+ (void)CKSaveTimeEntry:(TimeEntry *)timeEntry completion:(void (^)(CKRecord * record, NSError * error))completion;
+ (void)CKDeleteTimeEntry:(TimeEntry *)timeEntry completion:(void (^_Nonnull)(CKRecordID * _Nullable recordID, NSError * _Nullable error))completion;

@end
