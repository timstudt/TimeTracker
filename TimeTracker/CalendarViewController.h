//
//  ViewController.h
//  TimeTracker
//
//  Created by Tim Studt on 25/04/15.
//  Copyright (c) 2015 Tim Studt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTCalendar.h"

@interface CalendarViewController : UIViewController
@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;

@property (weak, nonatomic) IBOutlet JTCalendarContentView *calendarContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarContentViewHeightConstraint;

@property (strong, nonatomic) JTCalendar *calendar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *weekModeToggle;

- (IBAction)tappedWeekModeToggle:(UIBarButtonItem *)sender;
- (IBAction)tappedAddButton:(id)sender;

@end

