//
//  TimeEntryDetailsViewController.m
//  TimeTracker
//
//  Created by Tim Studt on 26/04/15.
//  Copyright (c) 2015 Tim Studt. All rights reserved.
//

#import "TimeEntryDetailsViewController.h"
#import "NSDate+Helpers.h"
#import "TimeEntry.h"

static NSString *const kButtonTitleSave =  @"Save";
static NSString *const kButtonTitleEdit =  @"Edit";

@interface TimeEntryDetailsViewController (KeyboardEvents)
- (void)registerForKeyboardNotifications;
@end

@interface TimeEntryDetailsViewController (){
    CGRect _kbdFrame;
}

//Data to display
//@property (nonatomic, strong) NSString *dateEntry;
@property (nonatomic, strong) NSDate *startTimeEntry;
@property (nonatomic, strong) NSDate *endTimeEntry;
@property (nonatomic, strong) NSString *projectEntry;
@property (nonatomic, strong) NSString *noteEntry;
//Outlets
@property (weak, nonatomic) IBOutlet UITextField *projectTextField;
@property (weak, nonatomic) IBOutlet UITextField *noteTextField;

// keep track which indexPath points to the cell with UIDatePicker
@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;
@property (nonatomic,strong) UITextField *activeField;
@end

@implementation TimeEntryDetailsViewController

#pragma mark - ViewController life cycle

- (void)viewDidLoad {

    [super viewDidLoad];
    [self registerForKeyboardNotifications];
    //setup table view
//    [self.tableView registerClass:<#(__unsafe_unretained Class)#> forCellReuseIdentifier:<#(NSString *)#>]
    self.tableView.estimatedRowHeight =  100;
    self.tableView.rowHeight =  UITableViewAutomaticDimension;
    
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [self refreshNavigationBarButtons];

}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

#pragma mark - public methods

- (void)setIsEditMode:(BOOL)isEditMode{
    
    _isEditMode = isEditMode;
    [self refreshNavigationBarButtons];
    self.tableView.userInteractionEnabled = self.isEditMode;
    
}

- (void)setTimeEntry:(TimeEntry *)timeEntry{
    
    [self mapFromTimeEntry:timeEntry];
    [self.tableView reloadData];
    
}

- (void)newTimeEntryWithDate:(NSDate *)date project:(NSString *)project{
    
    //    self.dateEntry = [date dateString];
    self.startTimeEntry = date;
    self.endTimeEntry = date;
    self.projectEntry = project;
    
}

- (void)mapToTimeEntry:(TimeEntry *)timeEntry{
    
    //map data
    //    timeEntry.dateString = self.dateEntry;
    timeEntry.dateString = [self.startTimeEntry dateString];
    timeEntry.startTime = self.startTimeEntry;
    timeEntry.endTime = self.endTimeEntry;
    timeEntry.project = self.projectEntry;
    timeEntry.note = self.noteEntry;
    
}

#pragma mark - tableview data source delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    NSInteger sections = tTimeEntryDetailsSectionCount;
    return sections;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger rows = 0;
    switch (section) {
        case tTimeEntryDetailsSectionDate:
            rows = tTimeEntryDetailsDateRowCount;
            if (self.datePickerIndexPath) {
                rows += 1;
            }
            break;
        case tTimeEntryDetailsSectionDescription:
            rows = tTimeEntryDetailsDescriptionRowCount;
            break;
        default:
            break;
    }
    return rows;
    
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *title = nil;
    
    switch (section) {
        case tTimeEntryDetailsSectionDate:
            title = @"Date";
            break;
        case tTimeEntryDetailsSectionDescription:
            title = @"Description";
            break;
        default:
            break;
    }
    
    return title;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = nil;
    NSString *title = nil;
    NSString *content = @" - ";
    
    //get cell
    NSString *reuseId = nil;
    switch (indexPath.section) {
        case tTimeEntryDetailsSectionDate:
        {
            if (self.datePickerIndexPath == indexPath) {
                //date picker
                cell = [self datePickerCellForTableView:tableView atIndexPath:indexPath];
            }else{
                //normal date cell
                NSInteger row = indexPath.row;
                reuseId = @"TimeEntryTimeCell";
                if (self.datePickerIndexPath && self.datePickerIndexPath.row < indexPath.row) {
                    row -= 1;
                }
                switch (row) {
                    case tTimeEntryDetailsDateRowDate:
                        title = @"Date";
                        content = [self.startTimeEntry dateString];
                        break;
                    case tTimeEntryDetailsDateRowStartTime:
                        title = @"Start Time";
                        content = [self.startTimeEntry dateAndTimeStringDoesRelativeDateFormatting:NO];
                        break;
                    case tTimeEntryDetailsDateRowEndTime:
                        title = @"End Time";
                        content = [self.endTimeEntry dateAndTimeStringDoesRelativeDateFormatting:NO];
                        break;
                    default:
                        NSLog(@"ERROR: unspecified row in SectionDate");
                        break;
                }
                
                cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:reuseId];
                }
                
                //setup cells
                cell.textLabel.text = title;
                cell.detailTextLabel.text = content;
                if (row == tTimeEntryDetailsDateRowDate) {
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
            }

        }
            break;
        case tTimeEntryDetailsSectionDescription:
        {
            reuseId = @"TimeEntryTextCell";
            cell = [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:reuseId];
            }
            
            UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
            UITextField *detailsTextField = (UITextField *)[cell viewWithTag:2];
            
            switch (indexPath.row) {
                case tTimeEntryDetailsDescriptionRowProject:
                    title = @"Project";
                    content = self.projectEntry;
                    self.projectTextField = detailsTextField;

                    break;
                case tTimeEntryDetailsDescriptionRowNote:
                    title = @"Notes";
                    content = self.noteEntry;
                    self.noteTextField = detailsTextField;
                    break;
                default:
                    NSLog(@"ERROR: unspecified row in SectionDescription");
                    break;
            }
            
            titleLabel.text = title;
            if ([self isEditMode]) {
                detailsTextField.text = content;
            }else{
                detailsTextField.text = nil;
                detailsTextField.placeholder = content;
            }

        }
            break;
        default:
            NSLog(@"ERROR: unspecified section");
            break;
    }

    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.section) {
        case tTimeEntryDetailsSectionDate:
        {
            if (self.datePickerIndexPath && self.datePickerIndexPath.row < indexPath.row) {
                self.datePickerIndexPath = indexPath;
            }else if (self.datePickerIndexPath == indexPath || [self datePickerParentIndexPath] == indexPath){
                self.datePickerIndexPath = nil;
            }else{
                //hide datePicker
                self.datePickerIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
            }
            
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:tTimeEntryDetailsSectionDate] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }
            break;
            
        case tTimeEntryDetailsSectionDescription:
        {
            switch (indexPath.row) {
                case tTimeEntryDetailsDescriptionRowProject:
                    if (![self.projectTextField isFirstResponder]) {
                        [self.projectTextField becomeFirstResponder];
                    }
                    break;
                case tTimeEntryDetailsDescriptionRowNote:
                    if (![self.noteTextField isFirstResponder]) {
                        [self.noteTextField becomeFirstResponder];
                    }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

#pragma mark - IBOutlets actions
- (IBAction)cancelButtonPressed:(id)sender {
    
    if (_activeField) {
        [_activeField resignFirstResponder];
    }
    
   if([self.delegate respondsToSelector:@selector(timeEntryDetailsDidCancel:)]) {
        [self.delegate timeEntryDetailsDidCancel:self];
    }
    [self performSegueWithIdentifier:@"UnwindCalendarDetailsSegue" sender:self];

}

- (IBAction)rightButtonTapped:(UIBarButtonItem *)sender {

    if ([sender.title isEqualToString:kButtonTitleEdit]){
        self.isEditMode = YES;
    }else if([sender.title isEqualToString:kButtonTitleSave]){
        self.isEditMode = NO;

        if([self.delegate respondsToSelector:@selector(timeEntryDetailsDidSave:)]) {
            [self.delegate timeEntryDetailsDidSave:self];
        }
        [self performSegueWithIdentifier:@"UnwindCalendarDetailsSegue" sender:self];
    }
    
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    self.activeField = textField;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{

    [textField resignFirstResponder];
    self.activeField = nil;
    return YES;
    
}

// Here we save the textField's string whenever the user finishes editing it.
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    if (textField == self.projectTextField) {
        self.projectEntry = textField.text;
    }else if (textField == self.noteTextField){
        self.noteEntry = textField.text;
    }
    [self.tableView reloadData];
    
}

#pragma mark - DatePicker delegate

- (IBAction)dateChanged:(UIDatePicker *)sender {
    
    if (![self isDateValidForDatePicker:sender]) {
        return;
    }
    
    if ([self datePickerIndexPath]){
        //datePicker is visible
        NSIndexPath *parentCellIndexPath = nil;
        parentCellIndexPath = [self datePickerParentIndexPath];
        
        NSDate *newDate = sender.date;
        switch (parentCellIndexPath.row) {
            case tTimeEntryDetailsDateRowStartTime:
                self.startTimeEntry = newDate;
                if ([self.endTimeEntry compare:self.startTimeEntry] == NSOrderedAscending) {
                    //end date must be higher then start date
                    self.endTimeEntry = self.startTimeEntry;
                }
                break;
            case tTimeEntryDetailsDateRowEndTime:
                self.endTimeEntry = newDate;
                break;
            default:
                break;
        }
        self.datePickerIndexPath = nil;

        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:tTimeEntryDetailsSectionDate] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
}

#pragma mark - private methods

- (void)refreshNavigationBarButtons{
    
    self.rightBarButton.title = self.isEditMode? kButtonTitleSave : kButtonTitleEdit;
    self.cancelButton.width = self.isEditMode? 0. : 0.1;

}

- (void)mapFromTimeEntry:(TimeEntry *)timeEntry{

    //map data
    self.startTimeEntry = timeEntry.startTime;
    self.endTimeEntry = timeEntry.endTime;
    self.projectEntry = timeEntry.project;
    self.noteEntry = timeEntry.note;

}

- (UITableViewCell *)datePickerCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = nil;
    NSString *reuseId = @"TimeEntryPickerCell";
    cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:reuseId];
    }
    UIDatePicker *datePicker = (UIDatePicker *)[cell viewWithTag:1];
    datePicker.datePickerMode = ([self datePickerParentIndexPath].row == tTimeEntryDetailsDateRowDate)? UIDatePickerModeDate : UIDatePickerModeDateAndTime;
    
    switch ([self datePickerParentIndexPath].row) {
        case tTimeEntryDetailsDateRowStartTime:
            datePicker.date = self.startTimeEntry?:[NSDate date];
            datePicker.minimumDate = nil;
            datePicker.maximumDate = nil;
            break;
        case tTimeEntryDetailsDateRowEndTime:
            datePicker.date = self.endTimeEntry?:[NSDate date];
            datePicker.minimumDate = self.startTimeEntry;
            datePicker.maximumDate = nil;
            break;
        default:
            datePicker.date = [NSDate date];
            datePicker.minimumDate = nil;
            datePicker.maximumDate = nil;
            break;
    }
    return cell;
    
}

- (BOOL)isDateValidForDatePicker:(UIDatePicker *)datePicker{
   
    NSDate *newDate = datePicker.date;
   return  ([newDate compare:datePicker.minimumDate] != NSOrderedAscending) && ([newDate compare:datePicker.maximumDate] != NSOrderedDescending);
//    return YES;
    
}

- (NSIndexPath *)datePickerParentIndexPath{

    NSIndexPath *parentCellIndexPath = nil;
    
    if ([self datePickerIndexPath]){
        
        parentCellIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:self.datePickerIndexPath.section];
        
    }
    return parentCellIndexPath;
    
}

@end

@implementation TimeEntryDetailsViewController (KeyboardEvents)

#pragma mark - Keyboard ntfs
- (void)registerForKeyboardNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

}

// Called when the UIKeyboardDidShowNotification is sent.

- (void)keyboardWasShown:(NSNotification*)aNotification{
    
    NSDictionary* info = [aNotification userInfo];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGFloat coveredHeight = kbSize.height;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, coveredHeight/*kbSize.height*/, 0.0);
    
    self.tableView.contentInset = contentInsets;
    
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    
    // Your application might not need or want this behavior.
    
    CGRect aRect = self.tableView.frame;
    
    aRect.size.height -= coveredHeight;//(kbSize.height);
    
    if (!CGRectContainsPoint(aRect, _activeField.frame.origin) ) {
        //        CGFloat offsetY =
        CGPoint scrollPoint = CGPointMake(0.0, _activeField.frame.origin.y-aRect.size.height+_activeField.frame.size.height+10/*margin*/);
        
        [self.tableView setContentOffset:scrollPoint animated:YES];
        
    }
}
// Called when the UIKeyboardWillHideNotification is sent

- (void)keyboardWillBeHidden:(NSNotification*)aNotification{
    
    _kbdFrame = CGRectZero;
    
}



@end
