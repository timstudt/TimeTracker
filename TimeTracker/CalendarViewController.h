//
//  ViewController.h
//  TimeTracker
//
//  Created by Tim Studt on 25/04/15.
//  Copyright (c) 2015 Tim Studt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTCalendar.h"
#import "TimeEntryDetailsViewController.h"
#import "CoreDataHelper.h"

@interface CalendarViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, TimeEntryDetailsViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *weekModeToggle;
@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;

@property (weak, nonatomic) IBOutlet JTCalendarContentView *calendarContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarContentViewHeightConstraint; //needed for resizing calendarview
@property (weak, nonatomic) IBOutlet UITableView *calendarTableView;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

@property (strong, nonatomic) JTCalendar *calendar;
@property (nonatomic, strong) CoreDataHelper *coreDataHelper;

- (IBAction)tappedAddButton:(id)sender;
- (IBAction)tappedGetMonthButton:(UIBarButtonItem *)sender;

- (void)updateUI;

@end

