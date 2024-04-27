//
//  ViewController.m
//  TODO List App
//
//  Created by Anas Salah on 17/04/2024.
//

#import "ViewController.h"
#import "Task.h"
#import "DetailsVC.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableViewTodo; // TODO: when we have data show UITable and hide image.
@property (weak, nonatomic) IBOutlet UIImageView *todoImg;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarVC;

@property NSDate *archiveData;

@end

@implementation ViewController{
    NSUserDefaults *defaults;
    NSMutableArray<Task *> *taskArray;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tabBarController.navigationItem.rightBarButtonItems[0] setHidden:NO];
    [self.tabBarController.navigationItem.rightBarButtonItems[1] setHidden:YES];
    NSData *savedData = [defaults objectForKey:@"taskArray"];
    NSError *error;
    NSSet *set = [NSSet setWithArray:@[[NSArray class], [Task class]]];
    if (savedData) {
        NSArray<Task *> *savedTasks = (NSArray<Task *> *)[NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:savedData error:&error];
        if (savedTasks) {
            [taskArray removeAllObjects];
            [taskArray addObjectsFromArray:savedTasks];
            [self.tableViewTodo reloadData];
        } else {
            NSLog(@"Error unarchiving tasks: %@", error);
        }
    } else {
        NSLog(@"No data found in UserDefaults.");
    }
    
    NSInteger index = 0;
        while (index < taskArray.count) {
            if (![taskArray[index].status isEqual:@"TODO"]) {
                [taskArray removeObjectAtIndex:index];
                [self.tableViewTodo  reloadData];
            } else {
                index++;
            }
        }
    
    
    [self.tableViewTodo reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    defaults = [NSUserDefaults standardUserDefaults];
    taskArray = [NSMutableArray array];
    self.searchBarVC.delegate = self;

    [self printUserDefaults];
    _todoImg.image = [UIImage imageNamed:@"todoImg"];
    [self.tableViewTodo  reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSPredicate *todoPredicate = [NSPredicate predicateWithFormat:@"status == %@", @"TODO"];
    NSArray<Task *> *todoTasks = [taskArray filteredArrayUsingPredicate:todoPredicate];
    
    if (todoTasks.count == 0) {
        _tableViewTodo.hidden = true;
        _todoImg.hidden = false;
    } else {
        _tableViewTodo.hidden = false;
        _todoImg.hidden = true;
    }
    
    return todoTasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSPredicate *todoPredicate = [NSPredicate predicateWithFormat:@"status == %@", @"TODO"];
    NSArray<Task *> *todoTasks = [taskArray filteredArrayUsingPredicate:todoPredicate];
    
    Task *task = todoTasks[indexPath.row];
    
    cell.textLabel.text = task.name;
    
    if ([task.periority isEqualToString:@"Low"]) {
        cell.imageView.image = [UIImage imageNamed:@"green_icon"]; 
    } else if ([task.periority isEqualToString:@"Medium"]) {
        cell.imageView.image = [UIImage imageNamed:@"aqua_icon"];
    } else if ([task.periority isEqualToString:@"High"]) {
        cell.imageView.image = [UIImage imageNamed:@"red_icon"];
    }
    [self reloadOriginalTasks];
    return cell;
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
    [_tableViewTodo deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self reloadOriginalTasks];
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
    [self reloadOriginalTasks];
    [self.navigationController pushViewController:detailsVC animated:YES];
}

- (void)printUserDefaults {
    NSDictionary *userDefaultsDict = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    NSLog(@"Contents of UserDefaults: %@", userDefaultsDict);
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *searchText = [searchBar.text stringByReplacingCharactersInRange:range withString:text];
    
    if (searchText.length > 0) {
        NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchText];
        NSArray<Task *> *filteredTasks = [taskArray filteredArrayUsingPredicate:searchPredicate];
        
        taskArray = [NSMutableArray arrayWithArray:filteredTasks];
    } else {
        [self reloadOriginalTasks];
    }
    
    [self.tableViewTodo reloadData];
    return YES;
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
@end
/*
 Thread 1: "Invalid update: invalid number of rows in section 0. The number of rows contained in an existing section after the update (2) must be equal to the number of rows contained in that section before the update (2), plus or minus the number of rows inserted or deleted from that section (0 inserted, 1 deleted) and plus or minus the number of rows moved into or out of that section (0
 moved in, 0 moved out). Table view: <UITableView: 0x11202a00; frame = (16 159; 361 610);
 clipsToBounds = YES; autoresize = RM+BM; gestureRecognizers = <NSArray: 0x600000c7d8f0>;
 backgroundColor = <UlDynamicSystemColor: 0x600001763580; name = tableBackgroundColor>;
 layer = <CALayer: 0x60000025560>; contentOffset: {0, 0); contentSize: {361, 96);
 adjustedContentinset: (0, 0, 0, 0}: [dataSource: <ViewController: 0x110606f00>>"
 */
