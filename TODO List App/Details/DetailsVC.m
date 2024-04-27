//
//  DetailsVC.m
//  TODO List App
//
//  Created by Anas Salah on 17/04/2024.
//

#import "DetailsVC.h"
#import "Task.h"
@interface DetailsVC ()

//@property bool isAdd; // true if comeing from addbtn || false if ccoming from update btn
@property (weak, nonatomic) IBOutlet UILabel *pageNameLb;

@property (weak, nonatomic) IBOutlet UIImageView *periorityImg;
@property (weak, nonatomic) IBOutlet UITextField *taskNameTF;
@property (weak, nonatomic) IBOutlet UITextView *taskDescription;
@property (weak, nonatomic) IBOutlet UISegmentedControl *periorityStatus;
@property (weak, nonatomic) IBOutlet UISegmentedControl *Status;
@property (weak, nonatomic) IBOutlet UIDatePicker *Date;
@property (weak, nonatomic) IBOutlet UIButton *btnName;

@property Task *task;

@property NSMutableArray *taskArr;
@property NSDate *archiveData;

- (NSInteger)segmentIndexForPriorityString:(NSString *)priority;
- (NSInteger)segmentIndexForStatusString:(NSString *)status;
- (NSDate *)dateFromString:(NSString *)dateString;

@end

@implementation DetailsVC {
    NSUserDefaults *defaults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"isAdd ======= %d", _isAdd);
    if (!_isAdd) {
        [self populateUIWithTask:_selectedTask];
        self.pageNameLb.text = @"Edit";
        [_btnName setTitle:@"Edit" forState:UIControlStateNormal];
        if ([_task.periority isEqualToString:@"Low"]) {
            _periorityImg.image = [UIImage imageNamed:@"green_icon"];
        } else if ([_task.periority isEqualToString:@"Medium"]) {
            _periorityImg.image = [UIImage imageNamed:@"aqua_icon"];
        } else if ([_task.periority isEqualToString:@"High"]) {
            _periorityImg.image = [UIImage imageNamed:@"red_icon"];
        }
    }
    
    self.Date.minimumDate = [NSDate date];
}

- (void)populateUIWithTask:(Task *)task {
    _taskNameTF.text = task.name;
    _taskDescription.text = task.des;
    _periorityStatus.selectedSegmentIndex = [self segmentIndexForPriorityString:task.periority];
    _Status.selectedSegmentIndex = [self segmentIndexForStatusString:task.status];
    _Date.date = [self dateFromString:task.date];
}

- (IBAction)addBtn:(id)sender {
    if (_isAdd) {
        [self addTask];
    } else {
        [self updateTask];
    }

}

- (void)updateTask {
    defaults = [NSUserDefaults standardUserDefaults];
    NSData *savedData = [defaults objectForKey:@"taskArray"];
    NSError *error;
    NSSet *set = [NSSet setWithArray:@[[NSArray class], [Task class]]];
    NSMutableArray<Task *> *existingTasks;
    if (savedData) {
        existingTasks = [(NSArray<Task *> *)[NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:savedData error:&error] mutableCopy];
    } else {
        existingTasks = [NSMutableArray array];
    }

    NSLog(@"Existing tasks array BEFORE update: %@", existingTasks);

    NSUInteger index = [existingTasks indexOfObjectPassingTest:^BOOL(Task * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
        return [task isEqualToTask:_selectedTask];
    }];

    if (index != NSNotFound) {
        Task *updatedTask = existingTasks[index];
        updatedTask.name = _taskNameTF.text;
        updatedTask.des = _taskDescription.text;
        updatedTask.date = [self formatDate:self.Date.date];
        updatedTask.status = [self statusFromSegment:self.Status.selectedSegmentIndex];
        updatedTask.periority = [self priorityFromSegment:self.periorityStatus.selectedSegmentIndex];
        
        NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:existingTasks requiringSecureCoding:YES error:&error];
        [defaults setObject:archiveData forKey:@"taskArray"];
        
        NSLog(@"Updated task: %@", updatedTask);
        NSLog(@"Saved task data to UserDefaults: %@", archiveData);
    } else {
        NSLog(@"Error: Updated task not found in existing tasks array.");
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addTask {
    defaults = [NSUserDefaults standardUserDefaults];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm"
                                                                   message:@"Are you sure you want to add this task?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
        NSData *savedData = [defaults objectForKey:@"taskArray"];
        NSError *error;
        NSSet *set = [NSSet setWithArray:@[[NSArray class], [Task class]]];
        NSMutableArray<Task *> *existingTasks;
        if (savedData) {
            existingTasks = [(NSArray<Task *> *)[NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:savedData error:&error] mutableCopy];
        } else {
            existingTasks = [NSMutableArray array];
        }
        
        _task = [Task new];
        _task.name = _taskNameTF.text;
        _task.des = _taskDescription.text;
        _task.date = [self formatDate:self.Date.date];
        _task.status = [self statusFromSegment:self.Status.selectedSegmentIndex];
        _task.periority = [self priorityFromSegment:self.periorityStatus.selectedSegmentIndex];
        
        [existingTasks addObject:_task];
        
        _archiveData = [NSKeyedArchiver archivedDataWithRootObject:existingTasks requiringSecureCoding:YES error:&error];
        [defaults setObject:_archiveData forKey:@"taskArray"];
        
        NSLog(@"Saved task data: %@", existingTasks);
        NSLog(@"Saved task data to UserDefaults: %@", _archiveData);
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {
    }];
    
    [alert addAction:confirmAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}



- (NSString *)formatDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [dateFormatter stringFromDate:date];
}


-(NSString *)statusFromSegment:(NSInteger)segmentIndex {
    switch (segmentIndex) {
        case 0:
            return @"TODO";
        case 1:
            return @"Progress";
        case 2:
            return @"Done";
        default:
            return @"Unknown";
    }
}

- (NSString *)priorityFromSegment:(NSInteger)segmentIndex {
    switch (segmentIndex) {
        case 0:
            return @"Low";
        case 1:
            return @"Medium";
        case 2:
            return @"High";
        default:
            return @"Unknown";
    }
}

- (NSInteger)segmentIndexForPriorityString:(NSString *)priority {
    if ([priority isEqualToString:@"Low"]) {
        return 0;
    } else if ([priority isEqualToString:@"Medium"]) {
        return 1;
    } else if ([priority isEqualToString:@"High"]) {
        return 2;
    } else {
        return UISegmentedControlNoSegment;
    }
}

- (NSInteger)segmentIndexForStatusString:(NSString *)status {
    if ([status isEqualToString:@"TODO"]) {
        return 0;
    } else if ([status isEqualToString:@"Progress"]) {
        return 1;
    } else if ([status isEqualToString:@"Done"]) {
        return 2;
    } else {
        return UISegmentedControlNoSegment;
    }
}

// Helper method 
- (NSDate *)dateFromString:(NSString *)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [dateFormatter dateFromString:dateString];
}

- (IBAction)perioritySegmant:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSInteger selectedIndex = segmentedControl.selectedSegmentIndex;
        
    switch (selectedIndex) {
        case 0:
            _periorityImg.image = [UIImage imageNamed:@"green_icon"];
            _task.periority = @"Low";
            break;
        case 1:
            _periorityImg.image = [UIImage imageNamed:@"aqua_icon"];
            _task.periority = @"Medium";
            break;
        case 2:
            _periorityImg.image = [UIImage imageNamed:@"red_icon"];
            _task.periority = @"High";
            break;
        default:
            break;
    }
}

@end
