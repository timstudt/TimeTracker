//
//  CalendarViewController.m
//  TimeTracker
//
//  Created by Tim Studt on 25/04/15.
//  Copyright (c) 2015 Tim Studt. All rights reserved.
//

#import "CalendarViewController.h"
#import "TimeEntry+CoreDataHelper.h"
#import "User.h"
#import "NSDate+Helpers.h"

static NSString *const kCalendarModeWeek = @"Show Month";
static NSString *const kCalendarModeMonth = @"Show Week";

//KVO
static NSString *const kCalendarCurrentDateKey = @"currentDate";

@interface CalendarViewController ()
{
    CGFloat _calendarContentViewHeightConstraintMonthMode;
}
@end

@implementation CalendarViewController

#pragma mark - ViewController life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCalendarView];
    
    //store constraint, so we can restore it after change
    _calendarContentViewHeightConstraintMonthMode = self.calendarContentViewHeightConstraint.constant;
    
    //setup core data
    [self.coreDataHelper fetchedResultsController];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [self refreshViewAfterDataChanged:YES];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"AddEntrySegue"]) {
        UIViewController *dstViewController = segue.destinationViewController;
        TimeEntryDetailsViewController *addEntryViewController = nil;
        if ([dstViewController isKindOfClass:[UINavigationController class]]) {
            //VC is embedded in NavigationController
            addEntryViewController = ((UINavigationController *)dstViewController).viewControllers[0];
        }else{
            addEntryViewController = (TimeEntryDetailsViewController *)dstViewController;
        }
        
        NSAssert2([addEntryViewController isKindOfClass:[TimeEntryDetailsViewController class]], @"ERROR: Segue  %@ to unidentified viewcontroller %@", segue.identifier, addEntryViewController.class);
        
        addEntryViewController.isEditMode = YES;
        addEntryViewController.delegate = self;
        [addEntryViewController newTimeEntryWithDate:[self dateHighlighted] project:[User lastUsedProject]];
    }else if ([segue.identifier isEqualToString:@"TimeEntryDetailsSegue"]){
        TimeEntryDetailsViewController *detailsViewController = segue.destinationViewController;
        detailsViewController.isEditMode = NO;
        detailsViewController.delegate = self;
        [detailsViewController setTimeEntry:[self tableDataSelectedEntry]];
    }
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:kCalendarCurrentDateKey]) {
        NSLog(@"Calendar view was changed: %@ was changed.", keyPath);
        NSLog(@"%@", change);
        [self unselectHighlightedDate];
        [self refreshViewAfterDataChanged:NO];
    }
    
}

#pragma mark - JTCalendar data source, delegates

- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date{

    return [TimeEntry countTimeEntriesWithDateString:[date dateString]
                                           inContext:self.coreDataHelper.context];
    
}

- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date{
    
    NSLog(@"%@", date);
    [self refreshViewAfterDataChanged:NO];
    
}

#pragma mark - UITableView delegate, data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    NSInteger rows = self.tableData.count;
    return rows;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //get cell
    NSString *reuseId = @"calendarTimeEntryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                      reuseIdentifier:reuseId];
    }
    
    //get timeEntry for row
    TimeEntry *timeEntry = self.tableData[indexPath.row];
    
    //setup cell
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[[NSDate dateFromString:timeEntry.dateString] dateStringDoesRelativeDateFormatting:NO]];
    cell.detailTextLabel.text = timeEntry.project;
    UILabel *hoursLabel = (UILabel *)[cell viewWithTag:3];
    hoursLabel.text = [timeEntry durationString];
    
    return cell;
    
}

#pragma mark - TimeEntryDetailsView delegate

- (void)timeEntryDetailsDidCancel:(TimeEntryDetailsViewController *)viewController{
    
    //refresh done on viewdidappear
    
}

- (void)timeEntryDetailsDidSave:(TimeEntryDetailsViewController *)viewController{

    TimeEntry *entryToSave = [self tableDataSelectedEntry];
    if (!entryToSave) {
        //new entry
        entryToSave = [TimeEntry newTimeEntryInContext:self.coreDataHelper.context];
    }
    [viewController mapToTimeEntry:entryToSave];
    [self.coreDataHelper save];
    if (entryToSave.project) {
        [User setLastUsedProject:entryToSave.project];
    }
    //refresh done on viewdidappear
    
}

#pragma mark - IBoutlet actions

// here we get back from both segues
- (IBAction)unwindFromDetailViewController:(UIStoryboardSegue *)segue
{
    
    NSLog(@"%@", segue.identifier);
    
}

- (IBAction)tappedAddButton:(id)sender {
    
    NSLog(@"Add entry tapped");
    
}

- (IBAction)tappedGetMonthButton:(UIBarButtonItem *)sender {
    
    [self unselectHighlightedDate];
    NSString *newTitle = sender.title;
    BOOL goFullsize = NO;
    if ([sender.title isEqualToString:@"Time Sheet"]) {
        newTitle = @"Calendar";
        goFullsize = YES;
    }else if ([sender.title isEqualToString:@"Calendar"]) {
        newTitle = @"Time Sheet";
        goFullsize = NO;
    }
    [self activateFullsizeTableView:goFullsize];
    [self refreshViewAfterDataChanged:NO];

    sender.title = newTitle;
    
}

#pragma mark - private methods

- (void)setupCalendarView{
    
    if (!_calendar) {
        //instantiate
        _calendar = [JTCalendar new];
    }
    
    //setup calendarView
    [self.calendar setMenuMonthsView:self.calendarMenuView];
    [self.calendar setContentView:self.calendarContentView];
    [self.calendar setDataSource:(id<JTCalendarDataSource>)self];
    //KVO for getting updates when user swipes month/week
    [self.calendar setValue:[NSDate date]
                     forKey:kCalendarCurrentDateKey];
    [self.calendar addObserver:self
                    forKeyPath:kCalendarCurrentDateKey
                       options:NSKeyValueObservingOptionNew
                       context:nil];

}

- (NSArray *)tableData{
    
    return self.coreDataHelper.fetchedResultsController.fetchedObjects;
    
}

- (TimeEntry *)tableDataSelectedEntry{
    
    TimeEntry *selectedEntry = nil;
    if (self.calendarTableView.indexPathForSelectedRow) {
        NSInteger selectedRow = self.calendarTableView.indexPathForSelectedRow.row;
        selectedEntry = self.tableData[selectedRow];
    }

    return selectedEntry;
    
}

- (NSTimeInterval)getTimeSumOfSelectedEntries{
    
    NSTimeInterval sum = 0.;
    
    NSArray *timeEntries = self.tableData;
    for (TimeEntry *timeEntry in timeEntries) {
        sum += [timeEntry duration];
    }
    
    return sum;

}

- (void)activateFullsizeTableView:(BOOL)fullSize{
    
    CGFloat newSize = fullSize? 0.1f : _calendarContentViewHeightConstraintMonthMode;
    [self updateViewConstraintsWithCalendarHeight:newSize animated:YES];

}

- (void)updateViewConstraintsWithCalendarHeight:(CGFloat)calendarHeight animated:(BOOL)animated{
    
    [self.view layoutIfNeeded]; // Called on parent view
    self.calendarContentViewHeightConstraint.constant = calendarHeight;
    if (animated) {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.5f animations:^{
            [weakSelf.view layoutIfNeeded];
        }];
    }
    
}

- (void)unselectHighlightedDate{
    
    self.calendar.currentDateSelected = nil;
    
}

/**
 * use dateHighlighted as date for new entries
 */
- (NSDate *)dateHighlighted{
    
    NSDate *date = self.calendar.currentDateSelected ?: self.calendar.currentDate;
    return date;
    
}

/**
 * use datesDisplayed as dates for tableview content
 */
- (NSString *)datesDisplayed{
    
    NSString *dateString = self.calendar.currentDateSelected ? [self.calendar.currentDateSelected dateString ] : [self.calendar.currentDate dateStringNoDay];
    //Todo handle week view
    return dateString;
    
}

- (void)refreshViewAfterDataChanged:(BOOL)didChangeData{
    
    [self reloadFetchedItems];
    [self.calendarTableView reloadData];
    [self refreshTotalTimeLabel];
    
    if (didChangeData) {
        [self.calendar reloadData];
    }
    
}

- (void)reloadFetchedItems{

    [self.coreDataHelper fetchItemsMatching:[self datesDisplayed]
                               forAttribute:kTimeEntryAttributeDateString
                                  sortingBy:nil];

}

- (void)refreshTotalTimeLabel{

//    self.totalTimeLabel.text = [NSDate timeStringFromInterval:[self getTimeSumOfSelectedEntries]]; //format 23:33
    NSTimeInterval totalTimeInHours = [self getTimeSumOfSelectedEntries] / 3600.;
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%.2f", totalTimeInHours]; //format 12.7
    
}

#pragma mark - properties setters/getters

/**
 * setups up CoreData (moc, fetchedResultsController for table view, etc)
 */
- (CoreDataHelper *)coreDataHelper{

    if (!_coreDataHelper) {
        _coreDataHelper = [[CoreDataHelper alloc] init];
        _coreDataHelper.entityName = kTimeEntryEntityName;
        _coreDataHelper.defaultSortAttribute = kTimeEntryAttributeDateString;
        [_coreDataHelper setupCoreData];
    }
    return _coreDataHelper;

}
@end
