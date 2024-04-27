//
//  DetailsVC.h
//  TODO List App
//
//  Created by Anas Salah on 17/04/2024.
//

#import <UIKit/UIKit.h>
#import "Task.h"
NS_ASSUME_NONNULL_BEGIN

@interface DetailsVC : UIViewController

@property (nonatomic, strong) Task *selectedTask;
@property (nonatomic) BOOL isAdd;

@end

NS_ASSUME_NONNULL_END
