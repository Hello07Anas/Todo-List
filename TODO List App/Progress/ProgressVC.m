//
//  ProgressVC.m
//  TODO List App
//
//  Created by Anas Salah on 17/04/2024.
//

#import "ProgressVC.h"
#import "Task.h"
#import "DetailsVC.h"

@interface ProgressVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableViewProgress;
@property (weak, nonatomic) IBOutlet UIImageView *todoImg;


@property NSDate *archiveData;

@property (assign, nonatomic) BOOL displaySingleSection;

@end

@implementation ProgressVC{
    NSUserDefaults *defaults;
    NSMutableArray<Task *> *taskArray;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tabBarController.navigationItem.rightBarButtonItems[0] setHidden:YES];
    [self.tabBarController.navigationItem.rightBarButtonItems[1] setHidden:NO];

    NSData *savedData = [defaults objectForKey:@"taskArray"];
    NSError *error;
    NSSet *set = [NSSet setWithArray:@[[NSArray class], [Task class]]];
    if (savedData) {
        NSArray<Task *> *savedTasks = (NSArray<Task *> *)[NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:savedData error:&error];
        if (savedTasks) {
            [taskArray removeAllObjects];
            [taskArray addObjectsFromArray:savedTasks];
            [self.tableViewProgress reloadData];
        } else {
            NSLog(@"Error unarchiving tasks: %@", error);
        }
    } else {
        NSLog(@"No data found in UserDefaults.");
    }
    
    NSInteger index = 0;
        while (index < taskArray.count) {
            if (![taskArray[index].status isEqual:@"Progress"]) {
                [taskArray removeObjectAtIndex:index];
                [self.tableViewProgress reloadData];
            } else {
                index++;
            }
        }
    
    [self.tableViewProgress reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    defaults = [NSUserDefaults standardUserDefaults];
    taskArray = [NSMutableArray array];
    self.displaySingleSection = YES;

    _todoImg.image = [UIImage imageNamed:@"todoImgInProgress"];

    if ([self.tabBarController isKindOfClass:[TabBar class]]) {
        TabBar *tabBarController = (TabBar *)self.tabBarController;
        tabBarController.delegate = self;
    }
    
    [self.tableViewProgress  reloadData];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.displaySingleSection) {
        return 1;
    } else {
        return 3;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSPredicate *donePredicate = [NSPredicate predicateWithFormat:@"status == %@", @"Progress"];
    NSArray<Task *> *doneTasks = [taskArray filteredArrayUsingPredicate:donePredicate];
    
    if (doneTasks.count == 0) {
        _tableViewProgress.hidden = true;
        _todoImg.hidden = false;
    } else {
        _tableViewProgress.hidden = false;
        _todoImg.hidden = true;
    }
    
    if (self.displaySingleSection) {
        return doneTasks.count;
    } else {
        //  low, Medium, High
        NSPredicate *priorityPredicate;
        switch (section) {
            case 0:
                priorityPredicate = [NSPredicate predicateWithFormat:@"periority == %@", @"Low"];
                break;
            case 1:
                priorityPredicate = [NSPredicate predicateWithFormat:@"periority == %@", @"Medium"];
                break;
            case 2:
                priorityPredicate = [NSPredicate predicateWithFormat:@"periority == %@", @"High"];
                break;
            default:
                return 0;
        }
        
        NSArray<Task *> *priorityTasks = [doneTasks filteredArrayUsingPredicate:priorityPredicate];

        return priorityTasks.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSPredicate *donePredicate = [NSPredicate predicateWithFormat:@"status == %@", @"Progress"];
    NSArray<Task *> *doneTasks = [taskArray filteredArrayUsingPredicate:donePredicate];
    Task *task = doneTasks[indexPath.row];

    if (self.displaySingleSection) {
        cell.textLabel.text = task.name;
    } else {
        NSPredicate *priorityPredicate;
        switch (indexPath.section) {
            case 0:
                priorityPredicate = [NSPredicate predicateWithFormat:@"periority == %@", @"Low"];
                break;
            case 1:
                priorityPredicate = [NSPredicate predicateWithFormat:@"periority == %@", @"Medium"];
                break;
            case 2:
                priorityPredicate = [NSPredicate predicateWithFormat:@"periority == %@", @"High"];
                break;
            default:
                break;
        }
        
        NSArray<Task *> *priorityTasks = [doneTasks filteredArrayUsingPredicate:priorityPredicate];
        
        Task *task = priorityTasks[indexPath.row];
        
        cell.textLabel.text = task.name;
    }
    
    if ([task.periority isEqualToString:@"Low"]) {
        cell.imageView.image = [UIImage imageNamed:@"green_icon"];
    } else if ([task.periority isEqualToString:@"Medium"]) {
        cell.imageView.image = [UIImage imageNamed:@"aqua_icon"];
    } else if ([task.periority isEqualToString:@"High"]) {
        cell.imageView.image = [UIImage imageNamed:@"red_icon"];
    }
    
    return cell;
}

- (void)filterButtonTappedInTabBar {
    self.displaySingleSection = !self.displaySingleSection;
    [self.tableViewProgress reloadData];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.displaySingleSection) {
        return nil;
    } else {
        switch (section) {
            case 0:
                return @"Low Priority";
            case 1:
                return @"Medium Priority";
            case 2:
                return @"High Priority";
            default:
                return nil;
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete Task" message:@"Are you sure you want to delete this task?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self deleteTaskAtIndexPath:indexPath];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:deleteAction];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)deleteTaskAtIndexPath:(NSIndexPath *)indexPath {
    [taskArray removeObjectAtIndex:indexPath.row];
    NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:taskArray requiringSecureCoding:YES error:nil];
    [defaults setObject:archiveData forKey:@"taskArray"];
    [_tableViewProgress deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self reloadOriginalTasks];
}

- (void)reloadOriginalTasks {
    NSData *savedData = [defaults objectForKey:@"taskArray"];
    NSError *error;
    NSSet *set = [NSSet setWithArray:@[[NSArray class], [Task class]]];
    if (savedData) {
        NSArray<Task *> *savedTasks = (NSArray<Task *> *)[NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:savedData error:&error];
        if (savedTasks) {
            [taskArray removeAllObjects];
            [taskArray addObjectsFromArray:savedTasks];
        } else {
            NSLog(@"Error unarchiving tasks: %@", error);
        }
    } else {
        NSLog(@"No data found in UserDefaults.");
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailsVC *detailsVC = [storyboard instantiateViewControllerWithIdentifier:@"DetailsVC"];

    if (indexPath.row < taskArray.count) {
        Task *selectedTask = taskArray[indexPath.row];
        
        detailsVC.selectedTask = selectedTask;
    } else {
        detailsVC.isAdd = false;
    }

    [self.navigationController pushViewController:detailsVC animated:YES];
}

@end
