//
//  NSDate+Helpers.h
//  TimeTracker
//
//  Created by Tim Studt on 26/04/15.
//  Copyright (c) 2015 Tim Studt. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kDateFormat = @"yyyy-MM-dd";
static NSString *const kDateFormatNoDay = @"yyyy-MM";
static NSString *const kTimeFormat = @"hh:mm";
static NSString *const kDateTimeFormat = @"yyyy-MM-dd hh:mm";

@interface NSDate (Helpers)

+ (NSDate *)dateFromString:(NSString *)dateString;
+ (NSDate *)timeFromString:(NSString *)timeString;

- (NSString *)dateString;
- (NSString *)dateStringNoDay;
- (NSString *)timeString;
- (NSDate *)startOfDay;
- (NSDate *)endOfDay;
- (NSString *)timeStringDoesRelativeDateFormatting:(BOOL)doesRelativeDateFormatting;
- (NSString *)dateStringDoesRelativeDateFormatting:(BOOL)doesRelativeDateFormatting;
- (NSString *)dateAndTimeStringDoesRelativeDateFormatting:(BOOL)doesRelativeDateFormatting;

+ (NSString *)timeStringFromInterval:(NSTimeInterval)interval;

@end
