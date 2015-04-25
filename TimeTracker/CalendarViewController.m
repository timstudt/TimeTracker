//
//  ViewController.m
//  TimeTracker
//
//  Created by Tim Studt on 25/04/15.
//  Copyright (c) 2015 Tim Studt. All rights reserved.
//

#import "CalendarViewController.h"
//#import "AddEntryViewController.h"
#import "TimeEntry.h"

static NSString *const kCalendarModeWeek = @"Show Month";
static NSString *const kCalendarModeMonth = @"Show Week";

@interface CalendarViewController ()
{
    CGFloat _calendarContentViewHeightConstraintMonthMode;
}
@end

@implementation CalendarViewController

#pragma mark - ViewController life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //setup calendarView
    self.calendar = [JTCalendar new];
    [self.calendar setMenuMonthsView:self.calendarMenuView];
    [self.calendar setContentView:self.calendarContentView];
    [self.calendar setDataSource:(id)self];
    _calendarContentViewHeightConstraintMonthMode = self.calendarContentViewHeightConstraint.constant;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [self.calendar reloadData]; // Must be call in viewDidAppear
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"AddEntrySegue"]) {
        UIViewController *addEntryViewController = segue.destinationViewController;
//        addEntryViewController.timeEntry = selectedEntry;
    }
}

#pragma mark - JTCalendar data source, delegates

- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date{
    
    return NO;
    
}



- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date{
    
    NSLog(@"%@", date);
    
}

#pragma mark - private methods

- (void)activateWeekMode:(BOOL)activateWeekMode{

    //update toggle switch
    self.weekModeToggle.title = activateWeekMode? kCalendarModeWeek : kCalendarModeMonth;
    //update calendar view
    self.calendar.calendarAppearance.isWeekMode = activateWeekMode;
    self.calendarContentViewHeightConstraint.constant = activateWeekMode? 55.f : _calendarContentViewHeightConstraintMonthMode;
    [self.calendar reloadAppearance];

}
#pragma mark - Iboutlet actions
- (IBAction)tappedWeekModeToggle:(UIBarButtonItem *)sender {

    BOOL weekMode = self.calendar.calendarAppearance.isWeekMode;
    [self activateWeekMode:!weekMode];
    
}

- (IBAction)tappedAddButton:(id)sender {
    

}
@end
