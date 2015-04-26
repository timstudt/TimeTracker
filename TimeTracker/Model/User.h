//
//  User.h
//  TimeTracker
//
//  Created by Tim Studt on 26/04/15.
//  Copyright (c) 2015 Tim Studt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TimeEntry;

@interface User : NSManagedObject

@property (nonatomic, retain) NSSet *times;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addTimesObject:(TimeEntry *)value;
- (void)removeTimesObject:(TimeEntry *)value;
- (void)addTimes:(NSSet *)values;
- (void)removeTimes:(NSSet *)values;

@end
