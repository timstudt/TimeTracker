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

@interface CalendarViewController (CloudKit)

#pragma mark - Notification Observers
- (void)registerForiCloudNotifications;
- (void) persistentStoreDidImportUbiquitousContentChanges:(NSNotification *)changeNotification;

@end

@implementation CalendarViewController{
    NSArray<CKRecord *> *_CKTableData;
}

#pragma mark - ViewController life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCalendarView];
    
    //store constraint, so we can restore it after change
    _calendarContentViewHeightConstraintMonthMode = self.calendarContentViewHeightConstraint.constant;
    
    //setup core data
    [self.coreDataHelper fetchedResultsController].delegate = self;
//    [self registerForiCloudNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
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

#pragma mark - public methods
- (void)updateUI{
    [self.calendarTableView reloadData];
    [self refreshTotalTimeLabel];
    
    [self.calendar reloadData];

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

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return [self.coreDataHelper numberOfSections];
//}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    NSInteger rows = self.tableData.count;
//    NSInteger rows = [self.coreDataHelper itemsInSection:section];
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
//    TimeEntry *timeEntry = [self.coreDataHelper.fetchedResultsController objectAtIndexPath:indexPath];
    
    //setup cell
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[[NSDate dateFromString:timeEntry.dateString] dateStringDoesRelativeDateFormatting:NO]];
    cell.detailTextLabel.text =  TIMEENTRYDETAILSPROJECTTYPESTRING([timeEntry.project intValue]);
    UILabel *hoursLabel = (UILabel *)[cell viewWithTag:3];
    hoursLabel.text = [timeEntry durationString];
    
    return cell;
    
}

//#pragma mark - FetchedResultsController delegate
//
//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
//    [self.calendarTableView beginUpdates];
//}
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
// }
//
//- (void)contextDidSave:(id)object{
//    
//}
#pragma mark - TimeEntryDetailsView delegate

- (void)timeEntryDetailsDidCancel:(TimeEntryDetailsViewController *)viewController{
    
    //refresh done on viewdidappear
    
}

- (void)timeEntryDetailsDidSave:(TimeEntryDetailsViewController *)viewController{

    TimeEntry *entryToSave = [self tableDataSelectedEntry];
    if (!entryToSave) {
        //new entry
        entryToSave = [TimeEntry newTimeEntryInContext:self.coreDataHelper.context];
//        entryToSave = [TimeEntry CKNewTimeEntry];
    }
    [viewController mapToTimeEntry:entryToSave];
//    [self.coreDataHelper save];
    [TimeEntry CKSaveTimeEntry:entryToSave completion:^(CKRecord *record, NSError *error) {
        if (error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops" message:@"could not sync data with database" preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alert animated:YES completion:nil];
        }
        [self updateUI];
    }];
    if (entryToSave.project) {
        [User setLastUsedProject:entryToSave.project];
    }
    //refresh done on viewdidappear
    
}

- (void)timeEntryDetailsDidDelete:(TimeEntryDetailsViewController *)viewController{
    TimeEntry *entryToDelete = [self tableDataSelectedEntry];
    [TimeEntry CKDeleteTimeEntry:entryToDelete completion:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadFetchedItems];
        });
    }];
    
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

static NSString *const kButtonTitleCalendarShow = @"Show Calendar";
static NSString *const kButtonTitleCalendarHide = @"Hide Calendar";
- (IBAction)tappedGetMonthButton:(UIBarButtonItem *)sender {
    
    [self unselectHighlightedDate];
    NSString *newTitle = sender.title;
    BOOL goFullsize = NO;
    if ([sender.title isEqualToString:kButtonTitleCalendarHide]) {
        newTitle = kButtonTitleCalendarShow;
        goFullsize = YES;
    }else if ([sender.title isEqualToString:kButtonTitleCalendarShow]) {
        newTitle = kButtonTitleCalendarHide;
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
    
//    return self.coreDataHelper.fetchedResultsController.fetchedObjects;
    return _CKTableData;
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

//    [self.coreDataHelper fetchItemsMatching:[self datesDisplayed]
//                               forAttribute:kTimeEntryAttributeDateString
//                                  sortingBy:nil];
    [TimeEntry CKFindTimeEntriesWithDateString:[self datesDisplayed] completion:^(NSArray<CKRecord *> *results, NSError *error) {
        NSMutableArray *timeEntries = [[NSMutableArray alloc]initWithCapacity:results.count];
        for (CKRecord *record in results) {
            TimeEntry *timeEntry = [TimeEntry newTimeEntryInContext:self.coreDataHelper.context];
//            TimeEntry *timeEntry = [TimeEntry CKNewTimeEntry];
            [timeEntry mapFromRecord:record];
            [timeEntries addObject:timeEntry];
        }
        _CKTableData = [NSArray arrayWithArray:timeEntries];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self updateUI];
        });
    }];
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

@implementation CalendarViewController (CloudKit)
#pragma mark - Notification Observers
- (void)registerForiCloudNotifications {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    NSManagedObjectContext *context = [self coreDataHelper].context;
    
    [notificationCenter addObserver:self
                           selector:@selector(storesWillChange:)
                               name:NSPersistentStoreCoordinatorStoresWillChangeNotification
                             object:context.persistentStoreCoordinator];
    
    [notificationCenter addObserver:self
                           selector:@selector(storesDidChange:)
                               name:NSPersistentStoreCoordinatorStoresDidChangeNotification
                             object:context.persistentStoreCoordinator];
    
    [notificationCenter addObserver:self
                           selector:@selector(persistentStoreDidImportUbiquitousContentChanges:)
                               name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                             object:context.persistentStoreCoordinator];
}
- (void) persistentStoreDidImportUbiquitousContentChanges:(NSNotification *)changeNotification {
    NSManagedObjectContext *context = [self.coreDataHelper threadMOC];// self.managedObjectContext;
    
    [context performBlock:^{
        [context mergeChangesFromContextDidSaveNotification:changeNotification];
    }];
}

- (void)storesWillChange:(NSNotification *)notification {
    NSManagedObjectContext *context = [self.coreDataHelper threadMOC];// self.managedObjectContext;
    
    [context performBlockAndWait:^{
        NSError *error;
        
        if ([context hasChanges]) {
            BOOL success = [context save:&error];
            
            if (!success && error) {
                // perform error handling
                NSLog(@"%@",[error localizedDescription]);
            }
        }
        
        [context reset];
    }];
    
    // Refresh your User Interface.
}

- (void)storesDidChange:(NSNotification *)notification {
    // Refresh your User Interface.
    //    [self fetchData];
    [self reloadFetchedItems];
    [self updateUI];
    
}

@end


