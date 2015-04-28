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

@class TimeEntryDetailsViewController, TimeEntry;

@protocol TimeEntryDetailsViewControllerDelegate
@optional
-(void)timeEntryDetailsDidSave:(TimeEntryDetailsViewController *)viewController;
-(void)timeEntryDetailsDidCancel:(TimeEntryDetailsViewController *)viewController;
@end

@interface TimeEntryDetailsViewController : UITableViewController
@property (assign, nonatomic) BOOL isEditMode;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;

@property (nonatomic, weak) id delegate;

- (void)setTimeEntry:(TimeEntry *)timeEntry;
- (void)newTimeEntryWithDate:(NSDate *)date project:(NSString *)project;
- (void)mapToTimeEntry:(TimeEntry *)timeEntry;
@end

