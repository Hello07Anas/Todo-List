//
//  TabBar.m
//  TODO List App
//
//  Created by Anas Salah on 17/04/2024.
//

#import "TabBar.h"
#import "DetailsVC.h"
#import "DoneVC.h"
@interface TabBar ()

@end

@implementation TabBar

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Segue identifier: %@", segue.identifier);
    if ([segue.identifier isEqualToString:@"addBtnID"]) {
        DetailsVC *detailsVC = segue.destinationViewController;
        detailsVC.isAdd = YES;
    }
}

- (IBAction)filterButtonAction:(id)sender {
    // notifi the delegate method when the filter button is tapped
    if ([self.delegate respondsToSelector:@selector(filterButtonTappedInTabBar)]) {
        [self.delegate filterButtonTappedInTabBar];
    }
}
@end
