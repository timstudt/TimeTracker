//
//  NSDate+Helpers.m
//  TimeTracker
//
//  Created by Tim Studt on 26/04/15.
//  Copyright (c) 2015 Tim Studt. All rights reserved.
//

#import "NSDate+Helpers.h"

@implementation NSDate (Helpers)

+ (NSDate *)dateFromString:(NSString *)dateString format:(NSString *)format{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    [dateFormatter setDateFormat:format];
    if (dateString){
        NSDate *date = nil; //EMPTYSTRING_DATE;
        date = [dateFormatter dateFromString:dateString];
        return date;
    }
    return nil;

}

//default date format
+ (NSDate *)dateFromString:(NSString *)dateString{

    NSDate *date = [NSDate dateFromString:dateString format:kDateTimeFormat];
    if (!date) {
        //wrong format, check if it's date only format
        date = [NSDate dateFromString:dateString format:kDateFormat];
    }
    return date;

}

+ (NSDate *)timeFromString:(NSString *)timeString{
    
    NSDate *date = [NSDate dateFromString:timeString format:kTimeFormat];
    return date;

}

- (NSString *)dateString{
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDateFormat];
    return [formatter stringFromDate:self];
    
}

- (NSString *)dateStringNoDay{
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDateFormatNoDay];
    return [formatter stringFromDate:self];
}

- (NSString *)timeString{
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kTimeFormat];
    return [formatter stringFromDate:self];
}

- (NSDate *)startOfDay{

    return [self dateWithHour:0 minute:0 second:0];

}

- (NSDate *)endOfDay{
    
    return [self dateWithHour:23 minute:59 second:59];
    
}

- (NSDate *)dateWithHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second{

    //gather current calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    //gather date components from date
    NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    
    //set date components
    [dateComponents setHour:hour];
    [dateComponents setMinute:minute];
    [dateComponents setSecond:second];

    //return date relative from date
    return [calendar dateFromComponents:dateComponents];

}

- (NSString *)timeStringDoesRelativeDateFormatting:(BOOL)doesRelativeDateFormatting{
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    //    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDoesRelativeDateFormatting:doesRelativeDateFormatting];
    return [formatter stringFromDate:self];

}

- (NSString *)dateStringDoesRelativeDateFormatting:(BOOL)doesRelativeDateFormatting{

    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDoesRelativeDateFormatting:doesRelativeDateFormatting];
    return [formatter stringFromDate:self];
    
}

- (NSString *)dateAndTimeStringDoesRelativeDateFormatting:(BOOL)doesRelativeDateFormatting{
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDoesRelativeDateFormatting:doesRelativeDateFormatting];
    return [formatter stringFromDate:self];
    
}

+ (NSString *)timeStringFromInterval:(NSTimeInterval)interval{
    
#define SECONDS_PER_MINUTE (60)
#define MINUTES_PER_HOUR (60)
#define SECONDS_PER_HOUR (SECONDS_PER_MINUTE * MINUTES_PER_HOUR)
    NSInteger intervalInt = round(interval);
    NSInteger hours = (intervalInt / SECONDS_PER_HOUR);
    NSInteger minutes =  (intervalInt / SECONDS_PER_MINUTE) % MINUTES_PER_HOUR;
#undef SECONDS_PER_MINUTE
#undef MINUTES_PER_HOUR
#undef SECONDS_PER_HOUR
    return [NSString stringWithFormat:@"%.2ld:%.2ld", (long)hours, (long)minutes];
    
}


@end
