//
//  TimeEntryDetailsViewController.h
//  TimeTracker
//
//  Created by Tim Studt on 26/04/15.
//  Copyright (c) 2015 Tim Studt. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    tTimeEntryDetailsSectionDate,
    tTimeEntryDetailsSectionDescription,
    tTimeEntryDetailsSectionNotification,
    tTimeEntryDetailsSectionDelete,
    tTimeEntryDetailsSectionCount,
}tTimeEntryDetailsSectionType;

typedef enum : NSUInteger {
    tTimeEntryDetailsDateRowStartTime,
    tTimeEntryDetailsDateRowEndTime,
    tTimeEntryDetailsDateRowCount,
    tTimeEntryDetailsDateRowDate,
}tTimeEntryDetailsDateRowType;

typedef enum : NSUInteger {
    tTimeEntryDetailsDescriptionRowProject,
    tTimeEntryDetailsDescriptionRowNote,
    tTimeEntryDetailsDescriptionRowCount,
}tTimeEntryDetailsDescriptionRowType;

typedef enum : NSUInteger {
    tTimeEntryDetailsProjectTypeEatLeft,
    tTimeEntryDetailsProjectTypeEatRight,
    tTimeEntryDetailsProjectTypeEatBottle,
    tTimeEntryDetailsProjectTypeNumber1,
    tTimeEntryDetailsProjectTypeNumber2,
    tTimeEntryDetailsProjectTypeCount,
}tTimeEntryDetailsProjectType;
#define TIMEENTRYDETAILSPROJECTTYPESTRING(enum) (enum < tTimeEntryDetailsProjectTypeCount? [@[@"Feed Left", @"Feed Right", @"Feed Bottle", @"Pee", @"Poo"] objectAtIndex:enum] : nil)
//#define TIMEENTRYDETAILSPROJECTTYPESTRING(enum) [@[@"Eat", @"Pee", @"Poo"] objectAtIndex:enum]

@class TimeEntryDetailsViewController, TimeEntry;

@protocol TimeEntryDetailsViewControllerDelegate
@optional
-(void)timeEntryDetailsDidSave:(TimeEntryDetailsViewController *)viewController;
-(void)timeEntryDetailsDidCancel:(TimeEntryDetailsViewController *)viewController;
-(void)timeEntryDetailsDidDelete:(TimeEntryDetailsViewController *)viewController;
@end

@interface TimeEntryDetailsViewController : UITableViewController<UIPickerViewDataSource, UIPickerViewDelegate>
@property (assign, nonatomic) BOOL isEditMode;
@property (assign, nonatomic) BOOL enableDeleteButton;
@property (assign, nonatomic) BOOL notificationSwitchOn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;

@property (nonatomic, weak) id delegate;

- (void)setTimeEntry:(TimeEntry *)timeEntry;
- (void)newTimeEntryWithDate:(NSDate *)date project:(NSString *)project;
- (void)mapToTimeEntry:(TimeEntry *)timeEntry;
@end

