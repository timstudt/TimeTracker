//
//  TimeEntry.h
//  TimeTracker
//
//  Created by Tim Studt on 29/04/15.
//  Copyright (c) 2015 Tim Studt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TimeEntry : NSManagedObject

@property (nonatomic, retain) NSString * dateString;
@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * project;
@property (nonatomic, retain) NSDate * startTime;

@end
