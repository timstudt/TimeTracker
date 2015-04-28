//
//  TimeEntry.h
//  TimeTracker
//
//  Created by Tim Studt on 28/04/15.
//  Copyright (c) 2015 Tim Studt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface TimeEntry : NSManagedObject

@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * project;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSString * dateString;
@property (nonatomic, retain) User *user;

@end
